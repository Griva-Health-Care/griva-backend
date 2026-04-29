import admin from 'firebase-admin';
import serviceAccount from '../../serviceAccountKey.json' assert { type: 'json' };
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});
export const verifyFirebaseToken = async (token) => {
    return admin.auth().verifyIdToken(token);
};
//# sourceMappingURL=firebase.js.map