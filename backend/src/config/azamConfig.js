const dotenv = require('dotenv');
dotenv.config();

module.exports = {
    port: process.env.PORT || 5000,
    azamPayWebhookSecret: process.env.AZAMPAY_WEBHOOK_SECRET || '',
};
