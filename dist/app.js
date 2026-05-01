"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const user_routes_1 = __importDefault(require("./routes/user.routes"));
const admin_routes_1 = __importDefault(require("./routes/admin.routes"));
const credit_routes_1 = __importDefault(require("./routes/credit.routes"));
const case_routes_1 = __importDefault(require("./routes/case.routes"));
const abdm_routes_1 = __importDefault(require("./routes/abdm.routes"));
const audit_middleware_1 = require("./middleware/audit.middleware");
const app = (0, express_1.default)();
// ── Security headers ──────────────────────────────────────────────────────────
app.use((0, helmet_1.default)());
// ── CORS ──────────────────────────────────────────────────────────────────────
const rawOrigins = process.env.ALLOWED_ORIGINS ?? '';
const allowedOrigins = rawOrigins === '*'
    ? true
    : rawOrigins.split(',').map(o => o.trim()).filter(Boolean);
app.use((0, cors_1.default)({
    origin: Array.isArray(allowedOrigins) && allowedOrigins.length ? allowedOrigins : true,
    credentials: true,
}));
// ── Body parsing (10 kb limit — no file uploads go through JSON) ───────────────
app.use(express_1.default.json({ limit: '10kb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10kb' }));
// ── Rate limiting ─────────────────────────────────────────────────────────────
const limiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 200, // max requests per window per IP
    standardHeaders: true,
    legacyHeaders: false,
    message: { message: 'Too many requests, please try again later.' },
});
app.use(limiter);
// Tighter limit for auth-adjacent endpoints
const authLimiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000,
    max: 30,
    standardHeaders: true,
    legacyHeaders: false,
    message: { message: 'Too many requests, please try again later.' },
});
app.use('/users/register', authLimiter);
// ── Request logging ───────────────────────────────────────────────────────────
app.use((req, _res, next) => {
    const ts = new Date().toISOString();
    console.log(`[${ts}] ${req.method} ${req.url} — ip:${req.ip}`);
    next();
});
// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// ── Audit + routes ────────────────────────────────────────────────────────────
app.use(audit_middleware_1.auditMiddleware);
app.use('/users', user_routes_1.default);
app.use('/admin', admin_routes_1.default);
app.use('/credits', credit_routes_1.default);
app.use('/cases', case_routes_1.default);
app.use('/abdm', abdm_routes_1.default);
// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((_req, res) => {
    res.status(404).json({ message: 'Not found' });
});
// ── Global error handler ──────────────────────────────────────────────────────
app.use((err, _req, res, _next) => {
    console.error(`[ERROR] ${err.message}`);
    res.status(500).json({ message: 'Internal server error' });
});
exports.default = app;
//# sourceMappingURL=app.js.map