const express = require('express');
const router = express.Router();
const recyclersController = require('../controllers/recyclers.controller');

router.get('/', recyclersController.listRecyclers);
router.get('/:id', recyclersController.getRecyclerById);

module.exports = router;
