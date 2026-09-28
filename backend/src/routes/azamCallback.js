const express = require('express');
const azamController = require('../controllers/azamController');
const router = express.Router();

router.post('/callback', azamController.handleCallback);

module.exports = router;
