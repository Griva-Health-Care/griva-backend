import { SignJWT, jwtVerify, JWTPayload } from 'jose';

const secret = process.env.JWT_SECRET;
if (!secret) {
  console.warn('[JWT] JWT_SECRET is not set — tokens will fail to sign/verify');
}

const encoder = new TextEncoder();
const KEY = encoder.encode(secret ?? 'dev-secret-change-in-production');

// 7 days — long enough for offline-first medical app
const EXPIRY = '7d';

export interface GrivaToken {
  sub:      string;   // supabaseUid — stable user identifier
  userId:   string;   // internal RDS User.id
  email:    string;
  role:     string;
}

export async function signToken(payload: GrivaToken): Promise<string> {
  return new SignJWT({ ...payload })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(EXPIRY)
    .sign(KEY);
}

export async function verifyToken(token: string): Promise<GrivaToken> {
  const { payload } = await jwtVerify(token, KEY) as {
    payload: JWTPayload & GrivaToken;
  };
  return {
    sub:    payload.sub    as string,
    userId: payload.userId as string,
    email:  payload.email  as string,
    role:   payload.role   as string,
  };
}
