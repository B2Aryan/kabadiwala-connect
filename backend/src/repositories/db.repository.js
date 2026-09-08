const db = require('../config/database');

/**
 * PostgreSQL Database Repository
 * Uses parameterized queries to prevent SQL injection vulnerabilities.
 */
class DbRepository {
  // Recyclers
  async getRecyclers({ query, materialKey, pickupOnly, maxDistanceKm } = {}) {
    let sql = `
      SELECT r.*, ARRAY_AGG(rm.material_key) AS accepted_materials
      FROM recyclers r
      LEFT JOIN recycler_materials rm ON r.id = rm.recycler_id
      WHERE 1=1
    `;
    const params = [];

    if (query && query.trim()) {
      params.push(`%${query.trim()}%`);
      sql += ` AND (r.name ILIKE $${params.length} OR r.address ILIKE $${params.length})`;
    }

    if (pickupOnly === true) {
      sql += ` AND r.pickup_available = TRUE`;
    }

    sql += ` GROUP BY r.id`;

    if (materialKey) {
      params.push(materialKey);
      sql += ` HAVING $${params.length} = ANY(ARRAY_AGG(rm.material_key))`;
    }

    sql += ` ORDER BY r.name ASC`;

    const res = await db.query(sql, params);
    return res.rows.map((row) => ({
      id: row.id,
      name: row.name,
      authorizationNumber: row.authorization_number,
      isAuthorized: row.is_authorized,
      pickupAvailable: row.pickup_available,
      operatingHours: row.operating_hours,
      address: row.address,
      phone: row.phone,
      rating: parseFloat(row.rating) || 4.8,
      statusTag: row.status_tag,
      disclaimer: row.disclaimer,
      isDemo: row.is_demo,
      latitude: parseFloat(row.latitude),
      longitude: parseFloat(row.longitude),
      acceptedMaterials: row.accepted_materials ? row.accepted_materials.filter(Boolean) : [],
    }));
  }

  async getRecyclerById(id) {
    const sql = `
      SELECT r.*, ARRAY_AGG(rm.material_key) AS accepted_materials
      FROM recyclers r
      LEFT JOIN recycler_materials rm ON r.id = rm.recycler_id
      WHERE r.id = $1
      GROUP BY r.id
    `;
    const res = await db.query(sql, [id]);
    if (res.rows.length === 0) return null;
    const row = res.rows[0];
    return {
      id: row.id,
      name: row.name,
      authorizationNumber: row.authorization_number,
      isAuthorized: row.is_authorized,
      pickupAvailable: row.pickup_available,
      operatingHours: row.operating_hours,
      address: row.address,
      phone: row.phone,
      rating: parseFloat(row.rating) || 4.8,
      statusTag: row.status_tag,
      disclaimer: row.disclaimer,
      isDemo: row.is_demo,
      latitude: parseFloat(row.latitude),
      longitude: parseFloat(row.longitude),
      acceptedMaterials: row.accepted_materials ? row.accepted_materials.filter(Boolean) : [],
    };
  }

  // Lots
  async getLots({ collectorId, status } = {}) {
    let sql = `SELECT * FROM ewaste_lots WHERE 1=1`;
    const params = [];

    if (collectorId) {
      params.push(collectorId);
      sql += ` AND collector_id = $${params.length}`;
    }
    if (status && status !== 'all') {
      params.push(status);
      sql += ` AND status ILIKE $${params.length}`;
    }
    sql += ` ORDER BY created_at DESC`;

    const res = await db.query(sql, params);
    return res.rows.map(this._mapLot);
  }

  async getLotById(id) {
    const res = await db.query(`SELECT * FROM ewaste_lots WHERE id = $1`, [id]);
    if (res.rows.length === 0) return null;
    return this._mapLot(res.rows[0]);
  }

  async createLot(lotData) {
    const id = lotData.id || `KC-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;
    const sql = `
      INSERT INTO ewaste_lots (
        id, collector_id, material_key, material_name, quantity, unit,
        rate_per_unit, estimated_value, condition, notes, status,
        recycler_id, recycler_name, photos
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *
    `;
    const params = [
      id,
      lotData.collectorId || 'COL-MH-2026-089',
      lotData.materialKey,
      lotData.materialName,
      lotData.quantity,
      lotData.unit || 'kg',
      lotData.ratePerUnit,
      lotData.estimatedValue || (lotData.quantity * lotData.ratePerUnit),
      lotData.condition,
      lotData.notes || '',
      lotData.status || 'Created',
      lotData.recyclerId || null,
      lotData.recyclerName || null,
      lotData.photos || [],
    ];
    const res = await db.query(sql, params);
    return this._mapLot(res.rows[0]);
  }

  async updateLotStatus(id, status, recyclerId = null, recyclerName = null) {
    const sql = `
      UPDATE ewaste_lots
      SET status = $2,
          recycler_id = COALESCE($3, recycler_id),
          recycler_name = COALESCE($4, recycler_name),
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;
    const res = await db.query(sql, [id, status, recyclerId, recyclerName]);
    if (res.rows.length === 0) return null;
    return this._mapLot(res.rows[0]);
  }

  // Handover Requests
  async createHandoverRequest(data) {
    const id = data.id || `REQ-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;
    const sql = `
      INSERT INTO handover_requests (
        id, lot_id, collector_id, recycler_id, recycler_name, status,
        material_name, quantity, unit, estimated_value, notes, is_pending_sync
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `;
    const params = [
      id,
      data.lotId,
      data.collectorId || 'COL-MH-2026-089',
      data.recyclerId,
      data.recyclerName || 'Authorized Facility',
      data.status || 'requested',
      data.materialName,
      data.quantity,
      data.unit || 'kg',
      data.estimatedValue,
      data.notes || '',
      data.isPendingSync || false,
    ];
    const res = await db.query(sql, params);
    return this._mapHandover(res.rows[0]);
  }

  async getHandoverRequestById(id) {
    const res = await db.query(`SELECT * FROM handover_requests WHERE id = $1`, [id]);
    if (res.rows.length === 0) return null;
    return this._mapHandover(res.rows[0]);
  }

  // Transactions
  async getTransactions({ collectorId, recyclerId } = {}) {
    let sql = `SELECT * FROM transactions WHERE 1=1`;
    const params = [];
    if (collectorId) {
      params.push(collectorId);
      sql += ` AND collector_id = $${params.length}`;
    }
    if (recyclerId) {
      params.push(recyclerId);
      sql += ` AND recycler_id = $${params.length}`;
    }
    sql += ` ORDER BY created_at DESC`;

    const res = await db.query(sql, params);
    return res.rows.map(this._mapTransaction);
  }

  async getTransactionById(id) {
    const res = await db.query(`SELECT * FROM transactions WHERE id = $1`, [id]);
    if (res.rows.length === 0) return null;
    return this._mapTransaction(res.rows[0]);
  }

  async createTransaction(txnData) {
    const id = txnData.id || `TXN-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;
    const gross = Number(txnData.grossAmount || (txnData.quantity * txnData.agreedRate));
    const fee = Number(txnData.facilitationFee || 0.0);
    const net = Number(txnData.netAmount || (gross - fee));

    const sql = `
      INSERT INTO transactions (
        id, lot_id, handover_request_id, collector_id, recycler_id,
        recycler_name, material, quantity, unit, agreed_rate,
        gross_amount, facilitation_fee, net_amount, status, payment_status,
        is_pending_sync, is_demo, disclaimer, completed_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
      RETURNING *
    `;
    const params = [
      id,
      txnData.lotId,
      txnData.handoverRequestId || null,
      txnData.collectorId || 'COL-MH-2026-089',
      txnData.recyclerId,
      txnData.recyclerName || 'Authorized Recycler',
      txnData.material,
      txnData.quantity,
      txnData.unit || 'kg',
      txnData.agreedRate,
      gross,
      fee,
      net,
      txnData.status || 'completed',
      txnData.paymentStatus || 'recorded',
      txnData.isPendingSync || false,
      txnData.isDemo !== undefined ? txnData.isDemo : true,
      txnData.disclaimer || 'Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.',
      txnData.completedAt || new Date().toISOString(),
    ];
    const res = await db.query(sql, params);
    return this._mapTransaction(res.rows[0]);
  }

  async getEarningsSummary(collectorId = 'COL-MH-2026-089') {
    const sql = `
      SELECT 
        COALESCE(SUM(net_amount), 0) AS total_earnings,
        COALESCE(SUM(gross_amount), 0) AS total_gross_amount,
        COALESCE(SUM(facilitation_fee), 0) AS total_facilitation_fee,
        COUNT(*) AS completed_count
      FROM transactions
      WHERE collector_id = $1 AND status = 'completed'
    `;
    const res = await db.query(sql, [collectorId]);
    const row = res.rows[0];

    const lotsSql = `
      SELECT COUNT(*) AS pending_count
      FROM ewaste_lots
      WHERE collector_id = $1 AND status != 'Handover Completed'
    `;
    const lotsRes = await db.query(lotsSql, [collectorId]);

    const recentTxns = await this.getTransactions({ collectorId });

    return {
      collectorId,
      totalEarnings: parseFloat(row.total_earnings) || 0.0,
      totalGrossAmount: parseFloat(row.total_gross_amount) || 0.0,
      totalFacilitationFee: parseFloat(row.total_facilitation_fee) || 0.0,
      completedTransactionsCount: parseInt(row.completed_count, 10) || 0,
      pendingLotsCount: parseInt(lotsRes.rows[0].pending_count, 10) || 0,
      currency: 'INR',
      currencySymbol: '₹',
      recentTransactions: recentTxns.slice(0, 5),
    };
  }

  // Mappers
  _mapLot(row) {
    return {
      id: row.id,
      collectorId: row.collector_id,
      materialKey: row.material_key,
      materialName: row.material_name,
      quantity: parseFloat(row.quantity),
      unit: row.unit,
      ratePerUnit: parseFloat(row.rate_per_unit),
      estimatedValue: parseFloat(row.estimated_value),
      condition: row.condition,
      notes: row.notes,
      status: row.status,
      recyclerId: row.recycler_id,
      recyclerName: row.recycler_name,
      photos: row.photos || [],
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  _mapHandover(row) {
    return {
      id: row.id,
      lotId: row.lot_id,
      collectorId: row.collector_id,
      recyclerId: row.recycler_id,
      recyclerName: row.recycler_name,
      status: row.status,
      materialName: row.material_name,
      quantity: parseFloat(row.quantity),
      unit: row.unit,
      estimatedValue: parseFloat(row.estimated_value),
      notes: row.notes,
      isPendingSync: row.is_pending_sync,
      scheduledPickupAt: row.scheduled_pickup_at,
      requestedAt: row.requested_at,
      acceptedAt: row.accepted_at,
      completedAt: row.completed_at,
      createdAt: row.created_at,
    };
  }

  _mapTransaction(row) {
    return {
      id: row.id,
      lotId: row.lot_id,
      handoverRequestId: row.handover_request_id,
      collectorId: row.collector_id,
      recyclerId: row.recycler_id,
      recyclerName: row.recycler_name,
      material: row.material,
      quantity: parseFloat(row.quantity),
      unit: row.unit,
      agreedRate: parseFloat(row.agreed_rate),
      grossAmount: parseFloat(row.gross_amount),
      facilitationFee: parseFloat(row.facilitation_fee),
      netAmount: parseFloat(row.net_amount),
      status: row.status,
      paymentStatus: row.payment_status,
      isPendingSync: row.is_pending_sync,
      isDemo: row.is_demo,
      disclaimer: row.disclaimer,
      completedAt: row.completed_at,
      createdAt: row.created_at,
    };
  }
}

module.exports = new DbRepository();
