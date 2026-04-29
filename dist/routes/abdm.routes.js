"use strict";
/**
 * ABDM Routes  —  /abdm/*
 * ─────────────────────────────────────────────────────────────────────────────
 * All endpoints return 501 until the ABDM service stubs are implemented.
 * A future developer only needs to:
 *   1. Fill the TODO blocks in abdm.service.ts
 *   2. Remove the AbdmNotImplementedError catches below (or let them propagate)
 *
 * Route map:
 *   POST /abdm/abha/otp          — send Aadhaar OTP (start ABHA creation)
 *   POST /abdm/abha/verify       — verify OTP
 *   POST /abdm/abha/create       — create ABHA account
 *   GET  /abdm/abha/profile      — fetch logged-in user's ABHA profile
 *   POST /abdm/consent/request   — request consent to access patient PHR
 *   POST /abdm/webhook/consent   — receive ABDM consent outcome (no auth)
 *   POST /abdm/webhook/hiu-notify — receive health record notifications (no auth)
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const abdm_service_1 = require("../services/abdm.service");
const prisma_1 = require("../utils/prisma");
const router = (0, express_1.Router)();
// ── Helper ────────────────────────────────────────────────────────────────────
function handleAbdmError(res, err) {
    if (err instanceof abdm_service_1.AbdmNotImplementedError) {
        return res.status(501).json({
            message: 'ABDM integration not yet active',
            detail: err.message,
            docs: 'See backend/src/services/abdm.service.ts for implementation steps.',
        });
    }
    console.error('[ABDM]', err instanceof Error ? err.message : err);
    return res.status(500).json({ message: 'ABDM request failed' });
}
// ── ABHA creation flow ────────────────────────────────────────────────────────
/**
 * POST /abdm/abha/otp
 * Body: { aadhaar: string }
 * Sends OTP to the mobile number linked to the Aadhaar card.
 * Returns: { txnId }  — save this on the client to continue the flow.
 */
router.post('/abha/otp', auth_middleware_1.authMiddleware, async (req, res) => {
    const { aadhaar } = req.body;
    if (!aadhaar)
        return res.status(400).json({ message: 'aadhaar is required' });
    try {
        const result = await (0, abdm_service_1.sendAadhaarOtp)(aadhaar);
        res.json(result);
    }
    catch (err) {
        handleAbdmError(res, err);
    }
});
/**
 * POST /abdm/abha/verify
 * Body: { txnId: string, otp: string }
 * Verifies the OTP. Returns: { txnId, mobileNumber }
 */
router.post('/abha/verify', auth_middleware_1.authMiddleware, async (req, res) => {
    const { txnId, otp } = req.body;
    if (!txnId || !otp)
        return res.status(400).json({ message: 'txnId and otp are required' });
    try {
        const result = await (0, abdm_service_1.verifyAadhaarOtp)(txnId, otp);
        res.json(result);
    }
    catch (err) {
        handleAbdmError(res, err);
    }
});
/**
 * POST /abdm/abha/create
 * Body: { txnId, firstName, lastName?, email? }
 * Creates the ABHA account and stores the user's ABDM token in AbdmSession.
 * Also updates User.abhaNumber on success.
 */
router.post('/abha/create', auth_middleware_1.authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { txnId, firstName, lastName, email } = req.body;
    if (!txnId || !firstName) {
        return res.status(400).json({ message: 'txnId and firstName are required' });
    }
    try {
        const result = await (0, abdm_service_1.createAbha)(txnId, { firstName, lastName, email });
        // Persist ABHA number on the user record
        await prisma_1.prisma.user.update({
            where: { id: userId },
            data: { abhaNumber: result.healthIdNumber, abdmLinked: true },
        });
        // Store ABDM user token for future profile / consent calls (10-minute TTL)
        await (0, abdm_service_1.saveAbdmSession)(userId, result.token, null, 600);
        res.json({
            healthId: result.healthId,
            healthIdNumber: result.healthIdNumber,
        });
    }
    catch (err) {
        handleAbdmError(res, err);
    }
});
/**
 * GET /abdm/abha/profile
 * Returns the ABHA profile for the signed-in user using their stored ABDM token.
 */
router.get('/abha/profile', auth_middleware_1.authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const session = await (0, abdm_service_1.getAbdmSession)(userId);
    if (!session) {
        return res.status(404).json({
            message: 'No active ABDM session. Complete ABHA creation or login first.',
        });
    }
    try {
        const profile = await (0, abdm_service_1.getPatientProfile)(session.accessToken);
        res.json({ profile });
    }
    catch (err) {
        handleAbdmError(res, err);
    }
});
// ── Consent ───────────────────────────────────────────────────────────────────
/**
 * POST /abdm/consent/request
 * Body: { patientAbhaAddress, fromDate, toDate, hiTypes? }
 * Initiates an async consent request. ABDM will call back on /abdm/webhook/consent.
 * Returns: { consentRequestId }
 *
 * hiTypes defaults to: DiagnosticReport, Prescription, ImmunizationRecord
 */
router.post('/consent/request', auth_middleware_1.authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { patientAbhaAddress, fromDate, toDate, hiTypes = ['DiagnosticReport', 'Prescription', 'ImmunizationRecord'], } = req.body;
    if (!patientAbhaAddress || !fromDate || !toDate) {
        return res.status(400).json({ message: 'patientAbhaAddress, fromDate, and toDate are required' });
    }
    // Fetch the requester's name for the consent request display
    const user = await prisma_1.prisma.user.findUnique({
        where: { id: userId },
        select: { fullName: true },
    });
    try {
        const result = await (0, abdm_service_1.requestConsent)({
            patientAbhaAddress,
            requesterName: user?.fullName ?? 'Griva Health',
            fromDate,
            toDate,
            hiTypes,
        });
        res.json(result);
    }
    catch (err) {
        handleAbdmError(res, err);
    }
});
// ── Webhooks (no auth — called by ABDM gateway) ───────────────────────────────
/**
 * POST /abdm/webhook/consent
 * ABDM calls this URL when the patient approves or denies a consent request.
 *
 * TODO: Validate the X-HIP-ID / X-CM-ID headers and the JWT signature
 *       that ABDM includes for webhook authenticity.
 *       Then store the consent artefact and trigger health record fetch.
 *
 * Register this URL in ABDM sandbox:
 *   https://dev.abdm.gov.in  →  Application Settings →  Callback URL
 *   Value: https://your-domain.com/abdm/webhook/consent
 */
router.post('/webhook/consent', async (req, res) => {
    try {
        const payload = req.body;
        console.log('[ABDM WEBHOOK] consent:', JSON.stringify(payload));
        // TODO: parse payload, extract consentArtefact, store in DB, kick off
        //       fetchHealthRecords(consentArtefactId) if status === 'GRANTED'
        res.status(202).json({ status: 'acknowledged' });
    }
    catch (err) {
        console.error('[ABDM WEBHOOK]', err);
        res.status(500).json({ message: 'Webhook processing failed' });
    }
});
/**
 * POST /abdm/webhook/hiu-notify
 * ABDM notifies this endpoint when health records are ready to be fetched
 * after a consent artefact is approved.
 *
 * TODO: extract the health record transfer details and call
 *       fetchHealthRecords() then store the FHIR bundle.
 */
router.post('/webhook/hiu-notify', async (req, res) => {
    try {
        const payload = req.body;
        console.log('[ABDM WEBHOOK] hiu-notify:', JSON.stringify(payload));
        // TODO: verify, fetch records, store FHIR bundle against the TeleCase
        res.status(202).json({ status: 'acknowledged' });
    }
    catch (err) {
        console.error('[ABDM WEBHOOK]', err);
        res.status(500).json({ message: 'Webhook processing failed' });
    }
});
exports.default = router;
//# sourceMappingURL=abdm.routes.js.map