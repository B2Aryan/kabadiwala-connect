const repo = require('../repositories');

class HandoverService {
  async getHandoverRequest(id) {
    return repo.getHandoverRequestById(id);
  }

  async createHandoverRequest(data, user) {
    // Validate that lot exists
    const lot = await repo.getLotById(data.lotId);
    if (!lot) {
      const err = new Error(`Lot not found with ID ${data.lotId}`);
      err.statusCode = 404;
      err.code = 'LOT_NOT_FOUND';
      throw err;
    }

    // Validate recycler exists
    const recycler = await repo.getRecyclerById(data.recyclerId);
    if (!recycler) {
      const err = new Error(`Recycler not found with ID ${data.recyclerId}`);
      err.statusCode = 404;
      err.code = 'RECYCLER_NOT_FOUND';
      throw err;
    }

    const payload = {
      lotId: lot.id,
      collectorId: user?.id || lot.collectorId || 'COL-MH-2026-089',
      recyclerId: recycler.id,
      recyclerName: recycler.name,
      materialName: lot.materialName,
      quantity: lot.quantity,
      unit: lot.unit,
      estimatedValue: lot.estimatedValue,
      notes: data.notes || '',
      status: 'requested',
      isPendingSync: data.isPendingSync || false,
      scheduledPickupAt: data.scheduledPickupAt || null,
    };

    const request = await repo.createHandoverRequest(payload);

    // Update lot status to reflect handover requested
    await repo.updateLotStatus(lot.id, 'Pickup Requested', recycler.id, recycler.name);

    return request;
  }
}

module.exports = new HandoverService();
