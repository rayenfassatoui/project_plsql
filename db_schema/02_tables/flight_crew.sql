-- 02_tables/flight_crew.sql
-- Depends on: 01_schemas.sql, flights.sql, crew.sql

SET search_path TO airport_mgmt, public;

CREATE TABLE IF NOT EXISTS flight_crew (
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    assignment_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_flight_crew PRIMARY KEY (flight_id, crew_id),
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_crew FOREIGN KEY (crew_id) REFERENCES crew(crew_id) ON DELETE CASCADE
);
