-- Query 1: Available rooms in a date range
SELECT r.room_id, r.room_number, h.hotel_name, h.hotel_city, hc.chain_name, r.price_per_night
FROM room r
JOIN hotel h ON r.hotel_id = h.hotel_id
JOIN hotel_chain hc ON h.chain_id = hc.chain_id
WHERE r.room_id NOT IN (
    SELECT b.room_id
    FROM booking b
    WHERE b.status = 'ACTIVE'
      AND NOT ('2026-04-20' <= b.start_date OR '2026-04-15' >= b.end_date)
)
AND r.room_id NOT IN (
    SELECT rt.room_id
    FROM renting rt
    WHERE NOT ('2026-04-20' <= rt.start_date OR '2026-04-15' >= rt.end_date)
);

-- Query 2: Customers who booked 5-star hotels
SELECT DISTINCT p.full_name
FROM booking b
JOIN customer c ON b.customer_id = c.customer_id
JOIN person p ON c.customer_id = p.person_id
JOIN room r ON b.room_id = r.room_id
JOIN hotel h ON r.hotel_id = h.hotel_id
WHERE h.category_stars = 5;

-- Query 3: Number of rooms per hotel chain (aggregation)
SELECT hc.chain_name, COUNT(r.room_id) AS total_rooms
FROM hotel_chain hc
JOIN hotel h ON hc.chain_id = h.chain_id
JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY hc.chain_name
ORDER BY total_rooms DESC;

-- Query 4: Hotels with avg room price above global average (nested query)
SELECT h.hotel_name
FROM hotel h
JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_id, h.hotel_name
HAVING AVG(r.price_per_night) > (
    SELECT AVG(price_per_night)
    FROM room
);