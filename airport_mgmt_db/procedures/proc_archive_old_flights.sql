-- procedures/proc_archive_old_flights.sql
-- Standalone procedure to archive old flights.

SET search_path TO airport_mgmt, public;

-- 1. Create an archive table (if it doesn't exist)
-- This table should mirror the structure of the flights table,
-- potentially adding an 'archived_at' timestamp.
CREATE TABLE IF NOT EXISTS flights_archive (
    archived_flight_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL, -- Original flight ID
    flight_number VARCHAR(10) NOT NULL,
    airline_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    origin_airport_code CHAR(3) NOT NULL,
    destination_airport_code CHAR(3) NOT NULL,
    scheduled_departure TIMESTAMPTZ NOT NULL,
    scheduled_arrival TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    -- Note: No FK constraints typically, as related data might also be archived/deleted
);
CREATE INDEX IF NOT EXISTS idx_flights_archive_flight_id ON flights_archive(flight_id);
CREATE INDEX IF NOT EXISTS idx_flights_archive_departure ON flights_archive(scheduled_departure);

-- 2. Create the procedure
CREATE OR REPLACE PROCEDURE archive_old_flights(
    p_archive_before_date TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_flight_id INT;
    v_archived_count INT := 0;
BEGIN
    RAISE NOTICE 'Archiving flights with scheduled arrival before %', p_archive_before_date;

    -- Use a loop to process and delete flights individually or small batches
    -- to avoid holding locks for too long on the main flights table.
    -- This example uses a simple loop for demonstration.
    FOR v_flight_id IN
        SELECT flight_id
        FROM flights
        WHERE scheduled_arrival < p_archive_before_date
        -- Optional: Only archive flights in specific statuses (e.g., Arrived, Cancelled)
        AND status IN ('Arrived', 'Cancelled')
        ORDER BY flight_id -- Process in a consistent order
    LOOP
        -- Check if already archived (optional, belt-and-suspenders)
        IF NOT EXISTS (SELECT 1 FROM flights_archive fa WHERE fa.flight_id = v_flight_id) THEN
            BEGIN
                -- Insert into archive table
                INSERT INTO flights_archive (
                    flight_id, flight_number, airline_id, aircraft_id,
                    origin_airport_code, destination_airport_code,
                    scheduled_departure, scheduled_arrival, status, created_at
                )
                SELECT
                    f.flight_id, f.flight_number, f.airline_id, f.aircraft_id,
                    f.origin_airport_code, f.destination_airport_code,
                    f.scheduled_departure, f.scheduled_arrival, f.status, f.created_at
                FROM flights f
                WHERE f.flight_id = v_flight_id;

                -- Delete from original table
                -- IMPORTANT: Consider related data (bookings, flight_crew)!
                -- The current schema uses ON DELETE CASCADE for bookings and flight_crew,
                -- so deleting the flight will automatically remove related rows.
                -- If CASCADE wasn't used, you'd need to delete related data explicitly first.
                DELETE FROM flights WHERE flight_id = v_flight_id;

                v_archived_count := v_archived_count + 1;

            EXCEPTION
                WHEN OTHERS THEN
                    RAISE WARNING 'Error processing flight_id %: %. Skipping.', v_flight_id, SQLERRM;
                    -- Decide if you want to continue or stop on error
                    -- CONTINUE;
            END;
        END IF;
    END LOOP;

    RAISE NOTICE 'Archived % flights.', v_archived_count;
END;
$$;

-- Example Usage:
-- CALL archive_old_flights(NOW() - INTERVAL '1 year'); 