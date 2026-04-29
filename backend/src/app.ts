import express from 'express';
import cors from 'cors';

import userRoutes from './routes/user.routes.js';
import adminRoutes from './routes/admin.routes.js';
import creditRoutes from './routes/credit.routes.js';
import caseRoutes from './routes/case.routes.js';
import abdmRoutes from './routes/abdm.routes.js';
import { auditMiddleware } from './middleware/audit.middleware.js';

const app = express();

const rawOrigins = process.env.ALLOWED_ORIGINS ?? '';
const allowedOrigins: string[] | true = rawOrigins === '*'
  ? true
  : rawOrigins.split(',').map(o => o.trim()).filter(Boolean);

app.use(cors({
  origin: Array.isArray(allowedOrigins) && allowedOrigins.length ? allowedOrigins : true,
  credentials: true,
}));
app.use(express.json());

app.use((req, _res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use(auditMiddleware);

// Routes
app.use('/users', userRoutes);
app.use('/admin', adminRoutes);
app.use('/credits', creditRoutes);
app.use('/cases', caseRoutes);
app.use('/abdm', abdmRoutes);

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ message: 'Internal server error' });
});

export default app;
