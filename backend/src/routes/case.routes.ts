import { Router } from 'express';
import { createRequire } from 'module';
import { getMessaging } from 'firebase-admin/messaging';
import { prisma } from '../utils/prisma.js';
import { authMiddleware } from '../middleware/auth.middleware.js';
import { requireRole } from '../middleware/role.middleware.js';

const router = Router();

// pdfkit ships as CommonJS; load via createRequire in an ESM project.
const require = createRequire(import.meta.url);
// eslint-disable-next-line @typescript-eslint/no-var-requires
const PDFDocument = require('pdfkit') as typeof import('pdfkit');

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Pick available tele_reporter with fewest active cases (load balancing). */
async function autoAssign(): Promise<string | null> {
  const reporters = await prisma.user.findMany({
    where: { role: 'tele_reporter', isActive: true, isAvailable: true },
    select: { firebaseUid: true },
  });
  if (!reporters.length) return null;

  const counts = await Promise.all(
    reporters.map(async (r) => ({
      uid: r.firebaseUid,
      count: await prisma.teleCase.count({
        where: { assignedUid: r.firebaseUid, status: { not: 'completed' } },
      }),
    }))
  );
  counts.sort((a, b) => a.count - b.count);
  return counts[0]?.uid ?? null;
}

/** Write a notification row and send an FCM push. Fire-and-forget — never throws. */
async function notify(
  userId: string,
  title: string,
  body: string,
  caseId?: string
): Promise<void> {
  try {
    // 1. Persist in-app notification.
    await (prisma as any).notification.create({
      data: { userId, title, body, caseId: caseId ?? null },
    });

    // 2. Send FCM push if the user has a registered device token.
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { fcmToken: true },
    });

    if (user?.fcmToken) {
      await getMessaging().send({
        token: user.fcmToken,
        notification: { title, body },
        data: { caseId: caseId ?? '' },
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
      });
    }
  } catch (err) {
    console.error('[NOTIFY]', err instanceof Error ? err.message : err);
  }
}

// ── Routes ────────────────────────────────────────────────────────────────────

// GET /cases/reporters
router.get('/reporters', authMiddleware, async (_req, res) => {
  try {
    const reporters = await prisma.user.findMany({
      where: { role: 'tele_reporter', isActive: true },
      select: { id: true, fullName: true, email: true, hospital: true, firebaseUid: true, isAvailable: true },
      orderBy: { fullName: 'asc' },
    });
    res.json({ reporters });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch reporters' });
  }
});

// PUT /cases/availability — tele_reporter toggles availability
router.put('/availability', authMiddleware, requireRole('tele_reporter', 'admin', 'superadmin'), async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const { isAvailable } = req.body as { isAvailable: boolean };
    if (typeof isAvailable !== 'boolean') {
      return res.status(400).json({ message: 'isAvailable must be a boolean' });
    }
    const user = await prisma.user.update({
      where: { id: userId },
      data: { isAvailable },
      select: { id: true, fullName: true, role: true, isAvailable: true },
    });
    res.json({ user });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update availability' });
  }
});

// GET /cases/notifications — list the caller's notifications
router.get('/notifications', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const notifications = await (prisma as any).notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
    res.json({ notifications });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
});

// PUT /cases/notifications/:id/read — mark one notification as read
router.put('/notifications/:id/read', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const id = req.params['id'] as string;
    const notif = await (prisma as any).notification.findUnique({ where: { id } });
    if (!notif || notif.userId !== userId) {
      return res.status(404).json({ message: 'Notification not found' });
    }
    await (prisma as any).notification.update({ where: { id }, data: { isRead: true } });
    res.json({ ok: true });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to mark notification' });
  }
});

// POST /cases — submit a new tele case
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const { assignedUid, notes, files } = req.body as {
      assignedUid?: string;
      notes?: string;
      files: Array<{ url: string; name: string; type: string; size: number }>;
    };

    if (!Array.isArray(files) || files.length === 0) {
      return res.status(400).json({ message: 'At least one file is required' });
    }

    let resolvedUid: string | null = assignedUid ?? null;
    let assignedBy: string = userId;
    if (!resolvedUid) {
      resolvedUid = await autoAssign();
      assignedBy = 'auto';
    }

    const teleCase = await prisma.teleCase.create({
      data: {
        submittedBy: userId,
        assignedUid: resolvedUid ?? null,
        assignedBy: resolvedUid ? assignedBy : null,
        notes: notes ?? null,
        files,
        status: resolvedUid ? 'assigned' : 'pending',
      },
    });

    // Notify the submitter that their case was received.
    const submitterMsg = resolvedUid
      ? 'Your case has been assigned to a reporter and is under review.'
      : 'Your case is queued. An admin will assign a reporter shortly.';
    await notify(userId, 'Case Submitted', submitterMsg, teleCase.id);

    // If a reporter was auto-assigned, notify them too.
    if (resolvedUid) {
      const reporter = await prisma.user.findFirst({
        where: { firebaseUid: resolvedUid },
        select: { id: true },
      });
      if (reporter) {
        await notify(reporter.id, 'New Case Assigned', 'A new tele-report case has been assigned to you.', teleCase.id);
      }
    }

    res.status(201).json({
      teleCase,
      autoAssigned: !assignedUid && !!resolvedUid,
      unassigned: !resolvedUid,
    });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to submit case' });
  }
});

// GET /cases — list cases (role-scoped)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { userId, role, firebaseUid } = (req as any).user;
    const { status } = req.query as { status?: string };

    const where: Record<string, unknown> =
      role === 'admin' || role === 'superadmin'
        ? {}
        : role === 'tele_reporter'
        ? { assignedUid: firebaseUid }
        : { submittedBy: userId };

    if (status) where.status = status;

    const cases = await prisma.teleCase.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    res.json({ cases });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch cases' });
  }
});

// GET /cases/pending — unassigned cases (admin only)
router.get('/pending', authMiddleware, requireRole('admin', 'superadmin'), async (_req, res) => {
  try {
    const cases = await prisma.teleCase.findMany({
      where: { status: 'pending' },
      orderBy: { createdAt: 'asc' },
    });
    res.json({ cases });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch pending cases' });
  }
});

// GET /cases/:id — full case detail
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const { userId, role, firebaseUid } = (req as any).user;
    const id = req.params['id'] as string;

    const teleCase = await prisma.teleCase.findUnique({ where: { id } });
    if (!teleCase) return res.status(404).json({ message: 'Case not found' });

    const isAdmin = role === 'admin' || role === 'superadmin';
    const isAssignedReporter = role === 'tele_reporter' && teleCase.assignedUid === firebaseUid;
    const isSubmitter = teleCase.submittedBy === userId;

    if (!isAdmin && !isAssignedReporter && !isSubmitter) {
      return res.status(403).json({ message: 'Access denied' });
    }
    res.json({ teleCase });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch case' });
  }
});

// GET /cases/:id/report/pdf — generate and stream a PDF of the completed report
router.get('/:id/report/pdf', authMiddleware, async (req, res) => {
  try {
    const { userId, role, firebaseUid } = (req as any).user;
    const id = req.params['id'] as string;

    const teleCase = await prisma.teleCase.findUnique({ where: { id } });
    if (!teleCase) return res.status(404).json({ message: 'Case not found' });

    const isAdmin = role === 'admin' || role === 'superadmin';
    const isAssignedReporter = role === 'tele_reporter' && teleCase.assignedUid === firebaseUid;
    const isSubmitter = teleCase.submittedBy === userId;
    if (!isAdmin && !isAssignedReporter && !isSubmitter) {
      return res.status(403).json({ message: 'Access denied' });
    }

    if (!teleCase.reporterNote) {
      return res.status(400).json({ message: 'Report not yet completed' });
    }

    // Look up the submitting doctor's name for the header.
    const doctor = await prisma.user.findUnique({
      where: { id: teleCase.submittedBy },
      select: { fullName: true, email: true, hospital: true },
    });

    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `inline; filename="tele-report-${id.slice(0, 8)}.pdf"`);
    doc.pipe(res);

    // ── Header ──────────────────────────────────────────────────────────────
    doc.fontSize(20).font('Helvetica-Bold').text('Griva Tele-Report', { align: 'center' });
    doc.moveDown(0.3);
    doc.fontSize(11).font('Helvetica').fillColor('#555555')
       .text(`Case ID: ${id}`, { align: 'center' });
    doc.moveDown(0.2);
    const completedStr = teleCase.completedAt
      ? new Date(teleCase.completedAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'long', year: 'numeric' })
      : new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'long', year: 'numeric' });
    doc.text(`Report Date: ${completedStr}`, { align: 'center' });
    doc.moveDown(0.8);

    doc.moveTo(50, doc.y).lineTo(545, doc.y).strokeColor('#CCCCCC').stroke();
    doc.moveDown(0.8);

    // ── Doctor info ──────────────────────────────────────────────────────────
    doc.fontSize(13).font('Helvetica-Bold').fillColor('#000000').text('Submitted By');
    doc.moveDown(0.3);
    doc.fontSize(11).font('Helvetica').fillColor('#333333');
    doc.text(`Name    : ${doctor?.fullName ?? 'Unknown'}`);
    doc.text(`Email   : ${doctor?.email ?? ''}`);
    if (doctor?.hospital) doc.text(`Hospital: ${doctor.hospital}`);
    doc.moveDown(0.8);

    // ── Clinical notes ───────────────────────────────────────────────────────
    if (teleCase.notes) {
      doc.fontSize(13).font('Helvetica-Bold').fillColor('#000000').text('Clinical Notes');
      doc.moveDown(0.3);
      doc.fontSize(11).font('Helvetica').fillColor('#333333').text(teleCase.notes, { lineGap: 4 });
      doc.moveDown(0.8);
    }

    doc.moveTo(50, doc.y).lineTo(545, doc.y).strokeColor('#CCCCCC').stroke();
    doc.moveDown(0.8);

    // ── Reporter findings ────────────────────────────────────────────────────
    doc.fontSize(13).font('Helvetica-Bold').fillColor('#000000').text('Reporter Findings');
    doc.moveDown(0.3);
    doc.fontSize(11).font('Helvetica').fillColor('#333333')
       .text(teleCase.reporterNote, { lineGap: 5 });
    doc.moveDown(1.2);

    // ── Footer ───────────────────────────────────────────────────────────────
    doc.moveTo(50, doc.y).lineTo(545, doc.y).strokeColor('#CCCCCC').stroke();
    doc.moveDown(0.5);
    doc.fontSize(9).fillColor('#999999')
       .text('This report was generated by the Griva Tele-Reporting Platform. For clinical use only.', { align: 'center' });

    doc.end();
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    if (!res.headersSent) res.status(500).json({ message: 'Failed to generate PDF' });
  }
});

// PUT /cases/:id/assign — manually assign or reassign (admin only)
router.put('/:id/assign', authMiddleware, requireRole('admin', 'superadmin'), async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const id = req.params['id'] as string;
    const { assignedUid } = req.body as { assignedUid: string };

    if (!assignedUid) {
      return res.status(400).json({ message: 'assignedUid is required' });
    }

    const teleCase = await prisma.teleCase.update({
      where: { id },
      data: { assignedUid, assignedBy: userId, status: 'assigned' },
    });

    // Notify submitter and reporter.
    await notify(teleCase.submittedBy, 'Case Assigned', 'Your case has been assigned to a reporter.', id);
    const reporter = await prisma.user.findFirst({
      where: { firebaseUid: assignedUid },
      select: { id: true },
    });
    if (reporter) {
      await notify(reporter.id, 'New Case Assigned', 'A new tele-report case has been assigned to you.', id);
    }

    res.json({ teleCase });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to assign case' });
  }
});

// PUT /cases/:id/status — reporter or admin updates status
router.put('/:id/status', authMiddleware, async (req, res) => {
  try {
    const { role, firebaseUid } = (req as any).user;
    const id = req.params['id'] as string;
    const { status } = req.body as { status: string };

    const valid = ['pending', 'assigned', 'in_review', 'completed'];
    if (!valid.includes(status)) {
      return res.status(400).json({ message: `status must be one of: ${valid.join(', ')}` });
    }

    const existing = await prisma.teleCase.findUnique({ where: { id } });
    if (!existing) return res.status(404).json({ message: 'Case not found' });

    const isAdmin = role === 'admin' || role === 'superadmin';
    const isAssignedReporter = role === 'tele_reporter' && existing.assignedUid === firebaseUid;
    if (!isAdmin && !isAssignedReporter) {
      return res.status(403).json({ message: 'Insufficient permissions' });
    }

    const teleCase = await prisma.teleCase.update({
      where: { id },
      data: { status, ...(status === 'completed' ? { completedAt: new Date() } : {}) },
    });

    res.json({ teleCase });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to update case status' });
  }
});

// POST /cases/:id/report — reporter submits findings
router.post('/:id/report', authMiddleware, async (req, res) => {
  try {
    const { role, firebaseUid } = (req as any).user;
    const id = req.params['id'] as string;
    const { reporterNote } = req.body as { reporterNote: string };

    if (!reporterNote?.trim()) {
      return res.status(400).json({ message: 'reporterNote is required' });
    }

    const existing = await prisma.teleCase.findUnique({ where: { id } });
    if (!existing) return res.status(404).json({ message: 'Case not found' });

    const isAdmin = role === 'admin' || role === 'superadmin';
    const isAssignedReporter = role === 'tele_reporter' && existing.assignedUid === firebaseUid;
    if (!isAdmin && !isAssignedReporter) {
      return res.status(403).json({ message: 'Only the assigned reporter can submit findings' });
    }

    const teleCase = await prisma.teleCase.update({
      where: { id },
      data: { reporterNote: reporterNote.trim(), status: 'completed', completedAt: new Date() },
    });

    // Notify the submitter that their report is ready.
    await notify(
      teleCase.submittedBy,
      'Report Ready',
      'Your tele-report case has been reviewed. Tap to see the findings.',
      id
    );

    res.json({ teleCase });
  } catch (error) {
    console.error('[CASE]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to submit report' });
  }
});

export default router;
