# SQL practice

A small shop database: `customers`, `products`, `orders`, `order_items` ([schema.sql](schema.sql)).
The data has a few problems on purpose, the way real test data often does. The last queries are the ones a QA engineer uses to find them.

Every result below is the real output of the query. To run it yourself: `node sql/run.js` (Node 22.5+).

```
customers 1 ──< orders 1 ──< order_items >── 1 products
```

One customer has many orders, one order has many items, every item points to one product.

### 1. All paid orders, newest first

Basic filter and sort.

```sql
SELECT id, customer_id, total, created_at
FROM orders
WHERE status = 'paid'
ORDER BY created_at DESC;
```

| id | customer_id | total | created_at |
|---|---|---|---|
| 107 | 9 | 150 | 2026-10-08 |
| 106 | 5 | 255.5 | 2026-10-07 |
| 103 | 2 | 320 | 2026-10-04 |
| 101 | 1 | 265 | 2026-10-01 |

### 2. Orders with customer names (INNER JOIN)

INNER JOIN keeps only rows that have a match in both tables.
Order 107 is missing here: its customer_id 9 does not exist.

```sql
SELECT o.id AS order_id, c.name AS customer, o.status, o.total
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
ORDER BY o.id;
```

| order_id | customer | status | total |
|---|---|---|---|
| 101 | Anna Koval | paid | 265 |
| 102 | Anna Koval | shipped | 150 |
| 103 | Ivan Petrenko | paid | 320 |
| 104 | Max Shevchuk | draft | 0 |
| 105 | Ivan Petrenko | cancelled | 120 |
| 106 | Iryna Melnyk | paid | 255.5 |

### 3. Customers and how many orders they have (LEFT JOIN + GROUP BY)

LEFT JOIN keeps every customer, even without orders. COUNT(o.id) gives 0 for them.

```sql
SELECT c.name, COUNT(o.id) AS orders_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY orders_count DESC, c.name;
```

| name | orders_count |
|---|---|
| Anna Koval | 2 |
| Ivan Petrenko | 2 |
| Iryna Melnyk | 1 |
| Max Shevchuk | 1 |
| Olha Bondar | 0 |

### 4. Customers who spent more than 300 on paid and shipped orders (HAVING)

WHERE filters rows before grouping, HAVING filters groups after it.

```sql
SELECT c.name, SUM(o.total) AS spent
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.status IN ('paid', 'shipped')
GROUP BY c.id, c.name
HAVING SUM(o.total) > 300;
```

| name | spent |
|---|---|
| Anna Koval | 415 |
| Ivan Petrenko | 320 |

### 5. Order lines with product names (two JOINs)

```sql
SELECT oi.order_id, p.name AS product, oi.qty, oi.price, oi.qty * oi.price AS line_total
FROM order_items oi
JOIN products p ON p.id = oi.product_id
ORDER BY oi.order_id, oi.id;
```

| order_id | product | qty | price | line_total |
|---|---|---|---|---|
| 101 | Roller shade | 1 | 120 | 120 |
| 101 | Motor | 1 | 80 | 80 |
| 101 | Remote | 2 | 25.5 | 51 |
| 102 | Zebra shade | 1 | 150 | 150 |
| 103 | Zebra shade | 2 | 150 | 300 |
| 105 | Roller shade | 1 | 120 | 120 |
| 106 | Roller shade | 1 | 120 | 120 |
| 106 | Motor | 1 | 80 | 80 |
| 106 | Remote | 2 | 25.5 | 51 |
| 107 | Zebra shade | 1 | 150 | 150 |

### 6. QA check: saved order total does not match the sum of its items

The kind of bug I look for at work: the total shown to the customer differs from the lines.

```sql
SELECT o.id AS order_id, o.total AS saved_total, SUM(oi.qty * oi.price) AS items_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.total
HAVING ROUND(SUM(oi.qty * oi.price), 2) <> ROUND(o.total, 2);
```

| order_id | saved_total | items_total |
|---|---|---|
| 101 | 265 | 251 |
| 103 | 320 | 300 |
| 106 | 255.5 | 251 |

### 7. QA check: orders without any items

LEFT JOIN + IS NULL finds rows that have no match.

```sql
SELECT o.id AS order_id, o.status, o.total
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE oi.id IS NULL;
```

| order_id | status | total |
|---|---|---|
| 104 | draft | 0 |

### 8. QA check: orders that point to a customer who does not exist

```sql
SELECT o.id AS order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE c.id IS NULL;
```

| order_id | customer_id |
|---|---|
| 107 | 9 |

### 9. QA check: customers without email

```sql
SELECT id, name
FROM customers
WHERE email IS NULL OR email = '';
```

| id | name |
|---|---|
| 3 | Olha Bondar |
