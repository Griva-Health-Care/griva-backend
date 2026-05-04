import admin from 'firebase-admin';

// Firebase is kept ONLY for FCM push notifications.
// Auth token verification is handled by Supabase JWT (see utils/supabase.ts).

let initialized = false;

try {
  const fullConfig = process.env.FIREBASE_CONFIG;
  const projectId  = process.env.FIREBASE_PROJECT_ID;

  if (fullConfig) {
    const serviceAccount = JSON.parse(fullConfig) as admin.ServiceAccount;
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    initialized = true;
    console.log('[FIREBASE] Initialized with service account (FCM only)');
  } else if (projectId) {
    admin.initializeApp({ projectId });
    initialized = true;
    console.log('[FIREBASE] Initialized with project ID (FCM only):', projectId);
  } else {
    console.warn('[FIREBASE] No config — FCM push notifications will be disabled');
  }
} catch (error) {
  console.error('[FIREBASE] Initialization failed:', error instanceof Error ? error.message : error);
}

export const fcmInitialized = initialized;
