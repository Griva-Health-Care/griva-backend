# Griva PI – Technical Project Documentation

**Version:** 1.1  
**Date:** 2026-04-28  
**Audience:** Engineers onboarding to the Griva PI codebase

---

## 1. Project Summary
Griva PI is a Flutter application for digital colposcopy workflows and patient management. It provides:
- Login/sign-up for healthcare staff (Firebase Auth + local HPR OAuth)
- Patient registration and clinical data capture
- Colposcope device connectivity and camera streaming
- Image/video capture, editing, and comparison
- AI inference on images (server-side)
- PDF report generation (simple, detailed, and comprehensive)
- Local SQLite persistence with cloud sync
- ABDM integration (HPR OAuth, tenant selection, ABHA linking)
- Tele-medicine / tele-reporting workflows

Target platforms: **Android** and **Windows** (Linux present but video playback disabled).

---

## 2. Tech Stack

**App Framework**
- Flutter (Dart) — SDK ^3.7.2

**State/Utilities**
- flutter_screenutil, intl, uuid

**Storage**
- Drift (SQLite ORM) — tables: users, patients, media_files, tele_cases, sync_queue
- sqlite3 / sqlite3_flutter_libs
- firebase_core, cloud_firestore, firebase_storage (cloud sync)

**Media & Capture**
- flutter_mjpeg (live MJPEG streaming)
- audioplayers (timer sounds)
- video_player + video_player_win
- image, image_picker
- crop_your_image

**PDF & Export**
- pdf, printing, open_file

**Networking**
- http, dio (ABDM backend)
- socket_io_client
- webview_flutter
- network_info_plus, open_settings_plus

**Auth & Security**
- firebase_auth (primary auth)
- flutter_secure_storage (ABDM JWT tokens)
- bcrypt (local password hashing / legacy upgrade path)
- permission_handler

**Build/Release**
- Shorebird (OTA patch management) — see `shorebird.yaml`

---

## 3. Repository Layout

```
lib/
  main.dart                    # entry point + splash routing
  launch_screen.dart
  login_page.dart
  home_page.dart
  exam_screen.dart
  gallery_screen.dart
  image_edit_screen.dart
  diagnosis_page.dart
  new_patient_form.dart
  colposcopy_screen.dart
  swede_score_modal.dart
  data_swede_score.dart
  feature_row.dart
  ui_constants.dart
  custom_app_bar.dart
  custom_drawer.dart
  firebase_options.dart

  config/
    app_config.dart            # device/Pi endpoints (GRIVA_HOST, GRIVA_PORT)
    app_version.dart

  core/
    config.dart                # ABDM backend URL (ABDM_HOST), Firebase key, Pi URL
    app_router.dart

  services/
    abdm_auth_service.dart     # HPR OAuth, token refresh, tenant selection
    abdm_service.dart          # authenticated ABDM API client (Dio + interceptors)
    auth_service.dart          # Firebase auth wrapper
    cloud_config_service.dart
    credit_service.dart
    griva_api_service.dart     # Pi hardware API calls
    image_service.dart
    medical_report_service.dart
    network_service.dart
    password_service.dart      # bcrypt hashing + legacy upgrade
    patient_service.dart
    pdf_service.dart
    session_service.dart
    sync_engine.dart           # local↔cloud sync
    tele_case_service.dart
    user_service.dart
    video_service.dart

  screens/
    patient_list_screen.dart
    patient_details_screen.dart
    patient_form_screen.dart
    patient_selection_screen.dart
    image_comparison_screen.dart
    report_pdf_viewer_screen.dart
    clinical_data_form_screen.dart
    hpr_login_screen.dart      # ABDM HPR OAuth WebView flow
    user_profile_screen.dart
    diagnostic/
      diagnostic_home_page.dart
    tele_reporter/
      tele_reporter_home_page.dart
      case_review_screen.dart
      case_submission_screen.dart

  forms/
    colposcopy_form.dart
    vulvoscopy_form.dart
    vaginoscopy_form.dart
    hra_form.dart
    laser_therapy_form.dart
    sexual_assault_form.dart

  tele/
    tele_app.dart
    tele_login_screen.dart
    models.dart
    admin/
    diagnostic/
    doctor/
    reporter/
    api_client.dart

  repositories/
    i_patient_repository.dart
    i_media_repository.dart
    repository_factory.dart
    local/
    cloud/
    synced/

  widgets/
    centralized_footer.dart

  db/
    app_database.dart
    tables/
      users.dart
      patients.dart
      media_files.dart
      tele_cases.dart
      sync_queue.dart
    daos/
      user_dao.dart
      patient_dao.dart
      media_file_dao.dart
      tele_case_dao.dart

assets/
  images/     # logo, background, icons, reference images
  audio/      # timer sounds
  fonts/      # Roboto, Poppins

android/      # Android Gradle project
windows/      # Windows runner
ios/          # present, not primary target
macos/        # present, not primary target
linux/        # present, video disabled
web/          # present
backend/      # companion backend code
```

---

## 4. Configuration & Endpoints

### Device (Raspberry Pi / Colposcope)
Configured in `lib/config/app_config.dart` via `--dart-define`:

| Variable | Default | Purpose |
|---|---|---|
| `GRIVA_HOST` | `10.42.1.1` | Pi host IP |
| `GRIVA_PORT` | `5000` | Pi HTTP port |
| `GRIVA_HTTPS` | `false` | Use HTTPS to Pi |

Endpoints: LED control, green filter, image capture, video start/stop, MJPEG stream, AI inference, Socket.IO.

### ABDM Backend
Configured in `lib/core/config.dart` via `--dart-define`:

| Variable | Default | Purpose |
|---|---|---|
| `ABDM_HOST` | `https://api.yourabdm.com` | ABDM backend base URL |

---

## 5. Auth Flows

### Firebase Auth (primary)
- `lib/services/auth_service.dart` wraps Firebase Auth
- Used for staff login/signup via `login_page.dart`

### ABDM / HPR OAuth
- `lib/services/abdm_auth_service.dart` manages the HPR OAuth session independently of Firebase
- Token storage keys in `flutter_secure_storage`:
  - `abdm_access_token` — short-lived JWT (30 min)
  - `abdm_refresh_token` — long-lived JWT (7 days)
  - `abdm_tenant_id` — selected tenant UUID
- `lib/screens/hpr_login_screen.dart` — WebView-based HPR login
- `lib/services/abdm_service.dart` — Dio client that auto-attaches `Authorization` and `X-Tenant-ID` headers and transparently refreshes on 401

### Local Auth (legacy)
- `lib/services/password_service.dart` — bcrypt hashing
- Plaintext passwords are upgraded to bcrypt on first successful login
- Default admin seed only present in debug builds

---

## 6. Database Schema (Drift / SQLite)

DB file: Application documents directory → `db/patient_database.db`

| Table | Key fields |
|---|---|
| `users` | email, password (bcrypt), role, active flag, metadata |
| `patients` | full demographics, clinical fields, JSON blobs for images/forensic data |
| `media_files` | path, type, patient ref, sync status |
| `tele_cases` | case data, assignment, status |
| `sync_queue` | pending local→cloud operations |

---

## 7. Repository Pattern & Sync

`lib/repositories/` defines `IPatientRepository` and `IMediaRepository` interfaces with three implementations:
- **local/** — Drift (SQLite only)
- **cloud/** — Firestore/Firebase Storage
- **synced/** — local-first with background sync via `SyncEngine`

`repository_factory.dart` selects the implementation at runtime.

---

## 8. Tele-medicine Module

`lib/tele/` implements a separate role-based app within the same codebase:
- Roles: `admin`, `diagnostic`, `doctor`, `reporter`
- Entry: `tele_app.dart` / `tele_login_screen.dart`
- `lib/screens/tele_reporter/` — case submission and review screens
- `lib/tele/api_client.dart` — tele backend API client

---

## 9. Build & Run

### Android
```bash
flutter pub get
flutter run -d <device_id> \
  --dart-define=GRIVA_HOST=192.168.x.x \
  --dart-define=ABDM_HOST=https://your-abdm-backend.com
```
Release:
```bash
flutter build apk --release
flutter build appbundle --release
```
Signing: `android/app/build.gradle.kts` reads `android/key.properties`.

### Windows
```bash
flutter pub get
flutter run -d windows
flutter build windows
```

### OTA Patches (Shorebird)
See `SHOREBIRD_VERSION_MANAGEMENT.md` for patch workflow.

---

## 10. Known Limitations
- Linux build: present but video playback is disabled in code
- ABDM integration UI is partially built (`hpr_login_screen`, `abdm_auth_service`, `abdm_service` exist); full end-to-end flow is in progress
- Some tele-medicine role screens are placeholders

---

## 11. Related Documents
- `ABDM_INTEGRATION_REQUIREMENTS.md` — backend/app contract for ABDM integration
- `ARCHITECTURE.md` — system architecture overview
- `SHOREBIRD_VERSION_MANAGEMENT.md` — OTA release process
- `README.md` — project overview

---

## 12. Contact / Ownership
Add team contacts, Slack channel, and on-call rotation here.
