const fs = require('fs');
const path = require('path');
const paymentConfig = require('../config/paymentConfig');

const ensureDataFiles = () => {
    if (!fs.existsSync(paymentConfig.storageDir)) {
        fs.mkdirSync(paymentConfig.storageDir, { recursive: true });
    }
    if (!fs.existsSync(paymentConfig.transactionsFile)) {
        fs.writeFileSync(paymentConfig.transactionsFile, JSON.stringify([]));
    }
    if (!fs.existsSync(paymentConfig.walletsFile)) {
        fs.writeFileSync(paymentConfig.walletsFile, JSON.stringify({}));
    }
};

const readJson = (filePath) => {
    const raw = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(raw);
};

const writeJson = (filePath, data) => {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
};

const calculateCommission = (amount, isPurchase) => {
    const rate = isPurchase
        ? paymentConfig.purchaseCommissionRate
        : paymentConfig.rentalCommissionRate;
    return parseFloat((amount * rate).toFixed(2));
};

const creditWallet = (walletId, amount) => {
    const wallets = readJson(paymentConfig.walletsFile);
    wallets[walletId] = wallets[walletId] || { balance: 0, transactions: [] };
    wallets[walletId].balance = parseFloat((wallets[walletId].balance + amount).toFixed(2));
    return wallets;
};

exports.recordTransaction = (transaction) => {
    ensureDataFiles();
    const transactions = readJson(paymentConfig.transactionsFile);
    const now = new Date().toISOString();
    const normalizedTransaction = {
        ...transaction,
        amount: Number(transaction.amount),
        commission: Number(transaction.commission ?? 0),
        dealerAmount: Number(transaction.dealerAmount ?? 0),
        status: transaction.status ?? 'PENDING',
        paymentProvider: transaction.paymentProvider ?? null,
        customerPhone: transaction.customerPhone ?? null,
        createdAt: transaction.createdAt ?? now,
        updatedAt: now,
        receipt: {
            transactionId: transaction.id,
            date: transaction.createdAt ?? now,
            amount: Number(transaction.amount),
            listingType: transaction.listingType,
            dealerId: transaction.dealerId,
            customerId: transaction.customerId,
            paymentProvider: transaction.paymentProvider ?? null,
            customerPhone: transaction.customerPhone ?? null,
            status: transaction.status ?? 'PENDING',
        },
    };
    const index = transactions.findIndex((t) => t.id === normalizedTransaction.id);
    if (index >= 0) {
        transactions[index] = { ...transactions[index], ...normalizedTransaction };
    } else {
        transactions.push(normalizedTransaction);
    }
    writeJson(paymentConfig.transactionsFile, transactions);
};

exports.creditDealer = (dealerId, amount) => {
    ensureDataFiles();
    const wallets = creditWallet(dealerId, amount);
    writeJson(paymentConfig.walletsFile, wallets);
};

exports.creditAdmin = (amount) => {
    ensureDataFiles();
    const wallets = creditWallet(paymentConfig.adminWalletId, amount);
    writeJson(paymentConfig.walletsFile, wallets);
};

exports.getTransactions = () => {
    ensureDataFiles();
    return readJson(paymentConfig.transactionsFile);
};

exports.getTransactionById = (transactionId) => {
    ensureDataFiles();
    const transactions = readJson(paymentConfig.transactionsFile);
    return transactions.find((t) => t.id === transactionId) || null;
};

exports.getTransactionsByCustomer = (customerId) => {
    ensureDataFiles();
    const transactions = readJson(paymentConfig.transactionsFile);
    return transactions.filter((t) => t.customerId === customerId);
};

exports.getTransactionsByDealer = (dealerId) => {
    ensureDataFiles();
    const transactions = readJson(paymentConfig.transactionsFile);
    return transactions.filter((t) => t.dealerId === dealerId);
};

exports.getWallets = () => {
    ensureDataFiles();
    return readJson(paymentConfig.walletsFile);
};

exports.getWalletById = (walletId) => {
    ensureDataFiles();
    const wallets = readJson(paymentConfig.walletsFile);
    return wallets[walletId] || { balance: 0, transactions: [] };
};

exports.processTransaction = (transactionData) => {
    const amount = Number(transactionData.amount);
    const isPurchase = transactionData.listingType === 'purchase';
    const commission = calculateCommission(amount, isPurchase);
    const dealerAmount = parseFloat((amount - commission).toFixed(2));

    exports.creditDealer(transactionData.dealerId, dealerAmount);
    exports.creditAdmin(commission);

    exports.recordTransaction({
        id: transactionData.transactionId,
        dealerId: transactionData.dealerId,
        customerId: transactionData.customerId,
        listingType: transactionData.listingType,
        amount,
        commission,
        dealerAmount,
        paymentProvider: transactionData.paymentProvider ?? null,
        customerPhone: transactionData.customerPhone ?? null,
        status: 'COMPLETED',
        createdAt: new Date().toISOString(),
    });

    return {
        transactionId: transactionData.transactionId,
        amount,
        commission,
        dealerAmount,
        wallet: {
            dealer: transactionData.dealerId,
            admin: paymentConfig.adminWalletId,
        },
    };
};
