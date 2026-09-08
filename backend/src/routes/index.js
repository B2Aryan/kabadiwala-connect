const express = require('express');
const router = express.Router();

const healthRoutes = require('./health.routes');
const recyclersRoutes = require('./recyclers.routes');
const lotsRoutes = require('./lots.routes');
const handoverRoutes = require('./handover.routes');
const transactionsRoutes = require('./transactions.routes');
const earningsRoutes = require('./earnings.routes');

router.use('/', healthRoutes);
router.use('/recyclers', recyclersRoutes);
router.use('/lots', lotsRoutes);
router.use('/handover-requests', handoverRoutes);
router.use('/transactions', transactionsRoutes);
router.use('/earnings', earningsRoutes);

module.exports = router;
