import { Router } from 'express';
import { prisma } from '../utils/prisma.js';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = Router();

// POST /users/register — idempotent upsert after Firebase sign-up
// Called by the Flutter app immediately after a successful Firebase registration.
router.post('/register', authMiddleware, async (req, res) => {
  try {
    const { firebaseUid, userId } = (req as any).user;
    const { fullName, hospital, role } = req.body as {
      fullName?: string;
      hospital?: string;
      role?: string;
    };

    const safeRole = ['doctor', 'diagnostic', 'tele_reporter'].includes(role ?? '')
      ? role!
      : 'doctor';

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(fullName !== undefined && { fullName }),
        ...(hospital !== undefined && { hospital }),
        role: safeRole,
      },
      select: { id: true, email: true, fullName: true, role: true, hospital: true, isActive: true, createdAt: true },
    });

    res.status(200).json({ user });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to register user' });
  }
});

// GET /users/me — returns the authenticated user's profile
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, fullName: true, role: true, hospital: true, isActive: true, createdAt: true },
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
    const { fullName, hospital } = req.body as { fullName?: string; hospital?: string };

    const user = await prisma.user.update({
      where: { id: userId },
      data: { fullName: fullName ?? null, hospital: hospital ?? null },
      select: { id: true, email: true, fullName: true, role: true, hospital: true, isActive: true, updatedAt: true },
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
      data: { fcmToken },
    });

    res.json({ ok: true });
  } catch (error) {
    console.error('[USER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update FCM token' });
  }
});

export default router;
