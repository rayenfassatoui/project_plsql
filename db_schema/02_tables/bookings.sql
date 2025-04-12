-- 02_tables/bookings.sql
-- Depends on: 01_schemas.sql, flights.sql, passengers.sql

SET search_path TO airport_mgmt, public;

CREATE TABLE IF NOT EXISTS bookings (
    booking_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_number VARCHAR(4), -- e.g., 12A, 3F
    booking_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Confirmed' CHECK (status IN ('Confirmed', 'Cancelled', 'Checked-in')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_passenger FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id) ON DELETE CASCADE,
    UNIQUE (flight_id, passenger_id),
    UNIQUE (flight_id, seat_number)
); 