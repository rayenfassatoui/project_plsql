-- Trigger: Log Flight Status Changes

-- First, create a log table (can be in the main airport_mgmt schema or a separate audit schema)
CREATE TABLE IF NOT EXISTS airport_mgmt.flight_audit_log (
    log_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    change_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    changed_by NAME DEFAULT CURRENT_USER -- PostgreSQL specific function
);

-- Trigger Function
CREATE OR REPLACE FUNCTION airport_mgmt.fn_log_flight_status_change()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
    -- Log only if the status actually changed
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO airport_mgmt.flight_audit_log (flight_id, old_status, new_status)
        VALUES (NEW.flight_id, OLD.status, NEW.status);
    END IF;
    RETURN NEW; -- For AFTER trigger, return value is ignored, but good practice
END;
$$;

-- Trigger Definition
DROP TRIGGER IF EXISTS trg_log_flight_status_change ON airport_mgmt.flights;
CREATE TRIGGER trg_log_flight_status_change
AFTER UPDATE OF status ON airport_mgmt.flights
FOR EACH ROW
EXECUTE FUNCTION airport_mgmt.fn_log_flight_status_change(); 