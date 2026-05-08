-- Add passwordHash column for self-hosted JWT auth (nullable for migrated Supabase users)
ALTER TABLE "node_app"."User" ADD COLUMN IF NOT EXISTS "passwordHash" TEXT;
