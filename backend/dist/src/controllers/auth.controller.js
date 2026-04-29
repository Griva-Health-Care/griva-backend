import { z } from 'zod';
import { loginWithFirebase, register, refreshAccessToken, logout } from '../services/auth.service.js';
import { logEvent } from '../utils/logger.js';
const loginSchema = z.object({
    firebaseToken: z.string().min(1),
    email: z.string().email().optional(),
});
const registerSchema = z.object({
    email: z.string().email(),
    name: z.string().min(2),
    firebaseToken: z.string().optional(),
});
const refreshSchema = z.object({
    refreshToken: z.string().min(20),
});
const logoutSchema = z.object({
    refreshToken: z.string().min(20),
});
export const logoutHandler = async (req, res) => {
    const parsed = logoutSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid input' });
    }
    try {
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        await logout(parsed.data.refreshToken);
        await logEvent('logout_success', undefined, 'User logged out', ipAddress);
        res.json({ message: 'Logged out successfully' });
    }
    catch (error) {
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        await logEvent('logout_failure', undefined, error instanceof Error ? error.message : String(error), ipAddress);
        console.error('[LOGOUT_ERROR]', error instanceof Error ? error.message : error);
        res.status(500).json({ message: 'Logout failed' });
    }
};
export const login = async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid input' });
    }
    try {
        const deviceInfo = req.headers['user-agent'] || 'unknown';
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        const result = await loginWithFirebase(parsed.data.firebaseToken, deviceInfo, ipAddress, parsed.data.email);
        await logEvent('login_success', result.user.id, `Email: ${result.user.email}`, ipAddress);
        res.json(result);
    }
    catch (error) {
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        await logEvent('login_failure', undefined, error instanceof Error ? error.message : String(error), ipAddress);
        console.error('[AUTH_ERROR]', error instanceof Error ? error.message : error);
        res.status(401).json({ message: 'Authentication failed' });
    }
};
export const registerHandler = async (req, res) => {
    console.log('[REGISTER] Incoming request body:', req.body);
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success) {
        console.error('[REGISTER] Validation failed:', parsed.error);
        return res.status(400).json({ message: 'Invalid input', errors: parsed.error.issues });
    }
    try {
        const deviceInfo = req.headers['user-agent'] || 'unknown';
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        console.log('[REGISTER] Processing registration for:', parsed.data.email);
        const result = await register(parsed.data.email, parsed.data.name, parsed.data.firebaseToken || 'dev-token', deviceInfo, ipAddress);
        console.log('[REGISTER] User created successfully, ID:', result.user.id);
        console.log('[REGISTER] Response payload:', {
            userId: result.user.id,
            email: result.user.email,
            hasAccessToken: !!result.accessToken,
            hasRefreshToken: !!result.refreshToken,
        });
        await logEvent('register_success', result.user.id, `Email: ${result.user.email}`, ipAddress);
        res.status(201).json(result);
    }
    catch (error) {
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        const errorMsg = error instanceof Error ? error.message : String(error);
        console.error('[REGISTER_ERROR]', errorMsg);
        await logEvent('register_failure', undefined, errorMsg, ipAddress);
        // Return 409 Conflict for duplicate user
        if (errorMsg === 'DUPLICATE_USER') {
            console.log('[REGISTER] User already exists, returning 409');
            return res.status(409).json({ message: 'User already exists with this email' });
        }
        res.status(400).json({ message: errorMsg });
    }
};
export const refresh = async (req, res) => {
    const parsed = refreshSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ message: 'Invalid input' });
    }
    try {
        const deviceInfo = req.headers['user-agent'] || 'unknown';
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        const result = await refreshAccessToken(parsed.data.refreshToken, deviceInfo, ipAddress);
        await logEvent('refresh_success', undefined, 'Token refreshed', ipAddress);
        res.json(result);
    }
    catch (error) {
        const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
        await logEvent('refresh_failure', undefined, error instanceof Error ? error.message : String(error), ipAddress);
        console.error('[REFRESH_ERROR]', error instanceof Error ? error.message : error);
        res.status(401).json({ message: 'Invalid refresh token' });
    }
};
//# sourceMappingURL=auth.controller.js.map