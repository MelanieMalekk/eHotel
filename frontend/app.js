const API_BASE_URL = window.EHOTEL_API_URL || "http://localhost:4000/api";

const statusBox = document.querySelector("#status-box");
const searchPanel = document.querySelector("#search-panel");
const resultsPanel = document.querySelector("#results-panel");
const employeePanel = document.querySelector("#employee-panel");
const managementSection = document.querySelector("#management");
const availableRoomsTableBody = document.querySelector("#available-rooms-table tbody");
const viewsTableHead = document.querySelector("#views-table thead");
const viewsTableBody = document.querySelector("#views-table tbody");
const searchChainSelect = document.querySelector("#search-chain-id");
const noResultsMessage = document.querySelector("#no-results-message");
const bookingPrompt = document.querySelector("#booking-prompt");
const bookingForm = document.querySelector("#booking-form");
const roomsPagination = document.querySelector("#rooms-pagination");
const prevRoomsPageButton = document.querySelector("#prev-rooms-page");
const nextRoomsPageButton = document.querySelector("#next-rooms-page");
const roomsPageInfo = document.querySelector("#rooms-page-info");
const backToSearchButton = document.querySelector("#back-to-search");
const navSearch = document.querySelector("#nav-search");
const navResults = document.querySelector("#nav-results");
const navOperations = document.querySelector("#nav-operations");
const navManage = document.querySelector("#nav-manage");
const navViews = document.querySelector("#nav-views");

const ROOMS_PER_PAGE = 10;
const INTEGER_FIELDS = new Set([
  "customer_id", "employee_id", "hotel_id", "chain_id", "room_id", "booking_id", "renting_id", "number_of_rooms", "category_stars"
]);
const DECIMAL_FIELDS = new Set(["price_per_night", "amount", "min_price", "max_price"]);

let availableRoomsPage = 1;
let availableRoomsTotalPages = 1;
let availableRoomsTotalResults = 0;
let lastSearchPayload = null;

const ENTITY_API = {
  customer: "/customers",
  employee: "/employees",
  hotel: "/hotels",
  room: "/rooms"
};

function setStatus(message, isError = false) {
  statusBox.textContent = message;
  statusBox.style.color = isError ? "#7f1d1d" : "#0b3d16";
  statusBox.style.background = isError ? "#fef2f2" : "#f1fdf4";
  statusBox.style.borderColor = isError ? "#fecaca" : "#a5e8b7";
}

function updateRoomsPagination() {
  if (!roomsPagination || !prevRoomsPageButton || !nextRoomsPageButton || !roomsPageInfo) return;

  if (availableRoomsTotalPages <= 1) {
    roomsPagination.classList.add("hidden");
    return;
  }

  roomsPagination.classList.remove("hidden");
  roomsPageInfo.textContent = `Page ${availableRoomsPage} of ${availableRoomsTotalPages}`;
  prevRoomsPageButton.disabled = availableRoomsPage <= 1;
  nextRoomsPageButton.disabled = availableRoomsPage >= availableRoomsTotalPages;
}

function renderRooms(rows = []) {
  availableRoomsTableBody.innerHTML = "";

  const hasRows = Array.isArray(rows) && rows.length > 0;
  noResultsMessage?.classList.toggle("hidden", hasRows);
  bookingPrompt?.classList.remove("hidden");
  bookingForm?.classList.add("hidden");

  if (!hasRows) {
    updateRoomsPagination();
    return;
  }

  for (const row of rows) {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${row.room_id ?? ""}</td>
      <td>${row.chain_name ?? ""}</td>
      <td>${row.hotel_name ?? ""}</td>
      <td>${row.hotel_city ?? ""}</td>
      <td>${row.category_stars ?? ""}</td>
      <td>${row.number_of_rooms ?? ""}</td>
      <td>${row.capacity_type ?? ""}</td>
      <td>${row.price_per_night ?? ""}</td>
      <td><button type="button" data-room-id="${row.room_id}">Select</button></td>
    `;

    const button = tr.querySelector("button");
    button?.addEventListener("click", () => {
      const roomInput = bookingForm?.querySelector("input[name='room_id']");
      if (roomInput) roomInput.value = String(row.room_id ?? "");
      setStatus(`Selected room ${row.room_id}. Complete Booking below.`);
      bookingForm?.classList.remove("hidden");
      bookingPrompt?.classList.add("hidden");
      bookingForm?.scrollIntoView({ behavior: "smooth", block: "start" });
      bookingForm?.querySelector("input[name='customer_id']")?.focus();
    });

    availableRoomsTableBody.appendChild(tr);
  }

  updateRoomsPagination();
}

function formDataToPayload(formData) {
  const data = {};
  for (const [key, value] of formData.entries()) {
    if (value === "") continue;

    if (INTEGER_FIELDS.has(key)) {
      data[key] = Number(value);
      continue;
    }

    if (DECIMAL_FIELDS.has(key)) {
      data[key] = Number(value);
      continue;
    }

    if (key === "is_extendable") {
      data[key] = value === "true";
      continue;
    }

    data[key] = value;
  }
  return data;
}

async function apiRequest(path, options = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options
  });

  if (!response.ok) {
    let message = `Request failed (${response.status})`;
    try {
      const data = await response.json();
      if (data?.message) message = data.message;
    } catch {
      const text = await response.text();
      if (text) message = text;
    }
    throw new Error(message);
  }

  if (response.status === 204) return null;

  const contentType = response.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    return response.json();
  }
  return response.text();
}

function switchRole(role) {
  const isEmployee = role === "employee";

  navSearch?.classList.toggle("hidden", isEmployee);
  navResults?.classList.toggle("hidden", isEmployee);
  navOperations?.classList.toggle("hidden", !isEmployee);
  navManage?.classList.toggle("hidden", !isEmployee);
  navViews?.classList.toggle("hidden", !isEmployee);

  if (isEmployee) {
    searchPanel.classList.add("hidden");
    resultsPanel.classList.add("hidden");
    employeePanel.classList.remove("hidden");
    managementSection?.classList.remove("hidden");
    return;
  }

  employeePanel.classList.add("hidden");
  managementSection?.classList.add("hidden");
  searchPanel.classList.remove("hidden");
  const hasResults = sessionStorage.getItem("ehotel_last_search");
  resultsPanel.classList.toggle("hidden", !hasResults);
}

async function loadHotelChains() {
  if (!searchChainSelect) return;

  try {
    const rows = await apiRequest("/hotel-chains");
    const options = Array.isArray(rows) ? rows : [];

    for (const chain of options) {
      const option = document.createElement("option");
      option.value = String(chain.chain_id);
      option.textContent = chain.chain_name;
      searchChainSelect.appendChild(option);
    }
  } catch (error) {
    setStatus(`Could not load hotel chains: ${error.message}`, true);
  }
}

function saveSearchState(payload) {
  sessionStorage.setItem("ehotel_last_search", JSON.stringify(payload));
}

function readSearchState() {
  try {
    return JSON.parse(sessionStorage.getItem("ehotel_last_search") || "null");
  } catch {
    return null;
  }
}

function showSearchView() {
  searchPanel.classList.remove("hidden");
  resultsPanel.classList.add("hidden");
  if (backToSearchButton) backToSearchButton.blur();
}

function showResultsView() {
  searchPanel.classList.add("hidden");
  resultsPanel.classList.remove("hidden");
}

async function runAvailabilitySearch(payload, page = 1) {
  if (!payload.start_date || !payload.end_date) {
    renderRooms([]);
    setStatus("Select start and end dates to view available rooms.", true);
    return;
  }

  lastSearchPayload = { ...payload };
  const params = new URLSearchParams({
    ...payload,
    page: String(page),
    limit: String(ROOMS_PER_PAGE)
  });

  try {
    const responseData = await apiRequest(`/rooms/available?${params.toString()}`);
    const resultRows = Array.isArray(responseData)
      ? responseData
      : (Array.isArray(responseData?.rows) ? responseData.rows : []);

    availableRoomsPage = Number(responseData?.pagination?.page) || 1;
    availableRoomsTotalPages = Number(responseData?.pagination?.total_pages) || 1;
    availableRoomsTotalResults = Number(responseData?.pagination?.total_results) || resultRows.length;

    renderRooms(resultRows);
    showResultsView();
    setStatus(resultRows.length
      ? `Room availability loaded (${availableRoomsTotalResults} total, page ${availableRoomsPage}/${availableRoomsTotalPages}).`
      : "There are no rooms with the specified filters.");
  } catch (error) {
    renderRooms([]);
    showResultsView();
    setStatus(error.message, true);
  }
}

function renderRowsTable(rows = []) {
  viewsTableHead.innerHTML = "";
  viewsTableBody.innerHTML = "";

  if (!rows.length) {
    viewsTableBody.innerHTML = "<tr><td>No rows returned.</td></tr>";
    return;
  }

  const columns = Object.keys(rows[0]);
  const headRow = document.createElement("tr");
  for (const column of columns) {
    const th = document.createElement("th");
    th.textContent = column;
    headRow.appendChild(th);
  }
  viewsTableHead.appendChild(headRow);

  for (const row of rows) {
    const tr = document.createElement("tr");
    for (const column of columns) {
      const td = document.createElement("td");
      td.textContent = row[column] == null ? "" : String(row[column]);
      tr.appendChild(td);
    }
    viewsTableBody.appendChild(tr);
  }
}

async function handleCrud(form, operation) {
  const payload = formDataToPayload(new FormData(form));
  const entity = payload.entity;
  delete payload.entity;

  if (!entity || !ENTITY_API[entity]) {
    setStatus("Unknown entity selected.", true);
    return;
  }

  const idField = `${entity}_id`;
  const idValue = payload[idField];
  const basePath = ENTITY_API[entity];

  try {
    if (operation === "create") {
      await apiRequest(basePath, { method: "POST", body: JSON.stringify(payload) });
      setStatus(`${entity} inserted successfully.`);
      return;
    }

    if (!idValue) {
      setStatus(`Provide ${idField} for ${operation}.`, true);
      return;
    }

    if (operation === "update") {
      await apiRequest(`${basePath}/${idValue}`, { method: "PUT", body: JSON.stringify(payload) });
      setStatus(`${entity} ${idValue} updated successfully.`);
      return;
    }

    if (operation === "delete") {
      await apiRequest(`${basePath}/${idValue}`, { method: "DELETE" });
      setStatus(`${entity} ${idValue} deleted successfully.`);
    }
  } catch (error) {
    setStatus(error.message, true);
  }
}

function initRoleSwitch() {
  document.querySelectorAll("input[name='role']").forEach((input) => {
    input.addEventListener("change", (event) => {
      switchRole(event.target.value);
    });
  });
}

function initCrudForms() {
  ["#customer-crud-form", "#employee-crud-form", "#hotel-crud-form", "#room-crud-form"].forEach((selector) => {
    const form = document.querySelector(selector);
    if (!form) return;

    form.querySelectorAll("button[data-op]").forEach((button) => {
      button.addEventListener("click", () => {
        handleCrud(form, button.dataset.op);
      });
    });
  });
}

function initCustomerActions() {
  const searchForm = document.querySelector("#search-rooms-form");

  searchForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const payload = formDataToPayload(new FormData(searchForm));
    saveSearchState(payload);
    await runAvailabilitySearch(payload);
  });

  bookingForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const payload = formDataToPayload(new FormData(bookingForm));
    payload.status = "ACTIVE";

    try {
      await apiRequest("/bookings", { method: "POST", body: JSON.stringify(payload) });
      setStatus("Booking created.");
      bookingForm.reset();
    } catch (error) {
      setStatus(error.message, true);
    }
  });

  backToSearchButton?.addEventListener("click", () => {
    showSearchView();
    bookingForm?.classList.add("hidden");
    bookingPrompt?.classList.remove("hidden");
  });

  prevRoomsPageButton?.addEventListener("click", () => {
    if (!lastSearchPayload || availableRoomsPage <= 1) return;
    runAvailabilitySearch(lastSearchPayload, availableRoomsPage - 1);
  });

  nextRoomsPageButton?.addEventListener("click", () => {
    if (!lastSearchPayload || availableRoomsPage >= availableRoomsTotalPages) return;
    runAvailabilitySearch(lastSearchPayload, availableRoomsPage + 1);
  });
}

function initEmployeeActions() {
  const convertForm = document.querySelector("#convert-booking-form");
  const directForm = document.querySelector("#direct-renting-form");
  const paymentForm = document.querySelector("#payment-form");

  convertForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const payload = formDataToPayload(new FormData(convertForm));

    try {
      await apiRequest("/rentings/from-booking", { method: "POST", body: JSON.stringify(payload) });
      setStatus("Booking converted to renting.");
      convertForm.reset();
    } catch (error) {
      setStatus(error.message, true);
    }
  });

  directForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const payload = formDataToPayload(new FormData(directForm));

    try {
      await apiRequest("/rentings", { method: "POST", body: JSON.stringify(payload) });
      setStatus("Direct renting created.");
      directForm.reset();
    } catch (error) {
      setStatus(error.message, true);
    }
  });

  paymentForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const payload = formDataToPayload(new FormData(paymentForm));

    try {
      await apiRequest("/payments", { method: "POST", body: JSON.stringify(payload) });
      setStatus("Payment inserted for renting.");
      paymentForm.reset();
    } catch (error) {
      setStatus(error.message, true);
    }
  });
}

function initViewButtons() {
  document.querySelector("#load-view-1")?.addEventListener("click", async () => {
    try {
      const rows = await apiRequest("/views/view_available_rooms_per_area");
      renderRowsTable(Array.isArray(rows) ? rows : []);
      setStatus("Loaded view_available_rooms_per_area.");
    } catch (error) {
      setStatus(error.message, true);
    }
  });

  document.querySelector("#load-view-2")?.addEventListener("click", async () => {
    try {
      const rows = await apiRequest("/views/view_hotel_aggregated_capacity");
      renderRowsTable(Array.isArray(rows) ? rows : []);
      setStatus("Loaded view_hotel_aggregated_capacity.");
    } catch (error) {
      setStatus(error.message, true);
    }
  });
}

async function init() {
  await loadHotelChains();
  initRoleSwitch();
  initCrudForms();
  initCustomerActions();
  initEmployeeActions();
  initViewButtons();
  const savedSearch = readSearchState();
  if (savedSearch) {
    showResultsView();
    await runAvailabilitySearch(savedSearch);
  } else {
    showSearchView();
  }
  bookingForm?.classList.add("hidden");
  bookingPrompt?.classList.remove("hidden");
  switchRole("customer");
  setStatus(`Ready. API base URL: ${API_BASE_URL}`);
}

init();