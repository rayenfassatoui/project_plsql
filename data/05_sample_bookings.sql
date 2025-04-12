-- Sample Bookings
-- Assumes airport_mgmt schema exists and flights/passengers are populated

-- Note: Using hardcoded IDs based on previous inserts. In a real script, use queries or CTEs.
-- Flight IDs: 1 (AA101), 2 (AA102), 3 (BB201), 4 (BB202), 5 (CC301), 6 (DD401)
-- Passenger IDs: 1 (Alice), 2 (Bob), 3 (Carol), 4 (David), 5 (Eve)

INSERT INTO airport_mgmt.bookings (flight_id, passenger_id, seat_number, status)
VALUES
-- Bookings for AA101 (Flight 1)
(1, 1, '10A', 'Confirmed'),
(1, 2, '10B', 'Checked-in'), -- Bob checked in
-- Bookings for BB201 (Flight 3)
(3, 3, '5F', 'Confirmed'),
(3, 4, '5E', 'Confirmed'),
-- Booking for CC301 (Flight 5)
(5, 5, '3A', 'Confirmed'),
-- Booking for past flight DD401 (Flight 6) - already arrived
(6, 1, '22C', 'Checked-in'); -- Alice was on this flight

-- Attempt an overbooking (should fail if trigger is active)
-- INSERT INTO airport_mgmt.bookings (flight_id, passenger_id) VALUES (3, 1);

-- SELECT * FROM airport_mgmt.bookings; 