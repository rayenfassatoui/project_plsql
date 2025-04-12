-- Table: airports
-- Description: Stores information about airports served by the system

CREATE TABLE IF NOT EXISTS airports (
    airport_code CHAR(3) PRIMARY KEY, -- Standard IATA airport code
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 6), -- Geographic coordinates
    longitude DECIMAL(10, 6),
    timezone VARCHAR(50), -- Timezone identifier (e.g., 'America/New_York')
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
); 