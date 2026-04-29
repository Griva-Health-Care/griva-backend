import 'dotenv/config';
import app from './app.js';
const PORT = Number(process.env.PORT) || 5000;
try {
    console.log("🚀 Starting server...");
    app.listen(PORT, () => {
        console.log(`✅ Server running on http://localhost:${PORT}`);
    });
}
catch (err) {
    console.error("🔥 Server crash:", err);
}
//# sourceMappingURL=server.js.map