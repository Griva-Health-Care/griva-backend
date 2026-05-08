import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// ── GET /auth/me ───────────────────────────────────────────────────────────────
// Returns the authenticated caller's profile. Requires a valid Firebase ID token.
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const user = await prisma.user.findUnique({
      where:  { id: userId },
      select: {
        id: true, email: true, fullName: true, role: true,
        hospital: true, isActive: true, firebaseUid: true, createdAt: true,
      },
    });
    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json({
      user: {
        id:         user.firebaseUid,
        internalId: user.id,
        email:      user.email,
        fullName:   user.fullName,
        role:       user.role,
        hospital:   user.hospital,
        isActive:   user.isActive,
        createdAt:  user.createdAt,
      },
    });
  } catch (error) {
    console.error('[AUTH/ME]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch user' });
  }
});

export default router;
