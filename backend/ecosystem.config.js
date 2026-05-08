module.exports = {
  apps: [
    {
      name: 'griva-backend',
      script: 'dist/server.js',
      interpreter: 'node',

      // ── Instance count ───────────────────────────────────────────────────────
      // 'max' forks one worker per vCPU. For a single-vCPU EC2 instance (t3.micro/small)
      // set instances: 1 to avoid memory pressure. Increase on larger instances.
      instances: 1,
      exec_mode: 'fork',

      // ── Restart policy ───────────────────────────────────────────────────────
      autorestart: true,
      watch: false,
      max_restarts: 10,
      min_uptime: '10s',
      restart_delay: 3000,

      // ── Memory guard ─────────────────────────────────────────────────────────
      max_memory_restart: '400M',

      // ── Env (production) ─────────────────────────────────────────────────────
      // Sensitive values (DATABASE_URL, FIREBASE_CONFIG) are NOT set here.
      // They are read from /etc/environment or a .env file loaded by dotenv
      // in server.ts (dotenv.config() runs before anything else).
      env_production: {
        NODE_ENV: 'production',
        PORT: 5000,
      },

      // ── Logging ──────────────────────────────────────────────────────────────
      out_file: '/var/log/griva/out.log',
      error_file: '/var/log/griva/error.log',
      merge_logs: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',

      // ── Graceful shutdown ─────────────────────────────────────────────────────
      // Matches the 10s force-exit timeout in server.ts
      kill_timeout: 12000,
      listen_timeout: 15000,
    },
  ],
};
