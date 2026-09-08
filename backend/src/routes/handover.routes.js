const express = require('express');
const router = express.Router();
const handoverController = require('../controllers/handover.controller');
const { validateCreateHandoverRequest } = require('../middleware/validation.middleware');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/:id', handoverController.getHandoverRequestById);
router.post('/', validateCreateHandoverRequest, handoverController.createHandoverRequest);

module.exports = router;
