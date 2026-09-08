require('dotenv').config();

module.exports = {
  port: parseInt(process.env.PORT, 10) || 5000,
  nodeEnv: process.env.NODE_ENV || 'development',
  databaseUrl: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/kabadiwala_connect',
  jwtSecret: process.env.JWT_SECRET || 'kabadiwala_connect_demo_super_secret_jwt_key_2026',
  corsOrigin: process.env.CORS_ORIGIN || '*',
  useMemoryDb: process.env.USE_MEMORY_DB === 'true' || process.env.NODE_ENV === 'test',
};
