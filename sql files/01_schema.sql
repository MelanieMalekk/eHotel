DROP TABLE IF EXISTS rent_archive CASCADE;
DROP TABLE IF EXISTS booking_archive CASCADE;
DROP TABLE IF EXISTS renting CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS room_issue CASCADE;
DROP TABLE IF EXISTS room_amenity CASCADE;
DROP TABLE IF EXISTS amenity CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS contact CASCADE;
DROP TABLE IF EXISTS employee_role CASCADE;
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS hotel_chain CASCADE;

CREATE TABLE hotel_chain (
    chain_id SERIAL PRIMARY KEY,
    chain_name VARCHAR(100) NOT NULL UNIQUE,
    central_office_street VARCHAR(100) NOT NULL,
    central_office_city VARCHAR(50) NOT NULL,
    central_office_state_province VARCHAR(50) NOT NULL,
    central_office_postal_code VARCHAR(20) NOT NULL,
    central_office_country VARCHAR(50) NOT NULL,
    number_of_hotels INT NOT NULL CHECK (number_of_hotels >= 0)
);

CREATE TABLE hotel (
    hotel_id SERIAL PRIMARY KEY,
    chain_id INT NOT NULL REFERENCES hotel_chain(chain_id) ON DELETE CASCADE,
    hotel_name VARCHAR(100),
    hotel_street VARCHAR(100) NOT NULL,
    hotel_city VARCHAR(50) NOT NULL,
    hotel_state_province VARCHAR(50) NOT NULL,
    hotel_postal_code VARCHAR(20) NOT NULL,
    hotel_country VARCHAR(50) NOT NULL,
    category_stars INT NOT NULL CHECK (category_stars BETWEEN 1 AND 5),
    number_of_rooms INT NOT NULL CHECK (number_of_rooms >= 0)
);

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state_province VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY REFERENCES person(person_id) ON DELETE CASCADE,
    id_type VARCHAR(30) NOT NULL CHECK (id_type IN ('SSN', 'SIN', 'DRIVING_LICENSE', 'PASSPORT')),
    id_value VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL CHECK (registration_date <= CURRENT_DATE),
    UNIQUE (id_type, id_value)
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY REFERENCES person(person_id) ON DELETE CASCADE,
    hotel_id INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    ssn_sin VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employee_role (
    employee_id INT NOT NULL REFERENCES employee(employee_id) ON DELETE CASCADE,
    role_id INT NOT NULL REFERENCES role(role_id) ON DELETE CASCADE,
    PRIMARY KEY (employee_id, role_id)
);

CREATE TABLE contact (
    contact_id SERIAL PRIMARY KEY,
    contact_type VARCHAR(20) NOT NULL CHECK (contact_type IN ('EMAIL', 'PHONE')),
    contact_value VARCHAR(100) NOT NULL,
    chain_id INT REFERENCES hotel_chain(chain_id) ON DELETE CASCADE,
    hotel_id INT REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    CHECK (
        (chain_id IS NOT NULL AND hotel_id IS NULL)
        OR
        (chain_id IS NULL AND hotel_id IS NOT NULL)
    )
);

CREATE TABLE room (
    room_id SERIAL PRIMARY KEY,
    hotel_id INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    room_number VARCHAR(20) NOT NULL,
    price_per_night NUMERIC(10,2) NOT NULL CHECK (price_per_night > 0),
    capacity_type VARCHAR(20) NOT NULL CHECK (capacity_type IN ('SINGLE', 'DOUBLE', 'TRIPLE', 'SUITE')),
    view_type VARCHAR(20) NOT NULL CHECK (view_type IN ('SEA', 'MOUNTAIN', 'NONE')),
    is_extendable BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (hotel_id, room_number)
);

CREATE TABLE amenity (
    amenity_id SERIAL PRIMARY KEY,
    amenity_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE room_amenity (
    room_id INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    amenity_id INT NOT NULL REFERENCES amenity(amenity_id) ON DELETE CASCADE,
    PRIMARY KEY (room_id, amenity_id)
);

CREATE TABLE room_issue (
    issue_id SERIAL PRIMARY KEY,
    room_id INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    reported_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED'))
);

CREATE TABLE booking (
    booking_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    room_id INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    booking_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'CANCELLED', 'CONVERTED', 'COMPLETED')),
    CHECK (start_date < end_date)
);

CREATE TABLE renting (
    renting_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    room_id INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    employee_id INT NOT NULL REFERENCES employee(employee_id) ON DELETE CASCADE,
    booking_id INT UNIQUE REFERENCES booking(booking_id) ON DELETE SET NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    checkin_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checkout_at TIMESTAMP,
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (start_date < end_date)
);

CREATE TABLE booking_archive (
    booking_archive_id SERIAL PRIMARY KEY,
    original_booking_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    booking_created_at TIMESTAMP,
    archived_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_snapshot TEXT NOT NULL,
    room_snapshot TEXT NOT NULL,
    hotel_snapshot TEXT NOT NULL
);

CREATE TABLE rent_archive (
    rent_archive_id SERIAL PRIMARY KEY,
    original_renting_id INT,
    original_booking_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    checkin_at TIMESTAMP,
    checkout_at TIMESTAMP,
    archived_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_snapshot TEXT NOT NULL,
    room_snapshot TEXT NOT NULL,
    hotel_snapshot TEXT NOT NULL,
    employee_snapshot TEXT NOT NULL
);