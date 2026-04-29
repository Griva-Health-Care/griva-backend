"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = void 0;
const firebase_1 = require("../utils/firebase");
const prisma_1 = require("../utils/prisma");
const authMiddleware = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader?.startsWith('Bearer ')) {
            return res.status(401).json({ message: 'Missing or invalid Authorization header' });
        }
        const token = authHeader.split(' ')[1];
        const decoded = await (0, firebase_1.verifyFirebaseToken)(token);
        let user = await prisma_1.prisma.user.findUnique({
            where: { firebaseUid: decoded.uid },
            select: { id: true, role: true, isActive: true },
        });
        // Auto-register on first login so Firebase users don't need a separate
        // registration call before they can hit any authenticated endpoint.
        if (!user) {
            user = await prisma_1.prisma.user.create({
                data: {
                    firebaseUid: decoded.uid,
                    email: decoded.email ?? `${decoded.uid}@unknown.local`,
                    fullName: decoded.name ?? null,
                    role: 'doctor',
                    isActive: true,
                },
                select: { id: true, role: true, isActive: true },
            });
        }
        if (!user.isActive) {
            return res.status(403).json({ message: 'Account disabled' });
        }
        req.user = { userId: user.id, firebaseUid: decoded.uid, role: user.role };
        next();
    }
    catch (error) {
        console.error('[AUTH]', error instanceof Error ? error.message : error);
        return res.status(401).json({ message: 'Invalid or expired token' });
    }
};
exports.authMiddleware = authMiddleware;
//# sourceMappingURL=auth.middleware.js.map