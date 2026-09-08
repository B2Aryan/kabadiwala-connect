const jwt = require('jsonwebtoken');
const config = require('../config/env');
const { errorResponse } = require('../utils/response');

const DEFAULT_MOCK_USER = {
  id: 'COL-MH-2026-089',
  phone: '+91 98765 43210',
  fullName: 'रमेश (Ramesh)',
  role: 'COLLECTOR',
};

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
      const decoded = jwt.verify(token, config.jwtSecret);
      req.user = decoded;
      return next();
    } catch (err) {
      return errorResponse(res, 'Invalid or expired token', 401, 'UNAUTHORIZED');
    }
  }

  // MVP Fallback: If no token provided, attach the active mock collector session
  req.user = DEFAULT_MOCK_USER;
  return next();
}

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return errorResponse(res, 'Authentication token required', 401, 'UNAUTHORIZED');
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, config.jwtSecret);
    req.user = decoded;
    return next();
  } catch (err) {
    return errorResponse(res, 'Invalid or expired authentication token', 401, 'UNAUTHORIZED');
  }
}

function generateToken(payload, expiresIn = '30d') {
  return jwt.sign(payload, config.jwtSecret, { expiresIn });
}

module.exports = {
  authenticate,
  requireAuth,
  generateToken,
  DEFAULT_MOCK_USER,
};
