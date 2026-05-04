# QA Portfolio — Vladyslav Makovskyi

**Junior QA Engineer (Manual + API Testing)**  
📍 Ukraine | Open to Remote (EU)

---

## About Me

Junior QA Engineer with commercial experience in testing AI-based systems and hands-on experience in game testing.

Skilled in manual and API testing, bug reporting, and SQL data validation. Experienced in working with REST APIs, Postman collections, and debugging tools.

Focused on improving product quality and growing towards backend/API testing.

---

## Key Achievements

- Reported 30+ bugs with different severity levels (UI, API, logic)
- Identified critical issues in API validation and frontend behavior
- Created structured bug reports with clear reproduction steps
- Performed exploratory testing to improve test coverage

---

## Skills

**Testing:**  
Functional, Regression, Smoke, Sanity, Exploratory  

**API Testing:**  
REST API, Postman, Swagger, JSON validation  

**Database:**  
SQL (JOIN, GROUP BY, filtering, aggregations)  

**Tools:**  
Jira, Chrome DevTools, Git  

**Methodologies:**  
SDLC, STLC, BVA, Test Design  

---

## Test Artifacts

### 🐞 Bug Reports (Jira)

| ID | Title | Severity | Priority |
|---|---|---|---|
| KAN-1 | Forgot Password returns 500 error | Major | High |
| KAN-2 | Broken images return 404 | Minor | Medium |
| KAN-3 | Start button active during loading | Minor | Low |
| KAN-4 | API allows empty user creation | Major | High |

---

### 🔍 Example Bug Report (API)

**Title:** POST /api/users returns 201 Created with empty body  

**Severity:** Major  
**Priority:** High  

**Environment:**  
API: https://reqres.in/api/users  
Tool: Postman  

**Steps to reproduce:**
1. Send POST request to `/api/users`
2. Add valid API key in headers
3. Set body to empty JSON: `{}`  
4. Click Send  

**Expected result:**  
Server returns **400 Bad Request** with validation message  

**Actual result:**  
Server returns **201 Created** and creates empty object  

**Impact:**  
Allows creation of invalid data without required fields  

---

### 🔌 API Testing (Postman)

Tested endpoints:
- GET /users
- POST /users
- GET /users/{id}

Validation:
- Status codes (200, 201, 400, 404)
- Response time
- JSON structure validation

Test scenarios:
- Positive cases
- Negative cases (empty body, invalid data)
- Edge cases

Features used:
- Environment variables
- Request chaining
- Basic automated tests

---

### 🗄 SQL Practice

Used SQL for validating backend data:

```sql
SELECT 
users.name AS user_name,
bugs.title AS bug_title,
bugs.status AS bug_status,
bugs.created_at AS created_date,
COUNT(bugs.id) OVER (PARTITION BY bugs.user_id) AS total_bugs_per_user
FROM bugs
INNER JOIN users
ON bugs.user_id = users.id
WHERE bugs.status = 'open'
AND bugs.created_at >= '2024-01-01'
ORDER BY bugs.created_at DESC;
