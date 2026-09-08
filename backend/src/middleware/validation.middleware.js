const { errorResponse } = require('../utils/response');

function validateCreateLot(req, res, next) {
  const { materialKey, materialName, quantity, ratePerUnit, unit, condition } = req.body;
  const errors = [];

  if (!materialKey || typeof materialKey !== 'string') {
    errors.push('materialKey is required and must be a string (e.g. copper, aluminium, eWaste, other)');
  }
  if (!materialName || typeof materialName !== 'string') {
    errors.push('materialName is required and must be a string');
  }
  if (quantity === undefined || quantity === null || typeof quantity !== 'number' || quantity <= 0) {
    errors.push('quantity must be a positive number greater than 0');
  }
  if (ratePerUnit === undefined || ratePerUnit === null || typeof ratePerUnit !== 'number' || ratePerUnit < 0) {
    errors.push('ratePerUnit must be a valid non-negative number');
  }
  if (!condition || typeof condition !== 'string') {
    errors.push('condition is required (e.g. good, broken, scrap)');
  }

  if (errors.length > 0) {
    return errorResponse(res, 'Validation failed for lot creation', 400, 'VALIDATION_ERROR', errors);
  }

  next();
}

function validateCreateHandoverRequest(req, res, next) {
  const { lotId, recyclerId } = req.body;
  const errors = [];

  if (!lotId || typeof lotId !== 'string') {
    errors.push('lotId is required and must be a string');
  }
  if (!recyclerId || typeof recyclerId !== 'string') {
    errors.push('recyclerId is required and must be a string');
  }

  if (errors.length > 0) {
    return errorResponse(res, 'Validation failed for handover request', 400, 'VALIDATION_ERROR', errors);
  }

  next();
}

function validateCreateTransaction(req, res, next) {
  const { lotId, recyclerId, material, quantity, agreedRate } = req.body;
  const errors = [];

  if (!lotId || typeof lotId !== 'string') {
    errors.push('lotId is required');
  }
  if (!recyclerId || typeof recyclerId !== 'string') {
    errors.push('recyclerId is required');
  }
  if (!material || typeof material !== 'string') {
    errors.push('material is required');
  }
  if (quantity === undefined || typeof quantity !== 'number' || quantity <= 0) {
    errors.push('quantity must be a positive number');
  }
  if (agreedRate === undefined || typeof agreedRate !== 'number' || agreedRate < 0) {
    errors.push('agreedRate must be a non-negative number');
  }

  if (errors.length > 0) {
    return errorResponse(res, 'Validation failed for transaction recording', 400, 'VALIDATION_ERROR', errors);
  }

  next();
}

module.exports = {
  validateCreateLot,
  validateCreateHandoverRequest,
  validateCreateTransaction,
};
