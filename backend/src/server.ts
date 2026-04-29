import dotenv from 'dotenv';
dotenv.config();

import app from './app';
import { connectWithRetry } from './utils/prisma';

const PORT = Number(process.env.PORT) || 5000;

async function bootstrap() {
  console.log('[SERVER] Starting...');

  await connectWithRetry();

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`[SERVER] Running on port ${PORT}`);
  });
}

bootstrap().catch(err => {
  console.error('[SERVER] Fatal startup error:', err);
  process.exit(1);
});
