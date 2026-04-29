import { verifyToken } from '../utils/jwt.js';
import { prisma } from '../utils/prisma.js';
import { logEvent } from '../utils/logger.js';
export const authMiddleware = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ message: 'No authorization token' });
        }
        const token = authHeader.split(' ')[1];
        if (!token) {
            return res.status(401).json({ message: 'Invalid authorization format' });
        }
        const decoded = verifyToken(token);
        const rows = await prisma.$queryRaw `
      SELECT is_active
      FROM users
      WHERE id = ${decoded.userId}::uuid
      LIMIT 1
    `;
        const user = rows[0];
        if (!user || !user.is_active) {
            await logEvent('auth_denied', decoded.userId, `Active: ${user?.is_active ?? false}`, req.ip || req.connection.remoteAddress || 'unknown');
            return res.status(403).json({ message: 'Account disabled' });
        }
        req.user = {
            userId: decoded.userId,
            role: decoded.role,
        };
        next();
    }
    catch (error) {
        await logEvent('token_verification_failure', undefined, error instanceof Error ? error.message : String(error), req.ip || req.connection.remoteAddress || 'unknown');
        console.error('[TOKEN_ERROR]', error instanceof Error ? error.message : error);
        return res.status(401).json({ message: 'Invalid or expired token' });
    }
};
//# sourceMappingURL=auth.middleware.js.map