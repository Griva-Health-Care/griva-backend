"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const user_routes_1 = __importDefault(require("./routes/user.routes"));
const admin_routes_1 = __importDefault(require("./routes/admin.routes"));
const credit_routes_1 = __importDefault(require("./routes/credit.routes"));
const case_routes_1 = __importDefault(require("./routes/case.routes"));
const abdm_routes_1 = __importDefault(require("./routes/abdm.routes"));
const audit_middleware_1 = require("./middleware/audit.middleware");
const app = (0, express_1.default)();
const rawOrigins = process.env.ALLOWED_ORIGINS ?? '';
const allowedOrigins = rawOrigins === '*'
    ? true
    : rawOrigins.split(',').map(o => o.trim()).filter(Boolean);
app.use((0, cors_1.default)({
    origin: Array.isArray(allowedOrigins) && allowedOrigins.length ? allowedOrigins : true,
    credentials: true,
}));
app.use(express_1.default.json());
app.use((req, _res, next) => {
    console.log(`${req.method} ${req.url}`);
    next();
});
// Health check
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
app.use(audit_middleware_1.auditMiddleware);
// Routes
app.use('/users', user_routes_1.default);
app.use('/admin', admin_routes_1.default);
app.use('/credits', credit_routes_1.default);
app.use('/cases', case_routes_1.default);
app.use('/abdm', abdm_routes_1.default);
app.use((err, _req, res, _next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ message: 'Internal server error' });
});
exports.default = app;
//# sourceMappingURL=app.js.map