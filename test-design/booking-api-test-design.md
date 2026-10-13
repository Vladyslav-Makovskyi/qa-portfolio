# Test design: create booking (POST /booking)

**Object:** [Restful Booker](https://restful-booker.herokuapp.com/apidoc/index.html), a public training API with intentional defects.
**Feature:** creating a hotel booking.

The API documentation lists the fields but says nothing about validation. So I wrote down my assumptions first, the way I would ask a PM or developer at work.

## Assumptions about the rules

| Field | Assumed rule |
|---|---|
| firstname, lastname | required, not empty |
| totalprice | required, number, 0 or more |
| depositpaid | required, true or false only |
| checkin, checkout | required, date in `YYYY-MM-DD`, checkout after checkin |
| additionalneeds | optional text |

Invalid data should get **400 Bad Request** with a message. A server error (500) is never an acceptable answer to bad input.

## Equivalence classes and boundaries

**totalprice**

| Class | Value | Expected |
|---|---|---|
| valid, typical | 150 | created |
| boundary | 0 | created (free booking) |
| invalid, below boundary | -1, -50 | 400 |
| invalid, wrong type | "abc" | 400 |
| invalid, missing | field absent | 400 |

**bookingdates** (stay length = checkout minus checkin)

| Class | checkin / checkout | Expected |
|---|---|---|
| valid | 2026-12-01 / 2026-12-05 | created |
| boundary, 1 night | 2026-12-01 / 2026-12-02 | created |
| boundary, 0 nights | 2026-12-01 / 2026-12-01 | 400 (needs confirmation) |
| invalid, reversed | 2026-12-10 / 2026-12-01 | 400 |
| invalid, wrong format | not-a-date | 400 |

**depositpaid**: `true`, `false` are valid; `"yes"`, `1`, `null` are invalid.

## Checklist

**Positive**
- [x] Valid booking is created, response has a numeric `bookingid`
- [x] Saved booking equals the data that was sent
- [x] Created booking can be read by id
- [x] Created booking is found by first name search
- [x] Boundary: price 0 is accepted
- [x] Boundary: one night stay is accepted
- [x] Response time under 2 seconds

**Negative**
- [x] Empty body
- [x] Missing required field
- [x] Empty first name
- [x] Boundary: price -1
- [x] Price as text
- [x] Checkout before checkin
- [x] Invalid date format
- [x] depositpaid as text
- [x] Not existing booking id returns 404

**Not covered yet**
- [ ] Update and delete (need an auth token)
- [ ] Very long strings, special characters, Unicode names
- [ ] Same booking sent twice

## Result

Automated as a Postman collection: [api-testing](../api-testing). All positive checks pass. 8 of 9 negative checks fail, so the API accepts invalid data. The defects are written up in [bug-reports](../bug-reports).
