-- ### 1. All paid orders, newest first
-- Basic filter and sort.
SELECT id, customer_id, total, created_at
FROM orders
WHERE status = 'paid'
ORDER BY created_at DESC;

-- ### 2. Orders with customer names (INNER JOIN)
-- INNER JOIN keeps only rows that have a match in both tables.
-- Order 107 is missing here: its customer_id 9 does not exist.
SELECT o.id AS order_id, c.name AS customer, o.status, o.total
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
ORDER BY o.id;

-- ### 3. Customers and how many orders they have (LEFT JOIN + GROUP BY)
-- LEFT JOIN keeps every customer, even without orders. COUNT(o.id) gives 0 for them.
SELECT c.name, COUNT(o.id) AS orders_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY orders_count DESC, c.name;

-- ### 4. Customers who spent more than 300 on paid and shipped orders (HAVING)
-- WHERE filters rows before grouping, HAVING filters groups after it.
SELECT c.name, SUM(o.total) AS spent
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.status IN ('paid', 'shipped')
GROUP BY c.id, c.name
HAVING SUM(o.total) > 300;

-- ### 5. Order lines with product names (two JOINs)
SELECT oi.order_id, p.name AS product, oi.qty, oi.price, oi.qty * oi.price AS line_total
FROM order_items oi
JOIN products p ON p.id = oi.product_id
ORDER BY oi.order_id, oi.id;

-- ### 6. QA check: saved order total does not match the sum of its items
-- The kind of bug I look for at work: the total shown to the customer differs from the lines.
SELECT o.id AS order_id, o.total AS saved_total, SUM(oi.qty * oi.price) AS items_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.total
HAVING ROUND(SUM(oi.qty * oi.price), 2) <> ROUND(o.total, 2);

-- ### 7. QA check: orders without any items
-- LEFT JOIN + IS NULL finds rows that have no match.
SELECT o.id AS order_id, o.status, o.total
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE oi.id IS NULL;

-- ### 8. QA check: orders that point to a customer who does not exist
SELECT o.id AS order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE c.id IS NULL;

-- ### 9. QA check: customers without email
SELECT id, name
FROM customers
WHERE email IS NULL OR email = '';
