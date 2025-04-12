-- Test Script: CRUD Operations for Flights, Airlines, Aircraft

-- Assumes setup is done (schema, packages, triggers, data)
-- Run this after running all setup scripts.

-- Set search path
SET search_path TO airport_mgmt, pkg_flights, public;

-- ** Airline Tests **

-- Scenario 1.1: Add Airline
SELECT pkg_flights.add_airline('Echo Express', 'EE') AS new_airline_id;
SELECT * FROM airlines WHERE iata_code = 'EE';

-- Scenario 1.2: Add Duplicate Airline
SELECT pkg_flights.add_airline('Duplicate Air', 'AA') AS duplicate_airline_id; -- Should warn/return NULL
SELECT COUNT(*) FROM airlines WHERE iata_code = 'AA'; -- Should still be 1

-- Scenario 1.3: Get Airline
SELECT * FROM pkg_flights.get_airline(1); -- Get Alpha Air

-- Scenario 1.4: Update Airline
CALL pkg_flights.update_airline(1, 'Alpha Airways Updated', 'A1');
SELECT * FROM airlines WHERE airline_id = 1;
-- Revert change
CALL pkg_flights.update_airline(1, 'Alpha Air', 'AA');

-- Scenario 1.5: Delete Airline (no flights)
DO $$DECLARE v_temp_id INT; BEGIN v_temp_id := pkg_flights.add_airline('Temp Air', 'T1'); CALL pkg_flights.delete_airline(v_temp_id); END$$;
SELECT * FROM airlines WHERE iata_code = 'T1'; -- Should be empty

-- Scenario 1.6: Attempt Delete Airline with Flights
CALL pkg_flights.delete_airline(1); -- Should warn, airline 1 should still exist
SELECT * FROM airlines WHERE airline_id = 1;


-- ** Aircraft Tests (Extend similar tests here) **

-- Scenario 2.1: Add Aircraft
SELECT pkg_flights.add_aircraft('Bombardier', 'CRJ900', 90) AS new_aircraft_id;
SELECT * FROM aircraft WHERE model = 'CRJ900';


-- ** Flight Tests **

-- Scenario 3.1: Add Valid Flight
SELECT pkg_flights.add_flight('BB999', 2, 2, 'LGA', 'BOS', NOW() + INTERVAL '3 day', NOW() + INTERVAL '3 day 2 hours') AS new_flight_id;
SELECT * FROM flights WHERE flight_number = 'BB999';

-- Scenario 3.2: Add Flight with Invalid FK
SELECT pkg_flights.add_flight('XX001', 999, 1, 'JFK', 'LAX', NOW() + INTERVAL '4 day', NOW() + INTERVAL '4 day 6 hours') AS invalid_fk_flight_id; -- Should warn/return NULL

-- Scenario 3.3: Add Flight Violating CHECK (Arrival <= Departure)
SELECT pkg_flights.add_flight('XX002', 1, 1, 'JFK', 'LAX', NOW() + INTERVAL '4 day 6 hours', NOW() + INTERVAL '4 day') AS invalid_time_flight_id; -- Should warn/return NULL

-- Scenario 3.5: Update Flight Status
CALL pkg_flights.update_flight_status(1, 'Cancelled');
SELECT status FROM flights WHERE flight_id = 1;
-- Check audit log (Scenario 8.1 verification)
SELECT * FROM flight_audit_log WHERE flight_id = 1 ORDER BY change_time DESC LIMIT 1;
-- Revert status for other tests
CALL pkg_flights.update_flight_status(1, 'Scheduled');

-- Scenario 3.6: Update Flight Delay (Valid)
SELECT scheduled_departure, scheduled_arrival, status FROM flights WHERE flight_id = 2; -- AA102
CALL pkg_flights.update_flight_delay(2, NOW() + INTERVAL '1 day 9 hours', NOW() + INTERVAL '1 day 15 hours');
SELECT scheduled_departure, scheduled_arrival, status FROM flights WHERE flight_id = 2; -- Should show updated times and 'Delayed' status
-- Check audit log again
SELECT * FROM flight_audit_log WHERE flight_id = 2 ORDER BY change_time DESC LIMIT 1;

-- Scenario 3.9: Find Flights by Route
SELECT * FROM pkg_flights.find_flights_by_route('JFK', 'LAX');

-- Scenario 3.10: Find Flights by Status
SELECT * FROM pkg_flights.find_flights_by_status('Delayed');

-- Reset search path to default
RESET search_path; 