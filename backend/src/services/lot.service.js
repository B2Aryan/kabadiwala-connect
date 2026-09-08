const repo = require('../repositories');

class LotService {
  async listLots(filters = {}) {
    return repo.getLots({
      collectorId: filters.collectorId,
      status: filters.status,
    });
  }

  async getLot(id) {
    return repo.getLotById(id);
  }

  async createLot(lotData, user) {
    const quantity = parseFloat(lotData.quantity);
    const ratePerUnit = parseFloat(lotData.ratePerUnit);
    const estimatedValue = parseFloat((quantity * ratePerUnit).toFixed(2));

    const payload = {
      ...lotData,
      collectorId: user?.id || lotData.collectorId || 'COL-MH-2026-089',
      quantity,
      ratePerUnit,
      estimatedValue,
    };

    return repo.createLot(payload);
  }
}

module.exports = new LotService();
