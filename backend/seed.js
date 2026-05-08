// One-shot seed script — creates admin@gmail.com / admin123 for local testing.
// Run once from the backend directory:
//   node seed.js
//
// Safe to re-run — skips creation if the user already exists.

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL        = process.env.SUPABASE_URL;
const SUPABASE_SECRET_KEY = process.env.SUPABASE_SECRET_KEY;

if (!SUPABASE_URL || !SUPABASE_SECRET_KEY) {
  console.error('[SEED] SUPABASE_URL or SUPABASE_SECRET_KEY not set in .env');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SECRET_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const SEED_EMAIL    = 'admin@gmail.com';
const SEED_PASSWORD = 'admin123';
const SEED_NAME     = 'Griva Admin';

async function seed() {
  console.log('[SEED] Starting...');

  // ── 1. Create Supabase Auth user ──────────────────────────────────────────
  let supabaseUid;

  const { data: existing } = await supabase.auth.admin.listUsers();
  const existingUser = existing?.users?.find(u => u.email === SEED_EMAIL);

  if (existingUser) {
    console.log(`[SEED] Auth user already exists — uid: ${existingUser.id}`);
    supabaseUid = existingUser.id;
  } else {
    const { data, error } = await supabase.auth.admin.createUser({
      email:             SEED_EMAIL,
      password:          SEED_PASSWORD,
      email_confirm:     true,
      user_metadata:     { full_name: SEED_NAME },
    });
    if (error) {
      console.error('[SEED] Failed to create auth user:', error.message);
      process.exit(1);
    }
    supabaseUid = data.user.id;
    console.log(`[SEED] Auth user created — uid: ${supabaseUid}`);
  }

  // ── 2. Upsert doctor_profiles (public schema) ─────────────────────────────
  const { error: profileError } = await supabase
    .from('doctor_profiles')
    .upsert({
      uid:           supabaseUid,
      fullName:      SEED_NAME,
      phone:         '',
      hospital:      'Griva HQ',
      accountType:   'admin',
      licenseNumber: 'ADMIN-001',
      city:          '',
      state:         '',
    }, { onConflict: 'uid' });

  if (profileError) {
    console.error('[SEED] doctor_profiles upsert failed:', profileError.message);
  } else {
    console.log('[SEED] doctor_profiles upserted');
  }

  // ── 3. Upsert doctor_config (public schema) ───────────────────────────────
  const { error: configError } = await supabase
    .from('doctor_config')
    .upsert({
      uid:              supabaseUid,
      cloudSyncEnabled: true,
      role:             'admin',
      creditBalance:    999,
    }, { onConflict: 'uid' });

  if (configError) {
    console.error('[SEED] doctor_config upsert failed:', configError.message);
  } else {
    console.log('[SEED] doctor_config upserted');
  }

  // ── 4. Upsert node_app.User via raw SQL ───────────────────────────────────
  const { error: userError } = await supabase.rpc('seed_admin_user', {
    p_supabase_uid: supabaseUid,
    p_email:        SEED_EMAIL,
    p_full_name:    SEED_NAME,
  });

  // If the RPC doesn't exist yet, fall back to a direct insert attempt.
  if (userError) {
    console.warn('[SEED] RPC seed_admin_user not found — inserting directly into node_app.users');
    const { error: rawError } = await supabase
      .schema('node_app')
      .from('User')
      .upsert({
        supabase_uid: supabaseUid,
        email:        SEED_EMAIL,
        full_name:    SEED_NAME,
        role:         'admin',
        is_active:    true,
        is_available: true,
      }, { onConflict: 'supabase_uid' });

    if (rawError) {
      console.warn('[SEED] Direct insert also failed:', rawError.message);
      console.warn('[SEED] Run this SQL manually in Supabase SQL editor:');
      console.warn(`
INSERT INTO node_app."User" ("supabaseUid", email, "fullName", role, "isActive", "isAvailable")
VALUES ('${supabaseUid}', '${SEED_EMAIL}', '${SEED_NAME}', 'admin', true, true)
ON CONFLICT ("supabaseUid") DO UPDATE SET role = 'admin';
      `);
    } else {
      console.log('[SEED] node_app.User upserted');
    }
  } else {
    console.log('[SEED] node_app.User upserted via RPC');
  }

  console.log('\n[SEED] Done.');
  console.log(`  Email   : ${SEED_EMAIL}`);
  console.log(`  Password: ${SEED_PASSWORD}`);
  console.log(`  Role    : admin`);
  console.log(`  UID     : ${supabaseUid}`);
}

seed().catch(e => {
  console.error('[SEED] Unexpected error:', e);
  process.exit(1);
});
