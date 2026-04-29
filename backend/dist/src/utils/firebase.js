import admin from 'firebase-admin';
const firebaseConfig = process.env.FIREBASE_CONFIG;
let initialized = false;
try {
    if (firebaseConfig) {
        const serviceAccount = JSON.parse(firebaseConfig);
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });
        initialized = true;
        console.log('[FIREBASE] Initialized successfully');
    }
    else {
        console.warn('[FIREBASE] FIREBASE_CONFIG not set, dev mode will be used for auth');
    }
}
catch (error) {
    console.warn('[FIREBASE] Initialization warning:', error instanceof Error ? error.message : error);
}
export const verifyFirebaseToken = async (token) => {
    if (token === 'dev-token') {
        console.log('[FIREBASE] Dev token detected, returning mock user');
        return {
            uid: 'dev-user-' + Date.now(),
            email: 'dev@test.com',
            email_verified: true,
        };
    }
    if (!initialized) {
        throw new Error('Firebase not initialized. Set FIREBASE_CONFIG environment variable or use dev-token');
    }
    return admin.auth().verifyIdToken(token);
};
//# sourceMappingURL=firebase.js.map