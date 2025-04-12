-- 01_schemas.sql
-- Creates the main application schema and sets the search path.

CREATE SCHEMA IF NOT EXISTS airport_mgmt;

-- Optional: Set search path for subsequent scripts in the same session
-- Note: psql \i runs each script in its own session by default,
-- so setting search_path might be better done per-file or via connection string/role setting.
-- SET search_path TO airport_mgmt, public;

GRANT USAGE ON SCHEMA airport_mgmt TO plsqldb_owner; -- Grant usage to the user if needed
-- Potentially grant permissions on future objects if required
-- ALTER DEFAULT PRIVILEGES IN SCHEMA airport_mgmt GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO your_app_user;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA airport_mgmt GRANT EXECUTE ON FUNCTIONS TO your_app_user;

-- Add package schemas (already done in _spec files, but can be centralized here too)
CREATE SCHEMA IF NOT EXISTS pkg_flights;
CREATE SCHEMA IF NOT EXISTS pkg_bookings;
GRANT USAGE ON SCHEMA pkg_flights TO plsqldb_owner;
GRANT USAGE ON SCHEMA pkg_bookings TO plsqldb_owner; 