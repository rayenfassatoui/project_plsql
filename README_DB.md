# Airport Management Database Setup

This document provides instructions for setting up the Airport Management database on your local PostgreSQL server.

## Prerequisites

- PostgreSQL installed and running on your local machine
- Basic familiarity with PostgreSQL command-line tools

## Setup Instructions

### 1. Create the Database and Schema

Run the following command to create the database and all required tables:

```bash
psql -U postgres -f create_database.sql
```

This script will:
- Create a new database called `airport_mgmt`
- Create a schema named `airport_mgmt`
- Create all required tables with appropriate constraints
- Create indexes for optimized query performance

### 2. Load Sample Data (Optional)

If you want to populate the database with sample data, run:

```bash
psql -U postgres -f sample_data.sql
```

This will add sample data for:
- Airports (JFK, LAX, LHR, CDG, DXB)
- Airlines
- Aircraft
- Flights
- Passengers
- Crew members
- Bookings
- Flight crew assignments

### 3. Connect to the Database

You can connect to the database using:

```bash
psql -U postgres -d airport_mgmt
```

Then set the search path:

```sql
SET search_path TO airport_mgmt, public;
```

## Database Structure

The database consists of the following tables:
- `airports` - Information about airports
- `airlines` - Information about airline companies
- `aircraft` - Details about aircraft
- `flights` - Flight schedules and statuses
- `passengers` - Passenger information
- `bookings` - Flight bookings
- `crew` - Crew member details
- `flight_crew` - Junction table for assigning crew to flights

## Example Queries

### Find all flights departing from JFK

```sql
SELECT f.flight_id, f.flight_number, a.name AS airline, 
       f.origin_airport_code, f.destination_airport_code,
       f.scheduled_departure, f.scheduled_arrival
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
WHERE f.origin_airport_code = 'JFK';
```

### Find passengers on a specific flight

```sql
SELECT p.first_name, p.last_name, b.seat_number
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
WHERE b.flight_id = 1;
```

### Find crew assigned to a flight

```sql
SELECT c.first_name, c.last_name, c.role
FROM crew c
JOIN flight_crew fc ON c.crew_id = fc.crew_id
WHERE fc.flight_id = 1;
``` 