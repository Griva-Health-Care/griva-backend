import dotenv from 'dotenv';
dotenv.config();

import http from 'http';

import app from './app';
import { connectWithRetry, prisma } from './utils/prisma';

const PORT = Number(process.env.PORT) || 5000;

async function bootstrap() {
  console.log('[SERVER] Starting...');

  await connectWithRetry();

  const server = http.createServer(app);

  server.listen(PORT, '0.0.0.0', () => {
    console.log(`[SERVER] Running on port ${PORT}`);
  });

  const shutdown = async (signal: string) => {
    console.log(`[SERVER] ${signal} received — shutting down gracefully`);

    server.close(async () => {
      await prisma.$disconnect();

      console.log('[SERVER] Shutdown complete');

      process.exit(0);
    });

    setTimeout(() => process.exit(1), 10000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

bootstrap().catch((err) => {
  console.error('[SERVER] Fatal startup error:', err);
  process.exit(1);
});
