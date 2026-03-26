-- =========================================
-- 07_test_cases.sql
-- eHotels - Test cases to show when we film the video. constraints, triggers, views, and queries
-- =========================================

-- =====================================================
-- TEST 1: Valid booking (should succeed)
-- =====================================================
INSERT INTO booking (customer_id, room_id, start_date, end_date, status)
VALUES (1, 1, '2026-05-01', '2026-05-05', 'ACTIVE');

-- Verify
SELECT * FROM booking
WHERE customer_id = 1 AND room_id = 1 AND start_date = '2026-05-01';


-- =====================================================
-- TEST 2: Overlapping booking for same room (should fail)
-- Trigger: prevent_overlapping_bookings
-- =====================================================
-- Expected: ERROR
INSERT INTO booking (customer_id, room_id, start_date, end_date, status)
VALUES (2, 1, '2026-05-03', '2026-05-07', 'ACTIVE');


-- =====================================================
-- TEST 3: Valid walk-in renting (should succeed)
-- Employee must belong to same hotel as room
-- =====================================================
INSERT INTO renting (customer_id, room_id, employee_id, booking_id, start_date, end_date, is_paid)
VALUES (2, 6, 3, NULL, '2026-05-10', '2026-05-12', FALSE);

-- Verify
SELECT * FROM renting
WHERE customer_id = 2 AND room_id = 6 AND start_date = '2026-05-10';


-- =====================================================
-- TEST 4: Renting with employee from wrong hotel (should fail)
-- Trigger: validate_employee_hotel_match
-- =====================================================
-- Expected: ERROR
INSERT INTO renting (customer_id, room_id, employee_id, booking_id, start_date, end_date, is_paid)
VALUES (3, 6, 4, NULL, '2026-05-15', '2026-05-17', FALSE);


-- =====================================================
-- TEST 5: Valid renting converted from booking (should succeed)
-- Trigger: validate_booking_conversion
-- =====================================================
-- First create a booking
INSERT INTO booking (customer_id, room_id, start_date, end_date, status)
VALUES (3, 11, '2026-06-01', '2026-06-05', 'ACTIVE');

-- Then convert it to renting
INSERT INTO renting (customer_id, room_id, employee_id, booking_id, start_date, end_date, is_paid)
VALUES (3, 11, 5, 2, '2026-06-01', '2026-06-05', TRUE);

-- Verify
SELECT * FROM renting
WHERE booking_id = 2;


-- =====================================================
-- TEST 6: Renting with wrong customer for booking (should fail)
-- Trigger: validate_booking_conversion
-- =====================================================
-- Expected: ERROR
INSERT INTO renting (customer_id, room_id, employee_id, booking_id, start_date, end_date, is_paid)
VALUES (4, 11, 5, 2, '2026-06-01', '2026-06-05', TRUE);


-- =====================================================
-- TEST 7: Invalid contact ownership XOR (should fail)
-- CHECK constraint on contact
-- =====================================================
-- Expected: ERROR
INSERT INTO contact (contact_type, contact_value, chain_id, hotel_id)
VALUES ('EMAIL', 'bad@invalid.com', 1, 1);


-- =====================================================
-- TEST 8: Invalid hotel stars (should fail)
-- CHECK constraint on category_stars
-- =====================================================
-- Expected: ERROR
INSERT INTO hotel (
    chain_id, hotel_name, hotel_street, hotel_city, hotel_state_province,
    hotel_postal_code, hotel_country, category_stars, number_of_rooms
)
VALUES (
    1, 'Impossible Hotel', '999 Fake St', 'Nowhere', 'Ontario',
    'A0A0A0', 'Canada', 7, 10
);


-- =====================================================
-- TEST 9: View test - available rooms per area
-- Should return rows
-- =====================================================
SELECT * FROM view_available_rooms_per_area
ORDER BY area;


-- =====================================================
-- TEST 10: View test - aggregated capacity
-- Should return rows
-- =====================================================
SELECT * FROM view_hotel_aggregated_capacity
ORDER BY hotel_id
LIMIT 10;


-- =====================================================
-- TEST 11: Query test - rooms per chain (aggregation)
-- =====================================================
SELECT hc.chain_name, COUNT(r.room_id) AS total_rooms
FROM hotel_chain hc
JOIN hotel h ON hc.chain_id = h.chain_id
JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY hc.chain_name
ORDER BY total_rooms DESC;


-- =====================================================
-- TEST 12: Query test - hotels above average room price (nested query)
-- =====================================================
SELECT h.hotel_name
FROM hotel h
JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_id, h.hotel_name
HAVING AVG(r.price_per_night) > (
    SELECT AVG(price_per_night)
    FROM room
);