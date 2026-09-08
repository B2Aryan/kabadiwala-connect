const { Pool } = require('pg');
const config = require('./env');

let pool = null;

if (!config.useMemoryDb && config.databaseUrl) {
  pool = new Pool({
    connectionString: config.databaseUrl,
    ssl: config.nodeEnv === 'production' ? { rejectUnauthorized: false } : false,
    max: 10,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
  });

  pool.on('error', (err) => {
    console.error('Unexpected PostgreSQL client error:', err.message);
  });
}

module.exports = {
  pool,
  query: async (text, params) => {
    if (!pool) {
      throw new Error('Database pool is not initialized. Running in memory mode or database unavailable.');
    }
    return pool.query(text, params);
  },
};
