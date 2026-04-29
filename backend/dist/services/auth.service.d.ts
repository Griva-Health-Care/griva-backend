export declare const loginWithFirebase: (idToken: string) => Promise<{
    accessToken: string;
    user: {
        id: string;
        firebaseUid: string;
        email: string;
        fullName: string | null;
        role: string;
        hospital: string | null;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
    };
}>;
//# sourceMappingURL=auth.service.d.ts.map