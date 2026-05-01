import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('[DB] FATAL: DATABASE_URL is not set.');
  process.exit(1);
}

// Render-hosted Postgres requires SSL. Append sslmode=require if not already present.
const dbUrl = connectionString.includes('sslmode')
  ? connectionString
  : `${connectionString}${connectionString.includes('?') ? '&' : '?'}sslmode=require`;

const adapter = new PrismaPg({ connectionString: dbUrl });
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
