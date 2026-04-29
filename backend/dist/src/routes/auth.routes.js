import { Router } from 'express';
import { login, registerHandler, refresh, logoutHandler } from '../controllers/auth.controller.js';
const router = Router();
router.post('/login', login);
router.post('/firebase-login', login);
router.post('/register', registerHandler);
router.post('/refresh', refresh);
router.post('/logout', logoutHandler);
export default router;
//# sourceMappingURL=auth.routes.js.map