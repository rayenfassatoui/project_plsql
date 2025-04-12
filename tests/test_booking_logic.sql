-- Test Script: Booking Logic and Passenger CRUD

-- Assumes setup is done (schema, packages, triggers, data)
-- Run this after running all setup scripts.

-- Set search path
SET search_path TO airport_mgmt, pkg_bookings, pkg_flights, public;

-- ** Passenger Tests (Extend similar tests here) **

-- Scenario 4.1: Add Passenger
SELECT pkg_bookings.add_passenger('Test', 'User', 'test.user@email.com', '555-9999') AS new_passenger_id;
SELECT * FROM passengers WHERE email = 'test.user@email.com';


-- ** Booking Tests **

-- Scenario 5.1: Create Valid Booking
-- Find a valid flight ID (e.g., flight ID 4 - BB202)
-- Find a valid passenger ID (e.g., passenger ID 1 - Alice)
SELECT pkg_bookings.create_booking(4, 1, '1A') AS new_booking_id_1;
SELECT * FROM bookings WHERE flight_id = 4 AND passenger_id = 1;

-- Scenario 5.2: Create Booking Invalid FK
SELECT pkg_bookings.create_booking(999, 1, '1B') AS invalid_flight_booking_id; -- Should warn/return NULL
SELECT pkg_bookings.create_booking(4, 999, '1C') AS invalid_passenger_booking_id; -- Should warn/return NULL

-- Scenario 5.3: Attempt Duplicate Booking (Passenger/Flight)
SELECT pkg_bookings.create_booking(4, 1, '1D') AS duplicate_booking_id; -- Should warn/return NULL

-- Scenario 5.4: Attempt Duplicate Seat Assignment
SELECT pkg_bookings.create_booking(4, 2, '1A') AS duplicate_seat_booking_id; -- Should warn/return NULL (Booking for seat 1A on flight 4 already exists)

-- Scenario 5.5 (Trigger): Attempt Overbooking (Manual example - depends heavily on capacity/data)
-- Assumes Flight 3 (BB201) uses Aircraft 2 (A320, Capacity 150)
-- Need to insert ~148 more bookings for flight 3 before this test
-- BEGIN;
-- SELECT pkg_bookings.create_booking(3, 5, '20A') -- Assume this makes bookings = capacity
-- SELECT pkg_bookings.create_booking(3, 1, '20B'); -- This one should fail due to trigger
-- ROLLBACK; -- Rollback test inserts
-- Note: Proper testing requires inserting many rows or adjusting capacity.

-- Scenario 5.6: Cancel Booking
-- Find a booking ID (e.g., the one created in 5.1 - let's assume ID 7 if starting from clean slate)
DO $$ DECLARE v_booking_id INT; BEGIN v_booking_id := (SELECT booking_id FROM bookings WHERE flight_id=4 AND passenger_id=1); CALL pkg_bookings.cancel_booking(v_booking_id); END $$;
SELECT status FROM bookings WHERE flight_id = 4 AND passenger_id = 1; -- Should be Cancelled
-- Try cancelling again
DO $$ DECLARE v_booking_id INT; BEGIN v_booking_id := (SELECT booking_id FROM bookings WHERE flight_id=4 AND passenger_id=1); CALL pkg_bookings.cancel_booking(v_booking_id); END $$; -- Should warn

-- Scenario 5.7: Check-in Valid Passenger
-- Use Booking for Flight 3, Passenger 3 (Carol Williams, ID 3)
-- Assume this booking ID is 3
SELECT status FROM bookings WHERE booking_id = 3;
CALL pkg_bookings.check_in_passenger(3);
SELECT status FROM bookings WHERE booking_id = 3; -- Should be Checked-in
-- Try check-in again
CALL pkg_bookings.check_in_passenger(3); -- Should warn

-- Scenario 5.8: Attempt Check-in Cancelled Booking
-- Use the booking cancelled in 5.6
DO $$ DECLARE v_booking_id INT; BEGIN v_booking_id := (SELECT booking_id FROM bookings WHERE flight_id=4 AND passenger_id=1); CALL pkg_bookings.check_in_passenger(v_booking_id); END $$; -- Should raise exception

-- Scenario 5.9: Attempt Check-in for Non-Checkinable Flight
-- Use Booking for Flight 6 (DD401 - Arrived), Passenger 1 (Alice)
-- Assume this booking ID is 6
SELECT status FROM flights WHERE flight_id = 6; -- Should be Arrived
CALL pkg_bookings.check_in_passenger(6); -- Should raise exception

-- Scenario 5.10: Find Passenger Bookings
SELECT * FROM pkg_bookings.find_passenger_bookings(1); -- Find Alice's bookings

-- Reset search path to default
RESET search_path; 