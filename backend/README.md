# eHotels Backend

Express + PostgreSQL backend for the eHotels frontend.

## 1) Install

```bash
cd backend
npm install
```

## 2) Configure env

```bash
cp .env.example .env
```

Update `.env` with your PostgreSQL credentials.

## 3) Create and populate DB (using your existing SQL files)

From project root (`eHotel/`), run in this order:

```bash
psql -U postgres -d ehotel -f "sql files/01_schema.sql"
psql -U postgres -d ehotel -f "sql files/02_triggers.sql"
psql -U postgres -d ehotel -f "sql files/03_sample_data.sql"
psql -U postgres -d ehotel -f "sql files/06_views.sql"
```

## 4) Start API

```bash
cd backend
npm run dev
```

API base URL: `http://localhost:4000/api`

## 5) Start frontend

```bash
cd frontend
python3 -m http.server 5500
```

Frontend URL: `http://localhost:5500`

## Notes

- This backend does not modify your SQL files.
- `GET /api/hotel-chains` returns chain options for UI dropdowns.
- `GET /api/rooms/available` supports: dates, capacity, area, hotel chain, category stars, hotel room-count range, and room price range.
- `POST /api/payments` marks `renting.is_paid = true` and returns the submitted payment payload.
