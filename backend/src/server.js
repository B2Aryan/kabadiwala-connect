const app = require('./app');
const config = require('./config/env');
const logger = require('./utils/logger');

const server = app.listen(config.port, () => {
  logger.info(`Kabadiwala Connect Backend listening on port ${config.port} [${config.nodeEnv}]`);
  logger.info(`Health check available at http://localhost:${config.port}/api/health`);
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Server closed.');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Server closed.');
    process.exit(0);
  });
});

module.exports = server;
