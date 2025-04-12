-- Trigger: Check Crew Assignment (Basic)

-- Trigger Function
CREATE OR REPLACE FUNCTION airport_mgmt.fn_check_crew_assignment()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
DECLARE
    v_flight_departure TIMESTAMPTZ;
    v_crew_role VARCHAR;
    v_flight_status VARCHAR;
BEGIN
    -- Get flight and crew details
    SELECT f.scheduled_departure, f.status INTO v_flight_departure, v_flight_status
    FROM airport_mgmt.flights f WHERE f.flight_id = NEW.flight_id;

    SELECT c.role INTO v_crew_role
    FROM airport_mgmt.crew c WHERE c.crew_id = NEW.crew_id;

    -- Basic Checks
    IF NOT FOUND THEN
        -- This should ideally be caught by FK constraints first
        IF v_flight_departure IS NULL THEN RAISE EXCEPTION 'Flight ID % not found.', NEW.flight_id; END IF;
        IF v_crew_role IS NULL THEN RAISE EXCEPTION 'Crew ID % not found.', NEW.crew_id; END IF;
    END IF;

    -- Prevent assignment to flights that are already departed/arrived/cancelled
    IF v_flight_status IN ('Departed', 'Arrived', 'Cancelled') THEN
        RAISE EXCEPTION 'Cannot assign crew to flight % because its status is %.', NEW.flight_id, v_flight_status;
    END IF;

    -- Placeholder for more complex checks (e.g., time conflicts, required roles per flight)
    -- Example: Check if pilot is already assigned, prevent assigning another pilot
    -- IF v_crew_role = 'Pilot' AND EXISTS (
    --     SELECT 1 FROM airport_mgmt.flight_crew fc
    --     JOIN airport_mgmt.crew c ON fc.crew_id = c.crew_id
    --     WHERE fc.flight_id = NEW.flight_id AND c.role = 'Pilot' AND fc.crew_id <> NEW.crew_id
    -- ) THEN
    --     RAISE EXCEPTION 'Flight % already has a Pilot assigned.', NEW.flight_id;
    -- END IF;

    -- Placeholder: Check crew availability (e.g., not assigned to another overlapping flight)
    -- This requires querying flight_crew and flights based on time ranges and is more complex.
    -- Example concept:
    -- IF EXISTS (
    --     SELECT 1 FROM airport_mgmt.flight_crew conflicting_fc
    --     JOIN airport_mgmt.flights conflicting_f ON conflicting_fc.flight_id = conflicting_f.flight_id
    --     WHERE conflicting_fc.crew_id = NEW.crew_id
    --       AND conflicting_fc.flight_id <> NEW.flight_id -- Exclude the current assignment being checked
    --       AND TSTZRANGE(conflicting_f.scheduled_departure, conflicting_f.scheduled_arrival, '[)') && -- Check for overlap
    --           TSTZRANGE(v_flight_departure, (SELECT scheduled_arrival FROM airport_mgmt.flights WHERE flight_id = NEW.flight_id), '[)')
    -- ) THEN
    --     RAISE EXCEPTION 'Crew member % is already assigned to an overlapping flight.', NEW.crew_id;
    -- END IF;

    RETURN NEW; -- Allow INSERT/UPDATE
END;
$$;

-- Trigger Definition
DROP TRIGGER IF EXISTS trg_check_crew_assign ON airport_mgmt.flight_crew;
CREATE TRIGGER trg_check_crew_assign
BEFORE INSERT OR UPDATE ON airport_mgmt.flight_crew -- Check on insert and update
FOR EACH ROW
EXECUTE FUNCTION airport_mgmt.fn_check_crew_assignment(); 