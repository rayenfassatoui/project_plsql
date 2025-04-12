# **Airport Management System: PL/PGSQL Project Implementation Plan**

This plan outlines the steps, structure, and tasks required to develop the database and PL/PGSQL components for an Airport Management System project, following common PL/SQL project practices (emulated in PostgreSQL) and standard requirements for such a system.

## **I. Project Structure (Folder Layout)**

A standard directory structure helps maintain organization and clarity:

airport_mgmt_db/  
├── db_schema/                \# Database object definitions  
│   ├── 01_schemas.sql        \# Schema creation (e.g., airport_mgmt, package schemas)  
│   ├── 02_tables/            \# Table definitions  
│   │   ├── airlines.sql  
│   │   ├── aircraft.sql  
│   │   ├── flights.sql  
│   │   ├── passengers.sql  
│   │   ├── bookings.sql  
│   │   ├── crew.sql  
│   │   └── flight_crew.sql   \# Junction table for M:M relationship  
│   ├── 03_sequences.sql      \# Sequence definitions (if any)  
│   ├── 04_views.sql          \# View definitions (e.g., upcoming_departures)  
│   └── 05_indexes.sql        \# Index definitions  
├── functions/                \# Standalone functions (if not in packages)  
├── procedures/               \# Standalone procedures (if not in packages)  
├── packages/                 \# PL/PGSQL Packages (emulated via schemas)  
│   ├── pkg_flights_spec.sql  \# Package specification for flights/crew  
│   ├── pkg_flights_body.sql  \# Package body for flights/crew  
│   ├── pkg_bookings_spec.sql # Package specification for bookings/passengers  
│   ├── pkg_bookings_body.sql # Package body for bookings/passengers  
│   └── ... (other packages like pkg_reports can be added later)  
├── triggers/                 \# Trigger functions and definitions  
│   ├── trg_log_flight_update.sql    \# Trigger function & definition for flight changes  
│   ├── trg_validate_booking.sql   \# Trigger for validating booking constraints  
│   ├── trg_check_crew_assign.sql  \# Trigger for checking crew assignments  
│   └── ...  
├── data/                     \# Data insertion scripts (seed/sample data)  
│   ├── 01_sample_airlines.sql  
│   ├── 02_sample_aircraft.sql  
│   ├── 03_sample_flights.sql  
│   ├── 04_sample_passengers.sql  
│   ├── 05_sample_bookings.sql  
│   └── 06_sample_crew.sql  
├── tests/                    \# Test scripts and scenarios  
│   ├── test_crud_flights.sql  
│   ├── test_booking_logic.sql  
│   ├── test_crew_assignment.sql  
│   └── test_scenarios.md     \# Description of test cases  
└── docs/                     \# Project documentation  
    ├── erd.md                \# Entity-Relationship Diagram (using Mermaid syntax)  
    ├── relational_schema.md  \# Description of relational schema (can include Mermaid)  
    └── technical_report.md   \# Final technical documentation aggregating all info

## **II. Implementation Phases and Tasks**

Here's a breakdown of the tasks required.

### **Phase 1: Database Design & Setup**

* [x] **Task 1.1: Project Structure Setup**
  * [x] Create directory structure according to the plan
  * [x] Create placeholder files
  * [x] *Deliverable:* Complete directory structure for the project
* [x] **Task 1.2: Conceptual Data Modeling** (Simplified Scope)
  * [x] Define core entities: `Airlines`, `Aircraft`, `Flights`, `Passengers`, `Bookings`, `Crew`, `Flight_Crew`.
  * [x] Define essential attributes for each entity (e.g., Flight: flight_id, flight_number, airline_id, aircraft_id, origin_code, destination_code, scheduled_departure, scheduled_arrival, status; Passenger: passenger_id, first_name, last_name; Booking: booking_id, flight_id, passenger_id, seat_number).
  * [x] Define key relationships:
      * **One-to-Many (1:M):** `Airlines` -> `Flights`; `Aircraft` -> `Flights`; `Flights` -> `Bookings`; `Passengers` -> `Bookings`.
      * **Many-to-Many (M:M):** `Flights` <-> `Crew` (linked via `Flight_Crew` junction table).
  * [x] Create an Entity-Relationship Diagram (ERD) using **Mermaid syntax** within the `erd.md` file, reflecting this simplified model.
  * [x] *Deliverable:* `docs/erd.md` containing the Mermaid ERD diagram and explanations for the simplified schema.
* [x] **Task 1.3: Relational Schema Design** (Simplified Scope)
  * [x] Convert the simplified ERD into a relational schema.
  * [x] Define tables: `airlines`, `aircraft`, `flights`, `passengers`, `bookings`, `crew`, `flight_crew`.
  * [x] Define columns with appropriate PostgreSQL data types (e.g., `SERIAL` or `INT` for IDs, `VARCHAR`, `TEXT`, `TIMESTAMP WITH TIME ZONE`, `BOOLEAN`).
  * [x] Define primary keys (PKs).
  * [x] Define foreign keys (FKs) to enforce relationships (e.g., `flights.airline_id` -> `airlines.airline_id`, `bookings.flight_id` -> `flights.flight_id`, `flight_crew.flight_id` -> `flights.flight_id`, `flight_crew.crew_id` -> `crew.crew_id`). Include appropriate `ON DELETE`/`ON UPDATE` actions.
  * [x] Define essential constraints (e.g., `NOT NULL`, `UNIQUE`, `CHECK` (e.g., `scheduled_arrival > scheduled_departure`)).
  * [x] *Deliverable:* `docs/relational_schema.md` describing the simplified tables, columns, types, and constraints.
* [x] **Task 1.5: Table Creation Scripts**
  * [x] Write `CREATE TABLE` scripts for each table in the simplified schema (`airlines`, `aircraft`, `flights`, `passengers`, `bookings`, `crew`, `flight_crew`).
  * [x] Include all defined constraints (PK, FK, UNIQUE, NOT NULL, CHECK).
  * [x] Define sequences explicitly (or use `SERIAL`/`BIGSERIAL`).
  * [x] Define necessary indexes (`CREATE INDEX`), especially on FKs and frequently queried columns.
  * [x] *Deliverable:* SQL files in `db_schema/02_tables/`, `db_schema/03_sequences.sql`, `db_schema/05_indexes.sql`.

### **Phase 2: PL/PGSQL Implementation**

* [x] **Task 2.1: Package Specification and Body Creation**
  * [x] Create package specification for flights/crew
  * [x] Create package body for flights/crew
  * [x] Create package specification for bookings/passengers
  * [x] Create package body for bookings/passengers
  * [x] *Deliverable:* Complete package specification and body for flights/crew and bookings/passengers
* [x] **Task 2.2: Trigger Functions and Definitions**
  * [x] Create trigger function & definition for flight changes
  * [x] Create trigger for validating booking constraints
  * [x] Create trigger for checking crew assignments
  * [x] *Deliverable:* Complete trigger functions and definitions
* [x] **Task 2.3: Data Insertion Scripts**
  * [x] Create data insertion scripts for airlines, aircraft, flights, passengers, bookings, and crew
  * [x] *Deliverable:* Complete data insertion scripts
* [x] **Task 2.4: Test Scripts and Scenarios**
  * [x] Create test scripts and scenarios for CRUD operations on flights, booking logic, crew assignment, and scenarios
  * [x] *Deliverable:* Complete test scripts and scenarios

### **Phase 3: Testing and Validation**

* [x] **Task 3.1: Unit Testing**
  * [x] Perform unit testing for individual functions and procedures
  * [x] *Deliverable:* Unit test results and report
* [x] **Task 3.2: Integration Testing**
  * [x] Perform integration testing for the entire system
  * [x] *Deliverable:* Integration test results and report
* [x] **Task 3.3: System Testing**
  * [x] Perform system testing for the entire system
  * [x] *Deliverable:* System test results and report

### **Phase 4: Testing**

* [x] **Task 4.1: Develop Test Scenarios**
  * [x] Define scenarios covering:
    * CRUD operations for core entities (`Airlines`, `Flights`, `Bookings`, `Passengers`, `Crew`).
    * Key search functions.
    * Custom logic: booking, check-in, flight delay, crew assignment.
    * Trigger actions: verify flight log entries, verify overbooking prevention, verify crew assignment checks.
    * Basic edge cases: invalid inputs, non-existent IDs.
  * [x] *Deliverable:* Test scenarios description (`tests/test_scenarios.md`).
* [x] **Task 4.2: Write Test Scripts/Queries**
  * [x] Write SQL scripts to execute the test scenarios.
  * [x] Use `SELECT` statements to call functions/procedures.
  * [x] Use `DO $$ ... $$` blocks or simple SQL for sequences.
  * [x] Include `INSERT`, `UPDATE`, `DELETE` for setup and testing triggers.
  * [x] Verify results by querying tables or checking return values.
  * [x] *Deliverable:* SQL files in `tests/`.
* [x] **Task 4.3: Execute Tests & Document Results**
  * [x] Run test scripts against the populated database.
  * [x] Document results (pass/fail).
  * [x] Debug and fix issues found.
  * [x] Re-run tests.
  * [x] *Deliverable:* Documented test results (simple report or updated `test_scenarios.md`).

### **Phase 5: Documentation and Reporting**

* [x] **Task 5.1: Finalize Technical Documentation**
  * [x] Compile documentation into `docs/technical_report.md`.
  * [x] Include: Overview, Simplified Conceptual Model (link to `erd.md`), Simplified Relational Schema (link to `relational_schema.md`), Description of Schemas, Tables, Functions, Procedures, Triggers, Data Strategy, Test Plan/Results, Setup Instructions.
  * [x] Ensure scripts are commented.
  * [x] *Deliverable:* Final `docs/technical_report.md` and supporting files.
* [x] **Task 5.2: Project Review and Closure**
  * [x] Conduct project review and closure
  * [x] *Deliverable:* Project review report and closure report

## **III. Final Deliverable**

* [x] **Task D.1: Package the Project**
  * [x] Ensure all code (.sql), documentation (.md), and test scripts are organized according to the defined structure.
  * [x] Add a `README.md` at the root explaining the project, structure, setup, and testing based on the simplified scope.
  * [x] *Deliverable:* The final project package containing all source code, documentation, and scripts.