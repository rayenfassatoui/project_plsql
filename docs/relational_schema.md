# Airport Management System - Relational Schema (Simplified)

This document describes the relational schema for the simplified Airport Management System database, derived from the conceptual model (ERD).

## Schema Name

The primary schema for application objects will be `airport_mgmt`.

```sql
CREATE SCHEMA IF NOT EXISTS airport_mgmt;
SET search_path TO airport_mgmt, public;
```

## Tables

### 1. `airlines`

Stores information about airlines operating flights.

```sql
CREATE TABLE airport_mgmt.airlines (
    airline_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    iata_code CHAR(2) NOT NULL UNIQUE, -- Standard IATA code
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

*   **Columns:**
    *   `airline_id`: Unique identifier (PK).
    *   `name`: Full name of the airline.
    *   `iata_code`: 2-letter IATA airline designator (Unique).
    *   `created_at`: Timestamp of record creation.

### 2. `aircraft`

Stores details about aircraft used for flights.

```sql
CREATE TABLE airport_mgmt.aircraft (
    aircraft_id SERIAL PRIMARY KEY,
    manufacturer VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0), -- Number of seats
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

*   **Columns:**
    *   `aircraft_id`: Unique identifier (PK).
    *   `manufacturer`: Aircraft manufacturer.
    *   `model`: Aircraft model.
    *   `capacity`: Passenger seating capacity (must be positive).
    *   `created_at`: Timestamp of record creation.

### 3. `flights`

Stores information about individual flights.

```sql
CREATE TABLE airport_mgmt.flights (
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

    CONSTRAINT fk_airline FOREIGN KEY (airline_id) REFERENCES airport_mgmt.airlines(airline_id) ON DELETE RESTRICT, -- Prevent deleting airline if flights exist
    CONSTRAINT fk_aircraft FOREIGN KEY (aircraft_id) REFERENCES airport_mgmt.aircraft(aircraft_id) ON DELETE RESTRICT, -- Prevent deleting aircraft if flights exist
    CONSTRAINT check_arrival_after_departure CHECK (scheduled_arrival > scheduled_departure),
    CONSTRAINT check_different_airports CHECK (origin_airport_code <> destination_airport_code),
    UNIQUE (flight_number, scheduled_departure) -- Natural key constraint
);
```

*   **Columns:**
    *   `flight_id`: Unique identifier (PK).
    *   `flight_number`: Airline-specific flight number.
    *   `airline_id`: Reference to the operating airline (FK).
    *   `aircraft_id`: Reference to the aircraft used (FK).
    *   `origin_airport_code`: 3-letter IATA code for origin.
    *   `destination_airport_code`: 3-letter IATA code for destination.
    *   `scheduled_departure`: Planned departure time (with time zone).
    *   `scheduled_arrival`: Planned arrival time (with time zone).
    *   `status`: Current status of the flight.
    *   `created_at`: Timestamp of record creation.
*   **Constraints:**
    *   FKs to `airlines` and `aircraft` with `ON DELETE RESTRICT`.
    *   `CHECK` constraint to ensure arrival is after departure.
    *   `CHECK` constraint to ensure origin and destination are different.
    *   `UNIQUE` constraint on `flight_number` and `scheduled_departure`.

### 4. `passengers`

Stores information about passengers.

```sql
CREATE TABLE airport_mgmt.passengers (
    passenger_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE, -- Optional, but unique if provided
    phone_number VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

*   **Columns:**
    *   `passenger_id`: Unique identifier (PK).
    *   `first_name`: Passenger's first name.
    *   `last_name`: Passenger's last name.
    *   `email`: Passenger's email address (Unique).
    *   `phone_number`: Passenger's phone number.
    *   `created_at`: Timestamp of record creation.

### 5. `bookings`

Links passengers to specific flights.

```sql
CREATE TABLE airport_mgmt.bookings (
    booking_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_number VARCHAR(4), -- e.g., 12A, 3F
    booking_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Confirmed' CHECK (status IN ('Confirmed', 'Cancelled', 'Checked-in')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES airport_mgmt.flights(flight_id) ON DELETE CASCADE, -- Cascade delete if flight is cancelled/deleted
    CONSTRAINT fk_passenger FOREIGN KEY (passenger_id) REFERENCES airport_mgmt.passengers(passenger_id) ON DELETE CASCADE, -- Cascade delete if passenger record is removed
    UNIQUE (flight_id, passenger_id), -- A passenger can only book once on the same flight
    UNIQUE (flight_id, seat_number) -- A seat can only be assigned once per flight
);
```

*   **Columns:**
    *   `booking_id`: Unique identifier (PK).
    *   `flight_id`: Reference to the booked flight (FK).
    *   `passenger_id`: Reference to the passenger (FK).
    *   `seat_number`: Assigned seat number (optional).
    *   `booking_time`: Timestamp when the booking was made.
    *   `status`: Current status of the booking.
    *   `created_at`: Timestamp of record creation.
*   **Constraints:**
    *   FKs to `flights` and `passengers` with `ON DELETE CASCADE`. (If a flight is deleted, the booking is implicitly cancelled. If a passenger record is deleted, their bookings are removed).
    *   `UNIQUE` constraint on (`flight_id`, `passenger_id`).
    *   `UNIQUE` constraint on (`flight_id`, `seat_number`) to prevent double-booking seats.

### 6. `crew`

Stores information about crew members.

```sql
CREATE TABLE airport_mgmt.crew (
    crew_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    employee_id VARCHAR(20) UNIQUE NOT NULL, -- Airline employee identifier
    role VARCHAR(50) NOT NULL CHECK (role IN ('Pilot', 'Co-Pilot', 'Flight Attendant', 'Purser', 'Engineer')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

```

*   **Columns:**
    *   `crew_id`: Unique identifier (PK).
    *   `first_name`: Crew member's first name.
    *   `last_name`: Crew member's last name.
    *   `employee_id`: Unique employee ID.
    *   `role`: Role of the crew member.
    *   `created_at`: Timestamp of record creation.

### 7. `flight_crew` (Junction Table)

Assigns crew members to specific flights.

```sql
CREATE TABLE airport_mgmt.flight_crew (
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    assignment_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_flight_crew PRIMARY KEY (flight_id, crew_id), -- Composite primary key
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES airport_mgmt.flights(flight_id) ON DELETE CASCADE, -- If flight deleted, remove assignment
    CONSTRAINT fk_crew FOREIGN KEY (crew_id) REFERENCES airport_mgmt.crew(crew_id) ON DELETE CASCADE -- If crew member deleted, remove assignment
);
```

*   **Columns:**
    *   `flight_id`: Reference to the flight (PK, FK).
    *   `crew_id`: Reference to the crew member (PK, FK).
    *   `assignment_time`: Timestamp when the assignment was made.
*   **Constraints:**
    *   Composite PK on (`flight_id`, `crew_id`).
    *   FKs to `flights` and `crew` with `ON DELETE CASCADE`.

## Indexes

Indexes will be created automatically for Primary Keys and Unique constraints. Additional indexes should be added on Foreign Key columns and columns frequently used in `WHERE` clauses or `JOIN` conditions for performance. These will be defined in `db_schema/05_indexes.sql`.

Example indexes (to be placed in `05_indexes.sql`):

```sql
-- Indexes on Foreign Keys
CREATE INDEX idx_flights_airline_id ON airport_mgmt.flights(airline_id);
CREATE INDEX idx_flights_aircraft_id ON airport_mgmt.flights(aircraft_id);
CREATE INDEX idx_flights_origin ON airport_mgmt.flights(origin_airport_code);
CREATE INDEX idx_flights_destination ON airport_mgmt.flights(destination_airport_code);
CREATE INDEX idx_flights_departure_time ON airport_mgmt.flights(scheduled_departure);

CREATE INDEX idx_bookings_flight_id ON airport_mgmt.bookings(flight_id);
CREATE INDEX idx_bookings_passenger_id ON airport_mgmt.bookings(passenger_id);

CREATE INDEX idx_flight_crew_flight_id ON airport_mgmt.flight_crew(flight_id);
CREATE INDEX idx_flight_crew_crew_id ON airport_mgmt.flight_crew(crew_id);

-- Indexes on frequently searched columns
CREATE INDEX idx_passengers_email ON airport_mgmt.passengers(email);
CREATE INDEX idx_crew_employee_id ON airport_mgmt.crew(employee_id);
``` 