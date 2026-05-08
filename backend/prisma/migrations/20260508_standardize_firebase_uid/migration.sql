-- Standardize all UID columns to use the firebaseUid name consistently.
-- Also drops passwordHash (local bcrypt auth removed — Firebase Auth only).

-- ── node_app.User ─────────────────────────────────────────────────────────────
ALTER TABLE node_app."User" RENAME COLUMN "uid" TO "firebaseUid";
ALTER TABLE node_app."User" DROP COLUMN IF EXISTS "passwordHash";

-- ── node_app.CreditTransaction ────────────────────────────────────────────────
ALTER TABLE node_app."CreditTransaction" RENAME COLUMN "doctorUid" TO "doctorFirebaseUid";

-- ── node_app.TeleCase ─────────────────────────────────────────────────────────
ALTER TABLE node_app."TeleCase" RENAME COLUMN "assignedUid" TO "assignedFirebaseUid";

-- ── public.doctor_profiles ───────────────────────────────────────────────────
ALTER TABLE public.doctor_profiles RENAME COLUMN "uid" TO "firebaseUid";

-- ── public.doctor_config ─────────────────────────────────────────────────────
ALTER TABLE public.doctor_config RENAME COLUMN "uid" TO "firebaseUid";
