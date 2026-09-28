const crypto = require('crypto');
const azamService = require('../services/azamService');
const config = require('../config/azamConfig');

const getSignatureHeader = (req) => {
    return (
        req.header('x-azam-signature') ||
        req.header('x-azampay-signature') ||
        req.header('x-ayampay-signature') ||
        req.header('x-hub-signature') ||
        req.header('x-signature') ||
        ''
    );
};

const verifySignature = (req) => {
    const secret = config.azamPayWebhookSecret;
    if (!secret) {
        console.warn('AZAMPAY_WEBHOOK_SECRET not configured. Skipping webhook signature verification.');
        return true;
    }

    const signatureHeader = getSignatureHeader(req);
    if (!signatureHeader) {
        return false;
    }

    const rawSignature = signatureHeader.replace(/^sha256=/i, '').trim();
    const expectedSignature = crypto
        .createHmac('sha256', secret)
        .update(req.rawBody || '')
        .digest('hex');

    return rawSignature === expectedSignature;
};

exports.handleCallback = async (req, res) => {
    try {
        if (!verifySignature(req)) {
            return res.status(401).json({ error: 'Invalid webhook signature' });
        }

        const callbackData = req.body;

        console.log('Received Azam Pay callback:', callbackData);

        const result = await azamService.processCallback(callbackData);

        if (!result.success) {
            return res.status(400).json({ error: result.message });
        }

        return res.status(200).json({ received: true });
    } catch (error) {
        console.error('Azam callback error:', error);
        return res.status(500).json({ error: 'Failed to process callback' });
    }
};
