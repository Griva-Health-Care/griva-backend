import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

const fullProfileSelect = {
  id: true, email: true, fullName: true, role: true, hospital: true,
  phone: true, licenseNumber: true, city: true, state: true,
  colposcopeSerialNo: true, isActive: true, firebaseUid: true,
  isAvailable: true, createdAt: true, updatedAt: true,
} as const;

// POST /users/register — idempotent upsert after Firebase sign-up
// Called by the Flutter app immediately after a successful Firebase registration.
router.post('/register', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const { fullName, hospital, role, phone, licenseNumber, city, state, colposcopeSerialNo } = req.body as {
      fullName?: string; hospital?: string; role?: string;
      phone?: string; licenseNumber?: string; city?: string;
      state?: string; colposcopeSerialNo?: string;
    };

    const safeRole = ['doctor', 'diagnostic', 'tele_reporter'].includes(role ?? '')
      ? role!
      : 'doctor';

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(fullName !== undefined && { fullName }),
        ...(hospital !== undefined && { hospital }),
        ...(phone !== undefined && { phone }),
        ...(licenseNumber !== undefined && { licenseNumber }),
        ...(city !== undefined && { city }),
        ...(state !== undefined && { state }),
        ...(colposcopeSerialNo !== undefined && { colposcopeSerialNo }),
        role: safeRole,
      },
      select: fullProfileSelect,
    });

    res.status(200).json({ user });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to register user' });
  }
});

// GET /users/me — returns the authenticated user's full profile
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: fullProfileSelect,
    });

    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json({ user });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch user' });
  }
});

// PUT /users/me — update profile fields
router.put('/me', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const { fullName, hospital, phone, licenseNumber, city, state, colposcopeSerialNo } = req.body as {
      fullName?: string; hospital?: string; phone?: string;
      licenseNumber?: string; city?: string; state?: string; colposcopeSerialNo?: string;
    };

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(fullName !== undefined && { fullName }),
        ...(hospital !== undefined && { hospital }),
        ...(phone !== undefined && { phone }),
        ...(licenseNumber !== undefined && { licenseNumber }),
        ...(city !== undefined && { city }),
        ...(state !== undefined && { state }),
        ...(colposcopeSerialNo !== undefined && { colposcopeSerialNo }),
      },
      select: fullProfileSelect,
    });

    res.json({ user });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update user' });
  }
});

// GET /users/config — returns doctor_config row (cloudSyncEnabled, creditBalance, role)
router.get('/config', authMiddleware, async (req, res) => {
  try {
    const { firebaseUid } = (req as any).user;

    const config = await (prisma as any).doctor_config.findUnique({
      where: { uid: firebaseUid },
    });

    res.json({
      config: {
        cloudSyncEnabled: config?.cloudSyncEnabled ?? false,
        role:             config?.role             ?? 'solo',
        creditBalance:    config?.creditBalance    ?? 0,
      },
    });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch config' });
  }
});

// PUT /users/fcm-token — store or refresh the caller's FCM device token
router.put('/fcm-token', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const { fcmToken } = req.body as { fcmToken: string };

    if (!fcmToken || typeof fcmToken !== 'string') {
      return res.status(400).json({ message: 'fcmToken is required' });
    }

    await prisma.user.update({
      where: { id: userId },
      data: { fcmToken },
    });

    res.json({ ok: true });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update FCM token' });
  }
});

export default router;
