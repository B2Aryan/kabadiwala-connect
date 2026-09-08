const config = require('../config/env');

const logger = {
  info: (msg, meta = '') => {
    if (config.nodeEnv !== 'test') {
      console.log(`[INFO] ${new Date().toISOString()} - ${msg}`, meta ? JSON.stringify(meta) : '');
    }
  },
  warn: (msg, meta = '') => {
    if (config.nodeEnv !== 'test') {
      console.warn(`[WARN] ${new Date().toISOString()} - ${msg}`, meta ? JSON.stringify(meta) : '');
    }
  },
  error: (msg, err = '') => {
    if (config.nodeEnv !== 'test') {
      console.error(`[ERROR] ${new Date().toISOString()} - ${msg}`, err);
    }
  },
};

module.exports = logger;
