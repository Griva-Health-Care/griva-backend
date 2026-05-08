import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// Full profile field selection reused across all user endpoints
const USER_SELECT = {
  id:                true,
  email:             true,
  fullName:          true,
  role:              true,
  hospital:          true,
  phone:             true,
  licenseNumber:     true,
  city:              true,
  state:             true,
  colposcopeSerialNo: true,
  isActive:          true,
  isAvailable:       true,
  createdAt:         true,
  updatedAt:         true,
} as const;

// POST /users/register — idempotent upsert after Firebase sign-up
// Called by the Flutter app immediately after a successful Firebase registration.
router.post('/register', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const {
      fullName, hospital, role,
      phone, licenseNumber, city, state, colposcopeSerialNo,
    } = req.body as Record<string, string | undefined>;

    const safeRole = ['doctor', 'diagnostic', 'tele_reporter'].includes(role ?? '')
      ? role!
      : 'doctor';

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(fullName           !== undefined && { fullName }),
        ...(hospital           !== undefined && { hospital }),
        ...(phone              !== undefined && { phone }),
        ...(licenseNumber      !== undefined && { licenseNumber }),
        ...(city               !== undefined && { city }),
        ...(state              !== undefined && { state }),
        ...(colposcopeSerialNo !== undefined && { colposcopeSerialNo }),
        role: safeRole,
      },
      select: USER_SELECT,
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
      where:  { id: userId },
      select: USER_SELECT,
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
    const {
      fullName, hospital, role,
      phone, licenseNumber, city, state, colposcopeSerialNo,
    } = req.body as Record<string, string | undefined>;

    const safeRole = role && ['doctor', 'diagnostic', 'tele_reporter'].includes(role)
      ? role
      : undefined;

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(fullName           !== undefined && { fullName:           fullName           ?? null }),
        ...(hospital           !== undefined && { hospital:           hospital           ?? null }),
        ...(safeRole           !== undefined && { role:               safeRole }),
        ...(phone              !== undefined && { phone:              phone              ?? null }),
        ...(licenseNumber      !== undefined && { licenseNumber:      licenseNumber      ?? null }),
        ...(city               !== undefined && { city:               city               ?? null }),
        ...(state              !== undefined && { state:              state              ?? null }),
        ...(colposcopeSerialNo !== undefined && { colposcopeSerialNo: colposcopeSerialNo ?? null }),
      },
      select: USER_SELECT,
    });

    res.json({ user });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update user' });
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
      data:  { fcmToken },
    });

    res.json({ ok: true });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update FCM token' });
  }
});

export default router;
