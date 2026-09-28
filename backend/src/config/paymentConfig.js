const path = require('path');

module.exports = {
    rentalCommissionRate: 0.05,
    purchaseCommissionRate: 0.08,
    adminWalletId: 'admin',
    storageDir: path.resolve(__dirname, '../../data'),
    transactionsFile: path.resolve(__dirname, '../../data/transactions.json'),
    walletsFile: path.resolve(__dirname, '../../data/wallets.json'),
};
