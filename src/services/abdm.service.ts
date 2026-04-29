/**
 * ABDM (Ayushman Bharat Digital Mission) Service
 * ─────────────────────────────────────────────────────────────────────────────
 * This file is the single integration point for all ABDM APIs.
 * It is intentionally left as stubs so a future developer can implement
 * each method by reading the inline comments and filling the TODO blocks.
 *
 * Integration checklist (do these before uncommenting real calls):
 *  1. Register on https://sandbox.abdm.gov.in  → get CLIENT_ID + CLIENT_SECRET
 *  2. Set ABDM_CLIENT_ID, ABDM_CLIENT_SECRET, ABDM_BASE_URL in .env
 *  3. Complete sandbox testing, then swap ABDM_BASE_URL for the production URL
 *  4. Store ABDM tokens in the AbdmSession table (see prisma/schema.prisma)
 *
 * ABDM sandbox base URL : https://dev.abdm.gov.in/gateway
 * ABDM production URL   : https://live.abdm.gov.in/gateway
 *
 * Key API groups used by Griva:
 *  - /v0.5/sessions          → get M2M access token
 *  - /v1/registration/aadhaar/generateOtp  → ABHA creation via Aadhaar
 *  - /v1/registration/aadhaar/verifyOtp
 *  - /v1/registration/aadhaar/createHealthId
 *  - /v1/search/existsByHealthId          → check if ABHA exists
 *  - /v0.5/patients/profile               → fetch patient ABHA profile
 *  - /v0.5/consent-requests/init          → request consent for PHR access
 *  - /v0.5/health-information/cm/request  → fetch health records after consent
 *
 * Reference: https://sandbox.abdm.gov.in/swagger/
 */

import { prisma } from '../utils/prisma';

const BASE  = process.env.ABDM_BASE_URL    ?? 'https://dev.abdm.gov.in/gateway';
const CLIENT_ID     = process.env.ABDM_CLIENT_ID     ?? '';
const CLIENT_SECRET = process.env.ABDM_CLIENT_SECRET ?? '';

// ── Internal token cache ──────────────────────────────────────────────────────

interface M2MToken { accessToken: string; expiresAt: number }
let _m2mCache: M2MToken | null = null;

/**
 * Fetch (or return cached) Machine-to-Machine access token.
 * ABDM M2M tokens are valid for ~10 minutes.
 *
 * TODO: Uncomment the real fetch call below and remove the stub throw.
 * POST {BASE}/v0.5/sessions  →  { accessToken, tokenType, expiresIn }
 */
export async function getM2MToken(): Promise<string> {
  if (_m2mCache && Date.now() < _m2mCache.expiresAt - 30_000) {
    return _m2mCache.accessToken;
  }

  if (!CLIENT_ID || !CLIENT_SECRET) {
    throw new Error(
      'ABDM credentials not configured. Set ABDM_CLIENT_ID and ABDM_CLIENT_SECRET in .env'
    );
  }

  // TODO: replace stub with real call ─────────────────────────────────────────
  // const res = await fetch(`${BASE}/v0.5/sessions`, {
  //   method : 'POST',
  //   headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
  //   body   : JSON.stringify({ clientId: CLIENT_ID, clientSecret: CLIENT_SECRET }),
  // });
  // if (!res.ok) throw new Error(`ABDM session error: ${res.status}`);
  // const data = await res.json();
  // _m2mCache = { accessToken: data.accessToken, expiresAt: Date.now() + data.expiresIn * 1000 };
  // return _m2mCache.accessToken;
  // ────────────────────────────────────────────────────────────────────────────

  throw new AbdmNotImplementedError('getM2MToken');
}

// ── ABHA creation (Aadhaar OTP flow) ─────────────────────────────────────────

/**
 * Step 1 — Send OTP to the Aadhaar-linked mobile number.
 * POST {BASE}/v1/registration/aadhaar/generateOtp
 * Body: { aadhaar: string }  →  { txnId: string }
 *
 * TODO: Call with the encrypted Aadhaar number (RSA-OAEP, ABDM public key).
 *       Store txnId in session/DB to continue the flow.
 */
export async function sendAadhaarOtp(aadhaar: string): Promise<{ txnId: string }> {
  // const token = await getM2MToken();
  // const res = await fetch(`${BASE}/v1/registration/aadhaar/generateOtp`, {
  //   method : 'POST',
  //   headers: abdmHeaders(token),
  //   body   : JSON.stringify({ aadhaar: encryptWithAbdmKey(aadhaar) }),
  // });
  // const data = await checkResponse(res);
  // return { txnId: data.txnId };
  throw new AbdmNotImplementedError('sendAadhaarOtp');
}

/**
 * Step 2 — Verify OTP.
 * POST {BASE}/v1/registration/aadhaar/verifyOtp
 * Body: { txnId, otp }  →  { txnId, mobileNumber }
 */
export async function verifyAadhaarOtp(
  txnId: string,
  otp: string
): Promise<{ txnId: string; mobileNumber: string }> {
  // const token = await getM2MToken();
  // ...
  throw new AbdmNotImplementedError('verifyAadhaarOtp');
}

/**
 * Step 3 — Create ABHA (Health ID).
 * POST {BASE}/v1/registration/aadhaar/createHealthId
 * Body: { txnId, firstName, lastName, email, ... }
 * Returns the new ABHA number and ABHA address.
 */
export async function createAbha(
  txnId: string,
  profile: {
    firstName: string;
    lastName?: string;
    email?: string;
    profilePhoto?: string;
  }
): Promise<{ healthId: string; healthIdNumber: string; token: string }> {
  // const token = await getM2MToken();
  // ...
  throw new AbdmNotImplementedError('createAbha');
}

// ── ABHA lookup ───────────────────────────────────────────────────────────────

/**
 * Check whether an ABHA number already exists.
 * GET {BASE}/v1/search/existsByHealthId?healthId={abhaNumber}
 * Returns { status: boolean }
 *
 * Use this before linking so you get a clean error instead of a 4xx.
 */
export async function abhaExists(abhaNumber: string): Promise<boolean> {
  // const token = await getM2MToken();
  // const res = await fetch(
  //   `${BASE}/v1/search/existsByHealthId?healthId=${encodeURIComponent(abhaNumber)}`,
  //   { headers: abdmHeaders(token) }
  // );
  // const data = await checkResponse(res);
  // return data.status === true;
  throw new AbdmNotImplementedError('abhaExists');
}

/**
 * Fetch a patient's ABHA profile using their user-level ABDM token.
 * GET {BASE}/v0.5/patients/profile
 * Authorization: Bearer <userAbdmToken>
 *
 * Note: this uses the *patient* token (obtained after OTP flow), not the M2M token.
 * Store userAbdmToken in AbdmSession.accessToken after ABHA creation/login.
 */
export async function getPatientProfile(
  userAbdmToken: string
): Promise<Record<string, unknown>> {
  // const res = await fetch(`${BASE}/v0.5/patients/profile`, {
  //   headers: abdmHeaders(userAbdmToken),
  // });
  // return checkResponse(res);
  throw new AbdmNotImplementedError('getPatientProfile');
}

// ── Consent & health records ──────────────────────────────────────────────────

/**
 * Initiate a consent request so the patient can approve sharing their health
 * records with Griva.
 *
 * POST {BASE}/v0.5/consent-requests/init
 * This is an *asynchronous* call — ABDM sends the consent outcome to your
 * /abdm/webhook/consent endpoint (see abdm.routes.ts).
 *
 * TODO: implement consent polling or webhook handler before using health records.
 */
export async function requestConsent(params: {
  patientAbhaAddress: string;
  requesterName: string;
  fromDate: string;  // ISO date
  toDate: string;
  hiTypes: string[]; // e.g. ['DiagnosticReport', 'Prescription']
}): Promise<{ consentRequestId: string }> {
  // const token = await getM2MToken();
  // ...
  throw new AbdmNotImplementedError('requestConsent');
}

/**
 * After a consent artefact is received (via webhook), fetch health records.
 * POST {BASE}/v0.5/health-information/cm/request
 */
export async function fetchHealthRecords(
  consentArtefactId: string
): Promise<unknown> {
  // const token = await getM2MToken();
  // ...
  throw new AbdmNotImplementedError('fetchHealthRecords');
}

// ── DB helpers ────────────────────────────────────────────────────────────────

/** Persist a user-level ABDM token after ABHA creation / login. */
export async function saveAbdmSession(
  userId: string,
  accessToken: string,
  refreshToken: string | null,
  expiresInSeconds: number
): Promise<void> {
  const expiresAt = new Date(Date.now() + expiresInSeconds * 1000);
  await prisma.abdmSession.upsert({
    where : { userId },
    create: { userId, accessToken, refreshToken, expiresAt },
    update: { accessToken, refreshToken, expiresAt },
  });
}

/** Return a non-expired ABDM session for a user, or null. */
export async function getAbdmSession(userId: string) {
  const session = await prisma.abdmSession.findUnique({ where: { userId } });
  if (!session || session.expiresAt < new Date()) return null;
  return session;
}

// ── Utilities ─────────────────────────────────────────────────────────────────

function abdmHeaders(token: string): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    Accept        : 'application/json',
    Authorization : `Bearer ${token}`,
    'X-CM-ID'     : 'sbx',  // use 'abdm' in production
  };
}

async function checkResponse(res: Response): Promise<unknown> {
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = (body as any)?.message ?? (body as any)?.details ?? res.statusText;
    throw new Error(`ABDM API error ${res.status}: ${msg}`);
  }
  return body;
}

export class AbdmNotImplementedError extends Error {
  constructor(method: string) {
    super(
      `ABDM integration not yet active: '${method}' is a stub. ` +
      `Set ABDM_CLIENT_ID + ABDM_CLIENT_SECRET in .env and implement the marked TODO blocks in abdm.service.ts.`
    );
    this.name = 'AbdmNotImplementedError';
  }
}
