// One-shot seed script — creates a superadmin user for local testing / first deployment.
// Run once from the backend directory:
//   node seed.js
//
// Requires: FIREBASE_PROJECT_ID and either FIREBASE_CONFIG (JSON string)
//           or GOOGLE_APPLICATION_CREDENTIALS (path to service account JSON).
// Safe to re-run — skips creation if the user already exists.

require('dotenv').config();

const admin  = require('firebase-admin');
const { PrismaClient } = require('@prisma/client');

// ── Firebase Admin initialisation ─────────────────────────────────────────────
const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) {
  console.error('[SEED] FIREBASE_PROJECT_ID not set in .env');
  process.exit(1);
}

let credential;
const configJson = process.env.FIREBASE_CONFIG;
if (configJson && configJson.trim().startsWith('{')) {
  credential = admin.credential.cert(JSON.parse(configJson));
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  credential = admin.credential.applicationDefault();
} else {
  console.error('[SEED] Set FIREBASE_CONFIG (JSON string) or GOOGLE_APPLICATION_CREDENTIALS (file path)');
  process.exit(1);
}

admin.initializeApp({ credential, projectId });

// ── Prisma ────────────────────────────────────────────────────────────────────
const prisma = new PrismaClient();

const SEED_EMAIL = 'admin@grivahealth.com';
const SEED_NAME  = 'Griva Admin';

async function seed() {
  console.log('[SEED] Starting...');

  // ── 1. Get or create Firebase Auth user ────────────────────────────────────
  let firebaseUid;

  try {
    const existing = await admin.auth().getUserByEmail(SEED_EMAIL);
    console.log(`[SEED] Firebase user already exists — uid: ${existing.uid}`);
    firebaseUid = existing.uid;
  } catch (err) {
    if (err.code !== 'auth/user-not-found') {
      console.error('[SEED] Firebase lookup failed:', err.message);
      process.exit(1);
    }

    // User does not exist — create without a password (admins log in via Firebase console or link)
    const created = await admin.auth().createUser({
      email:         SEED_EMAIL,
      displayName:   SEED_NAME,
      emailVerified: true,
    });
    firebaseUid = created.uid;
    console.log(`[SEED] Firebase user created — uid: ${firebaseUid}`);
  }

  // ── 2. Upsert node_app.User ────────────────────────────────────────────────
  const user = await prisma.user.upsert({
    where:  { firebaseUid },
    update: { role: 'superadmin', isActive: true, fullName: SEED_NAME },
    create: {
      firebaseUid,
      email:    SEED_EMAIL,
      fullName: SEED_NAME,
      role:     'superadmin',
      isActive: true,
    },
  });
  console.log(`[SEED] node_app.User upserted — id: ${user.id}`);

  // ── 3. Upsert public.doctor_profiles ──────────────────────────────────────
  await prisma.doctorProfile.upsert({
    where:  { firebaseUid },
    update: { fullName: SEED_NAME, hospital: 'Griva HQ', role: 'doctor' },
    create: {
      firebaseUid,
      fullName:      SEED_NAME,
      hospital:      'Griva HQ',
      role:          'doctor',
      licenseNumber: 'ADMIN-001',
    },
  });
  console.log('[SEED] doctor_profiles upserted');

  // ── 4. Upsert public.doctor_config ────────────────────────────────────────
  await prisma.doctorConfig.upsert({
    where:  { firebaseUid },
    update: { creditBalance: 999, cloudSyncEnabled: true, role: 'admin' },
    create: {
      firebaseUid,
      creditBalance:    999,
      cloudSyncEnabled: true,
      role:             'admin',
    },
  });
  console.log('[SEED] doctor_config upserted');

  console.log('\n[SEED] Done.');
  console.log(`  Email      : ${SEED_EMAIL}`);
  console.log(`  Role       : superadmin`);
  console.log(`  FirebaseUID: ${firebaseUid}`);
  console.log('\n  NOTE: Set a password via Firebase Console or use a password-reset link.');
}

seed()
  .catch(e => {
    console.error('[SEED] Unexpected error:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
