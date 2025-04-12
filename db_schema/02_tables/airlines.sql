-- 02_tables/airlines.sql
-- Depends on: 01_schemas.sql

SET search_path TO airport_mgmt, public;

CREATE TABLE IF NOT EXISTS airlines (
    airline_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    iata_code CHAR(2) NOT NULL UNIQUE, -- Standard IATA code
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
); 