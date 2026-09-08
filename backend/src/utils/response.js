/**
 * Standard API response envelope helpers
 */

function successResponse(res, data, statusCode = 200, meta = null) {
  const payload = {
    success: true,
    data,
  };
  if (meta) {
    payload.meta = meta;
  }
  return res.status(statusCode).json(payload);
}

function errorResponse(res, message, statusCode = 400, code = 'BAD_REQUEST', details = null) {
  const errorObj = {
    code,
    message,
  };
  if (details !== null) {
    errorObj.details = details;
  }
  return res.status(statusCode).json({
    success: false,
    error: errorObj,
  });
}

module.exports = {
  successResponse,
  errorResponse,
};
