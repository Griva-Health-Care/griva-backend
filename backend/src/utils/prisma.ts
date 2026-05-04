import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('[DB] FATAL: DATABASE_URL is not set.');
  process.exit(1);
}

// Supabase uses its own CA that Node.js doesn't trust by default.
// Strip sslmode from the URL so the Pool's ssl option takes full control.
// rejectUnauthorized:false keeps the connection encrypted but skips cert chain
// verification — this is Supabase's own recommendation for direct connections.
const cleanUrl = connectionString.replace(/[?&]sslmode=[^&]*/g, '').replace(/[?&]uselibpqcompat=[^&]*/g, '');
const pool = new Pool({
  connectionString: cleanUrl,
  ssl: { rejectUnauthorized: false },
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
