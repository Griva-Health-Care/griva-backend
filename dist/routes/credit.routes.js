"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const firebase_admin_1 = __importDefault(require("firebase-admin"));
const prisma_1 = require("../utils/prisma");
const auth_middleware_1 = require("../middleware/auth.middleware");
const role_middleware_1 = require("../middleware/role.middleware");
const router = (0, express_1.Router)();
const adminOnly = [auth_middleware_1.authMiddleware, (0, role_middleware_1.requireRole)('admin', 'superadmin')];
// POST /credits/topup — add credits to a doctor's Firestore config and log the transaction
// Body: { doctorUid: string, amount: number, reason?: string }
router.post('/topup', ...adminOnly, async (req, res) => {
    try {
        const { userId } = req.user;
        const { doctorUid, amount, reason } = req.body;
        if (!doctorUid || typeof amount !== 'number' || amount <= 0 || !Number.isInteger(amount)) {
            return res.status(400).json({ message: 'doctorUid required and amount must be a positive integer' });
        }
        const fdb = firebase_admin_1.default.firestore();
        const configRef = fdb.collection('doctor_config').doc(doctorUid);
        let newBalance;
        await fdb.runTransaction(async (tx) => {
            const snap = await tx.get(configRef);
            const current = snap.data()?.creditBalance ?? 0;
            newBalance = current + amount;
            tx.set(configRef, { creditBalance: newBalance }, { merge: true });
        });
        await prisma_1.prisma.creditTransaction.create({
            data: {
                doctorUid,
                delta: amount,
                reason: reason ?? 'admin_topup',
                adminUserId: userId,
            },
        });
        res.json({ doctorUid, newBalance: newBalance });
    }
    catch (error) {
        console.error('[CREDIT]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Top-up failed' });
    }
});
// GET /credits/balance/:doctorUid — read current balance from Firestore
router.get('/balance/:doctorUid', auth_middleware_1.authMiddleware, async (req, res) => {
    try {
        const { role, userId } = req.user;
        const doctorUid = req.params['doctorUid'];
        // Doctors can only read their own balance; admins can read any
        if (role === 'doctor' || role === 'diagnostic') {
            const self = await prisma_1.prisma.user.findUnique({
                where: { id: userId },
                select: { firebaseUid: true },
            });
            if (self?.firebaseUid !== doctorUid) {
                return res.status(403).json({ message: 'Cannot read another account balance' });
            }
        }
        const snap = await firebase_admin_1.default.firestore().collection('doctor_config').doc(doctorUid).get();
        const balance = snap.data()?.creditBalance ?? 0;
        res.json({ doctorUid, balance });
    }
    catch (error) {
        console.error('[CREDIT]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to fetch balance' });
    }
});
// GET /credits/transactions/:doctorUid — ledger history (admin only)
router.get('/transactions/:doctorUid', ...adminOnly, async (req, res) => {
    try {
        const doctorUid = req.params['doctorUid'];
        const transactions = await prisma_1.prisma.creditTransaction.findMany({
            where: { doctorUid },
            orderBy: { createdAt: 'desc' },
            take: 100,
        });
        res.json({ transactions });
    }
    catch (error) {
        console.error('[CREDIT]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Failed to fetch transactions' });
    }
});
exports.default = router;
//# sourceMappingURL=credit.routes.js.map