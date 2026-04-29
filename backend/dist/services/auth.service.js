import { prisma } from '../utils/prisma.js';
import { verifyFirebaseToken } from '../utils/firebase.js';
import { signToken } from '../utils/jwt.js';
export const loginWithFirebase = async (idToken) => {
    const decoded = await verifyFirebaseToken(idToken);
    let user = await prisma.user.findUnique({
        where: { firebaseUid: decoded.uid },
    });
    if (!user) {
        user = await prisma.user.create({
            data: {
                firebaseUid: decoded.uid,
                email: decoded.email,
            },
        });
    }
    const accessToken = signToken(user.id);
    return {
        accessToken,
        user,
    };
};
//# sourceMappingURL=auth.service.js.map