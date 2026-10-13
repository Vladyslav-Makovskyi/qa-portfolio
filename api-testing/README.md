# API testing: Restful Booker

Postman collection for [Restful Booker](https://restful-booker.herokuapp.com/apidoc/index.html), a public training API with intentional defects.

**Files**
- [restful-booker.postman_collection.json](restful-booker.postman_collection.json): import into Postman or run with Newman
- [reports/newman-report.html](reports/newman-report.html): HTML report of the last run (download and open in a browser)

## What is inside

| Folder | Requests | What it checks |
|---|---|---|
| 1. Health check | 1 | service responds |
| 2. Positive | 6 | create, read by id, search by name, boundary values (price 0, one night) |
| 3. Negative | 9 | not existing id, empty body, missing and empty fields, price -1 and text, reversed and invalid dates |

Every request checks the status code and response time. Positive requests also check the response body: the saved booking must equal the data that was sent.

**Request chaining:** the create request saves `bookingId` to a collection variable, the next requests read and search that booking. A pre-request script gives every run a unique first name, so the search test always finds exactly this booking.

## Result of the last run

| | Total | Failed |
|---|---|---|
| Requests | 16 | 0 |
| Assertions | 37 | 8 |

All positive checks pass. The 8 failed assertions are negative checks where the API accepted invalid data or answered 500 instead of 400. They are not test errors, they are the defects described in [bug-reports](../bug-reports).

## How to run

```bash
npm install -g newman newman-reporter-htmlextra
newman run restful-booker.postman_collection.json -r cli,htmlextra --reporter-htmlextra-export reports/newman-report.html
```
