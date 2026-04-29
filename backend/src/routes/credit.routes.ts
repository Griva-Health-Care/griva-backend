import { Router } from 'express';
import admin from 'firebase-admin';
import { prisma } from '../utils/prisma.js';
import { authMiddleware } from '../middleware/auth.middleware.js';
import { requireRole } from '../middleware/role.middleware.js';

const router = Router();

const adminOnly = [authMiddleware, requireRole('admin', 'superadmin')];

// POST /credits/topup — add credits to a doctor's Firestore config and log the transaction
// Body: { doctorUid: string, amount: number, reason?: string }
router.post('/topup', ...adminOnly, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const { doctorUid, amount, reason } = req.body as {
      doctorUid: string;
      amount: number;
      reason?: string;
    };

    if (!doctorUid || typeof amount !== 'number' || amount <= 0 || !Number.isInteger(amount)) {
      return res.status(400).json({ message: 'doctorUid required and amount must be a positive integer' });
    }

    const fdb = admin.firestore();
    const configRef = fdb.collection('doctor_config').doc(doctorUid);

    let newBalance: number;

    await fdb.runTransaction(async (tx) => {
      const snap = await tx.get(configRef);
      const current = (snap.data()?.creditBalance as number) ?? 0;
      newBalance = current + amount;
      tx.set(configRef, { creditBalance: newBalance }, { merge: true });
    });

    await prisma.creditTransaction.create({
      data: {
        doctorUid,
        delta: amount,
        reason: reason ?? 'admin_topup',
        adminUserId: userId,
      },
    });

    res.json({ doctorUid, newBalance: newBalance! });
  } catch (error) {
    console.error('[CREDIT]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Top-up failed' });
  }
});

// GET /credits/balance/:doctorUid — read current balance from Firestore
router.get('/balance/:doctorUid', authMiddleware, async (req, res) => {
  try {
    const { role, userId } = (req as any).user;
    const doctorUid = req.params['doctorUid'] as string;

    // Doctors can only read their own balance; admins can read any
    if (role === 'doctor' || role === 'diagnostic') {
      const self = await prisma.user.findUnique({
        where: { id: userId },
        select: { firebaseUid: true },
      });
      if (self?.firebaseUid !== doctorUid) {
        return res.status(403).json({ message: 'Cannot read another account balance' });
      }
    }

    const snap = await admin.firestore().collection('doctor_config').doc(doctorUid).get();
    const balance = (snap.data()?.creditBalance as number) ?? 0;

    res.json({ doctorUid, balance });
  } catch (error) {
    console.error('[CREDIT]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch balance' });
  }
});

// GET /credits/transactions/:doctorUid — ledger history (admin only)
router.get('/transactions/:doctorUid', ...adminOnly, async (req, res) => {
  try {
    const doctorUid = req.params['doctorUid'] as string;
    const transactions = await prisma.creditTransaction.findMany({
      where: { doctorUid },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    res.json({ transactions });
  } catch (error) {
    console.error('[CREDIT]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch transactions' });
  }
});

export default router;
