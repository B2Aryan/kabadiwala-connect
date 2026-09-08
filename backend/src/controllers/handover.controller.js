const handoverService = require('../services/handover.service');
const { successResponse, errorResponse } = require('../utils/response');

async function getHandoverRequestById(req, res, next) {
  try {
    const { id } = req.params;
    const request = await handoverService.getHandoverRequest(id);
    if (!request) {
      return errorResponse(res, `Handover request with ID '${id}' not found`, 404, 'HANDOVER_NOT_FOUND');
    }
    return successResponse(res, request);
  } catch (err) {
    next(err);
  }
}

async function createHandoverRequest(req, res, next) {
  try {
    const request = await handoverService.createHandoverRequest(req.body, req.user);
    return successResponse(res, request, 201);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getHandoverRequestById,
  createHandoverRequest,
};
