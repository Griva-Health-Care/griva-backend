"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logEvent = void 0;
const logEvent = (action, userId, details, ipAddress) => {
    console.log('[AUDIT]', action, { userId, details, ipAddress });
};
exports.logEvent = logEvent;
//# sourceMappingURL=logger.js.map