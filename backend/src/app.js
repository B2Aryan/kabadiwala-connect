const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const config = require('./config/env');
const apiRoutes = require('./routes');
const { notFoundHandler, errorHandler } = require('./middleware/error.middleware');

const app = express();

// Security & Parsing Middleware
app.use(helmet());
app.use(cors({ origin: config.corsOrigin }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// HTTP logging (disabled in test)
if (config.nodeEnv !== 'test') {
  app.use(morgan('dev'));
}

// Mount API Routes
app.use('/api', apiRoutes);

// Root redirect / quick info
app.get('/', (req, res) => {
  res.json({
    name: 'Kabadiwala Connect Backend API',
    version: '1.0.0',
    theme: 'Clean & Green Technology (SIH 26229)',
    endpoints: {
      health: '/api/health',
      recyclers: '/api/recyclers',
      lots: '/api/lots',
      handoverRequests: '/api/handover-requests',
      transactions: '/api/transactions',
      earningsSummary: '/api/earnings/summary',
    },
  });
});

// 404 Not Found Handler
app.use(notFoundHandler);

// Centralized Error Handler
app.use(errorHandler);

module.exports = app;
