const { v4: uuidv4 } = require('uuid');
const paymentService = require('../services/paymentService');
const azamService = require('../services/azamService');

// Create a payment session (simulated)
exports.createSession = (req, res) => {
    try {
        const { amount, dealerId, customerId, listingType, paymentProvider, customerPhone } = req.body;
        if (!amount || !dealerId || !customerId || !listingType) {
            return res.status(400).json({ success: false, message: 'Missing required fields' });
        }

        const transactionId = uuidv4();

        const queryParts = [
            `transactionId=${encodeURIComponent(transactionId)}`,
            `amount=${encodeURIComponent(amount)}`,
            `dealerId=${encodeURIComponent(dealerId)}`,
            `customerId=${encodeURIComponent(customerId)}`,
            `listingType=${encodeURIComponent(listingType)}`,
        ];
        if (paymentProvider) {
            queryParts.push(`paymentProvider=${encodeURIComponent(paymentProvider)}`);
        }
        if (customerPhone) {
            queryParts.push(`customerPhone=${encodeURIComponent(customerPhone)}`);
        }

        const paymentUrl = `${req.protocol}://${req.get('host')}/api/payments/simulatePay?${queryParts.join('&')}`;

        paymentService.recordTransaction({
            id: transactionId,
            dealerId,
            customerId,
            listingType,
            amount: Number(amount),
            commission: 0,
            dealerAmount: 0,
            paymentProvider: paymentProvider ?? null,
            customerPhone: customerPhone ?? null,
            status: 'PENDING',
            createdAt: new Date().toISOString(),
        });

        return res.json({ success: true, transactionId, paymentUrl });
    } catch (error) {
        console.error('createSession error:', error);
        return res.status(500).json({ success: false, message: 'Failed to create payment session' });
    }
};

// Simulate visiting the payment provider and completing payment
exports.simulatePayment = async (req, res) => {
    try {
        const { transactionId, amount, dealerId, customerId, listingType, paymentProvider, customerPhone } = req.query;
        if (!transactionId || !amount || !dealerId || !customerId || !listingType) {
            return res.status(400).send('Missing required query parameters');
        }

        const callbackData = {
            transactionId,
            status: 'SUCCESS',
            amount: Number(amount),
            dealerId,
            customerId,
            listingType,
            paymentProvider: paymentProvider || null,
            customerPhone: customerPhone || null,
        };

        // Directly call the service that processes callbacks (bypassing webhook signature)
        const result = await azamService.processCallback(callbackData);

        // Simple HTML response for the simulated payment page
        res.setHeader('Content-Type', 'text/html');
        return res.send(`<!doctype html><html><head><title>Simulated Payment</title></head><body><h1>Payment Simulation</h1><p>Transaction ${transactionId} processed.</p><pre>${JSON.stringify(result)}</pre><p>You can close this page.</p></body></html>`);
    } catch (error) {
        console.error('simulatePayment error:', error);
        return res.status(500).send('Failed to simulate payment');
    }
};
