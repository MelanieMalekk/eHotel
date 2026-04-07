# eHotels Frontend

This folder contains a standalone frontend for the eHotels project.
It does not modify any SQL files.

## Run

From this folder, run a static server:

- Python: `python3 -m http.server 5500`

Then open:

- `http://localhost:5500/index.html`

## API Base URL

By default, the app calls:

- `http://localhost:4000/api`

To override in browser console before reload:

```js
window.EHOTEL_API_URL = "http://localhost:YOUR_PORT/api";
```

## Expected Endpoints

CRUD:

- `POST /customers`, `PUT /customers/:id`, `DELETE /customers/:id`
- `POST /employees`, `PUT /employees/:id`, `DELETE /employees/:id`
- `POST /hotels`, `PUT /hotels/:id`, `DELETE /hotels/:id`
- `POST /rooms`, `PUT /rooms/:id`, `DELETE /rooms/:id`

Customer flow:

- `GET /hotel-chains`
- `GET /rooms/available?area=&start_date=&end_date=&capacity_type=&chain_id=&category_stars=&min_hotel_rooms=&max_hotel_rooms=&min_price=&max_price=`
- `POST /bookings`

Employee flow:

- `POST /rentings/from-booking`
- `POST /rentings`
- `POST /payments`

Views:

- `GET /views/view_available_rooms_per_area`
- `GET /views/view_hotel_aggregated_capacity`

## Notes

- The view names match your SQL file exactly.
- The room search auto-refreshes when any search criterion changes.
- The UI includes customer and employee modes, plus insert/update/delete forms for customers, employees, hotels, and rooms.