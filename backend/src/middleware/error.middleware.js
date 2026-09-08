const config = require('../config/env');
const logger = require('../utils/logger');
const { errorResponse } = require('../utils/response');

function notFoundHandler(req, res, next) {
  return errorResponse(res, `Route not found: ${req.method} ${req.originalUrl}`, 404, 'NOT_FOUND');
}

function errorHandler(err, req, res, next) {
  logger.error(`Unhandled error during ${req.method} ${req.originalUrl}:`, err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  const code = err.code || 'INTERNAL_ERROR';

  const details = config.nodeEnv === 'production' ? null : (err.details || err.stack);

  return errorResponse(res, message, statusCode, code, details);
}

module.exports = {
  notFoundHandler,
  errorHandler,
};
