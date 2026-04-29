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
declare const router: import("express-serve-static-core").Router;
export default router;
