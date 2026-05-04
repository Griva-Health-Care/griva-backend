import { createClient } from '@supabase/supabase-js';
import { createRemoteJWKSet, jwtVerify, JWTPayload } from 'jose';

const supabaseUrl = process.env.SUPABASE_URL ?? '';
const serviceKey  = process.env.SUPABASE_SECRET_KEY ?? '';

if (!supabaseUrl || !serviceKey) {
  console.warn('[SUPABASE] SUPABASE_URL or SUPABASE_SECRET_KEY not set');
}

export const supabaseAdmin = createClient(supabaseUrl, serviceKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

// JWKS endpoint rotates keys automatically — no static secret needed.
const JWKS = createRemoteJWKSet(
  new URL(`${supabaseUrl}/auth/v1/.well-known/jwks.json`)
);

export interface SupabaseToken {
  sub:            string;   // Supabase user UUID
  email:          string;
  user_metadata?: Record<string, unknown>;
}

export const verifySupabaseToken = async (token: string): Promise<SupabaseToken> => {
  const { payload } = await jwtVerify(token, JWKS) as { payload: JWTPayload & Record<string, unknown> };
  return {
    sub:           payload['sub']           as string,
    email:         (payload['email']        as string | undefined) ?? '',
    user_metadata: payload['user_metadata'] as Record<string, unknown> | undefined,
  };
};
