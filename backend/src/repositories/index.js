const config = require('../config/env');
const memoryRepo = require('./memory.repository');
const dbRepo = require('./db.repository');
const logger = require('../utils/logger');

let activeRepository = memoryRepo;

if (!config.useMemoryDb) {
  activeRepository = dbRepo;
  logger.info('Configured repository: PostgreSQL Database Repository');
} else {
  logger.info('Configured repository: In-Memory Seeded Repository (Isolated/Test/Dev mode)');
}

module.exports = activeRepository;
