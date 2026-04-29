import { Request, Response, NextFunction } from 'express';
export declare const requireRole: (...roles: string[]) => (req: Request, res: Response, next: NextFunction) => Response<any, Record<string, any>>;
