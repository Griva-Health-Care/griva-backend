export declare const signToken: (userId: string, role: string) => string;
export declare const verifyToken: (token: string) => {
    userId: string;
    role: string;
};
export declare const signRefreshToken: (userId: string, role: string) => string;
export declare const verifyRefreshToken: (token: string) => {
    userId: string;
    role: string;
    typ?: string;
};
//# sourceMappingURL=jwt.d.ts.map