# Bug reports

Defects found in [Restful Booker](https://restful-booker.herokuapp.com/apidoc/index.html), a public training API with intentional bugs. Found with the checks from [test-design](../test-design/booking-api-test-design.md) and confirmed by the [Postman collection](../api-testing).

The API docs do not describe validation, so the expected results are based on the assumptions written in the test design. At work I would confirm them with the PM before filing.

| # | Title | Severity | Priority |
|---|---|---|---|
| [BR-01](#br-01) | Missing required field returns 500 instead of 400 | Major | High |
| [BR-02](#br-02) | Booking with checkout before checkin is created | Major | High |
| [BR-03](#br-03) | Invalid check-in date is saved as `0NaN-aN-aN` | Major | High |
| [BR-04](#br-04) | Negative and non-numeric total price is accepted | Major | Medium |
| [BR-05](#br-05) | Booking with empty first name is created | Minor | Low |

Also noticed, not filed as bugs: `depositpaid: "yes"` is silently saved as `true`; `POST /booking` answers `200 OK` instead of the usual `201 Created`, but this matches the API docs.

---

<a id="br-01"></a>
## BR-01. Missing required field returns 500 instead of 400

**Module:** Booking / POST /booking
**Environment:** https://restful-booker.herokuapp.com, Postman
**Severity / Priority:** Major / High

**Steps to Reproduce:**
1. Send `POST /booking` with header `Content-Type: application/json`
2. Use a valid body but without `firstname`:
```json
{
  "lastname": "Brown",
  "totalprice": 150,
  "depositpaid": true,
  "bookingdates": { "checkin": "2026-12-01", "checkout": "2026-12-05" }
}
```

**Actual Result:**
`500 Internal Server Error`, body `Internal Server Error`. The same happens with an empty body `{}`.

**Expected Result:**
`400 Bad Request` with a message which field is missing.

**Impact:**
The client cannot tell a user mistake from a server failure, so it cannot show a helpful message. A 500 on user input usually means the error is not handled, and monitoring fills up with false alarms.

---

<a id="br-02"></a>
## BR-02. Booking with checkout before checkin is created

**Module:** Booking / POST /booking
**Environment:** https://restful-booker.herokuapp.com, Postman
**Severity / Priority:** Major / High

**Steps to Reproduce:**
1. Send `POST /booking` with a valid body and dates
   `"bookingdates": { "checkin": "2026-12-10", "checkout": "2026-12-01" }`

**Actual Result:**
`200 OK`, booking is created with checkout 9 days before checkin.

**Expected Result:**
`400 Bad Request`, checkout must be after checkin.

**Impact:**
An impossible booking gets into the system. It can block rooms incorrectly and break any price calculation based on the number of nights.

---

<a id="br-03"></a>
## BR-03. Invalid check-in date is saved as `0NaN-aN-aN`

**Module:** Booking / POST /booking
**Environment:** https://restful-booker.herokuapp.com, Postman
**Severity / Priority:** Major / High

**Steps to Reproduce:**
1. Send `POST /booking` with a valid body and
   `"bookingdates": { "checkin": "not-a-date", "checkout": "2026-12-05" }`
2. Open the booking with `GET /booking/{id}`

**Actual Result:**
`200 OK`, the booking is saved with `"checkin": "0NaN-aN-aN"`.

**Expected Result:**
`400 Bad Request`, date must be in `YYYY-MM-DD` format.

**Impact:**
Broken data is stored permanently. Every screen, report or export that reads this booking will show garbage or fail.

---

<a id="br-04"></a>
## BR-04. Negative and non-numeric total price is accepted

**Module:** Booking / POST /booking
**Environment:** https://restful-booker.herokuapp.com, Postman
**Severity / Priority:** Major / Medium

**Steps to Reproduce:**
1. Send `POST /booking` with a valid body and `"totalprice": -1`
2. Send the same request with `"totalprice": "abc"`

**Actual Result:**
1. `200 OK`, booking saved with `totalprice: -1`
2. `200 OK`, booking saved with `totalprice: null`

**Expected Result:**
`400 Bad Request` in both cases, price must be a number 0 or more.

**Impact:**
Money fields accept impossible values. A negative or empty price breaks invoices and revenue reports.

---

<a id="br-05"></a>
## BR-05. Booking with empty first name is created

**Module:** Booking / POST /booking
**Environment:** https://restful-booker.herokuapp.com, Postman
**Severity / Priority:** Minor / Low

**Steps to Reproduce:**
1. Send `POST /booking` with a valid body and `"firstname": ""`

**Actual Result:**
`200 OK`, booking is created without a guest name.

**Expected Result:**
`400 Bad Request`, first name must not be empty.

**Impact:**
Staff cannot identify the guest, and search by name will never find this booking.
