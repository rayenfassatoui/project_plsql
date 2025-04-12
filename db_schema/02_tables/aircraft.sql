-- 02_tables/aircraft.sql
-- Depends on: 01_schemas.sql

SET search_path TO airport_mgmt, public;

CREATE TABLE IF NOT EXISTS aircraft (
    aircraft_id SERIAL PRIMARY KEY,
    manufacturer VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0), -- Number of seats
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
); 