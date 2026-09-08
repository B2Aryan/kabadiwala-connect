const express = require('express');
const router = express.Router();
const earningsController = require('../controllers/earnings.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/summary', earningsController.getEarningsSummary);

module.exports = router;
