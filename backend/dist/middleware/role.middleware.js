"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireRole = void 0;
const requireRole = (...roles) => (req, res, next) => {
    const userRole = req.user?.role;
    if (!userRole || !roles.includes(userRole)) {
        return res.status(403).json({ message: 'Insufficient permissions' });
    }
    next();
};
exports.requireRole = requireRole;
//# sourceMappingURL=role.middleware.js.map