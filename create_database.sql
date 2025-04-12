-- Create the airport_mgmt database
CREATE DATABASE airport_mgmt;

\c airport_mgmt

-- Create schema
CREATE SCHEMA IF NOT EXISTS airport_mgmt;
SET search_path TO airport_mgmt, public;

-- Create tables
-- Table: airports
CREATE TABLE IF NOT EXISTS airport_mgmt.airports (
    airport_code CHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    timezone VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: airlines
CREATE TABLE IF NOT EXISTS airport_mgmt.airlines (
    airline_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    iata_code CHAR(2) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: aircraft
CREATE TABLE IF NOT EXISTS airport_mgmt.aircraft (
    aircraft_id SERIAL PRIMARY KEY,
    manufacturer VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: flights
CREATE TABLE IF NOT EXISTS airport_mgmt.flights (
    flight_id SERIAL PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    airline_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    origin_airport_code CHAR(3) NOT NULL,
    destination_airport_code CHAR(3) NOT NULL,
    scheduled_departure TIMESTAMPTZ NOT NULL,
    scheduled_arrival TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'Delayed', 'Departed', 'Arrived', 'Cancelled')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_airline FOREIGN KEY (airline_id) REFERENCES airport_mgmt.airlines(airline_id) ON DELETE RESTRICT,
    CONSTRAINT fk_aircraft FOREIGN KEY (aircraft_id) REFERENCES airport_mgmt.aircraft(aircraft_id) ON DELETE RESTRICT,
    CONSTRAINT fk_origin_airport FOREIGN KEY (origin_airport_code) REFERENCES airport_mgmt.airports(airport_code) ON DELETE RESTRICT,
    CONSTRAINT fk_destination_airport FOREIGN KEY (destination_airport_code) REFERENCES airport_mgmt.airports(airport_code) ON DELETE RESTRICT,
    CONSTRAINT check_arrival_after_departure CHECK (scheduled_arrival > scheduled_departure),
    CONSTRAINT check_different_airports CHECK (origin_airport_code <> destination_airport_code),
    UNIQUE (flight_number, scheduled_departure)
);

-- Table: passengers
CREATE TABLE IF NOT EXISTS airport_mgmt.passengers (
    passenger_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: bookings
CREATE TABLE IF NOT EXISTS airport_mgmt.bookings (
    booking_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_number VARCHAR(4),
    booking_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Confirmed' CHECK (status IN ('Confirmed', 'Cancelled', 'Checked-in')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES airport_mgmt.flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_passenger FOREIGN KEY (passenger_id) REFERENCES airport_mgmt.passengers(passenger_id) ON DELETE CASCADE,
    UNIQUE (flight_id, passenger_id),
    UNIQUE (flight_id, seat_number)
);

-- Table: crew
CREATE TABLE IF NOT EXISTS airport_mgmt.crew (
    crew_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Pilot', 'Co-Pilot', 'Flight Attendant', 'Purser', 'Engineer')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: flight_crew
CREATE TABLE IF NOT EXISTS airport_mgmt.flight_crew (
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    assignment_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_flight_crew PRIMARY KEY (flight_id, crew_id),
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES airport_mgmt.flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_crew FOREIGN KEY (crew_id) REFERENCES airport_mgmt.crew(crew_id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_flights_airline_id ON airport_mgmt.flights(airline_id);
CREATE INDEX IF NOT EXISTS idx_flights_aircraft_id ON airport_mgmt.flights(aircraft_id);
CREATE INDEX IF NOT EXISTS idx_flights_origin ON airport_mgmt.flights(origin_airport_code);
CREATE INDEX IF NOT EXISTS idx_flights_destination ON airport_mgmt.flights(destination_airport_code);
CREATE INDEX IF NOT EXISTS idx_flights_departure_time ON airport_mgmt.flights(scheduled_departure);
CREATE INDEX IF NOT EXISTS idx_flights_status ON airport_mgmt.flights(status);

CREATE INDEX IF NOT EXISTS idx_bookings_flight_id ON airport_mgmt.bookings(flight_id);
CREATE INDEX IF NOT EXISTS idx_bookings_passenger_id ON airport_mgmt.bookings(passenger_id);

CREATE INDEX IF NOT EXISTS idx_flight_crew_flight_id ON airport_mgmt.flight_crew(flight_id);
CREATE INDEX IF NOT EXISTS idx_flight_crew_crew_id ON airport_mgmt.flight_crew(crew_id);

CREATE INDEX IF NOT EXISTS idx_passengers_email ON airport_mgmt.passengers(email);
CREATE INDEX IF NOT EXISTS idx_crew_employee_id ON airport_mgmt.crew(employee_id);

CREATE INDEX IF NOT EXISTS idx_airports_city ON airport_mgmt.airports(city);
CREATE INDEX IF NOT EXISTS idx_airports_country ON airport_mgmt.airports(country); 