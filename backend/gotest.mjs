import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://kivcxcdcvypnazpbuhey.supabase.co';
const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpdmN4Y2RjdnlwbmF6cGJ1aGV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NzA0OTcsImV4cCI6MjA5MzQ0NjQ5N30.vS43Nig7AZfTTEHsk8C9hLeMCULOQxSe89egvq-VTSs';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpdmN4Y2RjdnlwbmF6cGJ1aGV5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3Nzg3MDQ5NywiZXhwIjoyMDkzNDQ2NDk3fQ.EPQT4n4BzC1JdCoFDYUfDLFSd90vNjeos5DRj5b542s';
const BACKEND = 'http://localhost:5000';

const supabase = createClient(SUPABASE_URL, ANON_KEY);
const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_KEY, {auth:{autoRefreshToken:false,persistSession:false}});

let passed = 0, failed = 0;

function log(name, ok, detail = '') {
  const mark = ok ? 'PASS ✓' : 'FAIL ✗';
  console.log(`  ${name}: ${mark}${detail ? ' — ' + detail : ''}`);
  ok ? passed++ : failed++;
}

// Sign in test user (must exist in Supabase Auth)
const EMAIL = 'test-gotest@griva.dev';
const PASSWORD = 'GoTest@1234!';

console.log('\n=== Go/No-Go Test Suite ===\n');

// Ensure test user exists
let { data: signUpData } = await supabase.auth.signUp({ email: EMAIL, password: PASSWORD });
await new Promise(r => setTimeout(r, 500));

let { data: signInData, error: signInErr } = await supabase.auth.signInWithPassword({ email: EMAIL, password: PASSWORD });
if (signInErr || !signInData?.session) {
  console.error('Cannot sign in test user:', signInErr?.message);
  process.exit(1);
}
const token = signInData.session.access_token;
console.log('Signed in as', EMAIL);

// --- Test 1: Auth → Backend JWT ---
console.log('\n--- Test 1: Auth JWT (GET /users/me) ---');
const r1 = await fetch(`${BACKEND}/users/me`, {
  headers: { Authorization: `Bearer ${token}` },
});
log('GET /users/me', r1.status === 200, `status=${r1.status}`);
if (r1.status === 200) {
  const body = await r1.json();
  log('  has user.id', !!body.user?.id);
} else {
  const txt = await r1.text();
  console.log('    body:', txt.slice(0, 200));
}

// --- Test 2: Profile CRUD ---
console.log('\n--- Test 2: Profile CRUD ---');
const uid = signInData.session.user.id;

const { error: upsertErr } = await supabase.from('doctor_profiles').upsert({
  uid,
  fullName: 'Test Doctor',
  phone: '9876543210',
  hospital: 'Test Hospital',
  accountType: 'doctor',
  licenseNumber: 'LIC123',
  city: 'Mumbai',
  state: 'MH',
  colposcopeSerialNo: 'SN001',
  updatedAt: new Date().toISOString(),
}, { onConflict: 'uid' });
log('Profile upsert', !upsertErr, upsertErr?.message);

const { data: profileData, error: fetchErr } = await supabase.from('doctor_profiles')
  .select('*').eq('uid', uid).maybeSingle();
log('Profile fetch', !fetchErr && !!profileData, fetchErr?.message);

// RLS isolation test — create user2 via admin to avoid email rate limits
const supabase2 = createClient(SUPABASE_URL, ANON_KEY);
const EMAIL2 = 'test-gotest2@griva.dev';
// Delete user2 first in case it already exists (ignore errors)
const { data: existingUsers } = await supabaseAdmin.auth.admin.listUsers();
const existing2 = existingUsers?.users?.find(u => u.email === EMAIL2);
if (!existing2) {
  await supabaseAdmin.auth.admin.createUser({ email: EMAIL2, password: 'GoTest@1234!', email_confirm: true });
}
await new Promise(r => setTimeout(r, 300));
const { data: si2 } = await supabase2.auth.signInWithPassword({ email: EMAIL2, password: 'GoTest@1234!' });
if (si2?.session) {
  const { data: crossData } = await supabase2.from('doctor_profiles').select('*').eq('uid', uid).maybeSingle();
  log('RLS isolation (user2 cannot read user1 profile)', crossData === null, crossData ? 'leaked!' : 'correct');
} else {
  log('RLS isolation', false, 'could not create user2');
}

// --- Test 4: Storage ---
console.log('\n--- Test 4: Storage Upload ---');
const blob = new Blob(['fake-image-data'], { type: 'image/png' });
const { data: storageData, error: storageErr } = await supabase.storage
  .from('tele-cases')
  .upload(`test/${uid}/test.png`, blob, { upsert: true });
log('Storage upload', !storageErr, storageErr?.message ?? storageData?.path);

// --- Test 5: Restart resilience ---
console.log('\n--- Test 5: Restart resilience (re-ping after DB connected) ---');
const r5 = await fetch(`${BACKEND}/users/me`, {
  headers: { Authorization: `Bearer ${token}` },
});
log('Re-ping /users/me', r5.status === 200, `status=${r5.status}`);

console.log(`\n=== Results: ${passed} passed, ${failed} failed ===\n`);
process.exit(failed > 0 ? 1 : 0);
