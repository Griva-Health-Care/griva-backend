-- Rename supabaseUid → uid on the User table.
-- The column stores a stable UUID for each user; the name "supabaseUid" was a legacy
-- artifact from an earlier Supabase integration that has since been removed.
ALTER TABLE node_app."User" RENAME COLUMN "supabaseUid" TO "uid";
