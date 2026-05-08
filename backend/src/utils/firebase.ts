import admin from 'firebase-admin';

let initialized = false;

try {
  const credPath  = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const fullConfig = process.env.FIREBASE_CONFIG;
  const projectId  = process.env.FIREBASE_PROJECT_ID;

  if (credPath) {
    // Preferred: service account JSON file on disk (set GOOGLE_APPLICATION_CREDENTIALS)
    admin.initializeApp({ credential: admin.credential.applicationDefault() });
    initialized = true;
    console.log('[FIREBASE] Initialized via GOOGLE_APPLICATION_CREDENTIALS');
  } else if (fullConfig) {
    const serviceAccount = JSON.parse(fullConfig) as admin.ServiceAccount;
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    initialized = true;
    console.log('[FIREBASE] Initialized with service account JSON (FCM + auth)');
  } else if (projectId) {
    admin.initializeApp({ projectId });
    initialized = true;
    console.log('[FIREBASE] Initialized with project ID only:', projectId);
  } else {
    console.warn('[FIREBASE] No config — FCM and Firebase auth verification disabled');
  }
} catch (error) {
  console.error('[FIREBASE] Initialization failed:', error instanceof Error ? error.message : error);
}

export const firebaseAdmin  = admin;
export const fcmInitialized = initialized;
