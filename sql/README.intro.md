# SQL practice

A small shop database: `customers`, `products`, `orders`, `order_items` ([schema.sql](schema.sql)).
The data has a few problems on purpose, the way real test data often does. The last queries are the ones a QA engineer uses to find them.

Every result below is the real output of the query. To run it yourself: `node sql/run.js` (Node 22.5+).

```
customers 1 ──< orders 1 ──< order_items >── 1 products
```

One customer has many orders, one order has many items, every item points to one product.
