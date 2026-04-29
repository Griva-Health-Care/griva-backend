"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyFirebaseToken = void 0;
const firebase_admin_1 = __importDefault(require("firebase-admin"));
let initialized = false;
try {
    const fullConfig = process.env.FIREBASE_CONFIG;
    const projectId = process.env.FIREBASE_PROJECT_ID;
    if (fullConfig) {
        const serviceAccount = JSON.parse(fullConfig);
        firebase_admin_1.default.initializeApp({ credential: firebase_admin_1.default.credential.cert(serviceAccount) });
        initialized = true;
        console.log('[FIREBASE] Initialized with service account');
    }
    else if (projectId) {
        firebase_admin_1.default.initializeApp({ projectId });
        initialized = true;
        console.log('[FIREBASE] Initialized with project ID:', projectId);
    }
    else {
        console.error('[FIREBASE] No config found. Set FIREBASE_PROJECT_ID in .env');
    }
}
catch (error) {
    console.error('[FIREBASE] Initialization failed:', error instanceof Error ? error.message : error);
}
const verifyFirebaseToken = async (token) => {
    if (!initialized) {
        throw new Error('Firebase not initialized. Set FIREBASE_PROJECT_ID in .env');
    }
    return firebase_admin_1.default.auth().verifyIdToken(token);
};
exports.verifyFirebaseToken = verifyFirebaseToken;
//# sourceMappingURL=firebase.js.map