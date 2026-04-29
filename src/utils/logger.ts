export const logEvent = (action: string, userId?: string, details?: string, ipAddress?: string) => {
  console.log('[AUDIT]', action, { userId, details, ipAddress });
};
