const express = require('express');
const router = express.Router();
const lotsController = require('../controllers/lots.controller');
const { validateCreateLot } = require('../middleware/validation.middleware');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/', lotsController.listLots);
router.get('/:id', lotsController.getLotById);
router.post('/', validateCreateLot, lotsController.createLot);

module.exports = router;
