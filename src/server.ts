import dotenv from 'dotenv';
dotenv.config();

import app from './app';

const PORT = Number(process.env.PORT) || 5000;

try {
  console.log("🚀 Starting server...");

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Server running on port ${PORT}`);
  });

} catch (err) {
  console.error("🔥 Server crash:", err);
}