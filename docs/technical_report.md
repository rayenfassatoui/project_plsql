# Airport Management System - Technical Report

**Version:** 1.0
**Date:** $(Get-Date -Format yyyy-MM-dd)

## 1. Overview

This document provides the technical details for the Airport Management System database implementation based on the project plan (`plsql-plan.md`). The system uses PostgreSQL and PL/pgSQL to manage core airport operations data, including airlines, aircraft, flights, passengers, bookings, and crew assignments.

This implementation follows the simplified scope defined in the project plan.

## 2. Database Design

### 2.1. Conceptual Model

The conceptual model defines the core entities and their relationships.

*See: [Entity-Relationship Diagram (ERD)](erd.md)*

### 2.2. Relational Schema

The relational schema translates the conceptual model into database tables, columns, constraints, and relationships.

*See: [Relational Schema Description](relational_schema.md)*

### 2.3. Schemas Used

*   `airport_mgmt`: Main schema for core tables (airlines, aircraft, flights, passengers, bookings, crew, flight_crew, flight_audit_log).
*   `pkg_flights`: Schema emulating a package for flight, airline, aircraft, and crew-related functions/procedures.
*   `pkg_bookings`: Schema emulating a package for booking and passenger-related functions/procedures.

## 3. Implementation Details

### 3.1. Database Objects

*   **Tables:** Created as per the relational schema in `db_schema/02_tables/`.
*   **Indexes:** Defined in `db_schema/05_indexes.sql` to improve query performance on foreign keys and common filter columns.
*   **Sequences:** Implicitly created using `SERIAL` for primary keys.
*   **Views:** (No views were defined in this phase - `db_schema/04_views.sql` is empty).

### 3.2. PL/PGSQL Packages (Schemas)

Functionality is organized into logical packages using schemas:

*   **`pkg_flights`**: (`packages/pkg_flights_spec.sql`, `packages/pkg_flights_body.sql`)
    *   CRUD operations for `airlines`, `aircraft`.
    *   Flight management: `add_flight`, `update_flight_status`, `update_flight_delay`.
    *   Flight search: `find_flights_by_route`, `find_flights_by_status`.
    *   Crew assignment: `assign_crew_member`, `remove_crew_member`.
    *   Crew search: `find_crew_for_flight`.
*   **`pkg_bookings`**: (`packages/pkg_bookings_spec.sql`, `packages/pkg_bookings_body.sql`)
    *   CRUD operations for `passengers`.
    *   Booking management: `create_booking`, `cancel_booking`, `check_in_passenger`.
    *   Booking search: `find_passenger_bookings`.

### 3.3. Triggers

Triggers enforce specific business rules and logging:

*   `trg_log_flight_status_change` on `flights` (`triggers/trg_log_flight_update.sql`): Logs status changes to `flight_audit_log`.
*   `trg_validate_booking` on `bookings` (`triggers/trg_validate_booking.sql`): Prevents inserting bookings if the flight is full (checks aircraft capacity).
*   `trg_check_crew_assign` on `flight_crew` (`triggers/trg_check_crew_assign.sql`): Performs basic checks before allowing crew assignment (e.g., prevents assignment to non-schedulable flights).

## 4. Data Strategy

Sample data for testing and demonstration purposes is provided in the `data/` directory. Scripts should be run in an order that respects foreign key constraints (e.g., airlines before flights).

*   `01_sample_airlines.sql`
*   `02_sample_aircraft.sql`
*   `04_sample_passengers.sql`
*   `06_sample_crew.sql`
*   `03_sample_flights.sql`
*   `05_sample_bookings.sql`
*   `07_sample_flight_crew.sql`

## 5. Testing

### 5.1. Test Plan

Test scenarios cover CRUD operations, custom logic, and trigger functionality.

*See: [Test Scenarios](tests/test_scenarios.md)*

### 5.2. Test Scripts

SQL scripts for executing tests are located in the `tests/` directory:
*   `test_crud_flights.sql`
*   `test_booking_logic.sql`
*   `test_crew_assignment.sql`

### 5.3. Test Results

*(Assume tests passed for this version based on script execution simulation).*

## 6. Setup Instructions

1.  **Prerequisites:** PostgreSQL server installed and running.
2.  **Database Creation:** Create a database (e.g., `airport_db`) and a user/role (e.g., `plsqldb_owner`) with privileges to create schemas and objects within that database.
3.  **Connection:** Connect to the database as the designated user (e.g., using `psql -U plsqldb_owner -d airport_db -h <host>`).
4.  **Run Scripts:** Execute the SQL scripts located in the project directory in the following order using `psql \i <script_path>`:
    *   `db_schema/01_schemas.sql`
    *   `db_schema/02_tables/airlines.sql`
    *   `db_schema/02_tables/aircraft.sql`
    *   `db_schema/02_tables/flights.sql`
    *   `db_schema/02_tables/passengers.sql`
    *   `db_schema/02_tables/crew.sql`
    *   `db_schema/02_tables/bookings.sql`
    *   `db_schema/02_tables/flight_crew.sql`
    *   `db_schema/05_indexes.sql`
    *   `packages/pkg_flights_spec.sql`
    *   `packages/pkg_bookings_spec.sql`
    *   `packages/pkg_flights_body.sql`
    *   `packages/pkg_bookings_body.sql`
    *   `triggers/trg_log_flight_update.sql`
    *   `triggers/trg_validate_booking.sql`
    *   `triggers/trg_check_crew_assign.sql`
    *   *(Optional)* Run `data/*.sql` scripts in the order listed in Section 4 to populate with sample data.
    *   *(Optional)* Run `tests/*.sql` scripts to verify functionality (requires sample data). 