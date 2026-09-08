const transactionService = require('../services/transaction.service');
const { successResponse } = require('../utils/response');

async function getEarningsSummary(req, res, next) {
  try {
    const collectorId = req.user?.id || 'COL-MH-2026-089';
    const summary = await transactionService.getEarningsSummary(collectorId);
    return successResponse(res, summary);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getEarningsSummary,
};
