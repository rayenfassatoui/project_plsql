-- 05_indexes.sql
-- Depends on: All table creation scripts in 02_tables/

SET search_path TO airport_mgmt, public;

-- Indexes on Foreign Keys (PK indexes are created automatically)
CREATE INDEX IF NOT EXISTS idx_flights_airline_id ON flights(airline_id);
CREATE INDEX IF NOT EXISTS idx_flights_aircraft_id ON flights(aircraft_id);

CREATE INDEX IF NOT EXISTS idx_bookings_flight_id ON bookings(flight_id);
CREATE INDEX IF NOT EXISTS idx_bookings_passenger_id ON bookings(passenger_id);

CREATE INDEX IF NOT EXISTS idx_flight_crew_flight_id ON flight_crew(flight_id);
CREATE INDEX IF NOT EXISTS idx_flight_crew_crew_id ON flight_crew(crew_id);

-- Indexes on frequently searched/filtered columns
CREATE INDEX IF NOT EXISTS idx_flights_origin ON flights(origin_airport_code);
CREATE INDEX IF NOT EXISTS idx_flights_destination ON flights(destination_airport_code);
CREATE INDEX IF NOT EXISTS idx_flights_departure_time ON flights(scheduled_departure);
CREATE INDEX IF NOT EXISTS idx_flights_status ON flights(status);

CREATE INDEX IF NOT EXISTS idx_passengers_email ON passengers(email); -- Already unique, but explicit index can help some queries
CREATE INDEX IF NOT EXISTS idx_crew_employee_id ON crew(employee_id); -- Already unique

-- Indexes for airports table
CREATE INDEX IF NOT EXISTS idx_airports_city ON airports(city);
CREATE INDEX IF NOT EXISTS idx_airports_country ON airports(country); 