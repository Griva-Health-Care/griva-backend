import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// POST /patients/sync — bulk upsert patients for the authenticated doctor/diagnostic center.
// Flutter app calls this whenever it gains internet access.
// Body: { patients: [{ uuid, patientName, hasReport }] }
router.post('/sync', authMiddleware, async (req, res) => {
  try {
    const userId = (req as any).user.userId as string;
    const { patients } = req.body as {
      patients: { uuid: string; patientName: string; hasReport: boolean }[];
    };

    if (!Array.isArray(patients) || patients.length === 0) {
      return res.status(400).json({ message: 'patients array is required and must not be empty' });
    }

    // Upsert each patient — match on uuid, update name + hasReport flag
    await prisma.$transaction(
      patients.map((p) =>
        prisma.patient.upsert({
          where: { uuid: p.uuid },
          create: {
            uuid:        p.uuid,
            patientName: p.patientName,
            userId,
            hasReport:   p.hasReport ?? false,
          },
          update: {
            patientName: p.patientName,
            hasReport:   p.hasReport ?? false,
            updatedAt:   new Date(),
          },
        })
      )
    );

    res.json({ synced: patients.length });
  } catch (error) {
    console.error('[PATIENTS]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to sync patients' });
  }
});

export default router;
