# Griva Pi — Architecture Reference

> **Platform**: Flutter (Android-first), Dart  
> **Hardware target**: Raspberry Pi colposcopy controller (GRIVAVISION)  
> **Last updated**: April 2026

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Core Design Principles](#2-core-design-principles)
3. [User Roles](#3-user-roles)
4. [High-Level Architecture](#4-high-level-architecture)
5. [Source Tree](#5-source-tree)
6. [Database Layer](#6-database-layer)
7. [Repository Layer](#7-repository-layer)
8. [Service Layer](#8-service-layer)
9. [Session & Authentication Flow](#9-session--authentication-flow)
10. [Cloud Sync Architecture](#10-cloud-sync-architecture)
11. [Sync Engine](#11-sync-engine)
12. [Role-Based Routing](#12-role-based-routing)
13. [Credit System & Tele-Reporting](#13-credit-system--tele-reporting)
14. [Hardware Integration](#14-hardware-integration)
15. [ABDM Integration](#15-abdm-integration)
16. [Schema Migration History](#16-schema-migration-history)
17. [Provider Portability](#17-provider-portability)
18. [Pending Phases](#18-pending-phases)
19. [Key Constraints & Rules](#19-key-constraints--rules)

---

## 1. Product Overview

Griva Pi is a colposcopy imaging and reporting application that runs on an
Android tablet connected to the GRIVAVISION Raspberry Pi camera controller.
The app captures cervical images and videos, records clinical data, generates
PDF reports, and supports optional cloud sync and remote tele-reporting.

**Local-first philosophy**: the SQLite database is always free and unlimited.
Cloud sync is an optional paid feature. The app is fully functional with zero
internet connectivity — it is designed for use on the GRIVAVISION Wi-Fi
hotspot, which provides no internet access.

---

## 2. Core Design Principles

| Principle | Implementation |
|---|---|
| **Local-first** | Every write hits SQLite first. Cloud push is asynchronous. |
| **Offline-capable** | Auth, patient data, imaging, and report generation all work without internet. |
| **Provider-portable** | All cloud I/O goes through interfaces. Swapping Firebase for Supabase or a custom server changes only the implementation files, not the screens. |
| **Doctor isolation** | Every patient row carries a `doctorId` (Firebase UID). All queries are scoped to the logged-in doctor. |
| **Soft deletes only** | Rows are never hard-deleted. A `deletedAt` timestamp marks deletion. Rows are retained for sync propagation. |
| **UUID-based identity** | Each patient, media file, and tele-case has a stable UUID generated on creation. This is the cross-device key; the SQLite auto-increment `id` never leaves the device. |
| **SWEDE score is immutable at report time** | The SWEDE score recorded when the examination is performed is never modified during the report-generation phase. |

---

## 3. User Roles

Roles are stored in Firestore at `doctor_config/{uid}.role` and read by
`CloudConfigService` on every login. The app works offline with role
defaulting to `solo` when Firestore is unreachable.

### 3.1 Solo / Clinic Doctor (`solo`, `clinic`)

- Uses the standard `HomePage` (patient list, examination, reports).
- Local SQLite storage, unlimited patients, unlimited data.
- Can optionally pay to enable cloud sync (admin flips `cloudSyncEnabled` flag).
- No tele-reporting access.

### 3.2 Diagnostic Center (`diagnostic`)

- Uses `DiagnosticHomePage`.
- **Cloud sync is mandatory** — cases must reach tele-reporters.
- Submits colposcopy cases to Griva tele-reporters using **prepaid credits**.
- One credit = one tele-report.
- Cannot submit a case when credit balance is zero.
- Receives the completed report in-app and by email.
- Credit balance is stored in `doctor_config/{uid}.creditBalance` and managed
  by the Griva admin panel.

### 3.3 Tele-Reporter (`tele_reporter`)

- Griva's own doctor(s). Uses `TeleReporterHomePage`.
- Receives pending cases from diagnostic centers.
- **20-minute SLA** per case.
- Writes `reportFindings`, `reportImpression`, `reportRemarks` to the
  `tele_cases` Firestore collection.
- Completed report is pushed back to the diagnostic center in-app and email.

---

## 4. High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Flutter App (Android)                     │
│                                                                  │
│  Screens / UI                                                    │
│    └─► AppRouter ──► role-specific home screen                  │
│                                                                  │
│  Service Layer (facade)                                          │
│    PatientService ──► IPatientRepository                        │
│    CreditService  ──► Firestore transaction                      │
│    SyncEngine     ──► sync_queue table ──► Firestore             │
│    AuthService    ──► Firebase Auth + local bcrypt              │
│    SessionService ──► doctorId (Firebase UID)                   │
│    CloudConfigService ──► doctor_config/{uid} in Firestore      │
│                                                                  │
│  Repository Layer                                                │
│    RepositoryFactory                                             │
│      cloud sync OFF ──► LocalPatientRepository (SQLite)         │
│      cloud sync ON  ──► SyncedPatientRepository                 │
│                           ├─ local write (SQLite, immediate)    │
│                           └─ SyncEngine.enqueue() (async)       │
│                                                                  │
│  Database Layer (Drift / SQLite)                                 │
│    patients · users · media_files · sync_queue · tele_cases     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
              │ cloud sync enabled (paid)
              ▼
┌──────────────────────────────────────────────────────────────────┐
│                     Firebase (Google Cloud)                      │
│                                                                  │
│  Firebase Auth      — identity, UID                             │
│  Cloud Firestore    — doctors/{uid}/patients/{uuid}             │
│                       doctors/{uid}/media/{uuid}                │
│                       doctor_config/{uid}                       │
│                       tele_cases/{uuid}                         │
│  Firebase Storage   — doctors/{uid}/patients/{puuid}/{uuid}/… │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 5. Source Tree

```
lib/
├── main.dart                       App entry point, Firebase init, SplashScreen
├── login_page.dart                 Login / signup / ABDM login
├── home_page.dart                  Solo/clinic doctor home (patient list)
│
├── core/
│   └── app_router.dart             Reads role → navigates to correct home screen
│
├── db/                             Database layer (Drift ORM)
│   ├── app_database.dart           @DriftDatabase: schema v3, migrations, WAL
│   ├── connection/                 Platform-specific SQLite connection
│   ├── tables/
│   │   ├── patients.dart           40+ clinical fields + uuid/doctorId/sync cols
│   │   ├── users.dart              Local user accounts (bcrypt passwords)
│   │   ├── media_files.dart        Per-file sync lifecycle, checksum, cloudUrl
│   │   ├── sync_queue.dart         Pending cloud push queue (entity/op/payload)
│   │   └── tele_cases.dart         Tele-reporting cases (status/SLA/credits)
│   └── daos/
│       ├── patient_dao.dart
│       ├── media_file_dao.dart
│       ├── tele_case_dao.dart
│       └── user_dao.dart
│
├── repositories/                   Repository pattern
│   ├── i_patient_repository.dart   Interface: getAll/getByUuid/create/update/delete
│   ├── i_media_repository.dart     Interface: getForPatient/create/update/delete
│   ├── repository_factory.dart     Returns local or synced impl based on config
│   ├── media_file.dart             MediaFile domain model
│   ├── tele_case.dart              TeleCase domain model
│   ├── local/
│   │   ├── local_patient_repository.dart   SQLite via PatientDao
│   │   └── local_media_repository.dart     SQLite via MediaFileDao
│   ├── cloud/
│   │   ├── firestore_patient_repository.dart   Firestore impl
│   │   └── firebase_media_repository.dart       Storage + Firestore impl
│   └── synced/
│       ├── synced_patient_repository.dart  Local-first + SyncEngine.enqueue()
│       └── synced_media_repository.dart    Local-first + background upload
│
├── services/                       Business logic / facades
│   ├── auth_service.dart           Login/register/logout/auto-login
│   ├── session_service.dart        Singleton: currentDoctorId (Firebase UID)
│   ├── cloud_config_service.dart   Reads doctor_config/{uid} from Firestore
│   ├── patient_service.dart        Facade over IPatientRepository
│   ├── credit_service.dart         Atomic Firestore credit deduction
│   ├── sync_engine.dart            Processes sync_queue → Firestore (2-min timer)
│   ├── network_service.dart        GRIVAVISION hotspot detection (SSID check)
│   ├── password_service.dart       bcrypt hash/verify
│   ├── user_service.dart           Local user CRUD
│   ├── image_service.dart          Capture / save images
│   ├── video_service.dart          Video recording
│   ├── medical_report_service.dart Report data assembly
│   ├── pdf_service.dart            PDF generation
│   ├── abdm_auth_service.dart      ABDM / HPR OAuth
│   └── abdm_service.dart           ABDM API calls
│
├── screens/
│   ├── diagnostic/
│   │   ├── diagnostic_home_page.dart     Patient list + submitted cases + credit banner
│   │   └── case_submission_screen.dart   Submit case form (1 credit deduction)
│   ├── tele_reporter/
│   │   └── tele_reporter_home_page.dart  Pending case queue + SLA timer (Phase 8)
│   ├── patient_details_screen.dart
│   ├── patient_form_screen.dart
│   ├── patient_list_screen.dart
│   ├── patient_selection_screen.dart
│   ├── clinical_data_form_screen.dart
│   ├── image_comparison_screen.dart
│   ├── report_pdf_viewer_screen.dart
│   ├── user_profile_screen.dart
│   └── hpr_login_screen.dart
│
├── forms/                          Clinical examination forms
│   ├── colposcopy_form.dart        (SWEDE score lives here — never modified at report phase)
│   ├── hra_form.dart
│   ├── laser_therapy_form.dart
│   ├── sexual_assault_form.dart
│   ├── vaginoscopy_form.dart
│   └── vulvoscopy_form.dart
│
└── widgets/
    └── centralized_footer.dart
```

---

## 6. Database Layer

### 6.1 Technology

- **ORM**: [Drift](https://drift.simonbinder.eu/) (type-safe SQLite for Flutter)
- **Generator**: `drift_dev` + `build_runner` produce `*.g.dart` files
- **WAL mode**: enabled on every open for better concurrent read performance
- **Foreign keys**: enforced at runtime via `PRAGMA foreign_keys=ON`

### 6.2 Schema Version History

| Version | Change |
|---|---|
| v1 | Original schema: `patients`, `users` |
| v2 | Added `uuid`, `doctor_id`, `sync_status`, `cloud_id`, `deleted_at` to `patients`; created `media_files`, `sync_queue`; backfilled existing rows with UUIDs and `local_legacy` doctorId |
| v3 | Added `tele_cases` table for credit-based tele-reporting workflow |

### 6.3 Table: `patients`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | Auto-increment, local only, never synced |
| `uuid` | TEXT UNIQUE | UUIDv4, stable cross-device key |
| `doctor_id` | TEXT | Firebase Auth UID of owning doctor |
| `sync_status` | TEXT | `local_only` \| `pending_upload` \| `synced` |
| `cloud_id` | TEXT? | Firestore document ID once synced |
| `deleted_at` | TEXT? | ISO-8601 soft-delete timestamp |
| `patient_name` | TEXT | |
| `patient_id` | TEXT? | Hospital/clinic ID |
| `date_of_birth` | TEXT? | ISO-8601 |
| `date_of_visit` | TEXT? | ISO-8601 |
| `mobile_no` | TEXT | |
| `email` | TEXT? | |
| `address` | TEXT? | |
| `doctor_name` | TEXT? | |
| `referred_by` | TEXT? | |
| `smoking` | TEXT? | |
| `blood_group` | TEXT? | |
| `medication` | TEXT? | |
| `allergies` | TEXT? | |
| `menopause` | TEXT? | |
| `last_menstrual_date` | TEXT? | ISO-8601 |
| `sexually_active` | TEXT? | |
| `contraception` | TEXT? | |
| `hiv_status` | TEXT? | |
| `pregnant` | TEXT? | |
| `live_births` | INTEGER? | |
| `still_births` | INTEGER? | |
| `abortions` | INTEGER? | |
| `cesareans` | INTEGER? | |
| `miscarriages` | INTEGER? | |
| `hpv_vaccination` | TEXT? | |
| `referral_reason` | TEXT? | |
| `symptoms` | TEXT? | |
| `hpv_test` | TEXT? | |
| `hpv_result` | TEXT? | |
| `hpv_date` | TEXT? | ISO-8601 |
| `hcg_test` | TEXT? | |
| `hcg_date` | TEXT? | ISO-8601 |
| `hcg_level` | REAL? | |
| `patient_summary` | TEXT? | |
| `chief_complaint` | TEXT? | |
| `cytology_report` | TEXT? | |
| `pathological_report` | TEXT? | |
| `colposcopy_findings` | TEXT? | |
| `final_impression` | TEXT? | |
| `remarks` | TEXT? | |
| `treatment_provided` | TEXT? | |
| `precautions` | TEXT? | |
| `examining_physician` | TEXT? | |
| `forensic_examination` | TEXT? | JSON-encoded map |
| `examination_images` | TEXT? | JSON-encoded list of paths (legacy) |
| `image_metadata` | TEXT? | JSON-encoded map (legacy) |
| `created_at` | TEXT? | ISO-8601 |
| `updated_at` | TEXT? | ISO-8601 |

### 6.4 Table: `media_files`

Replaces the JSON arrays on the patient row. Each file gets its own sync
lifecycle, checksum, and cloud URL.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | |
| `uuid` | TEXT UNIQUE | UUIDv4 |
| `patient_uuid` | TEXT | References `patients.uuid` (app-level FK) |
| `doctor_id` | TEXT | |
| `file_type` | TEXT | `image` \| `video` \| `pdf` |
| `local_path` | TEXT? | Absolute device path |
| `cloud_url` | TEXT? | Firebase Storage download URL |
| `file_name` | TEXT | |
| `mime_type` | TEXT? | |
| `file_size` | INTEGER? | Bytes |
| `checksum` | TEXT? | MD5/SHA-256 — skips re-upload of identical files |
| `sync_status` | TEXT | `local_only` \| `pending_upload` \| `uploading` \| `synced` \| `error` |
| `upload_attempts` | INTEGER | Back-off counter |
| `deleted_at` | TEXT? | Soft-delete timestamp |
| `captured_at` | TEXT? | |
| `created_at` | TEXT? | |
| `updated_at` | TEXT? | |

### 6.5 Table: `sync_queue`

Every local write that has not yet been pushed to Firestore. Processed by
`SyncEngine` whenever connectivity is available.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | |
| `entity_type` | TEXT | `patient` \| `media_file` |
| `entity_uuid` | TEXT | UUID of the changed entity |
| `operation` | TEXT | `create` \| `update` \| `delete` |
| `payload` | TEXT | JSON snapshot of entity at change time |
| `attempts` | INTEGER | Default 0 |
| `last_attempt_at` | TEXT? | ISO-8601 |
| `last_error` | TEXT? | Last error message for diagnostics |
| `created_at` | TEXT | ISO-8601 |

### 6.6 Table: `tele_cases`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | |
| `uuid` | TEXT UNIQUE | UUIDv4 |
| `diagnostic_doctor_id` | TEXT | Submitting center's Firebase UID |
| `patient_uuid` | TEXT | |
| `reporter_doctor_id` | TEXT? | Assigned tele-reporter's Firebase UID |
| `status` | TEXT | `pending` \| `in_progress` \| `completed` \| `cancelled` |
| `submission_notes` | TEXT? | Notes from diagnostic center |
| `report_findings` | TEXT? | Written by tele-reporter |
| `report_impression` | TEXT? | Written by tele-reporter |
| `report_remarks` | TEXT? | Written by tele-reporter |
| `sla_deadline` | TEXT? | `submitted_at + 20 minutes` |
| `completed_at` | TEXT? | |
| `credits_used` | INTEGER | Always 1 |
| `sync_status` | TEXT | `local_only` \| `synced` |
| `cloud_id` | TEXT? | Firestore document ID |
| `submitted_at` | TEXT? | |
| `updated_at` | TEXT? | |

### 6.7 Table: `users`

Local user accounts. Passwords are stored as bcrypt hashes for offline
credential validation when Firebase is unreachable.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | |
| `full_name` | TEXT | |
| `email` | TEXT UNIQUE | Lowercase normalised |
| `password` | TEXT | bcrypt hash |
| `medical_license` | TEXT | |
| `hospital` | TEXT | |
| `role` | TEXT | `admin` \| `doctor` |
| `is_active` | BOOLEAN | |
| `created_at` | TEXT? | |
| `updated_at` | TEXT? | |

---

## 7. Repository Layer

### 7.1 Design

All screens and services program against **interfaces**, never against
concrete implementations. This is the single change point for moving between
Firebase and any other cloud provider.

```
IPatientRepository          IMediaRepository
       │                           │
       ├─ LocalPatientRepository   ├─ LocalMediaRepository
       ├─ FirestorePatientRepo     ├─ FirebaseMediaRepository
       └─ SyncedPatientRepository  └─ SyncedMediaRepository
```

### 7.2 IPatientRepository

```dart
abstract interface class IPatientRepository {
  Future<List<Patient>> getAll(String doctorId);
  Future<Patient?> getByUuid(String uuid);
  Future<Patient> create(Patient patient);
  Future<Patient> update(Patient patient);
  Future<void> delete(String uuid);           // soft-delete
  Future<List<Patient>> getPendingUpload(String doctorId);
  Future<void> markSynced(String uuid, String cloudId);
}
```

### 7.3 IMediaRepository

```dart
abstract interface class IMediaRepository {
  Future<List<MediaFile>> getForPatient(String patientUuid);
  Future<MediaFile?> getByUuid(String uuid);
  Future<MediaFile> create(MediaFile file);
  Future<MediaFile> update(MediaFile file);
  Future<void> delete(String uuid);
  Future<List<MediaFile>> getPendingUpload(String doctorId);
  Future<void> markSynced(String uuid, String cloudUrl);
  Future<void> incrementUploadAttempts(String uuid);
}
```

### 7.4 RepositoryFactory

```dart
// Single configuration call in AuthService._postLoginInit()
RepositoryFactory.configure(cloudSyncEnabled: config.cloudSyncEnabled);

// Returns the correct implementation everywhere:
RepositoryFactory.patientRepo()   // → Local or Synced
RepositoryFactory.mediaRepo()     // → Local or Synced
```

### 7.5 Synced Repositories

`SyncedPatientRepository` and `SyncedMediaRepository` implement the
local-first + async-cloud pattern:

1. Write to SQLite → return immediately (UI never waits for network)
2. Call `SyncEngine.enqueue()` which persists the change to `sync_queue`
3. `SyncEngine` pushes to Firestore on its next flush cycle
4. On success: local row's `sync_status` set to `synced`
5. On failure: `attempts` incremented; retried on next flush (max 5 attempts)

---

## 8. Service Layer

Services are facades that hide repository/DAO complexity from screens.
Screens **always** call a service; they never touch a DAO or repository
directly.

| Service | Responsibility |
|---|---|
| `AuthService` | Login/register/logout/auto-login. Calls `_postLoginInit()` which chains session init → cloud config fetch → factory config → sync engine start. |
| `SessionService` | Singleton. Holds `currentDoctorId` (Firebase UID). Persisted to `flutter_secure_storage` so offline sessions restore the correct UID. |
| `CloudConfigService` | Fetches `doctor_config/{uid}` from Firestore. Exposes `cloudSyncEnabled`, `role`, `creditBalance`. Streams live updates. Degrades gracefully offline. |
| `PatientService` | Facade over `IPatientRepository`. Auto-stamps `uuid` and `doctorId` from session on `createPatient()`. Screens call `getAllPatients()` with no arguments. |
| `CreditService` | Singleton. Runs a Firestore transaction to atomically check balance > 0, decrement by 1, and write the tele-case document. Throws `InsufficientCreditsException` on zero balance. |
| `SyncEngine` | Singleton. Processes `sync_queue` on a 2-minute `Timer.periodic`. Started on login when cloud sync is enabled; stopped on logout. |
| `NetworkService` | Detects GRIVAVISION hotspot by reading the Wi-Fi SSID (`startsWith('GRIVAVISION')`). Requires `ACCESS_FINE_LOCATION` permission. |
| `PasswordService` | bcrypt hash + verify for offline credential validation. |
| `UserService` | Local user CRUD (used by AuthService for offline login fallback and upsert). |
| `ImageService` | Image capture and save from camera stream. |
| `VideoService` | Video recording. |
| `MedicalReportService` | Assembles clinical data for report generation. |
| `PdfService` | Generates downloadable PDF reports. |
| `AbdmAuthService` | ABDM / HPR OAuth integration. |

---

## 9. Session & Authentication Flow

### 9.1 Login sequence (online)

```
User enters credentials
    │
    ▼
AuthService.login()
    ├─ Firebase.signInWithEmailAndPassword()
    ├─ _upsertLocalUser()        ← sync profile to local DB (bcrypt hash preserved)
    ├─ SecureStorage.write(email)
    └─ _postLoginInit()
           ├─ SessionService.initialize()  ← reads Firebase UID, stores to SecureStorage
           ├─ CloudConfigService.fetch(uid) ← reads role/cloudSyncEnabled/credits
           ├─ RepositoryFactory.configure() ← sets Local vs Synced impl
           └─ SyncEngine.start()           ← only if cloudSyncEnabled
```

### 9.2 Login sequence (offline / on GRIVAVISION hotspot)

```
Firebase.signIn() throws network-request-failed
    │
    ▼
AuthService._offlineLogin()
    ├─ UserService.authenticateUser()  ← bcrypt.verify against local hash
    ├─ SecureStorage.write(email)
    └─ _postLoginInit()
           ├─ SessionService.initialize()  ← reads last-stored UID from SecureStorage
           ├─ CloudConfigService.fetch()   ← fails silently, returns cached defaults
           ├─ RepositoryFactory.configure(cloudSyncEnabled: false)
           └─ (SyncEngine not started — offline)
```

### 9.3 Cold-start sequence

Every cold start always goes to the login page. There is no auto-login on
app launch. This is intentional — it ensures the device's current user is
always validated.

```
App launch → SplashScreen (2s) → GrivaLoginPage
```

### 9.4 Auto-login (signup verification only)

`tryAutoLogin()` is only called after signup to verify the Firebase session
was established. It reads `firebase.currentUser` without making a network
call (`getIdToken(true)` is deliberately avoided to preserve offline use).

### 9.5 Logout

```
AuthService.logout()
    ├─ Firebase.signOut()
    ├─ SecureStorage.delete(email)
    ├─ SyncEngine.stop()
    ├─ CloudConfigService.reset()
    └─ RepositoryFactory.configure(cloudSyncEnabled: false)
```

---

## 10. Cloud Sync Architecture

### 10.1 Enabling cloud sync

Cloud sync is a **paid feature** enabled by a Griva administrator. The admin
writes `cloudSyncEnabled: true` to `doctor_config/{uid}` in Firestore. The
app detects this on the next login or via the live Firestore stream
(`CloudConfigService.listenForChanges()`).

### 10.2 Firestore collection layout

```
doctors/
  {uid}/                         ← one document per doctor
    patients/
      {patientUuid}/             ← patient record (mirrors SQLite row)
    media/
      {mediaUuid}/               ← media file metadata

doctor_config/
  {uid}/                         ← cloud config per doctor
    cloudSyncEnabled: bool
    role: string
    creditBalance: int

tele_cases/
  {uuid}/                        ← tele-reporting cases (global collection)
```

### 10.3 Firebase Storage layout

```
doctors/{uid}/patients/{patientUuid}/{fileUuid}/{fileName}
```

### 10.4 Data flow (write path, cloud sync ON)

```
Screen calls PatientService.createPatient(p)
    │
    ▼
PatientService.createPatient()
    ├─ Stamps uuid + doctorId from SessionService
    └─ SyncedPatientRepository.create(p)
           ├─ LocalPatientRepository.create(p)   ← SQLite, immediate
           │    └─ Returns saved patient to screen
           └─ SyncEngine.enqueue('patient', uuid, 'create', payload)
                  └─ Inserts row into sync_queue (persisted)

[background, next flush cycle]
SyncEngine.flush()
    └─ For each sync_queue row:
           ├─ Firestore: col.doc(uuid).set(payload, merge: true)
           ├─ SQLite: patients.sync_status = 'synced'
           └─ DELETE from sync_queue
```

### 10.5 Conflict resolution

Last-write-wins based on `updatedAt`. When a patient is modified on two
devices simultaneously, the later `updatedAt` timestamp wins. This matches
the typical single-doctor workflow where conflicts are rare.

### 10.6 Offline resilience

- Writes always succeed locally regardless of connectivity.
- `sync_queue` rows persist across app restarts.
- `SyncEngine` retries up to **5 times** per entry.
- Failed entries record `last_error` for diagnostics.
- Entries exceeding max attempts remain in the queue and can be manually
  inspected or cleared.

---

## 11. Sync Engine

`SyncEngine` is a singleton service started on login (cloud sync ON only)
and stopped on logout.

```
SyncEngine
  ├─ flushInterval: 2 minutes (Timer.periodic)
  ├─ maxAttempts: 5
  ├─ enqueue(entityType, entityUuid, operation, payload)
  │    └─ INSERT into sync_queue
  └─ flush()
       └─ SELECT from sync_queue WHERE attempts < 5 ORDER BY id ASC
              └─ For each row:
                     ├─ _syncPatient(operation, payload)
                     │    ├─ create/update → Firestore set(merge: true)
                     │    └─ delete → Firestore set({deletedAt, syncStatus})
                     ├─ On success: DELETE from sync_queue
                     └─ On error: UPDATE attempts++, last_error
```

`flush()` can also be triggered on-demand when connectivity is detected
(call `SyncEngine.instance.flush()` from a connectivity listener — Phase 9).

---

## 12. Role-Based Routing

`AppRouter.navigateToHome(context, userEmail: email)` is the single point of
post-login navigation. It reads `CloudConfigService.instance.current.role`
and routes accordingly.

```dart
switch (role) {
  'diagnostic'    → DiagnosticHomePage
  'tele_reporter' → TeleReporterHomePage
  _               → HomePage   // solo / clinic / unknown
}
```

All role-resolution happens after `_postLoginInit()` completes, so
`CloudConfigService` always has the latest fetched config by the time routing
occurs. Offline default is `role = 'solo'`.

---

## 13. Credit System & Tele-Reporting

### 13.1 Credit lifecycle

```
Admin tops up balance
    └─ Writes creditBalance: N to doctor_config/{uid}
           └─ CloudConfigService stream updates local cache
                  └─ DiagnosticHomePage credit banner refreshes

Diagnostic center submits a case
    └─ CreditService.submitCase(draft)
           └─ Firestore.runTransaction():
                  ├─ Read creditBalance  ─── if 0: throw InsufficientCreditsException
                  ├─ creditBalance -= 1
                  └─ tele_cases/{uuid}.set(caseData)
           └─ TeleCaseDao.createCase(saved)  ← local SQLite record
           └─ CloudConfigService.fetch()     ← refresh balance cache
```

### 13.2 Case status lifecycle

```
pending → in_progress → completed
                     └─ cancelled
```

- `pending`: submitted, not yet picked up by a reporter
- `in_progress`: reporter has opened the case (20-min SLA clock running)
- `completed`: reporter has submitted the report
- `cancelled`: cancelled before completion (credit not refunded automatically —
  handled by admin)

### 13.3 SLA enforcement

- `sla_deadline = submitted_at + 20 minutes` — computed at submission time.
- `TeleCase.isSlaBreached` and `TeleCase.minutesUntilSla` are computed
  properties on the domain model (not stored derived values).
- Phase 8 will add push notifications for SLA warnings at 5 minutes remaining
  and SLA breach events.

### 13.4 CaseSubmissionScreen flow

```
DiagnosticHomePage
    └─ FAB "New Case" (disabled when balance = 0)
           └─ CaseSubmissionScreen
                  ├─ Patient selector (dropdown or pre-selected from patient row)
                  ├─ Submission notes (optional)
                  ├─ Credit balance banner
                  └─ Submit button "Submit Case (1 credit)"
                         └─ CreditService.submitCase()
                                └─ On success: pop(true) → DiagnosticHomePage._load()
                                └─ On InsufficientCreditsException: show error dialog
```

---

## 14. Hardware Integration

### 14.1 GRIVAVISION Colposcope

The GRIVAVISION is a Raspberry Pi-based colposcope camera controller that
broadcasts a Wi-Fi hotspot. The Android tablet connects to this hotspot to
receive the camera stream.

- **SSID pattern**: `GRIVAVISION*` (starts-with check, not exact match)
- **Detection**: `NetworkService.checkColposcopeConnection()`
  - Requests `ACCESS_FINE_LOCATION` permission (required for SSID read on Android)
  - Checks location services are enabled
  - Reads current SSID via `network_info_plus`
  - Returns `true` if SSID starts with `'GRIVAVISION'`
- **Popup**: shown on `HomePage.initState()` — permission is requested before
  the overlay renders to avoid timing conflicts with the system permission dialog
- **Wi-Fi settings**: tapping the Wi-Fi icon in the popup opens Android Wi-Fi
  settings via `open_settings_plus`
- **Note**: while connected to GRIVAVISION, the device has no internet. All
  cloud sync is deferred to `sync_queue`.

### 14.2 Camera stream

The colposcope streams MJPEG over the local network. The app displays this
stream in `ExamScreen` using `flutter_mjpeg`.

---

## 15. ABDM Integration

ABDM (Ayushman Bharat Digital Mission) is India's national health ID system.
The integration is optional and runs on a separate FastAPI + PostgreSQL backend
(not on Firebase).

- **Login**: `AbdmAuthService.getHprAuthUrl()` opens an OAuth flow in
  `HprLoginScreen` (WebView).
- **Backend**: separate FastAPI service, untouched by the Flutter rebuild.
- **ABDM is always free**: cloud sync billing does not apply to ABDM features.

---

## 16. Schema Migration History

Drift migrations run in `AppDatabase.migration.onUpgrade`. Each version block
is cumulative (a fresh install runs `onCreate` which calls `createAll()`).

### v1 → v2

- Added to `patients`: `uuid`, `doctor_id`, `sync_status`, `cloud_id`,
  `deleted_at`
- Created `media_files` table
- Created `sync_queue` table
- Backfilled all existing patient rows with `uuid = UUIDv4()` and
  `doctor_id = 'local_legacy'`

### v2 → v3

- Created `tele_cases` table

### Adding a future migration

1. Add columns/tables to the relevant `lib/db/tables/*.dart` file
2. Register new tables/DAOs in `@DriftDatabase` in `app_database.dart`
3. Bump `schemaVersion`
4. Add a `if (from < N)` block in `onUpgrade`
5. Run `dart run build_runner build --delete-conflicting-outputs`

---

## 17. Provider Portability

The entire cloud layer is behind interfaces. To migrate from Firebase to
Supabase, a custom REST API, or any other provider:

1. Create new implementations of `IPatientRepository` and `IMediaRepository`
2. Update `RepositoryFactory.patientRepo()` and `mediaRepo()` to return the
   new classes when `cloudSyncEnabled`
3. Update `CreditService.submitCase()` to use the new transaction mechanism
4. Update `CloudConfigService` to read from the new config source
5. Update `AuthService` to use the new auth provider

**Screens, services, DAOs, domain models, and the sync queue table are all
untouched.**

The `SessionService.currentDoctorId` abstraction means the doctor identity
concept is also provider-agnostic — it just needs a stable unique string per
doctor, regardless of auth provider.

---

## 18. Pending Phases

| Phase | Description | Status |
|---|---|---|
| 1 | DB schema rebuild (uuid, doctorId, soft deletes, media_files, sync_queue) | ✅ Complete |
| 2 | Repository layer (interfaces + local implementations + MediaFileDao) | ✅ Complete |
| 3 | Doctor linking (SessionService, auto-inject doctorId/uuid in PatientService) | ✅ Complete |
| 4 | Cloud layer (Firestore/Storage implementations, CloudConfigService, RepositoryFactory) | ✅ Complete |
| 5 | Sync engine (SyncedPatientRepository, SyncedMediaRepository, SyncEngine) | ✅ Complete |
| 6 | Role-based routing (AppRouter, DiagnosticHomePage stub, TeleReporterHomePage stub) | ✅ Complete |
| 7 | Credit system (tele_cases table, CreditService, CaseSubmissionScreen, DiagnosticHomePage wired) | ✅ Complete |
| 8 | Tele-reporting workflow (TeleReporterHomePage, case queue, report form, SLA notifications) | 🔲 Pending |
| 9 | Push notifications (FCM: case assigned, report ready, SLA warning, SLA breach) | 🔲 Pending |
| 10 | Settings screen (sync toggle display, credit top-up, profile, ABDM linking) | 🔲 Pending |

---

## 19. Key Constraints & Rules

| Rule | Reason |
|---|---|
| **SWEDE score is never modified at the report-generation phase** | Clinical integrity — the score must reflect the state at examination time, not at reporting time. |
| **Never hard-delete rows** | Rows with `deletedAt` are kept for sync propagation to other devices. Hard deletes would cause ghost references on devices that haven't synced yet. |
| **Screens never call FirebaseAuth directly** | All identity goes through `SessionService.currentDoctorId`. This makes the auth provider swappable. |
| **Screens never call DAOs or repositories directly** | Always go through a service. This preserves layering and makes the cloud/local switch transparent. |
| **`local_legacy` doctorId** | Rows created before multi-doctor support (v1 schema) are backfilled with `'local_legacy'`. They appear to whichever doctor first logs in on that device. |
| **Credit deduction is always atomic** | `CreditService` uses a Firestore transaction. There is no code path that creates a tele-case without deducting a credit. |
| **SyncEngine max 5 retries** | Prevents an unfixable error (e.g., malformed payload) from blocking the queue forever. Failed entries are kept for diagnostics. |
| **buildRunner must be re-run after any table/DAO change** | `dart run build_runner build --delete-conflicting-outputs` — all `*.g.dart` files are generated, never hand-edited. |
