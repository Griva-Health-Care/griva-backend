import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { prisma } from '../utils/prisma';
import { signToken } from '../utils/jwt';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// ── POST /auth/register ────────────────────────────────────────────────────────
// Creates a new user account and returns a signed JWT.
// Body: { email, password, fullName?, hospital?, role? }
router.post('/register', async (req, res) => {
  try {
    const { email, password, fullName, hospital, role } = req.body as {
      email:     string;
      password:  string;
      fullName?: string;
      hospital?: string;
      role?:     string;
    };

    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }
    if (password.length < 8) {
      return res.status(400).json({ message: 'password must be at least 8 characters' });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const existing = await prisma.user.findUnique({ where: { email: normalizedEmail } });
    if (existing) {
      return res.status(409).json({ message: 'An account with this email already exists' });
    }

    const safeRole = ['doctor', 'diagnostic', 'tele_reporter'].includes(role ?? '')
      ? role!
      : 'doctor';

    const passwordHash = await bcrypt.hash(password, 12);
    const supabaseUid  = uuidv4(); // stable user UUID — stored in supabaseUid column

    const user = await prisma.user.create({
      data: {
        supabaseUid,
        email:        normalizedEmail,
        fullName:     fullName ?? null,
        hospital:     hospital ?? null,
        role:         safeRole,
        passwordHash,
        isActive:     true,
      },
      select: { id: true, email: true, fullName: true, role: true, supabaseUid: true },
    });

    const token = await signToken({
      sub:    user.supabaseUid,
      userId: user.id,
      email:  user.email,
      role:   user.role,
    });

    res.status(201).json({
      token,
      user: {
        id:         user.supabaseUid,
        email:      user.email,
        fullName:   user.fullName,
        role:       user.role,
      },
    });
  } catch (error) {
    console.error('[AUTH/REGISTER]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Registration failed' });
  }
});

// ── POST /auth/login ───────────────────────────────────────────────────────────
// Authenticate with email + password, returns a signed JWT.
// Body: { email, password }
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body as { email: string; password: string };

    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const user = await prisma.user.findUnique({
      where:  { email: normalizedEmail },
      select: {
        id: true, email: true, fullName: true, role: true,
        supabaseUid: true, isActive: true, passwordHash: true,
      },
    });

    if (!user || !user.passwordHash) {
      // Generic message to avoid user enumeration
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    if (!user.isActive) {
      return res.status(403).json({ message: 'Account disabled' });
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const token = await signToken({
      sub:    user.supabaseUid,
      userId: user.id,
      email:  user.email,
      role:   user.role,
    });

    res.json({
      token,
      user: {
        id:       user.supabaseUid,
        email:    user.email,
        fullName: user.fullName,
        role:     user.role,
      },
    });
  } catch (error) {
    console.error('[AUTH/LOGIN]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Login failed' });
  }
});

// ── POST /auth/set-password ────────────────────────────────────────────────────
// Transition endpoint for users migrated from Supabase who have no passwordHash.
// If passwordHash is already set, requires the current password to change it.
// Body: { email, newPassword, currentPassword? }
router.post('/set-password', async (req, res) => {
  try {
    const { email, newPassword, currentPassword } = req.body as {
      email:            string;
      newPassword:      string;
      currentPassword?: string;
    };

    if (!email || !newPassword) {
      return res.status(400).json({ message: 'email and newPassword are required' });
    }
    if (newPassword.length < 8) {
      return res.status(400).json({ message: 'newPassword must be at least 8 characters' });
    }

    const user = await prisma.user.findUnique({
      where:  { email: email.trim().toLowerCase() },
      select: { id: true, email: true, fullName: true, role: true, supabaseUid: true, isActive: true, passwordHash: true },
    });

    if (!user) {
      return res.status(404).json({ message: 'Account not found' });
    }

    if (!user.isActive) {
      return res.status(403).json({ message: 'Account disabled' });
    }

    // If user already has a password, require current password verification
    if (user.passwordHash) {
      if (!currentPassword) {
        return res.status(400).json({ message: 'currentPassword is required to change an existing password' });
      }
      const valid = await bcrypt.compare(currentPassword, user.passwordHash);
      if (!valid) {
        return res.status(401).json({ message: 'Current password is incorrect' });
      }
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({
      where: { id: user.id },
      data:  { passwordHash },
    });

    const token = await signToken({
      sub:    user.supabaseUid,
      userId: user.id,
      email:  user.email,
      role:   user.role,
    });

    res.json({ message: 'Password set successfully', token });
  } catch (error) {
    console.error('[AUTH/SET-PASSWORD]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to set password' });
  }
});

// ── GET /auth/me ───────────────────────────────────────────────────────────────
// Returns the authenticated caller's profile. Requires valid JWT.
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { userId } = (req as any).user;
    const user = await prisma.user.findUnique({
      where:  { id: userId },
      select: {
        id: true, email: true, fullName: true, role: true,
        hospital: true, isActive: true, supabaseUid: true, createdAt: true,
      },
    });
    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json({
      user: {
        id:        user.supabaseUid,
        internalId: user.id,
        email:     user.email,
        fullName:  user.fullName,
        role:      user.role,
        hospital:  user.hospital,
        isActive:  user.isActive,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    console.error('[AUTH/ME]', error instanceof Error ? error.message : error);
    res.status(500).json({ message: 'Failed to fetch user' });
  }
});

export default router;
