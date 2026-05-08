-- Add extended profile fields to User table so admin dashboard and /users/me
-- can return the full profile without a join to doctor_profiles.
-- Note: role already exists on User — accountType was dropped in favour of role.
ALTER TABLE "node_app"."User"
  ADD COLUMN IF NOT EXISTS "phone"              TEXT,
  ADD COLUMN IF NOT EXISTS "licenseNumber"      TEXT,
  ADD COLUMN IF NOT EXISTS "city"               TEXT,
  ADD COLUMN IF NOT EXISTS "state"              TEXT,
  ADD COLUMN IF NOT EXISTS "colposcopeSerialNo" TEXT;
