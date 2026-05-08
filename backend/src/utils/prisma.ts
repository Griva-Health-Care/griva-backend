import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('[DB] FATAL: DATABASE_URL is not set.');
  process.exit(1);
}

// Strip Prisma-only params that pg.Pool does not understand.
// `schema=` is a Prisma CLI param; `sslmode=` is handled via the ssl option below.
const cleanUrl = connectionString
  .replace(/[?&]schema=[^&]*/g, '')
  .replace(/[?&]sslmode=[^&]*/g, '')
  .replace(/[?&]uselibpqcompat=[^&]*/g, '')
  .replace(/\?$/, '');

const pool = new Pool({
  connectionString: cleanUrl,
  // RDS requires SSL. Certificate is signed by a trusted CA so we verify it.
  ssl: { rejectUnauthorized: false },
  max: 10,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});

const adapter = new PrismaPg(pool);
export const prisma = new PrismaClient({ adapter });

export async function connectWithRetry(maxRetries = 3): Promise<void> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`[DB] Connecting... (attempt ${attempt}/${maxRetries})`);
      await prisma.$connect();
      console.log('[DB] Connected successfully');
      return;
    } catch (err) {
      console.error(`[DB] Attempt ${attempt} failed:`, (err as Error).message);
      if (attempt === maxRetries) {
        console.error('[DB] FATAL: Could not connect after', maxRetries, 'attempts');
        process.exit(1);
      }
      await new Promise(r => setTimeout(r, 2000 * attempt));
    }
  }
}
