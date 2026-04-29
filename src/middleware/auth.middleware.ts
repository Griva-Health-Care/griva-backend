import { Request, Response, NextFunction } from 'express';
import { verifyFirebaseToken } from '../utils/firebase';
import { prisma } from '../utils/prisma';

export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Missing or invalid Authorization header' });
    }

    const token = authHeader.split(' ')[1] as string;
    const decoded = await verifyFirebaseToken(token);

    let user = await prisma.user.findUnique({
      where: { firebaseUid: decoded.uid },
      select: { id: true, role: true, isActive: true },
    });

    // Auto-register on first login so Firebase users don't need a separate
    // registration call before they can hit any authenticated endpoint.
    if (!user) {
      user = await prisma.user.create({
        data: {
          firebaseUid: decoded.uid,
          email: decoded.email ?? `${decoded.uid}@unknown.local`,
          fullName: decoded.name ?? null,
          role: 'doctor',
          isActive: true,
        },
        select: { id: true, role: true, isActive: true },
      });
    }

    if (!user.isActive) {
      return res.status(403).json({ message: 'Account disabled' });
    }

    (req as any).user = { userId: user.id, firebaseUid: decoded.uid, role: user.role };
    next();
  } catch (error) {
    console.error('[AUTH]', error instanceof Error ? error.message : error);
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};
