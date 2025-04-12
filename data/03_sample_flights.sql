-- Sample Flights
-- Assumes airport_mgmt schema exists and airlines/aircraft are populated

-- Note: Using hardcoded IDs based on previous inserts. In a real script, use queries or CTEs.
-- Airline IDs: 1 (AA), 2 (BB), 3 (CC), 4 (DD)
-- Aircraft IDs: 1 (737), 2 (A320), 3 (777), 4 (E190)

INSERT INTO airport_mgmt.flights (flight_number, airline_id, aircraft_id, origin_airport_code, destination_airport_code, scheduled_departure, scheduled_arrival, status)
VALUES
-- Alpha Air Flights
('AA101', 1, 1, 'JFK', 'LAX', NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 6 hours', 'Scheduled'),
('AA102', 1, 1, 'LAX', 'JFK', NOW() + INTERVAL '1 day 8 hours', NOW() + INTERVAL '1 day 14 hours', 'Scheduled'),
-- Bravo Airways Flights
('BB201', 2, 2, 'ORD', 'MIA', NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 3 hours', 'Scheduled'),
('BB202', 2, 2, 'MIA', 'ORD', NOW() + INTERVAL '2 days 5 hours', NOW() + INTERVAL '2 days 8 hours', 'Scheduled'),
-- Charlie Charters (one delayed)
('CC301', 3, 4, 'DEN', 'SFO', NOW() + INTERVAL '1 day 2 hours', NOW() + INTERVAL '1 day 4 hours 30 minutes', 'Delayed'),
-- Delta Dominion (one arrived - in the past)
('DD401', 4, 3, 'ATL', 'LHR', NOW() - INTERVAL '12 hours', NOW() - INTERVAL '4 hours', 'Arrived');

-- SELECT * FROM airport_mgmt.flights; 