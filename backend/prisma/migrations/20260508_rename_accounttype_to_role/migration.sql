-- Rename doctor_profiles.accountType → role so it matches User.role.
-- Values stored were 'doctor' or 'diagnostic_center'; update 'diagnostic_center'
-- to 'diagnostic' so both tables use the same vocabulary.
ALTER TABLE "public"."doctor_profiles"
  RENAME COLUMN "accountType" TO "role";

UPDATE "public"."doctor_profiles"
  SET "role" = 'diagnostic'
  WHERE "role" = 'diagnostic_center';
