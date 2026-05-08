import { Request, Response, NextFunction } from 'express';
import { firebaseAdmin } from '../utils/firebase';
import { prisma } from '../utils/prisma';

export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Missing or invalid Authorization header' });
    }

    const token = authHeader.split(' ')[1] as string;

    // Verify Firebase ID token. uid == supabaseUid column in the User table.
    let firebaseUid: string;
    let tokenEmail: string | undefined;
    try {
      const decoded = await firebaseAdmin.auth().verifyIdToken(token);
      firebaseUid   = decoded.uid;
      tokenEmail    = decoded.email;
    } catch (err) {
      console.error('[AUTH] Firebase token verification failed:', err instanceof Error ? err.message : err);
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    // Look up user by Firebase UID (stored in supabaseUid column)
    let user = await prisma.user.findUnique({
      where:  { supabaseUid: firebaseUid },
      select: { id: true, role: true, isActive: true, supabaseUid: true },
    });

    // Auto-provision on first backend call for users who signed up via Firebase
    if (!user && tokenEmail) {
      user = await prisma.user.create({
        data: {
          supabaseUid: firebaseUid,
          email:       tokenEmail.trim().toLowerCase(),
          role:        'doctor',
          isActive:    true,
        },
        select: { id: true, role: true, isActive: true, supabaseUid: true },
      });
      console.log(`[AUTH] Auto-provisioned user: ${tokenEmail}`);
    }

    if (!user) {
      return res.status(401).json({ message: 'User not found' });
    }

    if (!user.isActive) {
      return res.status(403).json({ message: 'Account disabled' });
    }

    (req as any).user = {
      userId:      user.id,
      supabaseUid: user.supabaseUid,
      role:        user.role,
    };
    next();
  } catch (error) {
    console.error('[AUTH]', error instanceof Error ? error.message : error);
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};
