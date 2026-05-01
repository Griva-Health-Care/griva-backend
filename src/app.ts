import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

import userRoutes    from './routes/user.routes';
import adminRoutes   from './routes/admin.routes';
import creditRoutes  from './routes/credit.routes';
import caseRoutes    from './routes/case.routes';
import abdmRoutes    from './routes/abdm.routes';
import patientRoutes from './routes/patient.routes';
import { auditMiddleware } from './middleware/audit.middleware';

const app = express();

// ── Security headers ──────────────────────────────────────────────────────────
app.use(helmet());

// ── CORS ──────────────────────────────────────────────────────────────────────
const rawOrigins = process.env.ALLOWED_ORIGINS ?? '';
const allowedOrigins: string[] | true = rawOrigins === '*'
  ? true
  : rawOrigins.split(',').map(o => o.trim()).filter(Boolean);

app.use(cors({
  origin: Array.isArray(allowedOrigins) && allowedOrigins.length ? allowedOrigins : true,
  credentials: true,
}));

// ── Body parsing (10 kb limit — no file uploads go through JSON) ───────────────
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// ── Rate limiting ─────────────────────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200,                  // max requests per window per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests, please try again later.' },
});
app.use(limiter);

// Tighter limit for auth-adjacent endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests, please try again later.' },
});
app.use('/users/register', authLimiter);

// ── Request logging ───────────────────────────────────────────────────────────
app.use((req, _res, next) => {
  const ts = new Date().toISOString();
  console.log(`[${ts}] ${req.method} ${req.url} — ip:${req.ip}`);
  next();
});

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── One-time admin setup — DELETE AFTER FIRST USE ─────────────────────────────
import { prisma as _setupPrisma } from './utils/prisma';
app.get('/setup-admin', async (req, res) => {
  if (req.query['secret'] !== 'griva-setup-2024') {
    return res.status(403).json({ message: 'Forbidden' });
  }
  const email = req.query['email'] as string;
  if (!email) return res.status(400).json({ message: 'email required' });
  const user = await _setupPrisma.user.updateMany({
    where: { email },
    data:  { role: 'superadmin' },
  });
  res.json({ updated: user.count, email });
});

// ── Audit + routes ────────────────────────────────────────────────────────────
app.use(auditMiddleware);

app.use('/users',    userRoutes);
app.use('/admin',    adminRoutes);
app.use('/credits',  creditRoutes);
app.use('/cases',    caseRoutes);
app.use('/abdm',     abdmRoutes);
app.use('/patients', patientRoutes);

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ message: 'Not found' });
});

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(`[ERROR] ${err.message}`);
  res.status(500).json({ message: 'Internal server error' });
});

export default app;
