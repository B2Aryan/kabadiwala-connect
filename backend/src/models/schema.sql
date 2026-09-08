-- ==============================================================================
-- KABADIWALA CONNECT - POSTGRESQL DATABASE SCHEMA
-- SIH PS 26229 | Clean & Green Technology
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Collectors / Users Table
CREATE TABLE IF NOT EXISTS collectors (
    id VARCHAR(50) PRIMARY KEY, -- e.g. "COL-MH-2026-089" or UUID
    phone VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    preferred_language VARCHAR(10) DEFAULT 'hi',
    city VARCHAR(100) DEFAULT 'Pune, Maharashtra',
    kyc_status VARCHAR(20) DEFAULT 'VERIFIED',
    total_earnings NUMERIC(12, 2) DEFAULT 0.00,
    completed_lots INTEGER DEFAULT 0,
    password_hash VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Recyclers Table
CREATE TABLE IF NOT EXISTS recyclers (
    id VARCHAR(50) PRIMARY KEY, -- e.g. "REC-DEMO-001"
    name VARCHAR(150) NOT NULL,
    authorization_number VARCHAR(100) UNIQUE NOT NULL,
    is_authorized BOOLEAN DEFAULT TRUE,
    pickup_available BOOLEAN DEFAULT TRUE,
    operating_hours VARCHAR(100) DEFAULT '9:00 AM – 6:00 PM',
    address TEXT NOT NULL,
    phone VARCHAR(25) NOT NULL,
    rating NUMERIC(2, 1) DEFAULT 4.8,
    status_tag VARCHAR(100) DEFAULT 'Authorized E-Waste Facility (Demo)',
    disclaimer TEXT DEFAULT 'Demo facility for prototype validation. Not connected to live CPCB/SPCB portal.',
    is_demo BOOLEAN DEFAULT TRUE,
    latitude NUMERIC(10, 7) DEFAULT 18.5204,
    longitude NUMERIC(10, 7) DEFAULT 73.8567,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Recycler Accepted Materials Table (Junction)
CREATE TABLE IF NOT EXISTS recycler_materials (
    recycler_id VARCHAR(50) REFERENCES recyclers(id) ON DELETE CASCADE,
    material_key VARCHAR(50) NOT NULL,
    PRIMARY KEY (recycler_id, material_key)
);

-- 4. E-Waste Lots Table
CREATE TABLE IF NOT EXISTS ewaste_lots (
    id VARCHAR(50) PRIMARY KEY, -- e.g. "KC-2026-00125"
    collector_id VARCHAR(50) REFERENCES collectors(id) ON DELETE RESTRICT,
    material_key VARCHAR(50) NOT NULL,
    material_name VARCHAR(100) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
    unit VARCHAR(15) NOT NULL DEFAULT 'kg',
    rate_per_unit NUMERIC(10, 2) NOT NULL,
    estimated_value NUMERIC(12, 2) NOT NULL,
    condition VARCHAR(50) NOT NULL,
    notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'Created',
    recycler_id VARCHAR(50) REFERENCES recyclers(id) ON DELETE SET NULL,
    recycler_name VARCHAR(150),
    photos TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Handover Requests Table
CREATE TABLE IF NOT EXISTS handover_requests (
    id VARCHAR(50) PRIMARY KEY, -- e.g. "REQ-2026-00042"
    lot_id VARCHAR(50) REFERENCES ewaste_lots(id) ON DELETE RESTRICT,
    collector_id VARCHAR(50) REFERENCES collectors(id) ON DELETE RESTRICT,
    recycler_id VARCHAR(50) REFERENCES recyclers(id) ON DELETE RESTRICT,
    recycler_name VARCHAR(150) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'requested',
    material_name VARCHAR(100) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(15) NOT NULL DEFAULT 'kg',
    estimated_value NUMERIC(12, 2) NOT NULL,
    notes TEXT,
    is_pending_sync BOOLEAN DEFAULT FALSE,
    scheduled_pickup_at TIMESTAMP WITH TIME ZONE,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Digital Transaction Ledger Table
CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(50) PRIMARY KEY, -- e.g. "TXN-2026-00089"
    lot_id VARCHAR(50) REFERENCES ewaste_lots(id) ON DELETE RESTRICT,
    handover_request_id VARCHAR(50) REFERENCES handover_requests(id) ON DELETE SET NULL,
    collector_id VARCHAR(50) REFERENCES collectors(id) ON DELETE RESTRICT,
    recycler_id VARCHAR(50) REFERENCES recyclers(id) ON DELETE RESTRICT,
    recycler_name VARCHAR(150) NOT NULL,
    material VARCHAR(100) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(15) NOT NULL DEFAULT 'kg',
    agreed_rate NUMERIC(10, 2) NOT NULL,
    gross_amount NUMERIC(12, 2) NOT NULL,
    facilitation_fee NUMERIC(12, 2) DEFAULT 0.00,
    net_amount NUMERIC(12, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'completed',
    payment_status VARCHAR(50) NOT NULL DEFAULT 'recorded',
    is_pending_sync BOOLEAN DEFAULT FALSE,
    is_demo BOOLEAN DEFAULT TRUE,
    disclaimer TEXT DEFAULT 'Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.',
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- INDEXES FOR PERFORMANCE & FAST LOOKUP
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_lots_collector ON ewaste_lots(collector_id);
CREATE INDEX IF NOT EXISTS idx_lots_status ON ewaste_lots(status);
CREATE INDEX IF NOT EXISTS idx_handover_collector ON handover_requests(collector_id);
CREATE INDEX IF NOT EXISTS idx_handover_recycler ON handover_requests(recycler_id);
CREATE INDEX IF NOT EXISTS idx_handover_lot ON handover_requests(lot_id);
CREATE INDEX IF NOT EXISTS idx_handover_status ON handover_requests(status);
CREATE INDEX IF NOT EXISTS idx_transactions_collector ON transactions(collector_id);
CREATE INDEX IF NOT EXISTS idx_transactions_recycler ON transactions(recycler_id);
CREATE INDEX IF NOT EXISTS idx_transactions_lot ON transactions(lot_id);
CREATE INDEX IF NOT EXISTS idx_recycler_materials_mat ON recycler_materials(material_key);
