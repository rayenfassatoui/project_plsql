-- Package Specification: pkg_bookings
-- Contains functions and procedures for managing passengers and bookings.

CREATE SCHEMA IF NOT EXISTS pkg_bookings;

-- Intended Functions/Procedures:
-- CRUD for passengers
-- create_booking(p_flight_id, p_passenger_id, p_seat_number) RETURNS INT (booking_id)
-- cancel_booking(p_booking_id)
-- find_passenger_bookings(p_passenger_id) RETURNS SETOF airport_mgmt.bookings
-- check_in_passenger(p_booking_id) 