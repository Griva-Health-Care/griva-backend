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
/**
 * Fetch (or return cached) Machine-to-Machine access token.
 * ABDM M2M tokens are valid for ~10 minutes.
 *
 * TODO: Uncomment the real fetch call below and remove the stub throw.
 * POST {BASE}/v0.5/sessions  →  { accessToken, tokenType, expiresIn }
 */
export declare function getM2MToken(): Promise<string>;
/**
 * Step 1 — Send OTP to the Aadhaar-linked mobile number.
 * POST {BASE}/v1/registration/aadhaar/generateOtp
 * Body: { aadhaar: string }  →  { txnId: string }
 *
 * TODO: Call with the encrypted Aadhaar number (RSA-OAEP, ABDM public key).
 *       Store txnId in session/DB to continue the flow.
 */
export declare function sendAadhaarOtp(aadhaar: string): Promise<{
    txnId: string;
}>;
/**
 * Step 2 — Verify OTP.
 * POST {BASE}/v1/registration/aadhaar/verifyOtp
 * Body: { txnId, otp }  →  { txnId, mobileNumber }
 */
export declare function verifyAadhaarOtp(txnId: string, otp: string): Promise<{
    txnId: string;
    mobileNumber: string;
}>;
/**
 * Step 3 — Create ABHA (Health ID).
 * POST {BASE}/v1/registration/aadhaar/createHealthId
 * Body: { txnId, firstName, lastName, email, ... }
 * Returns the new ABHA number and ABHA address.
 */
export declare function createAbha(txnId: string, profile: {
    firstName: string;
    lastName?: string;
    email?: string;
    profilePhoto?: string;
}): Promise<{
    healthId: string;
    healthIdNumber: string;
    token: string;
}>;
/**
 * Check whether an ABHA number already exists.
 * GET {BASE}/v1/search/existsByHealthId?healthId={abhaNumber}
 * Returns { status: boolean }
 *
 * Use this before linking so you get a clean error instead of a 4xx.
 */
export declare function abhaExists(abhaNumber: string): Promise<boolean>;
/**
 * Fetch a patient's ABHA profile using their user-level ABDM token.
 * GET {BASE}/v0.5/patients/profile
 * Authorization: Bearer <userAbdmToken>
 *
 * Note: this uses the *patient* token (obtained after OTP flow), not the M2M token.
 * Store userAbdmToken in AbdmSession.accessToken after ABHA creation/login.
 */
export declare function getPatientProfile(userAbdmToken: string): Promise<Record<string, unknown>>;
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
export declare function requestConsent(params: {
    patientAbhaAddress: string;
    requesterName: string;
    fromDate: string;
    toDate: string;
    hiTypes: string[];
}): Promise<{
    consentRequestId: string;
}>;
/**
 * After a consent artefact is received (via webhook), fetch health records.
 * POST {BASE}/v0.5/health-information/cm/request
 */
export declare function fetchHealthRecords(consentArtefactId: string): Promise<unknown>;
/** Persist a user-level ABDM token after ABHA creation / login. */
export declare function saveAbdmSession(userId: string, accessToken: string, refreshToken: string | null, expiresInSeconds: number): Promise<void>;
/** Return a non-expired ABDM session for a user, or null. */
export declare function getAbdmSession(userId: string): Promise<{
    id: string;
    createdAt: Date;
    updatedAt: Date;
    userId: string;
    accessToken: string;
    refreshToken: string | null;
    expiresAt: Date;
}>;
export declare class AbdmNotImplementedError extends Error {
    constructor(method: string);
}
