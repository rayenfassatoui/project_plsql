-- Package Body: pkg_flights
-- Implementation of functions/procedures for flights, aircraft, airlines, and crew.

-- Note: Assumes airport_mgmt schema exists and is in search_path.

-- *** Airline CRUD ***

CREATE OR REPLACE FUNCTION pkg_flights.add_airline(
    p_name VARCHAR,
    p_iata_code CHAR(2)
)
RETURNS INT LANGUAGE plpgsql
AS $$
DECLARE
    v_airline_id INT;
BEGIN
    INSERT INTO airport_mgmt.airlines (name, iata_code)
    VALUES (p_name, p_iata_code)
    RETURNING airline_id INTO v_airline_id;
    RETURN v_airline_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE WARNING 'Airline with IATA code % already exists.', p_iata_code;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING 'Error adding airline %: %', p_name, SQLERRM;
        RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION pkg_flights.get_airline(p_airline_id INT)
RETURNS SETOF airport_mgmt.airlines LANGUAGE sql STABLE
AS $$
    SELECT * FROM airport_mgmt.airlines WHERE airline_id = p_airline_id;
$$;

CREATE OR REPLACE PROCEDURE pkg_flights.update_airline(
    p_airline_id INT,
    p_name VARCHAR,
    p_iata_code CHAR(2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE airport_mgmt.airlines
    SET name = p_name,
        iata_code = p_iata_code
    WHERE airline_id = p_airline_id;
    IF NOT FOUND THEN
        RAISE WARNING 'Airline with ID % not found.', p_airline_id;
    END IF;
EXCEPTION
    WHEN unique_violation THEN
        RAISE WARNING 'Could not update airline %. IATA code % already exists.', p_airline_id, p_iata_code;
    WHEN OTHERS THEN
        RAISE WARNING 'Error updating airline %: %', p_airline_id, SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE pkg_flights.delete_airline(p_airline_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM airport_mgmt.airlines WHERE airline_id = p_airline_id;
    IF NOT FOUND THEN
        RAISE WARNING 'Airline with ID % not found for deletion.', p_airline_id;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE WARNING 'Cannot delete airline % because it has associated flights.', p_airline_id;
    WHEN OTHERS THEN
        RAISE WARNING 'Error deleting airline %: %', p_airline_id, SQLERRM;
END;
$$;

-- *** Aircraft CRUD ***

CREATE OR REPLACE FUNCTION pkg_flights.add_aircraft(
    p_manufacturer VARCHAR,
    p_model VARCHAR,
    p_capacity INT
)
RETURNS INT LANGUAGE plpgsql
AS $$
DECLARE
    v_aircraft_id INT;
BEGIN
    INSERT INTO airport_mgmt.aircraft (manufacturer, model, capacity)
    VALUES (p_manufacturer, p_model, p_capacity)
    RETURNING aircraft_id INTO v_aircraft_id;
    RETURN v_aircraft_id;
EXCEPTION
    WHEN check_violation THEN
         RAISE WARNING 'Could not add aircraft %. Check constraint violated (e.g., capacity <= 0).', p_model;
         RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING 'Error adding aircraft %: %', p_model, SQLERRM;
        RETURN NULL;
END;
$$;

-- (Get, Update, Delete for Aircraft similar to Airlines - omitted for brevity but should be implemented)

-- *** Flight Management ***

CREATE OR REPLACE FUNCTION pkg_flights.add_flight(
    p_flight_number VARCHAR,
    p_airline_id INT,
    p_aircraft_id INT,
    p_origin_code CHAR(3),
    p_destination_code CHAR(3),
    p_departure TIMESTAMPTZ,
    p_arrival TIMESTAMPTZ,
    p_status VARCHAR DEFAULT 'Scheduled'
)
RETURNS INT LANGUAGE plpgsql
AS $$
DECLARE
    v_flight_id INT;
BEGIN
    INSERT INTO airport_mgmt.flights (
        flight_number, airline_id, aircraft_id, origin_airport_code,
        destination_airport_code, scheduled_departure, scheduled_arrival, status
    )
    VALUES (
        p_flight_number, p_airline_id, p_aircraft_id, p_origin_code,
        p_destination_code, p_departure, p_arrival, p_status
    )
    RETURNING flight_id INTO v_flight_id;
    RETURN v_flight_id;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE WARNING 'Could not add flight %. Invalid airline_id (%) or aircraft_id (%).', p_flight_number, p_airline_id, p_aircraft_id;
        RETURN NULL;
    WHEN check_violation THEN
         RAISE WARNING 'Could not add flight %. Check constraint violated (e.g., arrival before departure, same origin/destination).', p_flight_number;
         RETURN NULL;
    WHEN unique_violation THEN
         RAISE WARNING 'Could not add flight %. Flight number % already scheduled for departure at %.', p_flight_number, p_flight_number, p_departure;
         RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING 'Error adding flight %: %', p_flight_number, SQLERRM;
        RETURN NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE pkg_flights.update_flight_status(
    p_flight_id INT,
    p_new_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE airport_mgmt.flights
    SET status = p_new_status
    WHERE flight_id = p_flight_id;
    IF NOT FOUND THEN
        RAISE WARNING 'Flight with ID % not found.', p_flight_id;
    END IF;
EXCEPTION
    WHEN check_violation THEN
         RAISE WARNING 'Could not update flight status for flight %. Invalid status value: %.', p_flight_id, p_new_status;
    WHEN OTHERS THEN
        RAISE WARNING 'Error updating flight status for flight %: %', p_flight_id, SQLERRM;
END;
$$;

-- Update delay information for a flight
CREATE OR REPLACE PROCEDURE pkg_flights.update_flight_delay(
    p_flight_id INT,
    p_new_departure TIMESTAMPTZ,
    p_new_arrival TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_departure TIMESTAMPTZ;
    v_flight_status VARCHAR;
BEGIN
    SELECT scheduled_departure, status INTO v_current_departure, v_flight_status
    FROM airport_mgmt.flights WHERE flight_id = p_flight_id;

    IF NOT FOUND THEN
        RAISE WARNING 'Flight with ID % not found.', p_flight_id;
        RETURN;
    END IF;

    -- Validate new times
    IF p_new_arrival <= p_new_departure THEN
        RAISE EXCEPTION 'New arrival time must be after new departure time.';
    END IF;

    -- Check if flight is already departed/arrived/cancelled
     IF v_flight_status IN ('Departed', 'Arrived', 'Cancelled') THEN
        RAISE EXCEPTION 'Cannot update delay for a flight that has already %, arrived, or been cancelled.', v_flight_status;
    END IF;

    UPDATE airport_mgmt.flights
    SET
        scheduled_departure = p_new_departure,
        scheduled_arrival = p_new_arrival,
        -- Automatically update status to Delayed if not already delayed and new time is later
        status = CASE
                    WHEN status = 'Scheduled' AND p_new_departure > v_current_departure THEN 'Delayed'::VARCHAR
                    ELSE status -- Keep current status otherwise (e.g., if already Delayed)
                 END
    WHERE flight_id = p_flight_id;

EXCEPTION
    WHEN check_violation THEN
         RAISE WARNING 'Could not update flight delay for flight %. Check constraint violated (e.g., arrival before departure).', p_flight_id;
    WHEN OTHERS THEN
        RAISE WARNING 'An unexpected error occurred in update_flight_delay for flight %: % ', p_flight_id, SQLERRM;
END;
$$;

-- *** Flight Search Functions ***

CREATE OR REPLACE FUNCTION pkg_flights.find_flights_by_route(
    p_origin_code CHAR(3),
    p_destination_code CHAR(3)
)
RETURNS SETOF airport_mgmt.flights LANGUAGE sql STABLE
AS $$
    SELECT * FROM airport_mgmt.flights
    WHERE origin_airport_code = p_origin_code
      AND destination_airport_code = p_destination_code
    ORDER BY scheduled_departure;
$$;

CREATE OR REPLACE FUNCTION pkg_flights.find_flights_by_status(
    p_status VARCHAR
)
RETURNS SETOF airport_mgmt.flights LANGUAGE sql STABLE
AS $$
    SELECT * FROM airport_mgmt.flights
    WHERE status = p_status
    ORDER BY scheduled_departure;
$$;

-- *** Crew Management ***

-- (CRUD for Crew similar to Airlines - omitted for brevity but should be implemented)

CREATE OR REPLACE FUNCTION pkg_flights.assign_crew_member(
    p_flight_id INT,
    p_crew_id INT
)
RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
BEGIN
    -- Basic check: Prevent assigning crew if flight doesn't exist or crew doesn't exist (FK constraint handles this too)
    IF NOT EXISTS (SELECT 1 FROM airport_mgmt.flights WHERE flight_id = p_flight_id) THEN
        RAISE WARNING 'Flight ID % does not exist.', p_flight_id;
        RETURN FALSE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM airport_mgmt.crew WHERE crew_id = p_crew_id) THEN
        RAISE WARNING 'Crew ID % does not exist.', p_crew_id;
        RETURN FALSE;
    END IF;

    -- Add more complex checks if needed (e.g., check for time conflicts - requires schedule info)
    -- Example placeholder for a trigger/constraint based check:
    -- IF fn_check_crew_availability(p_crew_id, (SELECT scheduled_departure FROM flights WHERE flight_id = p_flight_id)) = FALSE THEN ...

    INSERT INTO airport_mgmt.flight_crew (flight_id, crew_id)
    VALUES (p_flight_id, p_crew_id);
    RETURN TRUE;
EXCEPTION
    WHEN unique_violation THEN
        RAISE WARNING 'Crew member % already assigned to flight %.', p_crew_id, p_flight_id;
        RETURN FALSE;
    WHEN foreign_key_violation THEN
        RAISE WARNING 'Invalid flight_id (%) or crew_id (%). Cannot assign crew.', p_flight_id, p_crew_id;
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE WARNING 'Error assigning crew % to flight %: %', p_crew_id, p_flight_id, SQLERRM;
        RETURN FALSE;
END;
$$;

CREATE OR REPLACE PROCEDURE pkg_flights.remove_crew_member(
    p_flight_id INT,
    p_crew_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM airport_mgmt.flight_crew
    WHERE flight_id = p_flight_id AND crew_id = p_crew_id;
    IF NOT FOUND THEN
        RAISE WARNING 'Crew member % was not assigned to flight %.', p_crew_id, p_flight_id;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error removing crew % from flight %: %', p_crew_id, p_flight_id, SQLERRM;
END;
$$;

CREATE OR REPLACE FUNCTION pkg_flights.find_crew_for_flight(
    p_flight_id INT
)
RETURNS SETOF airport_mgmt.crew LANGUAGE sql STABLE
AS $$
    SELECT c.*
    FROM airport_mgmt.crew c
    JOIN airport_mgmt.flight_crew fc ON c.crew_id = fc.crew_id
    WHERE fc.flight_id = p_flight_id;
$$; 