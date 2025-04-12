-- Test Script: Crew Assignment and Crew CRUD

-- Assumes setup is done (schema, packages, triggers, data)
-- Run this after running all setup scripts.

-- Set search path
SET search_path TO airport_mgmt, pkg_flights, public;

-- ** Crew Tests (Extend similar tests here) **

-- Scenario 6.1: Add Crew
-- SELECT pkg_crew.add_crew(...) -- Need to create pkg_crew or add to pkg_flights

-- ** Crew Assignment Tests **

-- Scenario 7.1: Assign Crew Member (Valid)
-- Assign Crew 2 (Grace/Co-Pilot) to Flight 4 (BB202)
SELECT pkg_flights.assign_crew_member(4, 2) AS assign_result_1;
SELECT * FROM flight_crew WHERE flight_id = 4 AND crew_id = 2;

-- Scenario 7.2: Assign Crew Invalid FK
SELECT pkg_flights.assign_crew_member(4, 999) AS assign_invalid_crew; -- Should warn/return FALSE
SELECT pkg_flights.assign_crew_member(999, 2) AS assign_invalid_flight; -- Should warn/return FALSE

-- Scenario 7.3 (Trigger): Attempt Assignment to Non-Assignable Flight
-- Use Flight 6 (DD401 - Arrived)
SELECT pkg_flights.assign_crew_member(6, 3) AS assign_to_arrived; -- Should raise exception from trigger

-- Scenario 7.4 (Constraint): Attempt Duplicate Assignment
SELECT pkg_flights.assign_crew_member(4, 2) AS assign_duplicate; -- Should warn/return FALSE (PK violation)

-- Scenario 7.5: Find Crew for Flight
SELECT * FROM pkg_flights.find_crew_for_flight(1); -- Find crew for AA101
SELECT * FROM pkg_flights.find_crew_for_flight(4); -- Find crew for BB202 (should include Grace now)

-- Scenario 7.6: Remove Crew Member
CALL pkg_flights.remove_crew_member(4, 2);
SELECT * FROM flight_crew WHERE flight_id = 4 AND crew_id = 2; -- Should be empty
-- Try removing again
CALL pkg_flights.remove_crew_member(4, 2); -- Should warn


-- ** Trigger Verification Tests **

-- Scenario 8.1 (Flight Log Trigger): Verified in test_crud_flights.sql Scenario 3.5
-- Scenario 8.2 (Overbooking Trigger): Manual test outlined in test_booking_logic.sql Scenario 5.5
-- Scenario 8.3 (Crew Assign Check Trigger): Verified in Scenario 7.3 above

-- Reset search path to default
RESET search_path; 