export declare const register: (email: string, _name: string, firebaseToken: string, _deviceInfo?: string, _ipAddress?: string) => Promise<{
    accessToken: string;
    refreshToken: string;
    user: {
        id: string;
        email: string | null;
        role: string;
        isActive: boolean;
        createdAt: Date | undefined;
    };
}>;
export declare const loginWithFirebase: (idToken: string, _deviceInfo?: string, _ipAddress?: string, emailHint?: string) => Promise<{
    accessToken: string;
    refreshToken: string;
    user: {
        id: string;
        email: string | null;
        role: string;
        isActive: boolean;
        createdAt: Date | undefined;
    };
}>;
export declare const refreshAccessToken: (refreshToken: string, _deviceInfo?: string, _ipAddress?: string) => Promise<{
    accessToken: string;
    refreshToken: string;
}>;
export declare const cleanupExpiredTokens: () => Promise<void>;
export declare const logout: (_refreshToken: string) => Promise<void>;
//# sourceMappingURL=auth.service.d.ts.map