const transactionService = require('../services/transaction.service');
const { successResponse, errorResponse } = require('../utils/response');

async function listTransactions(req, res, next) {
  try {
    const collectorId = req.user?.id || 'COL-MH-2026-089';
    const { recyclerId } = req.query;
    const transactions = await transactionService.listTransactions({
      collectorId,
      recyclerId,
    });
    return successResponse(res, transactions, 200, { total: transactions.length });
  } catch (err) {
    next(err);
  }
}

async function getTransactionById(req, res, next) {
  try {
    const { id } = req.params;
    const transaction = await transactionService.getTransaction(id);
    if (!transaction) {
      return errorResponse(res, `Transaction with ID '${id}' not found`, 404, 'TRANSACTION_NOT_FOUND');
    }
    return successResponse(res, transaction);
  } catch (err) {
    next(err);
  }
}

async function createTransaction(req, res, next) {
  try {
    const transaction = await transactionService.createTransaction(req.body, req.user);
    return successResponse(res, transaction, 201);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listTransactions,
  getTransactionById,
  createTransaction,
};
