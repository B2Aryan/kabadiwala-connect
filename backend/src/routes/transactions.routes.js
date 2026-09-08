const express = require('express');
const router = express.Router();
const transactionsController = require('../controllers/transactions.controller');
const { validateCreateTransaction } = require('../middleware/validation.middleware');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/', transactionsController.listTransactions);
router.get('/:id', transactionsController.getTransactionById);
router.post('/', validateCreateTransaction, transactionsController.createTransaction);

module.exports = router;
