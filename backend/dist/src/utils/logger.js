import { prisma } from './prisma.js';
export const logEvent = async (action, userId, details, ipAddress) => {
    console.log('[AUDIT]', action, { userId, details, ipAddress });
    try {
        await prisma.auditLog.create({
            data: {
                userId: userId || null,
                action,
                details: details || null,
                ipAddress: ipAddress || null,
            },
        });
    }
    catch (error) {
        console.error('Failed to log audit event:', error);
    }
};
//# sourceMappingURL=logger.js.map