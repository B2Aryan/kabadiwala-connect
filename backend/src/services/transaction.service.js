const repo = require('../repositories');

class TransactionService {
  async listTransactions(filters = {}) {
    return repo.getTransactions({
      collectorId: filters.collectorId,
      recyclerId: filters.recyclerId,
    });
  }

  async getTransaction(id) {
    return repo.getTransactionById(id);
  }

  async createTransaction(data, user) {
    const quantity = parseFloat(data.quantity);
    const agreedRate = parseFloat(data.agreedRate);
    const grossAmount = parseFloat((quantity * agreedRate).toFixed(2));

    // Transparent calculation:
    // Facilitation fee defaults to 0% in MVP/demo prototype
    const feePercentage = data.facilitationFeePercent !== undefined ? parseFloat(data.facilitationFeePercent) : 0.0;
    const facilitationFee = parseFloat(((grossAmount * feePercentage) / 100.0).toFixed(2));
    const netAmount = parseFloat((grossAmount - facilitationFee).toFixed(2));

    const payload = {
      ...data,
      collectorId: user?.id || data.collectorId || 'COL-MH-2026-089',
      quantity,
      agreedRate,
      grossAmount,
      facilitationFee,
      netAmount,
      status: data.status || 'completed',
      paymentStatus: data.paymentStatus || 'recorded',
      isDemo: true,
      disclaimer: 'Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.',
    };

    const txn = await repo.createTransaction(payload);

    // Update corresponding lot status to completed
    if (data.lotId) {
      await repo.updateLotStatus(data.lotId, 'Handover Completed', data.recyclerId, data.recyclerName);
    }

    return txn;
  }

  async getEarningsSummary(collectorId = 'COL-MH-2026-089') {
    return repo.getEarningsSummary(collectorId);
  }
}

module.exports = new TransactionService();
