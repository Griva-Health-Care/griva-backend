import jwt from 'jsonwebtoken';
const JWT_SECRET = process.env.JWT_SECRET;
export const signToken = (userId) => {
    return jwt.sign({ userId }, JWT_SECRET, { expiresIn: '15m' });
};
export const verifyToken = (token) => {
    return jwt.verify(token, JWT_SECRET);
};
//# sourceMappingURL=jwt.js.map