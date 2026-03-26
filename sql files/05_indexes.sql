CREATE INDEX idx_room_hotel_id ON room(hotel_id);
CREATE INDEX idx_booking_room_dates ON booking(room_id, start_date, end_date);
CREATE INDEX idx_renting_room_dates ON renting(room_id, start_date, end_date);
CREATE INDEX idx_hotel_city ON hotel(hotel_city);