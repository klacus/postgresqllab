-- Sample seed data for the 'sampledw' analytics schema.
INSERT INTO sampledw.dim_customer (customer_key, email, full_name, country_code)
VALUES (1, 'ada@example.com',   'Ada Lovelace',   'GB'),
       (2, 'linus@example.com', 'Linus Torvalds', 'FI'),
       (3, 'grace@example.com', 'Grace Hopper',   'US');

INSERT INTO sampledw.dim_product (product_key, sku, name, category, list_price)
VALUES (1, 'SKU-0001', 'Mechanical Keyboard', 'peripherals', 129.00),
       (2, 'SKU-0002', 'Ergonomic Mouse',     'peripherals',  59.50),
       (3, 'SKU-0003', '27" 4K Monitor',      'displays',    449.99),
       (4, 'SKU-0004', 'USB-C Dock',          'accessories', 189.00);

INSERT INTO sampledw.fact_sales (
    sale_time, order_id, line_no, customer_key, product_key,
    quantity, unit_price, net_amount, currency, status)
SELECT g.ts,
       g.n                                   AS order_id,
       p.product_key                         AS line_no,
       1 + (g.n % 3)                         AS customer_key,
       p.product_key,
       q.quantity,
       p.list_price,
       q.quantity * p.list_price             AS net_amount,
       'EUR',
       'PAID'
FROM (
    SELECT n, now() - (n || ' hours')::interval AS ts
    FROM generate_series(1, 240) AS n
) AS g
JOIN sampledw.dim_product p ON (g.n + p.product_key) % 2 = 0
CROSS JOIN LATERAL (SELECT 1 + ((g.n + p.product_key) % 4) AS quantity) AS q;

CALL refresh_continuous_aggregate('sampledw.cagg_sales_daily', NULL, NULL);
