process.env.NODE_ENV = 'test';
process.env.USE_MEMORY_DB = 'true';

const test = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/app');
const memoryRepo = require('../src/repositories/memory.repository');

let server;
let baseUrl;

test.before(async () => {
  // Start server on ephemeral port for tests
  await new Promise((resolve) => {
    server = app.listen(0, () => {
      const port = server.address().port;
      baseUrl = `http://127.0.0.1:${port}/api`;
      resolve();
    });
  });
});

test.after(async () => {
  await new Promise((resolve) => server.close(resolve));
});

test.beforeEach(() => {
  // Reset in-memory database to clean demo state before each test
  memoryRepo.reset();
});

// 1. Health Endpoint
test('GET /api/health should return 200 with healthy status and metadata', async () => {
  const res = await fetch(`${baseUrl}/health`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.equal(body.data.status, 'healthy');
  assert.equal(body.data.service, 'kabadiwala-connect-backend');
  assert.equal(typeof body.data.uptimeSeconds, 'number');
});

// 2. Recycler Retrieval & Filtering
test('GET /api/recyclers should return list of recyclers', async () => {
  const res = await fetch(`${baseUrl}/recyclers`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.ok(Array.isArray(body.data));
  assert.ok(body.data.length >= 4);
  assert.equal(body.meta.total, body.data.length);
});

test('GET /api/recyclers?materialKey=copper should filter recyclers accepting copper', async () => {
  const res = await fetch(`${baseUrl}/recyclers?materialKey=copper`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  body.data.forEach((r) => {
    assert.ok(r.acceptedMaterials.includes('copper'));
  });
});

test('GET /api/recyclers/:id should return single recycler details', async () => {
  const res = await fetch(`${baseUrl}/recyclers/REC-DEMO-001`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.equal(body.data.id, 'REC-DEMO-001');
  assert.equal(body.data.name, 'GreenCycle Recycling — Demo');
});

// 3. Lot Creation & Retrieval
test('POST /api/lots should create a new lot with calculated estimated value', async () => {
  const newLotPayload = {
    materialKey: 'copper',
    materialName: 'Copper Motors',
    quantity: 10.5,
    unit: 'kg',
    ratePerUnit: 720.0,
    condition: 'good',
    notes: 'Clean transformer core',
  };

  const res = await fetch(`${baseUrl}/lots`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(newLotPayload),
  });
  assert.equal(res.status, 201);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.ok(body.data.id.startsWith('KC-'));
  assert.equal(body.data.quantity, 10.5);
  assert.equal(body.data.estimatedValue, 7560.0); // 10.5 * 720
  assert.equal(body.data.status, 'Created');
});

test('GET /api/lots should return collector lots', async () => {
  const res = await fetch(`${baseUrl}/lots`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.ok(Array.isArray(body.data));
  assert.ok(body.data.length >= 2);
});

test('GET /api/lots/:id should return specific lot', async () => {
  const res = await fetch(`${baseUrl}/lots/KC-2026-00124`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.equal(body.data.id, 'KC-2026-00124');
  assert.equal(body.data.materialKey, 'eWaste');
});

// 4. Handover Request Creation & Tracking
test('POST /api/handover-requests should create a request and transition lot status', async () => {
  // First create a lot to request handover for
  const lotRes = await fetch(`${baseUrl}/lots`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      materialKey: 'aluminium',
      materialName: 'Aluminium Heat Sinks',
      quantity: 5.0,
      unit: 'kg',
      ratePerUnit: 180.0,
      condition: 'good',
    }),
  });
  const createdLot = (await lotRes.json()).data;

  // Now create handover request
  const handoverRes = await fetch(`${baseUrl}/handover-requests`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      lotId: createdLot.id,
      recyclerId: 'REC-DEMO-001',
      notes: 'Available after 2 PM',
    }),
  });
  assert.equal(handoverRes.status, 201);

  const handoverBody = await handoverRes.json();
  assert.equal(handoverBody.success, true);
  assert.ok(handoverBody.data.id.startsWith('REQ-'));
  assert.equal(handoverBody.data.status, 'requested');
  assert.equal(handoverBody.data.recyclerId, 'REC-DEMO-001');

  // Verify that the lot status changed to 'Pickup Requested'
  const updatedLotRes = await fetch(`${baseUrl}/lots/${createdLot.id}`);
  const updatedLot = (await updatedLotRes.json()).data;
  assert.equal(updatedLot.status, 'Pickup Requested');
  assert.equal(updatedLot.recyclerId, 'REC-DEMO-001');
});

// 5. Transaction Retrieval & Recording
test('GET /api/transactions should return transaction ledger', async () => {
  const res = await fetch(`${baseUrl}/transactions`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.ok(Array.isArray(body.data));
  assert.ok(body.data.length >= 2);
  assert.equal(body.data[0].status, 'completed');
  assert.equal(body.data[0].paymentStatus, 'recorded');
});

test('POST /api/transactions should record completed transaction with transparent calculation', async () => {
  const txnPayload = {
    lotId: 'KC-2026-00124',
    recyclerId: 'REC-DEMO-001',
    recyclerName: 'GreenCycle Recycling — Demo',
    material: 'Mixed Electronic PCBs',
    quantity: 10.0,
    unit: 'kg',
    agreedRate: 50.0,
    facilitationFeePercent: 0.0, // Zero fee prototype default
  };

  const res = await fetch(`${baseUrl}/transactions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(txnPayload),
  });
  assert.equal(res.status, 201);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.ok(body.data.id.startsWith('TXN-'));
  assert.equal(body.data.grossAmount, 500.0);
  assert.equal(body.data.facilitationFee, 0.0);
  assert.equal(body.data.netAmount, 500.0);
  assert.equal(body.data.isDemo, true);
  assert.ok(body.data.disclaimer.includes('prototype'));
});

// 6. Earnings Aggregation
test('GET /api/earnings/summary should aggregate total earnings and counts', async () => {
  const res = await fetch(`${baseUrl}/earnings/summary`);
  assert.equal(res.status, 200);

  const body = await res.json();
  assert.equal(body.success, true);
  assert.equal(body.data.currency, 'INR');
  assert.equal(body.data.currencySymbol, '₹');
  assert.equal(typeof body.data.totalEarnings, 'number');
  assert.ok(body.data.totalEarnings > 0);
  assert.ok(body.data.completedTransactionsCount >= 2);
  assert.ok(Array.isArray(body.data.recentTransactions));
});

// 7. Validation & Error Handling
test('POST /api/lots with invalid quantity should return 400 with details', async () => {
  const invalidPayload = {
    materialKey: 'copper',
    materialName: 'Copper Motors',
    quantity: -5, // Invalid negative quantity
    ratePerUnit: 720.0,
    condition: 'good',
  };

  const res = await fetch(`${baseUrl}/lots`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(invalidPayload),
  });
  assert.equal(res.status, 400);

  const body = await res.json();
  assert.equal(body.success, false);
  assert.equal(body.error.code, 'VALIDATION_ERROR');
  assert.ok(Array.isArray(body.error.details));
  assert.ok(body.error.details.some((d) => d.includes('quantity')));
});

// 8. 404 Response Handling
test('GET /api/non-existent-endpoint should return 404 NOT_FOUND', async () => {
  const res = await fetch(`${baseUrl}/non-existent-endpoint`);
  assert.equal(res.status, 404);

  const body = await res.json();
  assert.equal(body.success, false);
  assert.equal(body.error.code, 'NOT_FOUND');
});
