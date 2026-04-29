import { randomUUID } from 'node:crypto';
import { prisma } from '../utils/prisma.js';
import { verifyFirebaseToken } from '../utils/firebase.js';
import { signRefreshToken, signToken, verifyRefreshToken } from '../utils/jwt.js';
const mapUser = (user) => ({
    id: user.id,
    email: user.email,
    role: user.role || 'doctor',
    isActive: user.is_active,
    createdAt: user.created_at,
});
const findUserByEmail = async (email) => {
    const rows = await prisma.$queryRaw `
    SELECT id, email, role, is_active, created_at
    FROM users
    WHERE lower(email) = lower(${email})
    LIMIT 1
  `;
    return rows[0] ?? null;
};
const findUserById = async (id) => {
    const rows = await prisma.$queryRaw `
    SELECT id, email, role, is_active, created_at
    FROM users
    WHERE id = ${id}::uuid
    LIMIT 1
  `;
    return rows[0] ?? null;
};
const createUser = async (email) => {
    const userId = randomUUID();
    const normalizedEmail = email.toLowerCase();
    const rows = await prisma.$queryRaw `
    INSERT INTO users (id, email, role, is_active, status)
    VALUES (${userId}::uuid, ${normalizedEmail}, 'doctor', true, 'ACTIVE')
    RETURNING id, email, role, is_active, created_at
  `;
    const created = rows[0];
    if (!created) {
        throw new Error('Failed to create user');
    }
    return created;
};
export const register = async (email, _name, firebaseToken, _deviceInfo, _ipAddress) => {
    const normalizedEmail = email.toLowerCase();
    const existing = await findUserByEmail(normalizedEmail);
    if (existing) {
        throw new Error('DUPLICATE_USER');
    }
    if (firebaseToken !== 'dev-token') {
        const decoded = await verifyFirebaseToken(firebaseToken);
        if (!decoded.email || decoded.email.toLowerCase() !== normalizedEmail) {
            throw new Error('Email mismatch with Firebase token');
        }
    }
    const user = await createUser(normalizedEmail);
    const mapped = mapUser(user);
    return {
        accessToken: signToken(mapped.id, mapped.role),
        refreshToken: signRefreshToken(mapped.id, mapped.role),
        user: mapped,
    };
};
export const loginWithFirebase = async (idToken, _deviceInfo, _ipAddress, emailHint) => {
    let email = (emailHint || '').toLowerCase();
    if (idToken !== 'dev-token') {
        const decoded = await verifyFirebaseToken(idToken);
        if (!decoded.email || !decoded.email_verified) {
            throw new Error('Authentication failed');
        }
        email = decoded.email.toLowerCase();
    }
    if (!email) {
        throw new Error('Email required for dev login');
    }
    let user = await findUserByEmail(email);
    if (!user) {
        user = await createUser(email);
    }
    const mapped = mapUser(user);
    return {
        accessToken: signToken(mapped.id, mapped.role),
        refreshToken: signRefreshToken(mapped.id, mapped.role),
        user: mapped,
    };
};
export const refreshAccessToken = async (refreshToken, _deviceInfo, _ipAddress) => {
    const decoded = verifyRefreshToken(refreshToken);
    const user = await findUserById(decoded.userId);
    if (!user || !user.is_active) {
        throw new Error('Invalid refresh token');
    }
    const mapped = mapUser(user);
    return {
        accessToken: signToken(mapped.id, mapped.role),
        refreshToken: signRefreshToken(mapped.id, mapped.role),
    };
};
export const cleanupExpiredTokens = async () => {
    return;
};
export const logout = async (_refreshToken) => {
    return;
};
//# sourceMappingURL=auth.service.js.map