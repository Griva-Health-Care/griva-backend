"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.auditMiddleware = void 0;
const prisma_1 = require("../utils/prisma");
const MUTATION_METHODS = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);
const auditMiddleware = (req, res, next) => {
    if (!MUTATION_METHODS.has(req.method))
        return next();
    res.on('finish', () => {
        const userId = req.user?.userId;
        const action = `${req.method} ${req.path}`;
        const details = res.statusCode >= 400
            ? `status=${res.statusCode}`
            : undefined;
        prisma_1.prisma.auditLog.create({
            data: {
                userId: userId ?? null,
                action,
                details: details ?? null,
                ipAddress: req.ip ?? null,
            },
        }).catch((err) => {
            console.error('[AUDIT] Failed to write audit log:', err);
        });
    });
    next();
};
exports.auditMiddleware = auditMiddleware;
//# sourceMappingURL=audit.middleware.js.map