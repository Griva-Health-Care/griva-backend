import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

const adminOnly = [authMiddleware, requireRole('admin', 'superadmin')];

// POST /credits/topup — add credits to a doctor's DoctorConfig and log the transaction
// Body: { doctorUid: string, amount: number, reason?: string }
// doctorUid = Supabase user UUID of the doctor
router.post('/topup', ...adminOnly, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const { doctorUid, amount, reason } = req.body as {
      doctorUid: string;
      amount:    number;
      reason?:   string;
    };

    if (!doctorUid || typeof amount !== 'number' || amount <= 0 || !Number.isInteger(amount)) {
      return res.status(400).json({ message: 'doctorUid required and amount must be a positive integer' });
    }

    let newBalance: number;

    await (prisma as any).$transaction(async (tx: any) => {
      const config = await tx.doctorConfig.upsert({
        where:  { uid: doctorUid },
        update: { creditBalance: { increment: amount } },
        create: { uid: doctorUid, creditBalance: amount, updatedAt: new Date() },
      });
      newBalance = config.creditBalance;

      await tx.creditTransaction.create({
        data: {
          doctorUid,
          delta:       amount,
          reason:      reason ?? 'admin_topup',
          adminUserId: userId,
        },
      });
    });

    res.json({ doctorUid, newBalance: newBalance! });
  } catch (error) {
    console.error('[CREDIT]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Top-up failed' });
  }
});

// GET /credits/balance/:doctorUid — read current balance from DoctorConfig
router.get('/balance/:doctorUid', authMiddleware, async (req, res) => {
  try {
    const { role, userId } = (req as any).user;
    const doctorUid = req.params['doctorUid'] as string;

    // Doctors/diagnostics can only read their own balance; admins can read any
    if (role === 'doctor' || role === 'diagnostic') {
      const self = await prisma.user.findUnique({
        where:  { id: userId },
        select: { supabaseUid: true },
      });
      if (self?.supabaseUid !== doctorUid) {
        return res.status(403).json({ message: 'Cannot read another account balance' });
      }
    }

    const config  = await (prisma as any).doctorConfig.findUnique({ where: { uid: doctorUid } });
    const balance = (config?.creditBalance as number) ?? 0;

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
      where:   { doctorUid },
      orderBy: { createdAt: 'desc' },
      take:    100,
    });
    res.json({ transactions });
  } catch (error) {
    console.error('[CREDIT]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch transactions' });
  }
});

// POST /credits/submit-case — atomically deduct one credit and create a TeleCase.
// Used by diagnostic center Flutter app (replaces the old Firestore transaction).
// Body: { uuid?: string, notes?: string, files?: array }
router.post('/submit-case', authMiddleware, requireRole('diagnostic'), async (req, res) => {
  try {
    const { userId, supabaseUid } = (req as any).user;
    const { uuid, notes, files } = req.body as {
      uuid?:  string;
      notes?: string;
      files?: Array<{ url: string; name: string; type: string; size: number }>;
    };

    let teleCase: any;

    await (prisma as any).$transaction(async (tx: any) => {
      // 1. Check and decrement credit balance
      const config = await tx.doctorConfig.findUnique({ where: { uid: supabaseUid } });
      if (!config || config.creditBalance <= 0) {
        throw new Error('INSUFFICIENT_CREDITS');
      }

      await tx.doctorConfig.update({
        where: { uid: supabaseUid },
        data:  { creditBalance: { decrement: 1 } },
      });

      // 2. Create the TeleCase
      teleCase = await tx.teleCase.create({
        data: {
          submittedBy: userId,
          notes:       notes ?? null,
          files:       files ?? [],
          status:      'pending',
        },
      });

      // 3. Log the deduction
      await tx.creditTransaction.create({
        data: {
          doctorUid: supabaseUid,
          delta:     -1,
          reason:    'case_submission',
          caseUuid:  teleCase.id,
        },
      });
    });

    res.status(201).json({ teleCase });
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    if (msg === 'INSUFFICIENT_CREDITS') {
      return res.status(402).json({ message: 'Insufficient credits. Please purchase more credits.' });
    }
    console.error('[CREDIT]', msg);
    res.status(500).json({ message: 'Failed to submit case' });
  }
});

export default router;
