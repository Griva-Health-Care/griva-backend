import jwt from 'jsonwebtoken';
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || JWT_SECRET;
export const signToken = (userId, role) => {
    return jwt.sign({ userId, role }, JWT_SECRET, { expiresIn: '15m' });
};
export const verifyToken = (token) => {
    return jwt.verify(token, JWT_SECRET);
};
export const signRefreshToken = (userId, role) => {
    return jwt.sign({ userId, role, typ: 'refresh' }, JWT_REFRESH_SECRET, { expiresIn: '30d' });
};
export const verifyRefreshToken = (token) => {
    const decoded = jwt.verify(token, JWT_REFRESH_SECRET);
    if (decoded.typ !== 'refresh') {
        throw new Error('Invalid refresh token');
    }
    return decoded;
};
//# sourceMappingURL=jwt.js.map