const paymentService = require('./paymentService');

exports.processCallback = async (callbackData) => {
    if (!callbackData || !callbackData.transactionId || !callbackData.status || !callbackData.amount || !callbackData.dealerId || !callbackData.customerId || !callbackData.listingType) {
        return { success: false, message: 'Missing required callback data' };
    }

    if (callbackData.status !== 'SUCCESS' && callbackData.status !== 'COMPLETED') {
        return { success: false, message: 'Payment not completed' };
    }

    const amount = Number(callbackData.amount);
    if (Number.isNaN(amount) || amount <= 0) {
        return { success: false, message: 'Invalid amount' };
    }

    const result = paymentService.processTransaction({
        transactionId: callbackData.transactionId,
        dealerId: callbackData.dealerId,
        customerId: callbackData.customerId,
        listingType: callbackData.listingType.toString().toLowerCase() == 'purchase' ? 'purchase' : 'rental',
        amount,
        status: callbackData.status,
        paymentProvider: callbackData.paymentProvider ?? null,
        customerPhone: callbackData.customerPhone ?? null,
    });

    console.log('Payment succeeded. transactionId:', callbackData.transactionId);
    console.log('Dealer ID:', callbackData.dealerId);
    console.log('Amount:', amount);
    console.log('Commission:', result.commission);
    console.log('Dealer credit:', result.dealerAmount);

    return { success: true };
};
