-- Sample Crew
-- Assumes airport_mgmt schema exists

INSERT INTO airport_mgmt.crew (first_name, last_name, employee_id, role) VALUES
('Frank', 'Miller', 'EMP101', 'Pilot'),
('Grace', 'Lee', 'EMP102', 'Co-Pilot'),
('Henry', 'Wilson', 'EMP201', 'Purser'),
('Ivy', 'Moore', 'EMP202', 'Flight Attendant'),
('Judy', 'Taylor', 'EMP203', 'Flight Attendant'),
('Ken', 'Anderson', 'EMP103', 'Pilot');

-- SELECT * FROM airport_mgmt.crew; 