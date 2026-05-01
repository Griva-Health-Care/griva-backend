import { Request, Response, NextFunction } from 'express';
import { prisma } from '../utils/prisma';

const MUTATION_METHODS = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);

export const auditMiddleware = (req: Request, res: Response, next: NextFunction) => {
  if (!MUTATION_METHODS.has(req.method)) return next();

  res.on('finish', () => {
    const userId = (req as any).user?.userId as string | undefined;
    const action = `${req.method} ${req.path}`;
    const details = res.statusCode >= 400
      ? `status=${res.statusCode}`
      : undefined;

    prisma.auditLog.create({
      data: {
        userId: userId ?? null,
        action,
        details: details ?? null,
        ipAddress: req.ip ?? null,
      },
    }).catch((err: unknown) => {
      console.error('[AUDIT] Failed to write audit log:', err);
    });
  });

  next();
};
