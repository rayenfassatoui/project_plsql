# Airport Management System Database (PL/pgSQL Project)

This project contains the PostgreSQL database schema, PL/pgSQL functions/procedures, triggers, sample data, and tests for a simplified Airport Management System.

## Project Structure

The project follows the structure defined in `plsql-plan.md`:

```
airport_mgmt_db/
├── data/                 # Sample data scripts
├── db_schema/            # DDL scripts (schemas, tables, indexes)
│   └── 02_tables/
├── docs/                 # Documentation (ERD, Schema, Report)
├── functions/            # Standalone functions (currently unused)
├── packages/             # Package simulation (schemas, specs, bodies)
├── procedures/           # Standalone procedures (currently unused)
├── tests/                # Test scripts and scenarios
├── triggers/             # Trigger functions and definitions
└── README.md             # This file
```

## Features

*   **Schema:** Manages Airlines, Aircraft, Flights, Passengers, Bookings, Crew, and Flight Crew assignments.
*   **Packages (emulated):**
    *   `pkg_flights`: Handles logic for flights, airlines, aircraft, crew.
    *   `pkg_bookings`: Handles logic for passengers and bookings.
*   **Triggers:**
    *   Logs flight status changes.
    *   Prevents overbooking.
    *   Basic validation for crew assignments.
*   **Sample Data:** Includes scripts to populate the database for testing.
*   **Tests:** Basic SQL scripts to test package functions and triggers.

## Setup

For detailed setup instructions, please refer to the **Setup Instructions** section in the [Technical Report](docs/technical_report.md).

In summary:
1.  Ensure PostgreSQL is installed.
2.  Create a database and a user/role (e.g., `plsqldb_owner`).
3.  Connect to the database as the user.
4.  Run the SQL scripts in the specified order (Schema -> Tables -> Indexes -> Packages -> Triggers -> Data -> Tests) using `psql \i <script_path>`.

## Usage

Once the database is set up and populated, you can interact with it using:
*   Standard SQL queries.
*   Calling the functions and procedures defined in the `pkg_flights` and `pkg_bookings` schemas (e.g., `SELECT * FROM pkg_flights.find_flights_by_route('JFK', 'LAX');`, `CALL pkg_bookings.check_in_passenger(1);`).
