-- Sample Flight Crew Assignments
-- Assumes airport_mgmt schema exists and flights/crew are populated

-- Note: Using hardcoded IDs based on previous inserts. In a real script, use queries or CTEs.
-- Flight IDs: 1 (AA101), 2 (AA102), 3 (BB201), 4 (BB202), 5 (CC301), 6 (DD401)
-- Crew IDs: 1 (Frank/Pilot), 2 (Grace/Co-Pilot), 3 (Henry/Purser), 4 (Ivy/Attendant), 5 (Judy/Attendant), 6 (Ken/Pilot)

INSERT INTO airport_mgmt.flight_crew (flight_id, crew_id)
VALUES
-- Crew for AA101 (Flight 1)
(1, 1), -- Frank (Pilot)
(1, 2), -- Grace (Co-Pilot)
(1, 4), -- Ivy (Attendant)
(1, 5), -- Judy (Attendant)

-- Crew for BB201 (Flight 3)
(3, 6), -- Ken (Pilot)
(3, 3), -- Henry (Purser)
(3, 4), -- Ivy (Attendant) - Note: Ivy could be assigned if flights don't overlap

-- Crew for CC301 (Flight 5 - Delayed)
(5, 1), -- Frank (Pilot)
(5, 5); -- Judy (Attendant)

-- Attempt to assign crew to past flight (DD401 - Flight 6) - should fail if trigger is active
-- INSERT INTO airport_mgmt.flight_crew (flight_id, crew_id) VALUES (6, 2);

-- Attempt to double-assign crew (Frank to AA101 again) - should fail (PK constraint)
-- INSERT INTO airport_mgmt.flight_crew (flight_id, crew_id) VALUES (1, 1);

-- SELECT fc.flight_id, fc.crew_id, c.first_name, c.role, f.flight_number
-- FROM airport_mgmt.flight_crew fc
-- JOIN airport_mgmt.crew c ON fc.crew_id = c.crew_id
-- JOIN airport_mgmt.flights f ON fc.flight_id = f.flight_id
-- ORDER BY fc.flight_id, c.role; 