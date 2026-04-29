import admin from 'firebase-admin';

let initialized = false;

try {
  const fullConfig = process.env.FIREBASE_CONFIG;
  const projectId = process.env.FIREBASE_PROJECT_ID;

  if (fullConfig) {
    const serviceAccount = JSON.parse(fullConfig) as admin.ServiceAccount;
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    initialized = true;
    console.log('[FIREBASE] Initialized with service account');
  } else if (projectId) {
    admin.initializeApp({ projectId });
    initialized = true;
    console.log('[FIREBASE] Initialized with project ID:', projectId);
  } else {
    console.error('[FIREBASE] No config found. Set FIREBASE_PROJECT_ID in .env');
  }
} catch (error) {
  console.error('[FIREBASE] Initialization failed:', error instanceof Error ? error.message : error);
}

export const verifyFirebaseToken = async (token: string): Promise<admin.auth.DecodedIdToken> => {
  if (!initialized) {
    throw new Error('Firebase not initialized. Set FIREBASE_PROJECT_ID in .env');
  }
  return admin.auth().verifyIdToken(token);
};
