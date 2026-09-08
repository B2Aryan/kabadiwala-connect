# REST API Specification — Kabadiwala Connect

**Base URL:** `http://localhost:5000/api`  
**API Version:** `1.0.0`  
**Theme:** Clean & Green Technology (SIH PS 26229)  
**Content-Type:** `application/json`

---

## 1. Response Envelope Format

### Standard Success Envelope
```json
{
  "success": true,
  "data": { ... },
  "meta": { ... } // Optional (e.g. pagination, totals)
}
```

### Standard Error Envelope
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable description",
    "details": ["Optional array or object with field validation messages"]
  }
}
```

---

## 2. Authentication

- **Scheme:** HTTP Bearer Token (`Authorization: Bearer <jwt_token>`)
- **MVP Behavior:** If the `Authorization` header is omitted, the API defaults to the active demo collector session (`COL-MH-2026-089`, "Ramesh") for smooth prototype testing.
- **Production Path:** Pass standard JWT signed by `JWT_SECRET`. Tokens expire after 30 days.

---

## 3. Endpoints Matrix

### Health Check

#### `GET /api/health`
- **Purpose:** System uptime and status check.
- **Auth:** None
- **Status:** **Production Ready**
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "uptimeSeconds": 142,
    "timestamp": "2026-09-09T02:30:00.000Z",
    "environment": "development",
    "service": "kabadiwala-connect-backend",
    "version": "1.0.0",
    "theme": "Clean & Green Technology",
    "mode": "postgresql-active"
  }
}
```

---

### Recycler Discovery

#### `GET /api/recyclers`
- **Purpose:** List authorized recycler facilities with optional filters.
- **Auth:** None
- **Status:** **Demo Authorized Facilities** (Mock government registry)
- **Query Parameters:**
  - `query` (string, optional): Search by name or address.
  - `materialKey` (string, optional): Filter by accepted material (`copper`, `aluminium`, `eWaste`, `other`).
  - `pickupOnly` (boolean, optional): `true` to return only facilities offering doorstep vehicle pickup.
  - `maxDistanceKm` (number, optional): Max radius in kilometers.
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "REC-DEMO-001",
      "name": "GreenCycle Recycling — Demo",
      "distanceKm": 1.8,
      "acceptedMaterials": ["copper", "eWaste", "aluminium"],
      "pickupAvailable": true,
      "operatingHours": "9:00 AM – 6:00 PM",
      "address": "Plot 42, Hadapsar Industrial Area, Pune",
      "phone": "+91 98230 XXXXX (Demo)",
      "rating": 4.8,
      "statusTag": "Authorized E-Waste Facility (Demo)",
      "disclaimer": "Demo facility for prototype validation. Not connected to live CPCB/SPCB portal.",
      "isDemo": true,
      "latitude": 18.5089,
      "longitude": 73.9259
    }
  ],
  "meta": {
    "total": 1
  }
}
```

#### `GET /api/recyclers/:id`
- **Purpose:** Get single recycler facility profile.
- **Auth:** None
- **Response `200 OK`:** Recycler object.
- **Response `404 Not Found`:** If ID does not exist.

---

### E-Waste Lots

#### `GET /api/lots`
- **Purpose:** List lots belonging to the authenticated collector.
- **Auth:** Optional Bearer (defaults to active session)
- **Status:** **Connected**
- **Query Parameters:**
  - `status` (string, optional): Filter by status (`all`, `Created`, `Pickup Requested`, `Handover Completed`).
- **Response `200 OK`:** Array of lots.

#### `POST /api/lots`
- **Purpose:** Create a new e-waste lot.
- **Auth:** Optional Bearer
- **Status:** **Connected**
- **Request Body:**
```json
{
  "materialKey": "copper",
  "materialName": "Copper Motors & Wires",
  "quantity": 10.5,
  "unit": "kg",
  "ratePerUnit": 720.0,
  "condition": "good",
  "notes": "Stripped motor windings"
}
```
- **Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "id": "KC-2026-00125",
    "collectorId": "COL-MH-2026-089",
    "materialKey": "copper",
    "materialName": "Copper Motors & Wires",
    "quantity": 10.5,
    "unit": "kg",
    "ratePerUnit": 720.0,
    "estimatedValue": 7560.0,
    "condition": "good",
    "notes": "Stripped motor windings",
    "status": "Created",
    "photos": [],
    "createdAt": "2026-09-09T02:30:00.000Z"
  }
}
```
- **Response `400 Bad Request`:** If validation fails (`quantity <= 0`, missing `materialKey`, etc.).

#### `GET /api/lots/:id`
- **Purpose:** Get details of a specific lot.
- **Auth:** Optional Bearer
- **Response `200 OK`:** Lot object.
- **Response `404 Not Found`:** If lot not found.

---

### Handover Requests

#### `POST /api/handover-requests`
- **Purpose:** Submit a lot handover / pickup request to an authorized recycler.
- **Auth:** Optional Bearer
- **Status:** **Connected**
- **Request Body:**
```json
{
  "lotId": "KC-2026-00125",
  "recyclerId": "REC-DEMO-001",
  "notes": "Available morning 10 AM",
  "scheduledPickupAt": "2026-09-10T10:00:00.000Z"
}
```
- **Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "id": "REQ-2026-00043",
    "lotId": "KC-2026-00125",
    "collectorId": "COL-MH-2026-089",
    "recyclerId": "REC-DEMO-001",
    "recyclerName": "GreenCycle Recycling — Demo",
    "status": "requested",
    "materialName": "Copper Motors & Wires",
    "quantity": 10.5,
    "unit": "kg",
    "estimatedValue": 7560.0,
    "notes": "Available morning 10 AM",
    "scheduledPickupAt": "2026-09-10T10:00:00.000Z",
    "requestedAt": "2026-09-09T02:30:00.000Z"
  }
}
```

#### `GET /api/handover-requests/:id`
- **Purpose:** Retrieve status and tracking information for a handover request.
- **Auth:** Optional Bearer
- **Response `200 OK`:** Handover request object.
- **Response `404 Not Found`:** If ID not found.

---

### Digital Transaction Ledger

#### `GET /api/transactions`
- **Purpose:** Retrieve verified circular transaction ledger entries.
- **Auth:** Optional Bearer
- **Status:** **Demo Digital Ledger** (No real banking/tax transfer claimed)
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "TXN-2026-00088",
      "lotId": "KC-2026-00124",
      "handoverRequestId": "REQ-2026-00042",
      "collectorId": "COL-MH-2026-089",
      "recyclerId": "REC-DEMO-001",
      "recyclerName": "GreenCycle Recycling — Demo",
      "material": "Mixed Electronic PCBs",
      "quantity": 25.0,
      "unit": "kg",
      "agreedRate": 45.0,
      "grossAmount": 1125.0,
      "facilitationFee": 0.0,
      "netAmount": 1125.0,
      "status": "completed",
      "paymentStatus": "recorded",
      "isPendingSync": false,
      "isDemo": true,
      "disclaimer": "Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.",
      "completedAt": "2026-09-09T00:00:00.000Z",
      "createdAt": "2026-09-08T22:30:00.000Z"
    }
  ],
  "meta": { "total": 1 }
}
```

#### `POST /api/transactions`
- **Purpose:** Record a completed transaction from verified handover.
- **Transparent Calculation:** `grossAmount = quantity * agreedRate`, `facilitationFee = (grossAmount * facilitationFeePercent) / 100`, `netAmount = grossAmount - facilitationFee`.
- **Request Body:**
```json
{
  "lotId": "KC-2026-00125",
  "handoverRequestId": "REQ-2026-00043",
  "recyclerId": "REC-DEMO-001",
  "recyclerName": "GreenCycle Recycling — Demo",
  "material": "Copper Motors & Wires",
  "quantity": 10.0,
  "unit": "kg",
  "agreedRate": 720.0,
  "facilitationFeePercent": 0.0
}
```
- **Response `201 Created`:** Created transaction object.

---

### Earnings Aggregation

#### `GET /api/earnings/summary`
- **Purpose:** Aggregate financial ledger metrics for the collector.
- **Auth:** Optional Bearer
- **Status:** **Connected**
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "collectorId": "COL-MH-2026-089",
    "totalEarnings": 6885.0,
    "totalGrossAmount": 6885.0,
    "totalFacilitationFee": 0.0,
    "completedTransactionsCount": 2,
    "pendingLotsCount": 0,
    "currency": "INR",
    "currencySymbol": "₹",
    "recentTransactions": [ ... ]
  }
}
```
