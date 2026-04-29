import { Router } from 'express';
import { prisma } from '../utils/prisma.js';
import { authMiddleware } from '../middleware/auth.middleware.js';
const router = Router();
router.get('/me', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        const rows = await prisma.$queryRaw `
      SELECT id, email, role, is_active, created_at
      FROM users
      WHERE id = ${userId}::uuid
      LIMIT 1
    `;
        const user = rows[0];
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json({
            user: {
                id: user.id,
                email: user.email,
                role: user.role || 'doctor',
                isActive: user.is_active,
                createdAt: user.created_at,
            },
        });
    }
    catch (error) {
        console.error('[USER_ERROR]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to fetch user' });
    }
});
export default router;
//# sourceMappingURL=user.routes.js.map