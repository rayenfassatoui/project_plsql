-- Package Specification: pkg_flights
-- Contains functions and procedures for managing flights, aircraft, airlines, and crew assignments.

CREATE SCHEMA IF NOT EXISTS pkg_flights;

-- Intended Functions/Procedures:
-- CRUD for airlines
-- CRUD for aircraft
-- add_flight(...) RETURNS INT (flight_id)
-- update_flight_status(...)
-- find_flights_by_route(origin, destination) RETURNS SETOF airport_mgmt.flights
-- find_flights_by_status(status) RETURNS SETOF airport_mgmt.flights
-- find_crew_for_flight(p_flight_id) RETURNS SETOF airport_mgmt.crew
-- assign_crew_member(p_flight_id, p_crew_id) RETURNS BOOLEAN
-- remove_crew_member(p_flight_id, p_crew_id)
-- update_flight_delay(p_flight_id, ...) 