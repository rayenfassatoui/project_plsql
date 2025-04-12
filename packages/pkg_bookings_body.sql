-- Package Body: pkg_bookings
-- Implementation of functions/procedures for managing passengers and bookings.

-- Note: Assumes airport_mgmt schema exists and is in search_path.

-- *** Passenger CRUD ***

CREATE OR REPLACE FUNCTION pkg_bookings.add_passenger(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR DEFAULT NULL,
    p_phone VARCHAR DEFAULT NULL
)
RETURNS INT LANGUAGE plpgsql
AS $$
DECLARE
    v_passenger_id INT;
BEGIN
    INSERT INTO airport_mgmt.passengers (first_name, last_name, email, phone_number)
    VALUES (p_first_name, p_last_name, p_email, p_phone)
    RETURNING passenger_id INTO v_passenger_id;
    RETURN v_passenger_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE WARNING 'Passenger with email % already exists.', p_email;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING 'Error adding passenger % %: %', p_first_name, p_last_name, SQLERRM;
        RETURN NULL;
END;
$$;

-- (Get, Update, Delete for Passengers similar to Airlines - omitted for brevity but should be implemented)

-- *** Booking Management ***

CREATE OR REPLACE FUNCTION pkg_bookings.create_booking(
    p_flight_id INT,
    p_passenger_id INT,
    p_seat_number VARCHAR DEFAULT NULL
)
RETURNS INT LANGUAGE plpgsql
AS $$
DECLARE
    v_booking_id INT;
BEGIN
    -- Basic validation (existence checks are mostly handled by FKs)
    -- More complex validation (e.g., flight capacity) might go in a trigger (Task 3.5)

    INSERT INTO airport_mgmt.bookings (flight_id, passenger_id, seat_number)
    VALUES (p_flight_id, p_passenger_id, p_seat_number)
    RETURNING booking_id INTO v_booking_id;
    RETURN v_booking_id;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE WARNING 'Could not create booking. Invalid flight_id (%) or passenger_id (%).', p_flight_id, p_passenger_id;
        RETURN NULL;
    WHEN unique_violation THEN
        RAISE WARNING 'Could not create booking. Passenger % already booked on flight % OR seat % is already taken on flight %.', p_passenger_id, p_flight_id, p_seat_number, p_flight_id;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING 'Error creating booking for passenger % on flight %: %', p_passenger_id, p_flight_id, SQLERRM;
        RETURN NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE pkg_bookings.cancel_booking(p_booking_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Option 1: Update status to 'Cancelled'
    UPDATE airport_mgmt.bookings
    SET status = 'Cancelled'
    WHERE booking_id = p_booking_id AND status <> 'Cancelled';

    -- Option 2: Delete the booking (depends on requirements)
    -- DELETE FROM airport_mgmt.bookings WHERE booking_id = p_booking_id;

    IF NOT FOUND THEN
        RAISE WARNING 'Booking ID % not found or already cancelled.', p_booking_id;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error cancelling booking %: %', p_booking_id, SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE pkg_bookings.check_in_passenger(p_booking_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_flight_status VARCHAR;
    v_booking_status VARCHAR;
BEGIN
    -- Get current booking and flight status
    SELECT b.status, f.status
    INTO v_booking_status, v_flight_status
    FROM airport_mgmt.bookings b
    JOIN airport_mgmt.flights f ON b.flight_id = f.flight_id
    WHERE b.booking_id = p_booking_id;

    IF NOT FOUND THEN
        RAISE WARNING 'Booking ID % not found.', p_booking_id;
        RETURN;
    END IF;

    -- Validate check-in possibility
    IF v_booking_status = 'Cancelled' THEN
        RAISE EXCEPTION 'Cannot check in a cancelled booking (ID: %).', p_booking_id;
    END IF;
    IF v_booking_status = 'Checked-in' THEN
        RAISE WARNING 'Passenger for booking ID % is already checked in.', p_booking_id;
        RETURN; -- Or maybe allow re-check-in?
    END IF;
     IF v_flight_status NOT IN ('Scheduled', 'Delayed') THEN
        RAISE EXCEPTION 'Cannot check in for flight with status: %. Flight must be Scheduled or Delayed.', v_flight_status;
    END IF;
    -- Add time-based check-in window logic if needed

    UPDATE airport_mgmt.bookings
    SET status = 'Checked-in'
    WHERE booking_id = p_booking_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error checking in passenger for booking %: %', p_booking_id, SQLERRM;
END;
$$;

-- *** Booking Search Functions ***

CREATE OR REPLACE FUNCTION pkg_bookings.find_passenger_bookings(
    p_passenger_id INT
)
RETURNS SETOF airport_mgmt.bookings LANGUAGE sql STABLE
AS $$
    SELECT *
    FROM airport_mgmt.bookings
    WHERE passenger_id = p_passenger_id
    ORDER BY booking_time DESC;
$$; 