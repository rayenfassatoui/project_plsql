-- 02_tables/crew.sql
-- Depends on: 01_schemas.sql

SET search_path TO airport_mgmt, public;

CREATE TABLE IF NOT EXISTS crew (
    crew_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Pilot', 'Co-Pilot', 'Flight Attendant', 'Purser', 'Engineer')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
); 