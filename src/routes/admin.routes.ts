import { Router } from 'express';
import { getFirestore } from 'firebase-admin/firestore';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

const adminOnly = [authMiddleware, requireRole('admin', 'superadmin')];

// GET /admin/users — list all users with optional role filter
router.get('/users', ...adminOnly, async (req, res) => {
  try {
    const role = typeof req.query.role === 'string' ? req.query.role : undefined;
    const isActive = typeof req.query.isActive === 'string' ? req.query.isActive : undefined;

    const users = await prisma.user.findMany({
      where: {
        ...(role ? { role } : {}),
        ...(isActive !== undefined ? { isActive: isActive === 'true' } : {}),
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        hospital: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
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
    const id = req.params['id'] as string;
    const { role } = req.body as { role: string };

    const validRoles = ['doctor', 'diagnostic', 'tele_reporter', 'admin', 'superadmin'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ message: `Invalid role. Must be one of: ${validRoles.join(', ')}` });
    }

    const user = await prisma.user.update({
      where: { id },
      data: { role },
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
      where: { id },
      data: { isActive },
      select: { id: true, email: true, role: true, isActive: true },
    });

    res.json({ user });
  } catch (error) {
    console.error('[ADMIN]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update user status' });
  }
});

// GET /admin/overview — name, patient count, and report count for all doctors and diagnostic centers.
// Doctors:             reportCount = patients with hasReport = true
// Diagnostic centers: reportCount = completed TeleCases they submitted
router.get('/overview', ...adminOnly, async (_req, res) => {
  try {
    const users = await prisma.user.findMany({
      where: { role: { in: ['doctor', 'diagnostic'] } },
      select: {
        id:       true,
        fullName: true,
        email:    true,
        role:     true,
        hospital: true,
        patients: {
          select: { hasReport: true },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // For diagnostic centers, also fetch their completed TeleCase count
    const diagnosticIds = users
      .filter((u) => u.role === 'diagnostic')
      .map((u) => u.id);

    const teleCaseCounts = diagnosticIds.length
      ? await prisma.teleCase.groupBy({
          by:     ['submittedBy'],
          where:  { submittedBy: { in: diagnosticIds }, status: 'completed' },
          _count: { id: true },
        })
      : [];

    const teleCountMap = new Map(
      teleCaseCounts.map((r) => [r.submittedBy, r._count.id])
    );

    // Fetch Firestore profiles for all users in parallel
    const db = getFirestore();
    const profiles = await Promise.all(
      users.map(async (u) => {
        try {
          // Find the firebaseUid for this user
          const fullUser = await prisma.user.findUnique({
            where: { id: u.id },
            select: { firebaseUid: true, createdAt: true },
          });
          if (!fullUser) return null;
          const doc = await db.collection('doctor_profiles').doc(fullUser.firebaseUid).get();
          return doc.exists ? { ...doc.data(), createdAt: fullUser.createdAt } : { createdAt: fullUser.createdAt };
        } catch {
          return null;
        }
      })
    );

    const rows = users.map((u, i) => {
      const patientCount = u.patients.length;
      const reportCount  = u.role === 'diagnostic'
        ? (teleCountMap.get(u.id) ?? 0)
        : u.patients.filter((p) => p.hasReport).length;
      const profile = profiles[i] as Record<string, any> | null;

      return {
        name:          profile?.['fullName']      ?? u.fullName ?? u.email,
        email:         u.email,
        role:          u.role,
        phone:         profile?.['phone']         ?? null,
        hospital:      profile?.['hospital']      ?? u.hospital ?? null,
        licenseNumber: profile?.['licenseNumber'] ?? null,
        city:          profile?.['city']          ?? null,
        state:         profile?.['state']         ?? null,
        accountType:   profile?.['accountType']   ?? u.role,
        patientCount,
        reportCount,
        joinedAt:      profile?.['createdAt']     ?? null,
      };
    });

    res.json({ users: rows });
  } catch (error) {
    console.error('[ADMIN]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch overview' });
  }
});

export default router;
