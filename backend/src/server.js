require("dotenv").config();

const express = require("express");
const cors = require("cors");
const { pool, query } = require("./db");

const app = express();
const port = Number(process.env.PORT || 4000);
const ALLOWED_VIEWS = new Set([
  "view_available_rooms_per_area",
  "view_hotel_aggregated_capacity"
]);

app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "http://localhost:5500"
  })
);
app.use(express.json());

function toInt(value) {
  if (value === undefined || value === null || value === "") return undefined;
  const numberValue = Number(value);
  return Number.isNaN(numberValue) ? undefined : numberValue;
}

function buildPersonFields(body) {
  return {
    full_name: body.full_name,
    street: body.street,
    city: body.city,
    state_province: body.state_province,
    postal_code: body.postal_code,
    country: body.country
  };
}

function buildUpdateClause(fields) {
  const entries = Object.entries(fields).filter(([, value]) => value !== undefined);
  if (!entries.length) return { clause: "", values: [] };

  const setters = entries.map(([key], index) => `${key} = $${index + 1}`);
  return {
    clause: setters.join(", "),
    values: entries.map(([, value]) => value)
  };
}

app.get("/api/health", async (_req, res, next) => {
  try {
    await query("SELECT 1");
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.get("/api/hotel-chains", async (_req, res, next) => {
  try {
    const result = await query(
      `
      SELECT chain_id, chain_name
      FROM hotel_chain
      ORDER BY chain_name
      `
    );

    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

app.post("/api/customers", async (req, res, next) => {
  const client = await pool.connect();
  try {
    const person = buildPersonFields(req.body);
    const { id_type, id_value, registration_date } = req.body;

    await client.query("BEGIN");
    const personResult = await client.query(
      `
      INSERT INTO person (full_name, street, city, state_province, postal_code, country)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING person_id
      `,
      [person.full_name, person.street, person.city, person.state_province, person.postal_code, person.country]
    );

    const customerId = personResult.rows[0].person_id;
    await client.query(
      `
      INSERT INTO customer (customer_id, id_type, id_value, registration_date)
      VALUES ($1, $2, $3, $4)
      `,
      [customerId, id_type, id_value, registration_date]
    );

    await client.query("COMMIT");
    res.status(201).json({ customer_id: customerId });
  } catch (error) {
    await client.query("ROLLBACK");
    next(error);
  } finally {
    client.release();
  }
});

app.put("/api/customers/:id", async (req, res, next) => {
  const customerId = toInt(req.params.id);
  if (!customerId) return res.status(400).json({ message: "Invalid customer id." });

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const personUpdate = buildUpdateClause(buildPersonFields(req.body));
    if (personUpdate.clause) {
      await client.query(
        `UPDATE person SET ${personUpdate.clause} WHERE person_id = $${personUpdate.values.length + 1}`,
        [...personUpdate.values, customerId]
      );
    }

    const customerFields = {
      id_type: req.body.id_type,
      id_value: req.body.id_value,
      registration_date: req.body.registration_date
    };
    const customerUpdate = buildUpdateClause(customerFields);
    if (customerUpdate.clause) {
      await client.query(
        `UPDATE customer SET ${customerUpdate.clause} WHERE customer_id = $${customerUpdate.values.length + 1}`,
        [...customerUpdate.values, customerId]
      );
    }

    await client.query("COMMIT");
    res.json({ message: "Customer updated." });
  } catch (error) {
    await client.query("ROLLBACK");
    next(error);
  } finally {
    client.release();
  }
});

app.delete("/api/customers/:id", async (req, res, next) => {
  try {
    const customerId = toInt(req.params.id);
    if (!customerId) return res.status(400).json({ message: "Invalid customer id." });

    await query(
      `
      DELETE FROM person
      WHERE person_id = $1
        AND EXISTS (SELECT 1 FROM customer c WHERE c.customer_id = person.person_id)
      `,
      [customerId]
    );
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

app.post("/api/employees", async (req, res, next) => {
  const client = await pool.connect();
  try {
    const person = buildPersonFields(req.body);
    const { hotel_id, ssn_sin } = req.body;

    await client.query("BEGIN");
    const personResult = await client.query(
      `
      INSERT INTO person (full_name, street, city, state_province, postal_code, country)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING person_id
      `,
      [person.full_name, person.street, person.city, person.state_province, person.postal_code, person.country]
    );

    const employeeId = personResult.rows[0].person_id;
    await client.query(
      `
      INSERT INTO employee (employee_id, hotel_id, ssn_sin)
      VALUES ($1, $2, $3)
      `,
      [employeeId, toInt(hotel_id), ssn_sin]
    );

    await client.query("COMMIT");
    res.status(201).json({ employee_id: employeeId });
  } catch (error) {
    await client.query("ROLLBACK");
    next(error);
  } finally {
    client.release();
  }
});

app.put("/api/employees/:id", async (req, res, next) => {
  const employeeId = toInt(req.params.id);
  if (!employeeId) return res.status(400).json({ message: "Invalid employee id." });

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const personUpdate = buildUpdateClause(buildPersonFields(req.body));
    if (personUpdate.clause) {
      await client.query(
        `UPDATE person SET ${personUpdate.clause} WHERE person_id = $${personUpdate.values.length + 1}`,
        [...personUpdate.values, employeeId]
      );
    }

    const employeeFields = {
      hotel_id: toInt(req.body.hotel_id),
      ssn_sin: req.body.ssn_sin
    };
    const employeeUpdate = buildUpdateClause(employeeFields);
    if (employeeUpdate.clause) {
      await client.query(
        `UPDATE employee SET ${employeeUpdate.clause} WHERE employee_id = $${employeeUpdate.values.length + 1}`,
        [...employeeUpdate.values, employeeId]
      );
    }

    await client.query("COMMIT");
    res.json({ message: "Employee updated." });
  } catch (error) {
    await client.query("ROLLBACK");
    next(error);
  } finally {
    client.release();
  }
});

app.delete("/api/employees/:id", async (req, res, next) => {
  try {
    const employeeId = toInt(req.params.id);
    if (!employeeId) return res.status(400).json({ message: "Invalid employee id." });

    await query(
      `
      DELETE FROM person
      WHERE person_id = $1
        AND EXISTS (SELECT 1 FROM employee e WHERE e.employee_id = person.person_id)
      `,
      [employeeId]
    );
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

app.post("/api/hotels", async (req, res, next) => {
  try {
    const {
      chain_id,
      hotel_name,
      hotel_street,
      hotel_city,
      hotel_state_province,
      hotel_postal_code,
      hotel_country,
      category_stars,
      number_of_rooms
    } = req.body;

    const result = await query(
      `
      INSERT INTO hotel
      (chain_id, hotel_name, hotel_street, hotel_city, hotel_state_province, hotel_postal_code, hotel_country, category_stars, number_of_rooms)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING hotel_id
      `,
      [
        toInt(chain_id),
        hotel_name,
        hotel_street,
        hotel_city,
        hotel_state_province,
        hotel_postal_code,
        hotel_country,
        toInt(category_stars),
        toInt(number_of_rooms)
      ]
    );

    res.status(201).json({ hotel_id: result.rows[0].hotel_id });
  } catch (error) {
    next(error);
  }
});

app.put("/api/hotels/:id", async (req, res, next) => {
  try {
    const hotelId = toInt(req.params.id);
    if (!hotelId) return res.status(400).json({ message: "Invalid hotel id." });

    const payload = {
      chain_id: toInt(req.body.chain_id),
      hotel_name: req.body.hotel_name,
      hotel_street: req.body.hotel_street,
      hotel_city: req.body.hotel_city,
      hotel_state_province: req.body.hotel_state_province,
      hotel_postal_code: req.body.hotel_postal_code,
      hotel_country: req.body.hotel_country,
      category_stars: toInt(req.body.category_stars),
      number_of_rooms: toInt(req.body.number_of_rooms)
    };

    const update = buildUpdateClause(payload);
    if (!update.clause) return res.status(400).json({ message: "No fields to update." });

    await query(
      `UPDATE hotel SET ${update.clause} WHERE hotel_id = $${update.values.length + 1}`,
      [...update.values, hotelId]
    );

    res.json({ message: "Hotel updated." });
  } catch (error) {
    next(error);
  }
});

app.delete("/api/hotels/:id", async (req, res, next) => {
  try {
    const hotelId = toInt(req.params.id);
    if (!hotelId) return res.status(400).json({ message: "Invalid hotel id." });

    await query("DELETE FROM hotel WHERE hotel_id = $1", [hotelId]);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

app.post("/api/rooms", async (req, res, next) => {
  try {
    const {
      hotel_id,
      room_number,
      price_per_night,
      capacity_type,
      view_type,
      is_extendable
    } = req.body;

    const result = await query(
      `
      INSERT INTO room
      (hotel_id, room_number, price_per_night, capacity_type, view_type, is_extendable)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING room_id
      `,
      [
        toInt(hotel_id),
        room_number,
        price_per_night,
        capacity_type,
        view_type,
        is_extendable
      ]
    );

    res.status(201).json({ room_id: result.rows[0].room_id });
  } catch (error) {
    next(error);
  }
});

app.put("/api/rooms/:id", async (req, res, next) => {
  try {
    const roomId = toInt(req.params.id);
    if (!roomId) return res.status(400).json({ message: "Invalid room id." });

    const payload = {
      hotel_id: toInt(req.body.hotel_id),
      room_number: req.body.room_number,
      price_per_night: req.body.price_per_night,
      capacity_type: req.body.capacity_type,
      view_type: req.body.view_type,
      is_extendable: req.body.is_extendable
    };

    const update = buildUpdateClause(payload);
    if (!update.clause) return res.status(400).json({ message: "No fields to update." });

    await query(
      `UPDATE room SET ${update.clause} WHERE room_id = $${update.values.length + 1}`,
      [...update.values, roomId]
    );

    res.json({ message: "Room updated." });
  } catch (error) {
    next(error);
  }
});

app.delete("/api/rooms/:id", async (req, res, next) => {
  try {
    const roomId = toInt(req.params.id);
    if (!roomId) return res.status(400).json({ message: "Invalid room id." });

    await query("DELETE FROM room WHERE room_id = $1", [roomId]);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

app.get("/api/rooms/available", async (req, res, next) => {
  try {
    const {
      area,
      start_date: startDate,
      end_date: endDate,
      capacity_type: capacityType,
      view_type: viewType,
      chain_id: chainId,
      category_stars: categoryStars,
      min_hotel_rooms: minHotelRooms,
      max_hotel_rooms: maxHotelRooms,
      min_price: minPrice,
      max_price: maxPrice,
      page
    } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({ message: "start_date and end_date are required." });
    }

    const filters = [
      `NOT EXISTS (
        SELECT 1 FROM booking b
        WHERE b.room_id = r.room_id
          AND b.status = 'ACTIVE'
          AND NOT ($1::date >= b.end_date OR $2::date <= b.start_date)
      )`,
      `NOT EXISTS (
        SELECT 1 FROM renting rt
        WHERE rt.room_id = r.room_id
          AND NOT ($1::date >= rt.end_date OR $2::date <= rt.start_date)
      )`
    ];
    const queryParams = [endDate, startDate];

    if (area) {
      queryParams.push(`%${area}%`);
      filters.push(`(
        h.hotel_city ILIKE $${queryParams.length}
        OR h.hotel_state_province ILIKE $${queryParams.length}
        OR h.hotel_country ILIKE $${queryParams.length}
      )`);
    }
    if (capacityType) {
      queryParams.push(capacityType);
      filters.push(`r.capacity_type = $${queryParams.length}`);
    }
    if (viewType) {
      queryParams.push(viewType);
      filters.push(`r.view_type = $${queryParams.length}`);
    }
    if (chainId) {
      queryParams.push(toInt(chainId));
      filters.push(`h.chain_id = $${queryParams.length}`);
    }
    if (categoryStars) {
      queryParams.push(toInt(categoryStars));
      filters.push(`h.category_stars = $${queryParams.length}`);
    }
    if (minHotelRooms) {
      queryParams.push(toInt(minHotelRooms));
      filters.push(`h.number_of_rooms >= $${queryParams.length}`);
    }
    if (maxHotelRooms) {
      queryParams.push(toInt(maxHotelRooms));
      filters.push(`h.number_of_rooms <= $${queryParams.length}`);
    }
    if (minPrice) {
      queryParams.push(minPrice);
      filters.push(`r.price_per_night >= $${queryParams.length}`);
    }
    if (maxPrice) {
      queryParams.push(maxPrice);
      filters.push(`r.price_per_night <= $${queryParams.length}`);
    }

    const pageSize = 10;
    const requestedPage = Math.max(1, toInt(page) || 1);
    const fromClause = `
      FROM room r
      JOIN hotel h ON h.hotel_id = r.hotel_id
      JOIN hotel_chain hc ON hc.chain_id = h.chain_id
    `;
    const whereClause = filters.join(" AND ");

    const countResult = await query(
      `
      SELECT COUNT(*)::int AS total
      ${fromClause}
      WHERE ${whereClause}
      `,
      queryParams
    );

    const totalResults = countResult.rows[0]?.total ?? 0;
    const totalPages = Math.max(1, Math.ceil(totalResults / pageSize));
    const currentPage = Math.min(requestedPage, totalPages);
    const offset = (currentPage - 1) * pageSize;
    const pagedParams = [...queryParams, pageSize, offset];

    const result = await query(
      `
      SELECT r.room_id, r.room_number, r.capacity_type, r.view_type, r.price_per_night,
        h.hotel_name, h.hotel_city, h.hotel_state_province, h.hotel_country,
        h.category_stars, h.number_of_rooms, h.chain_id, hc.chain_name
      ${fromClause}
      WHERE ${whereClause}
      ORDER BY h.hotel_city, h.hotel_name, r.room_number
      LIMIT $${queryParams.length + 1}
      OFFSET $${queryParams.length + 2}
      `,
      pagedParams
    );

    res.json({
      rows: result.rows,
      pagination: {
        page: currentPage,
        limit: pageSize,
        total_results: totalResults,
        total_pages: totalPages
      }
    });
  } catch (error) {
    next(error);
  }
});

app.post("/api/bookings", async (req, res, next) => {
  try {
    const { customer_id, room_id, start_date, end_date, status } = req.body;

    const roomId = toInt(room_id);

    const overlappingBooking = await query(
      `
      SELECT 1
      FROM booking b
      WHERE b.room_id = $1
        AND b.status = 'ACTIVE'
        AND NOT ($2::date >= b.end_date OR $3::date <= b.start_date)
      LIMIT 1
      `,
      [roomId, end_date, start_date]
    );

    const overlappingRenting = await query(
      `
      SELECT 1
      FROM renting r
      WHERE r.room_id = $1
        AND NOT ($2::date >= r.end_date OR $3::date <= r.start_date)
      LIMIT 1
      `,
      [roomId, end_date, start_date]
    );

    if (overlappingBooking.rowCount || overlappingRenting.rowCount) {
      return res.status(409).json({ message: "Room is already booked for the selected dates." });
    }

    const result = await query(
      `
      INSERT INTO booking (customer_id, room_id, start_date, end_date, status)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING booking_id
      `,
      [toInt(customer_id), roomId, start_date, end_date, status || "ACTIVE"]
    );

    res.status(201).json({ booking_id: result.rows[0].booking_id });
  } catch (error) {
    next(error);
  }
});

app.post("/api/rentings", async (req, res, next) => {
  try {
    const { customer_id, room_id, employee_id, start_date, end_date } = req.body;
    const result = await query(
      `
      INSERT INTO renting (customer_id, room_id, employee_id, booking_id, start_date, end_date, is_paid)
      VALUES ($1, $2, $3, NULL, $4, $5, FALSE)
      RETURNING renting_id
      `,
      [toInt(customer_id), toInt(room_id), toInt(employee_id), start_date, end_date]
    );

    res.status(201).json({ renting_id: result.rows[0].renting_id });
  } catch (error) {
    next(error);
  }
});

app.post("/api/rentings/from-booking", async (req, res, next) => {
  const client = await pool.connect();
  try {
    const { booking_id, customer_id, room_id, employee_id, start_date, end_date } = req.body;

    await client.query("BEGIN");
    const rentingResult = await client.query(
      `
      INSERT INTO renting (customer_id, room_id, employee_id, booking_id, start_date, end_date, is_paid)
      VALUES ($1, $2, $3, $4, $5, $6, FALSE)
      RETURNING renting_id
      `,
      [toInt(customer_id), toInt(room_id), toInt(employee_id), toInt(booking_id), start_date, end_date]
    );

    await client.query(
      `
      UPDATE booking
      SET status = 'CONVERTED'
      WHERE booking_id = $1
      `,
      [toInt(booking_id)]
    );

    await client.query("COMMIT");
    res.status(201).json({ renting_id: rentingResult.rows[0].renting_id });
  } catch (error) {
    await client.query("ROLLBACK");
    next(error);
  } finally {
    client.release();
  }
});

app.post("/api/payments", async (req, res, next) => {
  try {
    const rentingId = toInt(req.body.renting_id);
    if (!rentingId) return res.status(400).json({ message: "renting_id is required." });

    const result = await query(
      `
      UPDATE renting
      SET is_paid = TRUE
      WHERE renting_id = $1
      RETURNING renting_id, is_paid
      `,
      [rentingId]
    );

    if (!result.rowCount) {
      return res.status(404).json({ message: "Renting not found." });
    }

    res.json({
      message: "Payment recorded as paid (is_paid = true).",
      renting: result.rows[0],
      received_payment_details: {
        amount: req.body.amount,
        payment_method: req.body.payment_method,
        payment_date: req.body.payment_date
      }
    });
  } catch (error) {
    next(error);
  }
});

app.get("/api/views/:viewName", async (req, res, next) => {
  try {
    const viewName = req.params.viewName;
    if (!ALLOWED_VIEWS.has(viewName)) {
      return res.status(400).json({ message: "View is not allowed." });
    }

    const result = await query(`SELECT * FROM ${viewName}`);
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

app.use((error, _req, res, _next) => {
  console.error(error);

  if (error.code === "ECONNREFUSED") {
    return res.status(503).json({
      message: "Database connection refused.",
      detail: "PostgreSQL is not reachable on the configured host/port."
    });
  }

  if (error.code === "23505") {
    return res.status(409).json({ message: "Unique constraint violation.", detail: error.detail });
  }

  if (error.code === "23503") {
    return res.status(400).json({ message: "Foreign key violation.", detail: error.detail });
  }

  if (error.code === "23514") {
    return res.status(400).json({ message: "Check constraint violation.", detail: error.detail });
  }

  if (error.code === "P0001") {
    return res.status(400).json({ message: error.message });
  }

  res.status(500).json({ message: "Internal server error.", detail: error.message });
});

app.listen(port, () => {
  console.log(`eHotels backend running on http://localhost:${port}`);
});