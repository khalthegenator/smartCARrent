const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

const azamCallbackRouter = require('./routes/azamCallback');
const paymentRouter = require('./routes/paymentRoutes');

dotenv.config();

const app = express();

const saveRawBody = (req, res, buf) => {
    if (buf && buf.length) {
        req.rawBody = buf.toString('utf8');
    }
};

app.use(cors());
app.use(express.json({ verify: saveRawBody }));
app.use(express.urlencoded({ extended: true, verify: saveRawBody }));

app.use('/api/azam-pay', azamCallbackRouter);
app.use('/api/payments', paymentRouter);

app.get('/', (req, res) => {
    res.json({ message: 'SmartCARrent backend is running.' });
});

app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

module.exports = app;
