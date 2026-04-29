import { loginWithFirebase } from '../services/auth.service.js';
export const login = async (req, res) => {
    try {
        const { firebaseToken } = req.body;
        if (!firebaseToken) {
            return res.status(400).json({ message: 'Token required' });
        }
        const result = await loginWithFirebase(firebaseToken);
        res.json(result);
    }
    catch (error) {
        console.error(error);
        res.status(401).json({ message: 'Authentication failed' });
    }
};
//# sourceMappingURL=auth.controller.js.map