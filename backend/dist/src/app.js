import express from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes.js';
import userRoutes from './routes/user.routes.js';
const app = express();
// ✅ FIXED CORS
app.use(cors({
    origin: true,
    credentials: true,
}));
app.use(express.json());
// ✅ REQUEST LOGGING
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url}`);
    next();
});
// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// Routes (without rate limiter for now)
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
// Global error handler
app.use((err, req, res, next) => {
    console.error('Global error:', err);
    res.status(500).json({ message: 'Internal server error' });
});
export default app;
//# sourceMappingURL=app.js.map