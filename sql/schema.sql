-- Small shop database for SQL practice (SQLite)

-- Foreign keys are switched off on purpose: the data below has broken links for the QA checks.
PRAGMA foreign_keys = OFF;

CREATE TABLE customers (
    id      INTEGER PRIMARY KEY,
    name    TEXT NOT NULL,
    email   TEXT,
    city    TEXT
);

CREATE TABLE products (
    id      INTEGER PRIMARY KEY,
    name    TEXT NOT NULL,
    price   REAL NOT NULL
);

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    status      TEXT NOT NULL,          -- draft, paid, shipped, cancelled
    created_at  TEXT NOT NULL,
    total       REAL NOT NULL           -- saved order total
);

CREATE TABLE order_items (
    id          INTEGER PRIMARY KEY,
    order_id    INTEGER REFERENCES orders(id),
    product_id  INTEGER REFERENCES products(id),
    qty         INTEGER NOT NULL,
    price       REAL NOT NULL           -- unit price at the moment of order
);

INSERT INTO customers VALUES
    (1, 'Anna Koval',    'anna@example.com',  'Kyiv'),
    (2, 'Ivan Petrenko', 'ivan@example.com',  'Lviv'),
    (3, 'Olha Bondar',   NULL,                'Kyiv'),
    (4, 'Max Shevchuk',  'max@example.com',   'Odesa'),
    (5, 'Iryna Melnyk',  'iryna@example.com', 'Dnipro');

INSERT INTO products VALUES
    (1, 'Roller shade', 120.00),
    (2, 'Zebra shade',  150.00),
    (3, 'Motor',         80.00),
    (4, 'Remote',        25.50);

INSERT INTO orders VALUES
    (101, 1, 'paid',      '2026-10-01', 265.00),
    (102, 1, 'shipped',   '2026-10-03', 150.00),
    (103, 2, 'paid',      '2026-10-04', 320.00),  -- total does not match items
    (104, 4, 'draft',     '2026-10-05',   0.00),  -- order without items
    (105, 2, 'cancelled', '2026-10-06', 120.00),
    (106, 5, 'paid',      '2026-10-07', 255.50),
    (107, 9, 'paid',      '2026-10-08', 150.00);  -- customer 9 does not exist

INSERT INTO order_items VALUES
    (1, 101, 1, 1, 120.00),
    (2, 101, 3, 1,  80.00),
    (3, 101, 4, 2,  25.50),   -- 120 + 80 + 51 = 251, saved total 265 is wrong too
    (4, 102, 2, 1, 150.00),
    (5, 103, 2, 2, 150.00),   -- 300, saved 320
    (6, 105, 1, 1, 120.00),
    (7, 106, 1, 1, 120.00),
    (8, 106, 3, 1,  80.00),
    (9, 106, 4, 2,  25.50),   -- 251, saved 255.50
    (10, 107, 2, 1, 150.00);
