const express = require('express');
const paymentController = require('../controllers/paymentController');
const paymentCreationController = require('../controllers/paymentCreationController');
const router = express.Router();

router.get('/transactions', paymentController.getTransactions);
router.get('/transactions/customer/:customerId', paymentController.getTransactionsByCustomer);
router.get('/transactions/dealer/:dealerId', paymentController.getTransactionsByDealer);
router.get('/wallets', paymentController.getWallets);
router.get('/wallets/:walletId', paymentController.getWallet);

// Create a simulated payment session (POST) and GET simulator
router.post('/create', paymentCreationController.createSession);
router.get('/simulatePay', paymentCreationController.simulatePayment);

module.exports = router;
