"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prisma = void 0;
exports.connectWithRetry = connectWithRetry;
const client_1 = require("@prisma/client");
const adapter_pg_1 = require("@prisma/adapter-pg");
const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
    console.error('[DB] FATAL: DATABASE_URL is not set.');
    process.exit(1);
}
// Render-hosted Postgres requires SSL. Append sslmode=require if not already present.
const dbUrl = connectionString.includes('sslmode')
    ? connectionString
    : `${connectionString}${connectionString.includes('?') ? '&' : '?'}sslmode=require`;
const adapter = new adapter_pg_1.PrismaPg({ connectionString: dbUrl });
exports.prisma = new client_1.PrismaClient({ adapter });
async function connectWithRetry(maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            console.log(`[DB] Connecting... (attempt ${attempt}/${maxRetries})`);
            await exports.prisma.$connect();
            console.log('[DB] Connected successfully');
            return;
        }
        catch (err) {
            console.error(`[DB] Attempt ${attempt} failed:`, err.message);
            if (attempt === maxRetries) {
                console.error('[DB] FATAL: Could not connect after', maxRetries, 'attempts');
                process.exit(1);
            }
            await new Promise(r => setTimeout(r, 2000 * attempt));
        }
    }
}
//# sourceMappingURL=prisma.js.map