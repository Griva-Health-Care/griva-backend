import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// ── GET /profile ───────────────────────────────────────────────────────────────
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { firebaseUid } = (req as any).user;
    const profile = await (prisma as any).doctorProfile.findUnique({
      where: { firebaseUid },
    });
    res.json({ profile: profile ?? null });
  } catch (error) {
    console.error('[PROFILE/GET]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch profile' });
  }
});

// ── PUT /profile ───────────────────────────────────────────────────────────────
// Upserts doctor_profiles AND syncs key fields into User so admin queries have
// a single source of truth.
// Required: fullName, phone, hospital, role
// Optional: licenseNumber, city, state, colposcopeSerialNo
router.put('/', authMiddleware, async (req, res) => {
  try {
    const { userId, firebaseUid } = (req as any).user;
    const {
      fullName, phone, hospital, role,
      licenseNumber, city, state, colposcopeSerialNo,
    } = req.body as Record<string, string | undefined>;

    const safeRole = (role && ['doctor', 'diagnostic'].includes(role)) ? role : '';

    const profileData = {
      fullName:           fullName           ?? '',
      phone:              phone              ?? '',
      hospital:           hospital           ?? '',
      role:               safeRole,
      licenseNumber:      licenseNumber      ?? '',
      city:               city               ?? '',
      state:              state              ?? '',
      colposcopeSerialNo: colposcopeSerialNo ?? '',
      updatedAt:          new Date(),
    };

    // Sync subset to User table — only overwrite fields that were explicitly sent
    const userPatch: Record<string, string | null> = {};
    if (fullName           !== undefined) userPatch.fullName           = fullName           || null;
    if (phone              !== undefined) userPatch.phone              = phone              || null;
    if (hospital           !== undefined) userPatch.hospital           = hospital           || null;
    if (licenseNumber      !== undefined) userPatch.licenseNumber      = licenseNumber      || null;
    if (city               !== undefined) userPatch.city               = city               || null;
    if (state              !== undefined) userPatch.state              = state              || null;
    if (colposcopeSerialNo !== undefined) userPatch.colposcopeSerialNo = colposcopeSerialNo || null;
    if (safeRole)                         userPatch.role               = safeRole;

    const [profile] = await Promise.all([
      (prisma as any).doctorProfile.upsert({
        where:  { firebaseUid },
        update: profileData,
        create: { firebaseUid, ...profileData },
      }),
      Object.keys(userPatch).length > 0
        ? prisma.user.update({ where: { id: userId }, data: userPatch })
        : Promise.resolve(),
    ]);

    res.json({ profile });
  } catch (error) {
    console.error('[PROFILE/PUT]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to save profile' });
  }
});

// ── GET /profile/config ────────────────────────────────────────────────────────
router.get('/config', authMiddleware, async (req, res) => {
  try {
    const { firebaseUid } = (req as any).user;
    const config = await (prisma as any).doctorConfig.findUnique({
      where: { firebaseUid },
    });
    res.json({
      config: config ?? {
        firebaseUid,
        cloudSyncEnabled: false,
        role:             'solo',
        creditBalance:    0,
      },
    });
  } catch (error) {
    console.error('[PROFILE/CONFIG]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch config' });
  }
});

export default router;
