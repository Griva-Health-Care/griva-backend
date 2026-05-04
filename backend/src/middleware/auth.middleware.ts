import { Request, Response, NextFunction } from 'express';
import { verifySupabaseToken } from '../utils/supabase';
import { prisma } from '../utils/prisma';

export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Missing or invalid Authorization header' });
    }

    const token   = authHeader.split(' ')[1] as string;
    const decoded = await verifySupabaseToken(token);

    let user = await prisma.user.findUnique({
      where:  { supabaseUid: decoded.sub },
      select: { id: true, role: true, isActive: true },
    });

    // Auto-register on first request so new Supabase users are synced to Postgres.
    if (!user) {
      user = await prisma.user.create({
        data: {
          supabaseUid: decoded.sub,
          email:       decoded.email || `${decoded.sub}@unknown.local`,
          fullName:    (decoded.user_metadata?.['full_name'] as string | undefined) ?? null,
          role:        'doctor',
          isActive:    true,
        },
        select: { id: true, role: true, isActive: true },
      });
    }

    if (!user.isActive) {
      return res.status(403).json({ message: 'Account disabled' });
    }

    (req as any).user = { userId: user.id, supabaseUid: decoded.sub, role: user.role };
    next();
  } catch (error) {
    console.error('[AUTH]', error instanceof Error ? error.message : error);
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};
