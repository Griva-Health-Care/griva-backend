import express from 'express';
import cors from 'cors';
import helmet from 'helmet';

import adminRoutes from './routes/admin.routes';
import caseRoutes from './routes/case.routes';
import creditRoutes from './routes/credit.routes';

const app = express();

app.set('trust proxy', 1);

app.use(helmet());

app.use(
  cors({
    origin: [
      'https://grivahealth.com',
      'https://www.grivahealth.com',
      'https://api.grivahealth.com',
      'https://admin.grivahealth.com',
    ],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_req, res) => {
  res.status(200).json({
    ok: true,
    service: 'griva-backend',
    timestamp: new Date().toISOString(),
  });
});

app.use('/admin', adminRoutes);
app.use('/cases', caseRoutes);
app.use('/credits', creditRoutes);

app.use((_req, res) => {
  res.status(404).json({
    message: 'Route not found',
  });
});

app.use(
  (
    err: any,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction
  ) => {
    console.error('[SERVER ERROR]', err);

    res.status(err?.status || 500).json({
      message: err?.message || 'Internal server error',
    });
  }
);

export default app;
