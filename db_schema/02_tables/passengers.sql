-- 02_tables/passengers.sql
-- Depends on: 01_schemas.sql

SET search_path TO airport_mgmt, public;

CREATE TABLE IF NOT EXISTS passengers (
    passenger_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE, -- Optional, but unique if provided
    phone_number VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
