# Griva PI

A Flutter application for medical colposcopy procedures, patient management, and tele-reporting — with ABDM (Ayushman Bharat Digital Mission) compliance.

## Description

Griva PI is a comprehensive medical platform designed for healthcare professionals performing colposcopy examinations. It supports offline-first patient data capture, cloud sync, credit-based tele-reporting, and India's national digital health (ABDM) ecosystem integration.

## Features

- **Patient Management**: Create and manage patient records with full clinical history
- **Colposcopy Integration**: Connect and stream live MJPEG video from colposcope devices
- **Clinical Forms**: Colposcopy, vaginoscopy, vulvoscopy, laser therapy, HRA, and sexual assault forms
- **Gallery Management**: Capture, annotate, and compare medical images side-by-side
- **Report Generation**: Generate and print PDF medical reports
- **User Authentication**: Firebase + offline bcrypt login with secure credential storage
- **Offline-First Sync**: SQLite-backed queue that syncs to Firestore when online
- **Tele-Reporting**: Credit-based system for diagnostic centers to submit cases to remote reporters
- **ABDM Compliance**: Consent management, health record exchange, and HPR authentication

## Project Structure

```
griva-pi-main/
├── lib/                        # Flutter app (Dart)
│   ├── main.dart               # Entry point, Firebase init
│   ├── login_page.dart         # Authentication screen
│   ├── home_page.dart          # Main dashboard
│   ├── core/                   # Router, config
│   ├── config/                 # Feature flags, version
│   ├── db/                     # Drift ORM database
│   │   ├── app_database.dart   # Schema (v3), migrations
│   │   ├── tables/             # patients, users, media_files, sync_queue, tele_cases
│   │   ├── daos/               # PatientDao, MediaFileDao, TeleCaseDao, UserDao
│   │   └── connection/         # Platform-specific DB connections
│   ├── repositories/           # Local, cloud, and synced repository implementations
│   ├── services/               # Business logic
│   │   ├── auth_service.dart
│   │   ├── patient_service.dart
│   │   ├── sync_engine.dart
│   │   ├── tele_case_service.dart
│   │   ├── credit_service.dart
│   │   ├── medical_report_service.dart
│   │   ├── abdm_service.dart
│   │   └── ...
│   ├── screens/                # UI screens
│   │   ├── patient_list_screen.dart
│   │   ├── patient_details_screen.dart
│   │   ├── patient_form_screen.dart
│   │   ├── clinical_data_form_screen.dart
│   │   ├── image_comparison_screen.dart
│   │   ├── diagnostic/         # Diagnostic center workflow
│   │   └── tele_reporter/      # Remote reporter workflow
│   ├── forms/                  # Clinical examination forms
│   └── widgets/                # Shared UI components
├── backend/                    # Node.js REST API (Express + Prisma + PostgreSQL)
└── abdm/                       # ABDM compliance layer
    ├── backend/                # Python FastAPI (consent, health records, emergency access)
    └── frontend/               # React dashboard (Vite + TypeScript)
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / VS Code
- Android SDK for Android builds
- Node.js 18+ (for backend)
- Python 3.12+ (for ABDM backend)
- PostgreSQL (for backend and ABDM backend)

### Flutter App

```bash
flutter pub get
flutter run
```

After schema changes, regenerate Drift code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Node.js Backend

```bash
cd backend
npm install
npx prisma migrate dev
npm run dev
```

### ABDM Backend

```bash
cd abdm/backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
alembic upgrade head
uvicorn app.main:app --reload
```

### ABDM Frontend

```bash
cd abdm/frontend
npm install
npm run dev
```

## Building and Deployment

### Android APK (Shorebird)

```bash
# First time only
shorebird init

# Release build
shorebird release android --artifact apk

# OTA patch for existing release
shorebird patch --platforms=android --release-version=1.0.0+1
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `drift` | Type-safe SQLite ORM with code generation |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Cloud sync for patient records |
| `firebase_storage` | Media file cloud storage |
| `flutter_mjpeg` | Live MJPEG stream from colposcope |
| `pdf` + `printing` | PDF report generation and printing |
| `bcrypt` | Offline password hashing |
| `flutter_secure_storage` | Secure credential storage |
| `dio` | HTTP client for API calls |
| `uuid` | UUID generation for offline-safe records |

## Database Schema

The local SQLite database uses Drift ORM with 3 schema versions:

- **v1 → v2**: Added `uuid`, `doctorId`, `syncStatus`, `cloudId` to patients. Created `media_files` and `sync_queue` tables.
- **v2 → v3**: Added `tele_cases` table for the tele-reporting workflow.

## ABDM Integration

See [abdm/README.md](abdm/README.md) and [abdm/audit_bundle/architecture.md](abdm/audit_bundle/architecture.md) for the full ABDM HIP/HIU architecture, consent lifecycle, and audit checklist.

## License

[Add your license information here]

## Support

For support: tech@grivahealth.com
