# Test Scenarios for Airport Management System

This document outlines test scenarios for the PL/PGSQL components.

## Setup

Before running tests, ensure the following steps are completed:
1.  Database schema created (`01_schemas.sql`, `02_tables/*.sql`, etc.)
2.  Packages compiled (`packages/*_spec.sql`, `packages/*_body.sql`)
3.  Triggers created (`triggers/*.sql`)
4.  Sample data inserted (`data/*.sql` in correct order)

## Test Suites

### 1. Airline CRUD (`test_crud_flights.sql`)

*   **Scenario 1.1:** Add a new airline successfully.
    *   Call `pkg_flights.add_airline` with valid data.
    *   Verify: Returns a new ID, `SELECT` confirms the airline exists.
*   **Scenario 1.2:** Add a duplicate airline (by IATA code).
    *   Call `pkg_flights.add_airline` with an existing IATA code.
    *   Verify: Returns NULL, raises a WARNING, no new airline inserted.
*   **Scenario 1.3:** Get an existing airline.
    *   Call `pkg_flights.get_airline` with a valid ID.
    *   Verify: Returns the correct airline row.
*   **Scenario 1.4:** Update an existing airline.
    *   Call `pkg_flights.update_airline` with valid data.
    *   Verify: `SELECT` confirms data is updated.
*   **Scenario 1.5:** Delete an airline without flights.
    *   Add a temporary airline.
    *   Call `pkg_flights.delete_airline` on the temporary airline.
    *   Verify: `SELECT` shows the airline is gone.
*   **Scenario 1.6:** Attempt to delete an airline with flights.
    *   Call `pkg_flights.delete_airline` on an airline with existing flights (e.g., ID 1).
    *   Verify: Raises a WARNING (due to FK constraint), airline is NOT deleted.

### 2. Aircraft CRUD (`test_crud_flights.sql` - Extend)

*   (Similar scenarios as Airlines: Add, Add Duplicate [if unique constraint added], Get, Update, Delete, Delete with Flights)

### 3. Flight Management (`test_crud_flights.sql`)

*   **Scenario 3.1:** Add a valid flight.
    *   Call `pkg_flights.add_flight` with valid data.
    *   Verify: Returns new ID, `SELECT` confirms flight exists with status 'Scheduled'.
*   **Scenario 3.2:** Add a flight with invalid FK (airline/aircraft).
    *   Call `pkg_flights.add_flight` with non-existent `airline_id` or `aircraft_id`.
    *   Verify: Returns NULL, raises WARNING, no flight inserted.
*   **Scenario 3.3:** Add a flight violating CHECK constraint (arrival <= departure).
    *   Call `pkg_flights.add_flight` with invalid times.
    *   Verify: Returns NULL, raises WARNING, no flight inserted.
*   **Scenario 3.4:** Add a duplicate flight (number + departure time).
    *   Call `pkg_flights.add_flight` duplicating an existing flight number and departure time.
    *   Verify: Returns NULL, raises WARNING, no flight inserted.
*   **Scenario 3.5:** Update flight status.
    *   Call `pkg_flights.update_flight_status` for a flight.
    *   Verify: `SELECT` confirms status change.
*   **Scenario 3.6:** Update flight delay (valid).
    *   Call `pkg_flights.update_flight_delay` for a 'Scheduled' flight with later times.
    *   Verify: Times updated, Status changes to 'Delayed', Audit log entry created (check `flight_audit_log`).
*   **Scenario 3.7:** Update flight delay (arrival <= departure).
    *   Call `pkg_flights.update_flight_delay` with invalid times.
    *   Verify: Raises EXCEPTION or WARNING, flight data unchanged.
*   **Scenario 3.8:** Attempt update delay on 'Departed' flight.
    *   Call `pkg_flights.update_flight_delay` on a departed/arrived flight.
    *   Verify: Raises EXCEPTION, flight data unchanged.
*   **Scenario 3.9:** Find flights by route.
    *   Call `pkg_flights.find_flights_by_route`.
    *   Verify: Returns expected flight set.
*   **Scenario 3.10:** Find flights by status.
    *   Call `pkg_flights.find_flights_by_status`.
    *   Verify: Returns expected flight set.

### 4. Passenger CRUD (`test_booking_logic.sql` - Extend)

*   (Similar scenarios as Airlines: Add, Add Duplicate [email], Get, Update, Delete, Delete with Bookings)

### 5. Booking Logic (`test_booking_logic.sql`)

*   **Scenario 5.1:** Create a valid booking.
    *   Call `pkg_bookings.create_booking` for an available flight/passenger.
    *   Verify: Returns new ID, `SELECT` confirms booking exists with status 'Confirmed'.
*   **Scenario 5.2:** Create booking with invalid FK (flight/passenger).
    *   Call `pkg_bookings.create_booking` with non-existent IDs.
    *   Verify: Returns NULL, raises WARNING, no booking inserted.
*   **Scenario 5.3:** Attempt duplicate booking (same passenger/flight).
    *   Call `pkg_bookings.create_booking` again for same passenger/flight.
    *   Verify: Returns NULL, raises WARNING, no booking inserted.
*   **Scenario 5.4:** Attempt duplicate seat assignment on same flight.
    *   Call `pkg_bookings.create_booking` for a different passenger but same flight/seat.
    *   Verify: Returns NULL, raises WARNING, no booking inserted.
*   **Scenario 5.5 (Trigger):** Attempt overbooking.
    *   Find a flight near capacity (based on sample data/aircraft).
    *   Add bookings until capacity is reached.
    *   Attempt `INSERT INTO airport_mgmt.bookings` (or call `create_booking`) for one more passenger.
    *   Verify: `INSERT`/function call raises EXCEPTION from `fn_prevent_overbooking` trigger.
*   **Scenario 5.6:** Cancel an existing booking.
    *   Call `pkg_bookings.cancel_booking` for a 'Confirmed' booking.
    *   Verify: `SELECT` shows status changed to 'Cancelled'.
*   **Scenario 5.7:** Check-in a valid passenger.
    *   Call `pkg_bookings.check_in_passenger` for a 'Confirmed' booking on a 'Scheduled'/'Delayed' flight.
    *   Verify: `SELECT` shows status changed to 'Checked-in'.
*   **Scenario 5.8:** Attempt check-in on cancelled booking.
    *   Call `pkg_bookings.check_in_passenger` for a 'Cancelled' booking.
    *   Verify: Raises EXCEPTION.
*   **Scenario 5.9:** Attempt check-in for flight not Scheduled/Delayed.
    *   Find a booking for an 'Arrived' or 'Cancelled' flight.
    *   Call `pkg_bookings.check_in_passenger`.
    *   Verify: Raises EXCEPTION.
*   **Scenario 5.10:** Find bookings for a passenger.
    *   Call `pkg_bookings.find_passenger_bookings`.
    *   Verify: Returns expected booking set.

### 6. Crew CRUD (`test_crew_assignment.sql` - Extend)

*   (Similar scenarios as Airlines: Add, Add Duplicate [employee_id], Get, Update, Delete, Delete with Assignments)

### 7. Crew Assignment (`test_crew_assignment.sql`)

*   **Scenario 7.1:** Assign crew member to a valid flight.
    *   Call `pkg_flights.assign_crew_member`.
    *   Verify: Returns TRUE, `SELECT` from `flight_crew` confirms assignment.
*   **Scenario 7.2:** Assign crew with invalid FK (flight/crew).
    *   Call `pkg_flights.assign_crew_member` with non-existent IDs.
    *   Verify: Returns FALSE, raises WARNING, no assignment.
*   **Scenario 7.3 (Trigger):** Attempt assignment to 'Departed'/'Arrived' flight.
    *   Attempt `INSERT INTO airport_mgmt.flight_crew` or call `assign_crew_member` for a past/departed flight.
    *   Verify: Raises EXCEPTION from `fn_check_crew_assignment` trigger.
*   **Scenario 7.4 (Constraint):** Attempt duplicate assignment (same crew/flight).
    *   Call `pkg_flights.assign_crew_member` again for same crew/flight.
    *   Verify: Returns FALSE, raises WARNING (PK constraint violation).
*   **Scenario 7.5:** Find crew for a flight.
    *   Call `pkg_flights.find_crew_for_flight`.
    *   Verify: Returns expected crew members.
*   **Scenario 7.6:** Remove crew member from a flight.
    *   Call `pkg_flights.remove_crew_member`.
    *   Verify: `SELECT` from `flight_crew` confirms removal.

### 8. Trigger Verification

*   **Scenario 8.1 (Flight Log):**
    *   Update a flight status using `pkg_flights.update_flight_status`.
    *   Verify: `SELECT` from `flight_audit_log` shows a new entry with correct old/new status.
*   **Scenario 8.2 (Overbooking):** (Covered in Scenario 5.5)
*   **Scenario 8.3 (Crew Assign Check):** (Covered in Scenario 7.3) 