const repo = require('../repositories');

class RecyclerService {
  async listRecyclers(filters = {}) {
    const pickupOnly = filters.pickupOnly === 'true' || filters.pickupOnly === true;
    const maxDistanceKm = filters.maxDistanceKm ? parseFloat(filters.maxDistanceKm) : null;

    return repo.getRecyclers({
      query: filters.query,
      materialKey: filters.materialKey,
      pickupOnly,
      maxDistanceKm,
    });
  }

  async getRecycler(id) {
    return repo.getRecyclerById(id);
  }
}

module.exports = new RecyclerService();
