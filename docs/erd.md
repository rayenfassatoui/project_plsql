# Airport Management System - Entity-Relationship Diagram (Simplified)

This document contains the Entity-Relationship Diagram (ERD) for the simplified Airport Management System database, represented using Mermaid syntax.

## ERD

```mermaid
erDiagram
    AIRLINES {
        INT airline_id PK
        VARCHAR name
        VARCHAR iata_code
        UNIQUE iata_code
    }

    AIRCRAFT {
        INT aircraft_id PK
        VARCHAR manufacturer
        VARCHAR model
        INT capacity
    }

    FLIGHTS {
        INT flight_id PK
        VARCHAR flight_number
        INT airline_id FK
        INT aircraft_id FK
        VARCHAR origin_code
        VARCHAR destination_code
        TIMESTAMP scheduled_departure
        TIMESTAMP scheduled_arrival
        VARCHAR status
    }

    PASSENGERS {
        INT passenger_id PK
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR email
        UNIQUE email
    }

    BOOKINGS {
        INT booking_id PK
        INT flight_id FK
        INT passenger_id FK
        VARCHAR seat_number
        TIMESTAMP booking_time
        VARCHAR status
    }

    CREW {
        INT crew_id PK
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR role
    }

    FLIGHT_CREW {
        INT flight_id FK
        INT crew_id FK
    }

    AIRLINES ||--o{ FLIGHTS : "has"
    AIRCRAFT ||--o{ FLIGHTS : "operates"
    FLIGHTS ||--o{ BOOKINGS : "includes"
    PASSENGERS ||--o{ BOOKINGS : "makes"
    FLIGHTS }o--o{ CREW : "assigned via FLIGHT_CREW"
    FLIGHT_CREW ||--|| FLIGHTS : "assignment for"
    FLIGHT_CREW ||--|| CREW : "assignment of"

```

## Explanation

*   **Entities:** The core entities are `AIRLINES`, `AIRCRAFT`, `FLIGHTS`, `PASSENGERS`, `BOOKINGS`, `CREW`, and the junction table `FLIGHT_CREW`.
*   **Attributes:** Each entity has essential attributes defined with basic types (`INT`, `VARCHAR`, `TIMESTAMP`). Primary Keys (PK) and Foreign Keys (FK) are indicated.
*   **Relationships:**
    *   One-to-Many (1:M): An `AIRLINE` has multiple `FLIGHTS`; an `AIRCRAFT` operates multiple `FLIGHTS`; a `FLIGHT` includes multiple `BOOKINGS`; a `PASSENGER` can make multiple `BOOKINGS`.
    *   Many-to-Many (M:M): A `FLIGHT` can have multiple `CREW` members assigned, and a `CREW` member can be assigned to multiple `FLIGHTS`. This is modeled using the `FLIGHT_CREW` junction table.
*   **Simplifications:** This model focuses on the core aspects needed for the planned PL/PGSQL functionality. Details like addresses, specific aircraft configurations, detailed crew scheduling rules, etc., are omitted for simplicity. 