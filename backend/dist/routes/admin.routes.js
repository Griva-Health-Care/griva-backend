"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const firestore_1 = require("firebase-admin/firestore");
const prisma_1 = require("../utils/prisma");
const auth_middleware_1 = require("../middleware/auth.middleware");
const role_middleware_1 = require("../middleware/role.middleware");
const router = (0, express_1.Router)();
const adminOnly = [auth_middleware_1.authMiddleware, (0, role_middleware_1.requireRole)('admin', 'superadmin')];
// GET /admin/users — list all users with optional role filter
router.get('/users', ...adminOnly, async (req, res) => {
    try {
        const role = typeof req.query.role === 'string' ? req.query.role : undefined;
        const isActive = typeof req.query.isActive === 'string' ? req.query.isActive : undefined;
        const users = await prisma_1.prisma.user.findMany({
            where: {
                ...(role ? { role } : {}),
                ...(isActive !== undefined ? { isActive: isActive === 'true' } : {}),
            },
            select: {
                id: true,
                email: true,
                fullName: true,
                role: true,
                hospital: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
            orderBy: { createdAt: 'desc' },
        });
        res.json({ users });
    }
    catch (error) {
        console.error('[ADMIN]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to list users' });
    }
});
// PUT /admin/users/:id/role — change a user's role
router.put('/users/:id/role', ...adminOnly, async (req, res) => {
    try {
        const id = req.params['id'];
        const { role } = req.body;
        const validRoles = ['doctor', 'diagnostic', 'tele_reporter', 'admin', 'superadmin'];
        if (!validRoles.includes(role)) {
            return res.status(400).json({ message: `Invalid role. Must be one of: ${validRoles.join(', ')}` });
        }
        const user = await prisma_1.prisma.user.update({
            where: { id },
            data: { role },
            select: { id: true, email: true, role: true, isActive: true },
        });
        res.json({ user });
    }
    catch (error) {
        console.error('[ADMIN]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to update role' });
    }
});
// PUT /admin/users/:id/status — enable or disable a user account
router.put('/users/:id/status', ...adminOnly, async (req, res) => {
    try {
        const id = req.params['id'];
        const { isActive } = req.body;
        if (typeof isActive !== 'boolean') {
            return res.status(400).json({ message: 'isActive must be a boolean' });
        }
        const user = await prisma_1.prisma.user.update({
            where: { id },
            data: { isActive },
            select: { id: true, email: true, role: true, isActive: true },
        });
        res.json({ user });
    }
    catch (error) {
        console.error('[ADMIN]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to update user status' });
    }
});
// GET /admin/doctor-stats — returns each doctor's name, patient count, and report count
router.get('/doctor-stats', ...adminOnly, async (_req, res) => {
    try {
        const doctors = await prisma_1.prisma.user.findMany({
            where: { role: 'doctor' },
            select: { id: true, firebaseUid: true, fullName: true },
        });
        const db = (0, firestore_1.getFirestore)();
        const stats = await Promise.all(doctors.map(async (doctor) => {
            const [patientSnap, reportCount] = await Promise.all([
                db.collection('patients')
                    .where('doctorId', '==', doctor.firebaseUid)
                    .count()
                    .get(),
                prisma_1.prisma.teleCase.count({ where: { submittedBy: doctor.id } }),
            ]);
            return {
                name: doctor.fullName ?? 'Unknown',
                patientCount: patientSnap.data().count,
                reportCount,
            };
        }));
        res.json({ doctors: stats });
    }
    catch (error) {
        console.error('[ADMIN]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to fetch doctor stats' });
    }
});
exports.default = router;
//# sourceMappingURL=admin.routes.js.map