const lotService = require('../services/lot.service');
const { successResponse, errorResponse } = require('../utils/response');

async function listLots(req, res, next) {
  try {
    const { status } = req.query;
    const collectorId = req.user?.id || 'COL-MH-2026-089';
    const lots = await lotService.listLots({ collectorId, status });
    return successResponse(res, lots, 200, { total: lots.length });
  } catch (err) {
    next(err);
  }
}

async function getLotById(req, res, next) {
  try {
    const { id } = req.params;
    const lot = await lotService.getLot(id);
    if (!lot) {
      return errorResponse(res, `Lot with ID '${id}' not found`, 404, 'LOT_NOT_FOUND');
    }
    return successResponse(res, lot);
  } catch (err) {
    next(err);
  }
}

async function createLot(req, res, next) {
  try {
    const newLot = await lotService.createLot(req.body, req.user);
    return successResponse(res, newLot, 201);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listLots,
  getLotById,
  createLot,
};
