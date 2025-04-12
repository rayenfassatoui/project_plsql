-- Trigger: Validate Booking (Prevent Overbooking)

-- Trigger Function
CREATE OR REPLACE FUNCTION airport_mgmt.fn_prevent_overbooking()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
DECLARE
    v_capacity INT;
    v_current_bookings INT;
    v_flight_status VARCHAR;
BEGIN
    -- Get aircraft capacity and current bookings for the flight
    SELECT ac.capacity, f.status
    INTO v_capacity, v_flight_status
    FROM airport_mgmt.flights f
    JOIN airport_mgmt.aircraft ac ON f.aircraft_id = ac.aircraft_id
    WHERE f.flight_id = NEW.flight_id;

    -- Check if flight exists and is bookable
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Flight ID % does not exist.', NEW.flight_id;
    END IF;

    IF v_flight_status <> 'Scheduled' AND v_flight_status <> 'Delayed' THEN
         RAISE EXCEPTION 'Cannot book on flight % because its status is %.', NEW.flight_id, v_flight_status;
    END IF;

    -- Count current CONFIRMED or CHECKED-IN bookings (excluding CANCELLED)
    SELECT COUNT(*)
    INTO v_current_bookings
    FROM airport_mgmt.bookings
    WHERE flight_id = NEW.flight_id
      AND status IN ('Confirmed', 'Checked-in');

    -- Check capacity
    IF v_current_bookings >= v_capacity THEN
        RAISE EXCEPTION 'Cannot create booking for flight %. Flight is fully booked (Capacity: %, Current Bookings: %).', NEW.flight_id, v_capacity, v_current_bookings;
    END IF;

    RETURN NEW; -- Allow the INSERT operation
END;
$$;

-- Trigger Definition
DROP TRIGGER IF EXISTS trg_validate_booking ON airport_mgmt.bookings;
CREATE TRIGGER trg_validate_booking
BEFORE INSERT ON airport_mgmt.bookings
FOR EACH ROW
EXECUTE FUNCTION airport_mgmt.fn_prevent_overbooking(); 