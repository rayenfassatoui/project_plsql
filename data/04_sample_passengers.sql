-- Sample Passengers
-- Assumes airport_mgmt schema exists

INSERT INTO airport_mgmt.passengers (first_name, last_name, email, phone_number) VALUES
('Alice', 'Smith', 'alice.s@email.com', '555-1111'),
('Bob', 'Jones', 'bob.j@email.com', '555-2222'),
('Carol', 'Williams', 'carol.w@email.com', '555-3333'),
('David', 'Brown', 'david.b@email.com', '555-4444'),
('Eve', 'Davis', 'eve.d@email.com', NULL);

-- SELECT * FROM airport_mgmt.passengers; 