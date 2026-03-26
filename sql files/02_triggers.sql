CREATE OR REPLACE FUNCTION prevent_overlapping_bookings()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM booking b
        WHERE b.room_id = NEW.room_id
          AND b.booking_id <> COALESCE(NEW.booking_id, -1)
          AND b.status = 'ACTIVE'
          AND NEW.status = 'ACTIVE'
          AND NOT (NEW.end_date <= b.start_date OR NEW.start_date >= b.end_date)
    ) THEN
        RAISE EXCEPTION 'Booking dates overlap for this room.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_overlapping_bookings
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION prevent_overlapping_bookings();


CREATE OR REPLACE FUNCTION prevent_overlapping_rentings()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM renting r
        WHERE r.room_id = NEW.room_id
          AND r.renting_id <> COALESCE(NEW.renting_id, -1)
          AND NOT (NEW.end_date <= r.start_date OR NEW.start_date >= r.end_date)
    ) THEN
        RAISE EXCEPTION 'Renting dates overlap for this room.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_overlapping_rentings
BEFORE INSERT OR UPDATE ON renting
FOR EACH ROW
EXECUTE FUNCTION prevent_overlapping_rentings();


CREATE OR REPLACE FUNCTION validate_employee_hotel_match()
RETURNS TRIGGER AS $$
DECLARE
    emp_hotel_id INT;
    room_hotel_id INT;
BEGIN
    SELECT hotel_id INTO emp_hotel_id
    FROM employee
    WHERE employee_id = NEW.employee_id;

    SELECT hotel_id INTO room_hotel_id
    FROM room
    WHERE room_id = NEW.room_id;

    IF emp_hotel_id IS NULL OR room_hotel_id IS NULL OR emp_hotel_id <> room_hotel_id THEN
        RAISE EXCEPTION 'Employee must work at the same hotel as the rented room.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_employee_hotel_match
BEFORE INSERT OR UPDATE ON renting
FOR EACH ROW
EXECUTE FUNCTION validate_employee_hotel_match();


CREATE OR REPLACE FUNCTION validate_booking_conversion()
RETURNS TRIGGER AS $$
DECLARE
    b_customer_id INT;
    b_room_id INT;
    b_start DATE;
    b_end DATE;
BEGIN
    IF NEW.booking_id IS NOT NULL THEN
        SELECT customer_id, room_id, start_date, end_date
        INTO b_customer_id, b_room_id, b_start, b_end
        FROM booking
        WHERE booking_id = NEW.booking_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Referenced booking does not exist.';
        END IF;

        IF NEW.customer_id <> b_customer_id THEN
            RAISE EXCEPTION 'Renting customer must match booking customer.';
        END IF;

        IF NEW.room_id <> b_room_id THEN
            RAISE EXCEPTION 'Renting room must match booking room.';
        END IF;

        IF NEW.start_date < b_start OR NEW.end_date > b_end THEN
            RAISE EXCEPTION 'Renting dates must fall within booking period.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_booking_conversion
BEFORE INSERT OR UPDATE ON renting
FOR EACH ROW
EXECUTE FUNCTION validate_booking_conversion();