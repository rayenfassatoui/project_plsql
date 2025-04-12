-- Sample Aircraft
-- Assumes airport_mgmt schema exists

INSERT INTO airport_mgmt.aircraft (manufacturer, model, capacity) VALUES
('Boeing', '737', 180),
('Airbus', 'A320', 150),
('Boeing', '777', 300),
('Embraer', 'E190', 100);

-- SELECT * FROM airport_mgmt.aircraft; 