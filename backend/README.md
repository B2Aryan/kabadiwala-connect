# Kabadiwala Connect — Backend REST API

Clean & Green Technology REST API backend built with **Node.js**, **Express**, and **PostgreSQL** for **Kabadiwala Connect** (SIH PS 26229).

---

## 1. Project Architecture

```
backend/
├── src/
│   ├── config/
│   │   ├── env.js                      # Environment configuration & defaults
│   │   └── database.js                 # PostgreSQL connection pool (pg)
│   ├── controllers/
│   │   ├── health.controller.js        # Health check & system metadata
│   │   ├── recyclers.controller.js     # Recycler listing & details
│   │   ├── lots.controller.js          # Lot creation & queries
│   │   ├── handover.controller.js      # Handover request creation & tracking
│   │   ├── transactions.controller.js  # Ledger records & creation
│   │   └── earnings.controller.js      # Aggregated earnings summary
│   ├── middleware/
│   │   ├── auth.middleware.js          # JWT authentication foundation
│   │   ├── validation.middleware.js    # Request payload validation
│   │   └── error.middleware.js         # Centralized error handler & 404
│   ├── models/
│   │   └── schema.sql                  # PostgreSQL table definitions & indexes
│   ├── repositories/
│   │   ├── index.js                    # Dynamic repository selector
│   │   ├── db.repository.js            # PostgreSQL query implementations
│   │   └── memory.repository.js        # Seeded in-memory store for tests & offline dev
│   ├── routes/
│   │   ├── index.js                    # Route aggregator mounted on /api
│   │   ├── health.routes.js
│   │   ├── recyclers.routes.js
│   │   ├── lots.routes.js
│   │   ├── handover.routes.js
│   │   ├── transactions.routes.js
│   │   └── earnings.routes.js
│   ├── services/
│   │   ├── recycler.service.js         # Filtering & matching business logic
│   │   ├── lot.service.js              # Lot validation & numbering
│   │   ├── handover.service.js         # Handover state machine
│   │   └── transaction.service.js      # Transparent fee calculation & ledger
│   ├── utils/
│   │   ├── logger.js                   # Structured logging
│   │   └── response.js                 # Standardized JSON response envelope
│   ├── app.js                          # Express application configuration
│   └── server.js                       # HTTP server entry point
├── tests/
│   └── api.test.js                     # 13 automated integration tests
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

---

## 2. Environment Setup

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Default variables:
```env
PORT=5000
NODE_ENV=development
DATABASE_URL=postgres://postgres:postgres@localhost:5432/kabadiwala_connect
JWT_SECRET=kabadiwala_connect_demo_super_secret_jwt_key_2026
CORS_ORIGIN=*
USE_MEMORY_DB=false
```

---

## 3. Database Setup (PostgreSQL)

1. Ensure PostgreSQL 14+ is installed and running:
   ```bash
   createdb kabadiwala_connect
   ```

2. Run the schema migrations:
   ```bash
   psql -d kabadiwala_connect -f src/models/schema.sql
   ```

*Note: If PostgreSQL is not available locally, you can set `USE_MEMORY_DB=true` in `.env` to run with the seeded in-memory database.*

---

## 4. Running the Backend

### Development Mode:
```bash
npm run dev
```

### Production Mode:
```bash
npm start
```

### Run Automated Tests:
```bash
npm test
```
The test suite runs against an isolated in-memory test database, guaranteeing zero external dependencies and fast verification.

---

## 5. API Endpoints Overview

| Method | Endpoint | Description | Auth | Status |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/health` | Service uptime and health | None | Real |
| `GET` | `/api/recyclers` | List recyclers (filter by material, pickup, distance) | None | Demo Registry |
| `GET` | `/api/recyclers/:id` | Single recycler facility details | None | Demo Registry |
| `GET` | `/api/lots` | Collector lots list | Bearer (Opt) | Connected |
| `POST` | `/api/lots` | Create new e-waste lot | Bearer (Opt) | Connected |
| `GET` | `/api/lots/:id` | Get single lot | Bearer (Opt) | Connected |
| `POST` | `/api/handover-requests`| Submit handover request | Bearer (Opt) | Connected |
| `GET` | `/api/handover-requests/:id`| Get handover request status | Bearer (Opt) | Connected |
| `GET` | `/api/transactions` | Digital transaction ledger | Bearer (Opt) | Connected |
| `GET` | `/api/transactions/:id` | Single transaction invoice | Bearer (Opt) | Connected |
| `POST` | `/api/transactions` | Record transaction from handover | Bearer (Opt) | Connected |
| `GET` | `/api/earnings/summary` | Aggregated earnings summary | Bearer (Opt) | Connected |

For full request/response schemas, status codes, and examples, refer to [docs/API.md](../docs/API.md).
