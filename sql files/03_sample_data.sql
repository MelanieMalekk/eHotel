-- =========================================
-- 03_sample_data.sql
-- eHotels - Full sample data population
-- IMPORTANT:
-- Run this on a fresh database after 01_schema.sql and 02_triggers.sql
-- =========================================

-- =========================================
-- 1. HOTEL CHAINS
-- =========================================
INSERT INTO hotel_chain
(chain_name, central_office_street, central_office_city, central_office_state_province, central_office_postal_code, central_office_country, number_of_hotels)
VALUES
('Maple Stay', '100 Main St', 'Toronto', 'Ontario', 'M5V1A1', 'Canada', 8),
('Northern Inn', '200 Queen St', 'Ottawa', 'Ontario', 'K1A0A1', 'Canada', 8),
('Continental Suites', '300 Burrard St', 'Vancouver', 'British Columbia', 'V6C1X8', 'Canada', 8),
('Atlantic Retreat', '400 Spring Garden Rd', 'Halifax', 'Nova Scotia', 'B3J1T1', 'Canada', 8),
('Grand Horizon', '500 Rue Sainte-Catherine', 'Montreal', 'Quebec', 'H3B1A1', 'Canada', 8);

-- =========================================
-- 2. HOTELS (40 total)
-- 8 hotels per chain
-- =========================================
INSERT INTO hotel
(chain_id, hotel_name, hotel_street, hotel_city, hotel_state_province, hotel_postal_code, hotel_country, category_stars, number_of_rooms)
VALUES
-- Chain 1: Maple Stay
(1, 'Maple Downtown Toronto', '10 King St', 'Toronto', 'Ontario', 'M5H1A1', 'Canada', 5, 5),
(1, 'Maple Midtown Toronto', '20 Bloor St', 'Toronto', 'Ontario', 'M4W1A8', 'Canada', 4, 5),
(1, 'Maple Ottawa Centre', '30 Elgin St', 'Ottawa', 'Ontario', 'K1P1C3', 'Canada', 3, 5),
(1, 'Maple Ottawa Riverside', '40 Bank St', 'Ottawa', 'Ontario', 'K1P5N6', 'Canada', 4, 5),
(1, 'Maple Montreal Old Port', '50 Notre-Dame St', 'Montreal', 'Quebec', 'H2Y1C6', 'Canada', 5, 5),
(1, 'Maple Montreal Central', '60 Sherbrooke St', 'Montreal', 'Quebec', 'H2X1X4', 'Canada', 3, 5),
(1, 'Maple Vancouver Bay', '70 Georgia St', 'Vancouver', 'British Columbia', 'V6B1Z3', 'Canada', 5, 5),
(1, 'Maple Halifax Harbour', '80 Barrington St', 'Halifax', 'Nova Scotia', 'B3J1Y9', 'Canada', 4, 5),

-- Chain 2: Northern Inn
(2, 'Northern Central Ottawa', '101 Laurier Ave', 'Ottawa', 'Ontario', 'K1N6N5', 'Canada', 4, 5),
(2, 'Northern West Ottawa', '102 Richmond Rd', 'Ottawa', 'Ontario', 'K2A0E8', 'Canada', 3, 5),
(2, 'Northern Downtown Toronto', '103 Yonge St', 'Toronto', 'Ontario', 'M5C1W7', 'Canada', 5, 5),
(2, 'Northern North York', '104 Sheppard Ave', 'Toronto', 'Ontario', 'M2N5Y7', 'Canada', 3, 5),
(2, 'Northern Laval', '105 Curé-Labelle', 'Laval', 'Quebec', 'H7V2W4', 'Canada', 4, 5),
(2, 'Northern Quebec City', '106 Grande Allée', 'Quebec City', 'Quebec', 'G1R2H2', 'Canada', 5, 5),
(2, 'Northern Burnaby', '107 Kingsway', 'Burnaby', 'British Columbia', 'V5H2A9', 'Canada', 3, 5),
(2, 'Northern Dartmouth', '108 Portland St', 'Dartmouth', 'Nova Scotia', 'B2Y1H8', 'Canada', 4, 5),

-- Chain 3: Continental Suites
(3, 'Continental Downtown Vancouver', '201 Robson St', 'Vancouver', 'British Columbia', 'V6B2B7', 'Canada', 5, 5),
(3, 'Continental Richmond', '202 No 3 Rd', 'Richmond', 'British Columbia', 'V6X2B2', 'Canada', 4, 5),
(3, 'Continental Surrey', '203 King George Blvd', 'Surrey', 'British Columbia', 'V3T2W1', 'Canada', 3, 5),
(3, 'Continental Toronto Airport', '204 Dixon Rd', 'Toronto', 'Ontario', 'M9W1J9', 'Canada', 4, 5),
(3, 'Continental Mississauga', '205 Hurontario St', 'Mississauga', 'Ontario', 'L5B1M8', 'Canada', 3, 5),
(3, 'Continental Downtown Montreal', '206 René-Lévesque', 'Montreal', 'Quebec', 'H3B1R2', 'Canada', 5, 5),
(3, 'Continental Gatineau', '207 Boulevard Gréber', 'Gatineau', 'Quebec', 'J8T3R1', 'Canada', 3, 5),
(3, 'Continental Halifax Commons', '208 Quinpool Rd', 'Halifax', 'Nova Scotia', 'B3L1A2', 'Canada', 4, 5),

-- Chain 4: Atlantic Retreat
(4, 'Atlantic Halifax Waterfront', '301 Lower Water St', 'Halifax', 'Nova Scotia', 'B3J3S8', 'Canada', 5, 5),
(4, 'Atlantic Halifax North', '302 Gottingen St', 'Halifax', 'Nova Scotia', 'B3K3B2', 'Canada', 3, 5),
(4, 'Atlantic Moncton Centre', '303 Main St', 'Moncton', 'New Brunswick', 'E1C1B9', 'Canada', 4, 5),
(4, 'Atlantic Fredericton', '304 Queen St', 'Fredericton', 'New Brunswick', 'E3B1B2', 'Canada', 3, 5),
(4, 'Atlantic Charlottetown', '305 University Ave', 'Charlottetown', 'Prince Edward Island', 'C1A4M2', 'Canada', 4, 5),
(4, 'Atlantic St Johns', '306 Water St', 'St. John''s', 'Newfoundland and Labrador', 'A1C1A8', 'Canada', 5, 5),
(4, 'Atlantic Ottawa East', '307 Montreal Rd', 'Ottawa', 'Ontario', 'K1L6E8', 'Canada', 3, 5),
(4, 'Atlantic Toronto Lakeside', '308 Queens Quay', 'Toronto', 'Ontario', 'M5J2Y5', 'Canada', 4, 5),

-- Chain 5: Grand Horizon
(5, 'Grand Horizon Downtown Montreal', '401 Peel St', 'Montreal', 'Quebec', 'H3A1S9', 'Canada', 5, 5),
(5, 'Grand Horizon Plateau', '402 Saint-Denis', 'Montreal', 'Quebec', 'H2X3J8', 'Canada', 4, 5),
(5, 'Grand Horizon Ottawa Parliament', '403 Wellington St', 'Ottawa', 'Ontario', 'K1A0A9', 'Canada', 5, 5),
(5, 'Grand Horizon Toronto Financial', '404 Bay St', 'Toronto', 'Ontario', 'M5H2R2', 'Canada', 5, 5),
(5, 'Grand Horizon Vancouver Central', '405 Seymour St', 'Vancouver', 'British Columbia', 'V6B3K3', 'Canada', 4, 5),
(5, 'Grand Horizon Quebec Old Town', '406 Saint-Louis', 'Quebec City', 'Quebec', 'G1R3Z6', 'Canada', 3, 5),
(5, 'Grand Horizon Halifax South', '407 Inglis St', 'Halifax', 'Nova Scotia', 'B3H1J8', 'Canada', 4, 5),
(5, 'Grand Horizon Laval Central', '408 Saint-Martin', 'Laval', 'Quebec', 'H7S1N2', 'Canada', 3, 5);

-- =========================================
-- 3. CONTACTS
-- One chain email + phone for each chain
-- One hotel email + phone for each hotel
-- =========================================

-- Chain contacts
INSERT INTO contact (contact_type, contact_value, chain_id, hotel_id)
SELECT 'EMAIL', LOWER(REPLACE(chain_name, ' ', '')) || '@chain.com', chain_id, NULL
FROM hotel_chain;

INSERT INTO contact (contact_type, contact_value, chain_id, hotel_id)
SELECT 'PHONE', '1-800-' || LPAD(chain_id::text, 4, '0'), chain_id, NULL
FROM hotel_chain;

-- Hotel contacts
INSERT INTO contact (contact_type, contact_value, chain_id, hotel_id)
SELECT 'EMAIL', LOWER(REPLACE(REPLACE(hotel_name, ' ', ''), '''', '')) || '@hotel.com', NULL, hotel_id
FROM hotel;

INSERT INTO contact (contact_type, contact_value, chain_id, hotel_id)
SELECT 'PHONE', '1-888-' || LPAD(hotel_id::text, 4, '0'), NULL, hotel_id
FROM hotel;

-- =========================================
-- 4. AMENITIES
-- =========================================
INSERT INTO amenity (amenity_name)
VALUES
('TV'),
('AIR_CONDITIONING'),
('FRIDGE'),
('WIFI'),
('MINIBAR'),
('BALCONY'),
('COFFEE_MACHINE'),
('ROOM_SERVICE');

-- =========================================
-- 5. ROOMS
-- 5 rooms per hotel = 200 rooms
-- Room numbers: 101-105 for every hotel
-- =========================================
INSERT INTO room (hotel_id, room_number, price_per_night, capacity_type, view_type, is_extendable)
SELECT
    h.hotel_id,
    CASE gs.n
        WHEN 1 THEN '101'
        WHEN 2 THEN '102'
        WHEN 3 THEN '103'
        WHEN 4 THEN '104'
        WHEN 5 THEN '105'
    END AS room_number,
    CASE gs.n
        WHEN 1 THEN 120 + (h.hotel_id * 2)
        WHEN 2 THEN 160 + (h.hotel_id * 2)
        WHEN 3 THEN 210 + (h.hotel_id * 2)
        WHEN 4 THEN 280 + (h.hotel_id * 2)
        WHEN 5 THEN 350 + (h.hotel_id * 2)
    END AS price_per_night,
    CASE gs.n
        WHEN 1 THEN 'SINGLE'
        WHEN 2 THEN 'DOUBLE'
        WHEN 3 THEN 'TRIPLE'
        WHEN 4 THEN 'SUITE'
        WHEN 5 THEN 'DOUBLE'
    END AS capacity_type,
    CASE
        WHEN h.hotel_city IN ('Vancouver', 'Halifax', 'Montreal') AND gs.n IN (2,4) THEN 'SEA'
        WHEN h.hotel_city IN ('Quebec City', 'Gatineau', 'Burnaby', 'Surrey') AND gs.n IN (3,5) THEN 'MOUNTAIN'
        ELSE 'NONE'
    END AS view_type,
    CASE
        WHEN gs.n IN (2,4,5) THEN TRUE
        ELSE FALSE
    END AS is_extendable
FROM hotel h
CROSS JOIN generate_series(1,5) AS gs(n);

-- =========================================
-- 6. ROOM AMENITIES
-- Give every room WIFI and TV, then extras by type
-- =========================================
-- Every room gets TV and WIFI
INSERT INTO room_amenity (room_id, amenity_id)
SELECT room_id, 1 FROM room; -- TV

INSERT INTO room_amenity (room_id, amenity_id)
SELECT room_id, 4 FROM room; -- WIFI

-- DOUBLE/TRIPLE/SUITE get AIR_CONDITIONING
INSERT INTO room_amenity (room_id, amenity_id)
SELECT room_id, 2
FROM room
WHERE capacity_type IN ('DOUBLE', 'TRIPLE', 'SUITE');

-- SUITE gets MINIBAR + ROOM_SERVICE
INSERT INTO room_amenity (room_id, amenity_id)
SELECT room_id, 5
FROM room
WHERE capacity_type = 'SUITE';

INSERT INTO room_amenity (room_id, amenity_id)
SELECT room_id, 8
FROM room
WHERE capacity_type = 'SUITE';

-- Some rooms get FRIDGE
INSERT INTO room_amenity (room_id, amenity_id)
SELECT room_id, 3
FROM room
WHERE room_number IN ('103', '104', '105');

-- Some rooms get BALCONY
INSERT INTO room_amenity (room_id, amenity_id)
SELECT room_id, 6
FROM room
WHERE view_type IN ('SEA', 'MOUNTAIN');

-- =========================================
-- 7. PERSONS
-- 120 persons total
-- 40 employees + 80 customers
-- =========================================
INSERT INTO person (full_name, street, city, state_province, postal_code, country)
SELECT
    'Person ' || gs,
    gs || ' Example St',
    CASE
        WHEN gs % 5 = 0 THEN 'Toronto'
        WHEN gs % 5 = 1 THEN 'Ottawa'
        WHEN gs % 5 = 2 THEN 'Montreal'
        WHEN gs % 5 = 3 THEN 'Vancouver'
        ELSE 'Halifax'
    END,
    CASE
        WHEN gs % 5 IN (0,1) THEN 'Ontario'
        WHEN gs % 5 = 2 THEN 'Quebec'
        WHEN gs % 5 = 3 THEN 'British Columbia'
        ELSE 'Nova Scotia'
    END,
    'P' || LPAD(gs::text, 5, '0'),
    'Canada'
FROM generate_series(1,120) AS gs;

-- =========================================
-- 8. CUSTOMERS
-- person_id 1..80
-- =========================================
INSERT INTO customer (customer_id, id_type, id_value, registration_date)
SELECT
    person_id,
    CASE
        WHEN person_id % 4 = 0 THEN 'PASSPORT'
        WHEN person_id % 4 = 1 THEN 'DRIVING_LICENSE'
        WHEN person_id % 4 = 2 THEN 'SIN'
        ELSE 'SSN'
    END,
    'ID' || LPAD(person_id::text, 6, '0'),
    DATE '2026-01-01' + ((person_id % 60) || ' days')::interval
FROM person
WHERE person_id BETWEEN 1 AND 80;

-- =========================================
-- 9. EMPLOYEES
-- person_id 81..120
-- 1 employee per hotel (40 total)
-- =========================================
INSERT INTO employee (employee_id, hotel_id, ssn_sin)
SELECT
    80 + h.hotel_id,
    h.hotel_id,
    'SIN' || LPAD((80 + h.hotel_id)::text, 9, '0')
FROM hotel h;

-- =========================================
-- 10. ROLES
-- =========================================
INSERT INTO role (role_name)
VALUES
('MANAGER'),
('RECEPTIONIST'),
('MAINTENANCE'),
('CLEANER');

-- =========================================
-- 11. EMPLOYEE ROLES
-- Every hotel's single employee is MANAGER + RECEPTIONIST
-- Some also have MAINTENANCE
-- =========================================
INSERT INTO employee_role (employee_id, role_id)
SELECT employee_id, 1
FROM employee; -- MANAGER

INSERT INTO employee_role (employee_id, role_id)
SELECT employee_id, 2
FROM employee; -- RECEPTIONIST

INSERT INTO employee_role (employee_id, role_id)
SELECT employee_id, 3
FROM employee
WHERE employee_id % 3 = 0;

-- =========================================
-- 12. ROOM ISSUES
-- Add a few open/resolved issues
-- =========================================
INSERT INTO room_issue (room_id, description, reported_date, status)
VALUES
(4, 'Leaking sink', '2026-03-10', 'OPEN'),
(17, 'Broken lamp', '2026-03-12', 'RESOLVED'),
(33, 'Air conditioning malfunction', '2026-03-14', 'IN_PROGRESS'),
(58, 'Window lock issue', '2026-03-15', 'OPEN'),
(99, 'Mini fridge not cooling', '2026-03-16', 'RESOLVED'),
(120, 'Bathroom door hinge loose', '2026-03-17', 'OPEN');

-- =========================================
-- 13. BOOKINGS
-- Non-overlapping bookings for test/demo
-- =========================================
INSERT INTO booking (customer_id, room_id, start_date, end_date, booking_created_at, status)
VALUES
(1,   1,  '2026-04-10', '2026-04-15', '2026-03-20 10:00:00', 'ACTIVE'),
(2,   2,  '2026-04-16', '2026-04-20', '2026-03-20 10:30:00', 'ACTIVE'),
(3,   6,  '2026-04-12', '2026-04-14', '2026-03-21 09:00:00', 'ACTIVE'),
(4,   11, '2026-04-18', '2026-04-22', '2026-03-21 11:00:00', 'ACTIVE'),
(5,   16, '2026-04-25', '2026-04-29', '2026-03-22 08:45:00', 'ACTIVE'),
(6,   21, '2026-05-01', '2026-05-03', '2026-03-22 13:15:00', 'ACTIVE'),
(7,   26, '2026-05-04', '2026-05-07', '2026-03-23 14:00:00', 'ACTIVE'),
(8,   31, '2026-05-08', '2026-05-12', '2026-03-23 15:20:00', 'ACTIVE'),
(9,   36, '2026-05-13', '2026-05-18', '2026-03-24 09:30:00', 'ACTIVE'),
(10,  41, '2026-05-20', '2026-05-25', '2026-03-24 12:30:00', 'ACTIVE'),
(11,  46, '2026-06-01', '2026-06-04', '2026-03-25 10:00:00', 'ACTIVE'),
(12,  51, '2026-06-05', '2026-06-09', '2026-03-25 11:15:00', 'ACTIVE'),
(13,  56, '2026-06-10', '2026-06-15', '2026-03-26 09:10:00', 'ACTIVE'),
(14,  61, '2026-06-16', '2026-06-20', '2026-03-26 16:00:00', 'ACTIVE'),
(15,  66, '2026-06-21', '2026-06-24', '2026-03-27 10:40:00', 'ACTIVE');

-- =========================================
-- 14. RENTINGS
-- Some from bookings, some walk-ins
-- Make sure employee belongs to same hotel as room
-- =========================================
-- =========================================
-- 14. RENTINGS
-- Some from bookings, some walk-ins
-- Employee is selected automatically from the same hotel as the room
-- =========================================

-- booking conversions
INSERT INTO renting (
    customer_id, room_id, employee_id, booking_id,
    start_date, end_date, checkin_at, checkout_at, is_paid
)
SELECT
    b.customer_id,
    b.room_id,
    e.employee_id,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.start_date::timestamp + INTERVAL '14 hours',
    b.end_date::timestamp + INTERVAL '11 hours',
    TRUE
FROM booking b
JOIN room r ON b.room_id = r.room_id
JOIN employee e ON e.hotel_id = r.hotel_id
WHERE b.booking_id IN (1, 3, 4, 5);

-- walk-ins
INSERT INTO renting (
    customer_id, room_id, employee_id, booking_id,
    start_date, end_date, checkin_at, checkout_at, is_paid
)
SELECT
    x.customer_id,
    x.room_id,
    e.employee_id,
    NULL,
    x.start_date,
    x.end_date,
    x.start_date::timestamp + INTERVAL '16 hours',
    x.end_date::timestamp + INTERVAL '10 hours',
    x.is_paid
FROM (
    VALUES
        (16, 22, DATE '2026-05-02', DATE '2026-05-04', TRUE),
        (17, 27, DATE '2026-05-06', DATE '2026-05-08', FALSE),
        (18, 32, DATE '2026-05-09', DATE '2026-05-11', TRUE),
        (19, 37, DATE '2026-05-14', DATE '2026-05-17', TRUE)
) AS x(customer_id, room_id, start_date, end_date, is_paid)
JOIN room r ON x.room_id = r.room_id
JOIN employee e ON e.hotel_id = r.hotel_id;

-- =========================================
-- 15. OPTIONAL ARCHIVES
-- Just a few rows so the archive tables are not empty
-- =========================================
INSERT INTO booking_archive
(original_booking_id, start_date, end_date, booking_created_at, archived_at, customer_snapshot, room_snapshot, hotel_snapshot)
VALUES
(1001, '2025-12-01', '2025-12-05', '2025-11-15 10:00:00', '2025-12-06 12:00:00',
 'Customer 900 - archived', 'Room 999 - archived', 'Old Hotel A'),
(1002, '2025-12-10', '2025-12-12', '2025-11-20 09:00:00', '2025-12-13 12:00:00',
 'Customer 901 - archived', 'Room 998 - archived', 'Old Hotel B');

INSERT INTO rent_archive
(original_renting_id, original_booking_id, start_date, end_date, checkin_at, checkout_at, archived_at, customer_snapshot, room_snapshot, hotel_snapshot, employee_snapshot)
VALUES
(2001, 1001, '2025-12-01', '2025-12-05', '2025-12-01 14:00:00', '2025-12-05 11:00:00', '2025-12-05 12:00:00',
 'Customer 900 - archived', 'Room 999 - archived', 'Old Hotel A', 'Employee 700 - archived'),
(2002, NULL, '2025-12-15', '2025-12-18', '2025-12-15 16:00:00', '2025-12-18 10:30:00', '2025-12-18 11:00:00',
 'Customer 902 - archived', 'Room 997 - archived', 'Old Hotel C', 'Employee 701 - archived');