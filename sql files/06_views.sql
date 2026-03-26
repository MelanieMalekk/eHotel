CREATE OR REPLACE VIEW view_available_rooms_per_area AS
SELECT h.hotel_city AS area, COUNT(r.room_id) AS available_rooms
FROM room r
JOIN hotel h ON r.hotel_id = h.hotel_id
WHERE r.room_id NOT IN (
    SELECT b.room_id
    FROM booking b
    WHERE b.status = 'ACTIVE'
      AND CURRENT_DATE >= b.start_date
      AND CURRENT_DATE < b.end_date
)
AND r.room_id NOT IN (
    SELECT rt.room_id
    FROM renting rt
    WHERE CURRENT_DATE >= rt.start_date
      AND CURRENT_DATE < rt.end_date
)
GROUP BY h.hotel_city;


CREATE OR REPLACE VIEW view_hotel_aggregated_capacity AS
SELECT
    h.hotel_id,
    h.hotel_name,
    SUM(
        CASE r.capacity_type
            WHEN 'SINGLE' THEN 1
            WHEN 'DOUBLE' THEN 2
            WHEN 'TRIPLE' THEN 3
            WHEN 'SUITE' THEN 4
            ELSE 0
        END
    ) AS total_capacity
FROM hotel h
JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_id, h.hotel_name;