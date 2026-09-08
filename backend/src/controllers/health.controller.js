const config = require('../config/env');
const { successResponse } = require('../utils/response');

function getHealth(req, res) {
  return successResponse(res, {
    status: 'healthy',
    uptimeSeconds: Math.floor(process.uptime()),
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
    service: 'kabadiwala-connect-backend',
    version: '1.0.0',
    theme: 'Clean & Green Technology',
    mode: config.useMemoryDb ? 'in-memory-isolated' : 'postgresql-active',
  });
}

module.exports = {
  getHealth,
};
