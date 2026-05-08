import dotenv from 'dotenv';
dotenv.config();

import { execSync } from 'child_process';
import http from 'http';
import app from './app';
import { connectWithRetry, prisma } from './utils/prisma';
import { logS3Config } from './utils/s3';

const PORT = Number(process.env.PORT) || 5000;

function runMigrations() {
  console.log('[MIGRATE] Running prisma migrate deploy...');
  try {
    execSync('npx prisma migrate deploy', { stdio: 'inherit' });
    console.log('[MIGRATE] Migrations applied successfully');
  } catch (err) {
    console.error('[MIGRATE] Migration failed:', err);
    process.exit(1);
  }
}

async function bootstrap() {
  console.log('[SERVER] Starting...');

  runMigrations();
  logS3Config();
  await connectWithRetry();

  const server = http.createServer(app);

  server.listen(PORT, '0.0.0.0', () => {
    console.log(`[SERVER] Running on port ${PORT}`);
  });

  // ── Graceful shutdown ──────────────────────────────────────────────────────
  const shutdown = async (signal: string) => {
    console.log(`[SERVER] ${signal} received — shutting down gracefully`);
    server.close(async () => {
      await prisma.$disconnect();
      console.log('[SERVER] Shutdown complete');
      process.exit(0);
    });
    // Force exit if shutdown takes too long
    setTimeout(() => process.exit(1), 10_000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT',  () => shutdown('SIGINT'));
}

bootstrap().catch(err => {
  console.error('[SERVER] Fatal startup error:', err);
  process.exit(1);
});
