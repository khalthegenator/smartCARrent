const paymentService = require('../services/paymentService');

exports.getTransactions = (req, res) => {
    try {
        const transactions = paymentService.getTransactions();
        res.json({ success: true, transactions });
    } catch (error) {
        console.error('Failed to get transactions:', error);
        res.status(500).json({ success: false, error: 'Failed to load transactions' });
    }
};

exports.getTransactionsByCustomer = (req, res) => {
    try {
        const { customerId } = req.params;
        const transactions = paymentService.getTransactionsByCustomer(customerId);
        res.json({ success: true, transactions });
    } catch (error) {
        console.error('Failed to get customer transactions:', error);
        res.status(500).json({ success: false, error: 'Failed to load customer transactions' });
    }
};

exports.getTransactionsByDealer = (req, res) => {
    try {
        const { dealerId } = req.params;
        const transactions = paymentService.getTransactionsByDealer(dealerId);
        res.json({ success: true, transactions });
    } catch (error) {
        console.error('Failed to get dealer transactions:', error);
        res.status(500).json({ success: false, error: 'Failed to load dealer transactions' });
    }
};

exports.getWallets = (req, res) => {
    try {
        const wallets = paymentService.getWallets();
        res.json({ success: true, wallets });
    } catch (error) {
        console.error('Failed to get wallets:', error);
        res.status(500).json({ success: false, error: 'Failed to load wallets' });
    }
};

exports.getWallet = (req, res) => {
    try {
        const { walletId } = req.params;
        const wallet = paymentService.getWalletById(walletId);
        res.json({ success: true, wallet });
    } catch (error) {
        console.error('Failed to get wallet:', error);
        res.status(500).json({ success: false, error: 'Failed to load wallet' });
    }
};
