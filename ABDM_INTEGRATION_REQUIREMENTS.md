# Griva PI → ABDM Backend Integration Requirements

**Version:** 1.1  
**Date:** 2026-04-28  
**Owner:** Mobile App Team  
**Audience:** Backend Team (ABDM HIP)

---

## 1. Integration Objective
Enable the Griva PI mobile app to use the ABDM backend for:
- HPR OAuth login and JWT issuance
- Tenant selection and tenant-scoped operations
- Patient registration and lookup
- ABHA linking
- Uploading medical records (images, notes, reports)
- Consent status visibility
- Secure multi-tenant access

---

## 2. Environment & Connectivity

**Required from Backend**
- Base URLs for dev/staging/prod
- HTTPS support (mandatory for production)
- Expected headers and auth schemes
- Rate limits and file size limits

**App configuration**
- ABDM base URL is set at build time via `--dart-define=ABDM_HOST=<url>` (default: `https://api.yourabdm.com`)
- HTTPS only in production
- `X-Tenant-ID` header attached to every request after tenant selection (enforced by `AbdmService` Dio interceptor)

---

## 3. Auth & Session Flow (HPR OAuth + JWT)

### 3.1 Auth Start
**Backend endpoint**
- `GET /api/auth/hpr/start`

**App behavior**
- Open returned URL in `hpr_login_screen.dart` (WebView)
- Complete HPR login and redirect to app callback URI

### 3.2 Auth Callback
**Backend endpoint**
- `GET /api/auth/hpr/callback`

**Backend response**
```json
{
  "access_token": "…",
  "refresh_token": "…",
  "expires_in": 3600,
  "user": {
    "id": "...",
    "hpr_id": "...",
    "name": "..."
  }
}
```

**App behavior**
- Store `abdm_access_token` and `abdm_refresh_token` in `flutter_secure_storage`
- Fetch tenant memberships via `/api/auth/hpr/memberships`
- If more than one membership → show tenant picker
- Store `abdm_tenant_id` for all future API calls

### 3.3 Tenant Memberships
**Backend endpoint**
- `GET /api/auth/hpr/memberships`

**Backend response** (array of memberships)
```json
[
  {
    "membership_id": "...",
    "tenant_id": "t1",
    "tenant_name": "Hospital A",
    "role": "doctor",
    "status": "active"
  }
]
```

**App behavior (`AbdmMembership` model in `abdm_auth_service.dart`)**
- Deserializes `membership_id`, `tenant_id`, `tenant_name`, `role`, `status`
- Active membership stored as `abdm_tenant_id` in secure storage

### 3.4 Token Refresh
**Backend endpoint**
- `POST /api/auth/refresh`
- Payload: `{ "refresh_token": "..." }`

**App behavior**
- `AbdmService` Dio interceptor auto-retries the failed request on 401 after refresh
- Force logout on refresh failure

---

## 4. Tenant Selection

**App requirement**
- Show tenant picker when multiple memberships are returned
- Store active tenant as `abdm_tenant_id`
- Send `X-Tenant-ID: <tenant_id>` in all API calls (injected by `AbdmService` interceptor)

**Backend requirement**
- Reject requests with missing or mismatched tenant header
- Enforce strict tenant isolation

---

## 5. Patient Registration & Retrieval

### 5.1 Create Patient
**Endpoint:** `POST /patients`

```json
{
  "patient_id": "P001",
  "full_name": "Alice Smith",
  "dob": "1990-05-10",
  "mobile": "9876543210",
  "email": "alice@example.com",
  "address": "Bangalore",
  "doctor_name": "Dr. X"
}
```

### 5.2 Get Patients
- `GET /patients`
- `GET /patients/{id}`

**Backend must return:** `id`, `patient_id`, `tenant_id`, full demographic fields, ABHA link status (optional)

---

## 6. ABHA Linking
**Endpoint:** `POST /patients/{id}/abha-link`

```json
{
  "abha_address": "abcd@abdm",
  "abha_number": "12-3456-7890-1234"
}
```

**Backend:** Encrypt and store ABHA; return confirmation and verification status.

**App:** Never store ABHA locally. Display masked ABHA after linking only.

---

## 7. Medical Records Upload
**Endpoint:** `POST /medical-records`  
**Content-Type:** `multipart/form-data`

| Field | Required | Notes |
|---|---|---|
| `patient_id` | yes | |
| `procedure_type` | yes | colposcopy / vulvoscopy / vaginoscopy / etc. |
| `diagnosis_notes` | no | |
| `images[]` | no | JPEG or PNG |
| `videos[]` | no | MP4 |
| `metadata` | no | JSON (see below) |

**Metadata example**
```json
{
  "capture_device": "Griva Colposcope",
  "timestamp": "2026-04-28T10:00:00Z",
  "settings": { "led_stage": 3, "green_filter": 2, "zoom": 1.8 }
}
```

---

## 8. Consent Status Lookup
**Endpoint:** `GET /consents?patient_id=...`

```json
{
  "patient_id": "…",
  "status": "GRANTED",
  "valid_from": "...",
  "valid_to": "...",
  "hiu_id": "...",
  "hip_id": "..."
}
```

---

## 9. Error Handling Contract

**Backend must provide standard error JSON:**
```json
{
  "error_code": "TENANT_MISMATCH",
  "message": "You do not have access to this tenant."
}
```

**App handles (`AbdmService` Dio interceptor):**
| Status | Action |
|---|---|
| 401 | Refresh token; retry request once; logout on failure |
| 403 | Tenant mismatch — show error |
| 422 | Validation errors — surface to user |
| 5xx | Retry with backoff |

---

## 10. Security Requirements

**App (`AbdmAuthService` + `AbdmService`)**
- Tokens stored in `flutter_secure_storage` (Android Keystore-backed)
- ABHA / PII never logged in debug output
- HTTPS only for production `ABDM_HOST`
- `X-Tenant-ID` injected on every request by Dio interceptor
- Token refresh happens transparently before session expiry

**Backend**
- Reject requests without `X-Tenant-ID` header
- Enforce tenant isolation strictly
- Encrypt ABHA and HPR profiles at rest
- Audit all access

---

## 11. Required Shared Artifacts

**App → Backend**
- Android package name + signing SHA-256 (for OAuth allowlist)
- Callback URL scheme (for HPR OAuth WebView redirect)
- Final patient field schema
- Medical record payload sample
- Max file sizes (images / videos)

**Backend → App**
- API base URLs (dev / staging / prod) — set as `ABDM_HOST` at build time
- OAuth start + callback response schemas
- Memberships endpoint response schema
- Complete error code list
- Consent response schema

---

## 12. Implementation Status

| Feature | App Status | Notes |
|---|---|---|
| HPR OAuth WebView login | Implemented | `hpr_login_screen.dart` |
| Token storage (secure) | Implemented | `AbdmAuthService` |
| Token refresh on 401 | Implemented | `AbdmService` Dio interceptor |
| Tenant selection | Implemented | `AbdmMembership` model + picker |
| `X-Tenant-ID` header | Implemented | Auto-injected by interceptor |
| Patient create/list/view | In progress | |
| ABHA linking | Pending | |
| Medical record upload | Pending | |
| Consent status display | Pending | |
