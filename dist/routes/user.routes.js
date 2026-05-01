"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const prisma_1 = require("../utils/prisma");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
// POST /users/register — idempotent upsert after Firebase sign-up
// Called by the Flutter app immediately after a successful Firebase registration.
router.post('/register', auth_middleware_1.authMiddleware, async (req, res) => {
    try {
        const { firebaseUid, userId } = req.user;
        const { fullName, hospital, role } = req.body;
        const safeRole = ['doctor', 'diagnostic', 'tele_reporter'].includes(role ?? '')
            ? role
            : 'doctor';
        const user = await prisma_1.prisma.user.update({
            where: { id: userId },
            data: {
                ...(fullName !== undefined && { fullName }),
                ...(hospital !== undefined && { hospital }),
                role: safeRole,
            },
            select: { id: true, email: true, fullName: true, role: true, hospital: true, isActive: true, createdAt: true },
        });
        res.status(200).json({ user });
    }
    catch (error) {
        console.error('[USER]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to register user' });
    }
});
// GET /users/me — returns the authenticated user's profile
router.get('/me', auth_middleware_1.authMiddleware, async (req, res) => {
    try {
        const { userId } = req.user;
        const user = await prisma_1.prisma.user.findUnique({
            where: { id: userId },
            select: { id: true, email: true, fullName: true, role: true, hospital: true, isActive: true, createdAt: true },
        });
        if (!user)
            return res.status(404).json({ message: 'User not found' });
        res.json({ user });
    }
    catch (error) {
        console.error('[USER]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to fetch user' });
    }
});
// PUT /users/me — update profile fields
router.put('/me', auth_middleware_1.authMiddleware, async (req, res) => {
    try {
        const { userId } = req.user;
        const { fullName, hospital } = req.body;
        const user = await prisma_1.prisma.user.update({
            where: { id: userId },
            data: { fullName: fullName ?? null, hospital: hospital ?? null },
            select: { id: true, email: true, fullName: true, role: true, hospital: true, isActive: true, updatedAt: true },
        });
        res.json({ user });
    }
    catch (error) {
        console.error('[USER]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to update user' });
    }
});
// PUT /users/fcm-token — store or refresh the caller's FCM device token
router.put('/fcm-token', auth_middleware_1.authMiddleware, async (req, res) => {
    try {
        const { userId } = req.user;
        const { fcmToken } = req.body;
        if (!fcmToken || typeof fcmToken !== 'string') {
            return res.status(400).json({ message: 'fcmToken is required' });
        }
        await prisma_1.prisma.user.update({
            where: { id: userId },
            data: { fcmToken },
        });
        res.json({ ok: true });
    }
    catch (error) {
        console.error('[USER]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to update FCM token' });
    }
});
exports.default = router;
//# sourceMappingURL=user.routes.js.map