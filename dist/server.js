"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const child_process_1 = require("child_process");
const http_1 = __importDefault(require("http"));
const app_1 = __importDefault(require("./app"));
const prisma_1 = require("./utils/prisma");
const PORT = Number(process.env.PORT) || 5000;
function runMigrations() {
    console.log('[MIGRATE] Running prisma migrate deploy...');
    try {
        (0, child_process_1.execSync)('npx prisma migrate deploy', { stdio: 'inherit' });
        console.log('[MIGRATE] Migrations applied successfully');
    }
    catch (err) {
        console.error('[MIGRATE] Migration failed:', err);
        process.exit(1);
    }
}
async function bootstrap() {
    console.log('[SERVER] Starting...');
    runMigrations();
    await (0, prisma_1.connectWithRetry)();
    const server = http_1.default.createServer(app_1.default);
    server.listen(PORT, '0.0.0.0', () => {
        console.log(`[SERVER] Running on port ${PORT}`);
    });
    // ── Graceful shutdown ──────────────────────────────────────────────────────
    const shutdown = async (signal) => {
        console.log(`[SERVER] ${signal} received — shutting down gracefully`);
        server.close(async () => {
            await prisma_1.prisma.$disconnect();
            console.log('[SERVER] Shutdown complete');
            process.exit(0);
        });
        // Force exit if shutdown takes too long
        setTimeout(() => process.exit(1), 10000);
    };
    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));
}
bootstrap().catch(err => {
    console.error('[SERVER] Fatal startup error:', err);
    process.exit(1);
});
//# sourceMappingURL=server.js.map