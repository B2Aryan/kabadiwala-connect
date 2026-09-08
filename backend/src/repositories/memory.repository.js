/**
 * Pre-seeded in-memory repository for isolated unit & integration tests,
 * and offline/local development without requiring an active PostgreSQL daemon.
 */

class MemoryRepository {
  constructor() {
    this.reset();
  }

  reset() {
    this.collectors = [
      {
        id: 'COL-MH-2026-089',
        phone: '+91 98765 43210',
        fullName: 'रमेश (Ramesh)',
        preferredLanguage: 'hi',
        city: 'Pune, Maharashtra',
        kycStatus: 'VERIFIED',
        totalEarnings: 14250.0,
        completedLots: 18,
        createdAt: new Date('2026-01-15T00:00:00.000Z').toISOString(),
      },
    ];

    this.recyclers = [
      {
        id: 'REC-DEMO-001',
        name: 'GreenCycle Recycling — Demo',
        distanceKm: 1.8,
        acceptedMaterials: ['copper', 'eWaste', 'aluminium'],
        pickupAvailable: true,
        operatingHours: '9:00 AM – 6:00 PM',
        address: 'Plot 42, Hadapsar Industrial Area, Pune',
        phone: '+91 98230 XXXXX (Demo)',
        rating: 4.8,
        statusTag: 'Authorized E-Waste Facility (Demo)',
        disclaimer: 'Demo facility for prototype validation. Not connected to live CPCB/SPCB portal.',
        isDemo: true,
        latitude: 18.5089,
        longitude: 73.9259,
      },
      {
        id: 'REC-DEMO-002',
        name: 'EcoLoop Recycler — Demo',
        distanceKm: 3.2,
        acceptedMaterials: ['copper', 'aluminium', 'other'],
        pickupAvailable: true,
        operatingHours: '8:30 AM – 7:00 PM',
        address: 'Gate 3, Bhosari MIDC, Pune',
        phone: '+91 98221 XXXXX (Demo)',
        rating: 4.6,
        statusTag: 'EPR Registered Partner (Demo)',
        disclaimer: 'Demo facility for prototype validation. Not connected to live CPCB/SPCB portal.',
        isDemo: true,
        latitude: 18.6279,
        longitude: 73.8443,
      },
      {
        id: 'REC-DEMO-003',
        name: 'Circular Tech Recovery — Demo',
        distanceKm: 4.5,
        acceptedMaterials: ['eWaste', 'copper'],
        pickupAvailable: false,
        operatingHours: '10:00 AM – 5:30 PM',
        address: 'Phase 1, Hinjawadi Eco-Park, Pune',
        phone: '+91 98212 XXXXX (Demo)',
        rating: 4.7,
        statusTag: 'Govt. Authorized Yard (Demo)',
        disclaimer: 'Demo facility for prototype validation. Not connected to live CPCB/SPCB portal.',
        isDemo: true,
        latitude: 18.5913,
        longitude: 73.7389,
      },
      {
        id: 'REC-DEMO-004',
        name: 'Bharat Clean Scrap & E-Waste — Demo',
        distanceKm: 6.0,
        acceptedMaterials: ['copper', 'aluminium', 'eWaste', 'other'],
        pickupAvailable: true,
        operatingHours: '9:00 AM – 6:30 PM',
        address: 'Chakan Industrial Zone, Pune',
        phone: '+91 98244 XXXXX (Demo)',
        rating: 4.5,
        statusTag: 'State Certified Unit (Demo)',
        disclaimer: 'Demo facility for prototype validation. Not connected to live CPCB/SPCB portal.',
        isDemo: true,
        latitude: 18.7597,
        longitude: 73.8587,
      },
    ];

    this.lots = [
      {
        id: 'KC-2026-00124',
        collectorId: 'COL-MH-2026-089',
        materialKey: 'eWaste',
        materialName: 'Mixed Electronic PCBs',
        quantity: 25.0,
        unit: 'kg',
        ratePerUnit: 45.0,
        estimatedValue: 1125.0,
        condition: 'good',
        notes: 'Desktop and router motherboards',
        status: 'Handover Completed',
        recyclerId: 'REC-DEMO-001',
        recyclerName: 'GreenCycle Recycling — Demo',
        photos: [],
        createdAt: new Date(Date.now() - 14400000).toISOString(),
        updatedAt: new Date(Date.now() - 10800000).toISOString(),
      },
      {
        id: 'KC-2026-00115',
        collectorId: 'COL-MH-2026-089',
        materialKey: 'copper',
        materialName: 'Copper Motors & Wires',
        quantity: 8.0,
        unit: 'kg',
        ratePerUnit: 720.0,
        estimatedValue: 5760.0,
        condition: 'good',
        notes: 'Stripped transformer winding',
        status: 'Handover Completed',
        recyclerId: 'REC-DEMO-002',
        recyclerName: 'EcoLoop Recycler — Demo',
        photos: [],
        createdAt: new Date(Date.now() - 172800000).toISOString(),
        updatedAt: new Date(Date.now() - 172800000).toISOString(),
      },
    ];

    this.handoverRequests = [
      {
        id: 'REQ-2026-00042',
        lotId: 'KC-2026-00124',
        collectorId: 'COL-MH-2026-089',
        recyclerId: 'REC-DEMO-001',
        recyclerName: 'GreenCycle Recycling — Demo',
        status: 'confirmed',
        materialName: 'Mixed Electronic PCBs',
        quantity: 25.0,
        unit: 'kg',
        estimatedValue: 1125.0,
        notes: 'Doorstep pickup completed',
        isPendingSync: false,
        scheduledPickupAt: new Date(Date.now() - 7200000).toISOString(),
        requestedAt: new Date(Date.now() - 14400000).toISOString(),
        acceptedAt: new Date(Date.now() - 10800000).toISOString(),
        completedAt: new Date(Date.now() - 7200000).toISOString(),
        createdAt: new Date(Date.now() - 14400000).toISOString(),
      },
    ];

    this.transactions = [
      {
        id: 'TXN-2026-00088',
        lotId: 'KC-2026-00124',
        handoverRequestId: 'REQ-2026-00042',
        collectorId: 'COL-MH-2026-089',
        recyclerId: 'REC-DEMO-001',
        recyclerName: 'GreenCycle Recycling — Demo',
        material: 'Mixed Electronic PCBs',
        quantity: 25.0,
        unit: 'kg',
        agreedRate: 45.0,
        grossAmount: 1125.0,
        facilitationFee: 0.0,
        netAmount: 1125.0,
        status: 'completed',
        paymentStatus: 'recorded',
        isPendingSync: false,
        isDemo: true,
        disclaimer: 'Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.',
        completedAt: new Date(Date.now() - 10800000).toISOString(),
        createdAt: new Date(Date.now() - 14400000).toISOString(),
      },
      {
        id: 'TXN-2026-00085',
        lotId: 'KC-2026-00115',
        handoverRequestId: null,
        collectorId: 'COL-MH-2026-089',
        recyclerId: 'REC-DEMO-002',
        recyclerName: 'EcoLoop Recycler — Demo',
        material: 'Copper Motors & Wires',
        quantity: 8.0,
        unit: 'kg',
        agreedRate: 720.0,
        grossAmount: 5760.0,
        facilitationFee: 0.0,
        netAmount: 5760.0,
        status: 'completed',
        paymentStatus: 'recorded',
        isPendingSync: false,
        isDemo: true,
        disclaimer: 'Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.',
        completedAt: new Date(Date.now() - 172800000).toISOString(),
        createdAt: new Date(Date.now() - 172800000).toISOString(),
      },
    ];
  }

  // Recyclers
  async getRecyclers({ query, materialKey, pickupOnly, maxDistanceKm } = {}) {
    return this.recyclers.filter((rec) => {
      if (query && query.trim()) {
        const q = query.trim().toLowerCase();
        const matchName = rec.name.toLowerCase().includes(q);
        const matchAddr = rec.address.toLowerCase().includes(q);
        if (!matchName && !matchAddr) return false;
      }
      if (materialKey && !rec.acceptedMaterials.includes(materialKey)) {
        return false;
      }
      if (pickupOnly === true && !rec.pickupAvailable) {
        return false;
      }
      if (maxDistanceKm && rec.distanceKm > maxDistanceKm) {
        return false;
      }
      return true;
    });
  }

  async getRecyclerById(id) {
    return this.recyclers.find((r) => r.id === id) || null;
  }

  // Lots
  async getLots({ collectorId, status } = {}) {
    return this.lots.filter((lot) => {
      if (collectorId && lot.collectorId !== collectorId) return false;
      if (status && status !== 'all' && lot.status.toLowerCase() !== status.toLowerCase()) return false;
      return true;
    });
  }

  async getLotById(id) {
    return this.lots.find((l) => l.id === id) || null;
  }

  async createLot(lotData) {
    const newLot = {
      id: lotData.id || `KC-${new Date().getFullYear()}-${String(this.lots.length + 125).padStart(5, '0')}`,
      collectorId: lotData.collectorId || 'COL-MH-2026-089',
      materialKey: lotData.materialKey,
      materialName: lotData.materialName,
      quantity: Number(lotData.quantity),
      unit: lotData.unit || 'kg',
      ratePerUnit: Number(lotData.ratePerUnit),
      estimatedValue: Number(lotData.estimatedValue || (lotData.quantity * lotData.ratePerUnit)),
      condition: lotData.condition,
      notes: lotData.notes || '',
      status: lotData.status || 'Created',
      recyclerId: lotData.recyclerId || null,
      recyclerName: lotData.recyclerName || null,
      photos: lotData.photos || [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    this.lots.unshift(newLot);
    return newLot;
  }

  async updateLotStatus(id, status, recyclerId = null, recyclerName = null) {
    const lot = await this.getLotById(id);
    if (!lot) return null;
    lot.status = status;
    if (recyclerId) lot.recyclerId = recyclerId;
    if (recyclerName) lot.recyclerName = recyclerName;
    lot.updatedAt = new Date().toISOString();
    return lot;
  }

  // Handover Requests
  async createHandoverRequest(data) {
    const newReq = {
      id: data.id || `REQ-${new Date().getFullYear()}-${String(this.handoverRequests.length + 43).padStart(5, '0')}`,
      lotId: data.lotId,
      collectorId: data.collectorId || 'COL-MH-2026-089',
      recyclerId: data.recyclerId,
      recyclerName: data.recyclerName || 'Authorized Facility',
      status: data.status || 'requested',
      materialName: data.materialName,
      quantity: Number(data.quantity),
      unit: data.unit || 'kg',
      estimatedValue: Number(data.estimatedValue),
      notes: data.notes || '',
      isPendingSync: data.isPendingSync || false,
      scheduledPickupAt: data.scheduledPickupAt || null,
      requestedAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };
    this.handoverRequests.unshift(newReq);
    return newReq;
  }

  async getHandoverRequestById(id) {
    return this.handoverRequests.find((r) => r.id === id) || null;
  }

  async updateHandoverStatus(id, status) {
    const req = await this.getHandoverRequestById(id);
    if (!req) return null;
    req.status = status;
    req.updatedAt = new Date().toISOString();
    if (status === 'confirmed') {
      req.completedAt = new Date().toISOString();
    }
    return req;
  }

  // Transactions
  async getTransactions({ collectorId, recyclerId } = {}) {
    return this.transactions.filter((txn) => {
      if (collectorId && txn.collectorId !== collectorId) return false;
      if (recyclerId && txn.recyclerId !== recyclerId) return false;
      return true;
    });
  }

  async getTransactionById(id) {
    return this.transactions.find((t) => t.id === id) || null;
  }

  async createTransaction(txnData) {
    const gross = Number(txnData.grossAmount || (txnData.quantity * txnData.agreedRate));
    const fee = Number(txnData.facilitationFee || 0.0);
    const net = Number(txnData.netAmount || (gross - fee));

    const newTxn = {
      id: txnData.id || `TXN-${new Date().getFullYear()}-${String(this.transactions.length + 90).padStart(5, '0')}`,
      lotId: txnData.lotId,
      handoverRequestId: txnData.handoverRequestId || null,
      collectorId: txnData.collectorId || 'COL-MH-2026-089',
      recyclerId: txnData.recyclerId,
      recyclerName: txnData.recyclerName || 'Authorized Recycler',
      material: txnData.material,
      quantity: Number(txnData.quantity),
      unit: txnData.unit || 'kg',
      agreedRate: Number(txnData.agreedRate),
      grossAmount: gross,
      facilitationFee: fee,
      netAmount: net,
      status: txnData.status || 'completed',
      paymentStatus: txnData.paymentStatus || 'recorded',
      isPendingSync: txnData.isPendingSync || false,
      isDemo: txnData.isDemo !== undefined ? txnData.isDemo : true,
      disclaimer: txnData.disclaimer || 'Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.',
      completedAt: txnData.completedAt || new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };
    this.transactions.unshift(newTxn);
    return newTxn;
  }

  // Earnings Summary
  async getEarningsSummary(collectorId = 'COL-MH-2026-089') {
    const collectorTxns = this.transactions.filter((t) => t.collectorId === collectorId);
    const totalRecorded = collectorTxns.reduce((acc, curr) => acc + curr.netAmount, 0.0);
    const totalGross = collectorTxns.reduce((acc, curr) => acc + curr.grossAmount, 0.0);
    const totalFees = collectorTxns.reduce((acc, curr) => acc + curr.facilitationFee, 0.0);
    const completedCount = collectorTxns.length;

    const pendingLots = this.lots.filter(
      (l) => l.collectorId === collectorId && l.status !== 'Handover Completed'
    );

    return {
      collectorId,
      totalEarnings: Math.round(totalRecorded * 100) / 100,
      totalGrossAmount: Math.round(totalGross * 100) / 100,
      totalFacilitationFee: Math.round(totalFees * 100) / 100,
      completedTransactionsCount: completedCount,
      pendingLotsCount: pendingLots.length,
      currency: 'INR',
      currencySymbol: '₹',
      recentTransactions: collectorTxns.slice(0, 5),
    };
  }
}

module.exports = new MemoryRepository();
