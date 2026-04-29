import admin from 'firebase-admin';
export declare const verifyFirebaseToken: (token: string) => Promise<admin.auth.DecodedIdToken>;
