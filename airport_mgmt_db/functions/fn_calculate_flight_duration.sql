-- functions/fn_calculate_flight_duration.sql
-- Standalone function to calculate flight duration.

-- Note: This function doesn't strictly need to be in the airport_mgmt schema,
-- but placing it there keeps project objects grouped.
SET search_path TO airport_mgmt, public;

CREATE OR REPLACE FUNCTION calculate_flight_duration(
    p_departure TIMESTAMPTZ,
    p_arrival TIMESTAMPTZ
)
RETURNS INTERVAL
LANGUAGE sql
IMMUTABLE -- Result depends only on inputs
PARALLEL SAFE -- Safe to run in parallel
AS $$
    SELECT p_arrival - p_departure;
$$;

-- Example Usage:
-- SELECT calculate_flight_duration(scheduled_departure, scheduled_arrival) AS duration
-- FROM airport_mgmt.flights
-- WHERE flight_id = 1; 