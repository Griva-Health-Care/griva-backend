import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

console.log('[ENV] Checking DATABASE_URL...');
const connectionString = process.env.DATABASE_URL;
console.log(`[ENV] DATABASE_URL present: ${connectionString ? 'YES' : 'NO'}`);

if (!connectionString) {
  console.error('[ENV] FATAL: DATABASE_URL is not set. Set it in Render → Environment.');
  process.exit(1);
}

console.log('[DB] Initializing Prisma...');
const adapter = new PrismaPg({ connectionString });
export const prisma = new PrismaClient({ adapter });

export async function connectWithRetry(maxRetries = 3): Promise<void> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`[DB] Connecting... (attempt ${attempt}/${maxRetries})`);
      await prisma.$connect();
      console.log('[DB] Connected successfully');
      return;
    } catch (err) {
      console.error(`[DB] Connection attempt ${attempt} failed:`, (err as Error).message);
      if (attempt === maxRetries) {
        console.error('[DB] FATAL: Could not connect to database after', maxRetries, 'attempts');
        process.exit(1);
      }
      await new Promise(r => setTimeout(r, 2000 * attempt));
    }
  }
}
