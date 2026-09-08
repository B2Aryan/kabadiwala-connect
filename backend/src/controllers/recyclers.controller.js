const recyclerService = require('../services/recycler.service');
const { successResponse, errorResponse } = require('../utils/response');

async function listRecyclers(req, res, next) {
  try {
    const { query, materialKey, pickupOnly, maxDistanceKm } = req.query;
    const recyclers = await recyclerService.listRecyclers({
      query,
      materialKey,
      pickupOnly,
      maxDistanceKm,
    });
    return successResponse(res, recyclers, 200, { total: recyclers.length });
  } catch (err) {
    next(err);
  }
}

async function getRecyclerById(req, res, next) {
  try {
    const { id } = req.params;
    const recycler = await recyclerService.getRecycler(id);
    if (!recycler) {
      return errorResponse(res, `Recycler with ID '${id}' not found`, 404, 'RECYCLER_NOT_FOUND');
    }
    return successResponse(res, recycler);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listRecyclers,
  getRecyclerById,
};
