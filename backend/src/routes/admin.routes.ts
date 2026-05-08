import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

const adminOnly = [authMiddleware, requireRole('admin', 'superadmin')];

// GET /admin/users — list all users with optional role filter
router.get('/users', ...adminOnly, async (req, res) => {
  try {
    const role     = typeof req.query.role     === 'string' ? req.query.role     : undefined;
    const isActive = typeof req.query.isActive === 'string' ? req.query.isActive : undefined;

    const users = await prisma.user.findMany({
      where: {
        ...(role     ? { role }                                  : {}),
        ...(isActive !== undefined ? { isActive: isActive === 'true' } : {}),
      },
      select: {
        id: true, email: true, fullName: true, role: true,
        hospital: true, phone: true, licenseNumber: true,
        city: true, state: true, colposcopeSerialNo: true,
        isActive: true, createdAt: true, updatedAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({ users });
  } catch (error) {
    console.error('[ADMIN]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to list users' });
  }
});

// PUT /admin/users/:id/role — change a user's role
router.put('/users/:id/role', ...adminOnly, async (req, res) => {
  try {
    const id   = req.params['id'] as string;
    const { role } = req.body as { role: string };

    const validRoles = ['doctor', 'diagnostic', 'tele_reporter', 'admin', 'superadmin'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ message: `Invalid role. Must be one of: ${validRoles.join(', ')}` });
    }

    const user = await prisma.user.update({
      where:  { id },
      data:   { role },
      select: { id: true, email: true, role: true, isActive: true },
    });

    res.json({ user });
  } catch (error) {
    console.error('[ADMIN]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update role' });
  }
});

// PUT /admin/users/:id/status — enable or disable a user account
router.put('/users/:id/status', ...adminOnly, async (req, res) => {
  try {
    const id = req.params['id'] as string;
    const { isActive } = req.body as { isActive: boolean };

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({ message: 'isActive must be a boolean' });
    }

    const user = await prisma.user.update({
      where:  { id },
      data:   { isActive },
      select: { id: true, email: true, role: true, isActive: true },
    });

    res.json({ user });
  } catch (error) {
    console.error('[ADMIN]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update user status' });
  }
});

// GET /admin/overview — name, patient count, and report count for all doctors and diagnostic centers.
router.get('/overview', ...adminOnly, async (_req, res) => {
  try {
    const users = await prisma.user.findMany({
      where:   { role: { in: ['doctor', 'diagnostic'] } },
      select:  {
        id: true, fullName: true, email: true, role: true,
        hospital: true, phone: true, licenseNumber: true,
        city: true, state: true, colposcopeSerialNo: true,
        supabaseUid: true, createdAt: true,
      },
      orderBy: { createdAt: 'asc' },
    });

    const userIds    = users.map((u) => u.id);
    const supabaseUids = users.map((u) => u.supabaseUid);

    // Patient counts per user
    const patientCounts = await prisma.patient.groupBy({
      by:    ['userId'],
      where: { userId: { in: userIds } },
      _count: { id: true },
    });
    const patientCountMap = new Map(patientCounts.map((r) => [r.userId, r._count.id]));

    // Report counts for doctors (patients with hasReport = true)
    const reportCounts = await prisma.patient.groupBy({
      by:    ['userId'],
      where: { userId: { in: userIds }, hasReport: true },
      _count: { id: true },
    });
    const reportCountMap = new Map(reportCounts.map((r) => [r.userId, r._count.id]));

    // Completed TeleCase counts for diagnostic centers
    const diagnosticIds  = users.filter((u) => u.role === 'diagnostic').map((u) => u.id);
    const teleCaseCounts = diagnosticIds.length
      ? await prisma.teleCase.groupBy({
          by:    ['submittedBy'],
          where: { submittedBy: { in: diagnosticIds }, status: 'completed' },
          _count: { id: true },
        })
      : ([] as { submittedBy: string; _count: { id: number } }[]);
    const teleCountMap = new Map(teleCaseCounts.map((r) => [r.submittedBy, r._count.id]));

    // Fetch profiles from Postgres (replaces Firestore doctor_profiles collection)
    const profileRows = await (prisma as any).doctorProfile.findMany({
      where: { uid: { in: supabaseUids } },
    });
    const profileMap = new Map(profileRows.map((p: any) => [p.uid, p]));

    const rows = users.map((u) => {
      const profile      = profileMap.get(u.supabaseUid) as Record<string, any> | undefined;
      const patientCount = patientCountMap.get(u.id) ?? 0;
      const reportCount  = u.role === 'diagnostic'
        ? (teleCountMap.get(u.id) ?? 0)
        : (reportCountMap.get(u.id) ?? 0);

      // Prefer User table fields (synced on every PUT /profile); fall back to
      // DoctorProfile for rows created before the User sync was added.
      return {
        name:               u.fullName              ?? profile?.['fullName']           ?? u.email,
        email:              u.email,
        role:               u.role                  || profile?.['role']               || 'doctor',
        phone:              u.phone                 ?? profile?.['phone']              ?? null,
        hospital:           u.hospital              ?? profile?.['hospital']           ?? null,
        licenseNumber:      u.licenseNumber         ?? profile?.['licenseNumber']      ?? null,
        colposcopeSerialNo: u.colposcopeSerialNo    ?? profile?.['colposcopeSerialNo'] ?? null,
        city:               u.city                  ?? profile?.['city']               ?? null,
        state:              u.state                 ?? profile?.['state']              ?? null,
        patientCount,
        reportCount,
        joinedAt:           u.createdAt,
      };
    });

    res.json({ users: rows });
  } catch (error) {
    console.error('[ADMIN]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch overview' });
  }
});

export default router;
