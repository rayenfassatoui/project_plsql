-- 02_tables/flights.sql
-- Depends on: 01_schemas.sql, airlines.sql, aircraft.sql, airports.sql

SET search_path TO airport_mgmt, public;

CREATE TABLE IF NOT EXISTS flights (
    flight_id SERIAL PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    airline_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    origin_airport_code CHAR(3) NOT NULL, -- Standard IATA airport code
    destination_airport_code CHAR(3) NOT NULL,
    scheduled_departure TIMESTAMPTZ NOT NULL,
    scheduled_arrival TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'Delayed', 'Departed', 'Arrived', 'Cancelled')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_airline FOREIGN KEY (airline_id) REFERENCES airlines(airline_id) ON DELETE RESTRICT,
    CONSTRAINT fk_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id) ON DELETE RESTRICT,
    CONSTRAINT fk_origin_airport FOREIGN KEY (origin_airport_code) REFERENCES airports(airport_code) ON DELETE RESTRICT,
    CONSTRAINT fk_destination_airport FOREIGN KEY (destination_airport_code) REFERENCES airports(airport_code) ON DELETE RESTRICT,
    CONSTRAINT check_arrival_after_departure CHECK (scheduled_arrival > scheduled_departure),
    CONSTRAINT check_different_airports CHECK (origin_airport_code <> destination_airport_code),
    UNIQUE (flight_number, scheduled_departure)
); 