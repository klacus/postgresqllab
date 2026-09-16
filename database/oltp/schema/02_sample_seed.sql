-- Sample seed data for the 'sample' OLTP schema.
INSERT INTO sample.customer (email, full_name, country_code)
VALUES ('ada@example.com',   'Ada Lovelace',   'GB'),
       ('linus@example.com', 'Linus Torvalds', 'FI'),
       ('grace@example.com', 'Grace Hopper',   'US');

INSERT INTO sample.product (sku, name, category, unit_price)
VALUES ('SKU-0001', 'Mechanical Keyboard', 'peripherals', 129.00),
       ('SKU-0002', 'Ergonomic Mouse',     'peripherals',  59.50),
       ('SKU-0003', '27" 4K Monitor',      'displays',    449.99),
       ('SKU-0004', 'USB-C Dock',          'accessories', 189.00);

INSERT INTO sample.sales_order (customer_id, ordered_at, status)
SELECT c.customer_id, now() - (g.n || ' days')::interval,
       (ARRAY['NEW', 'PAID', 'SHIPPED'])[1 + (g.n % 3)]
FROM sample.customer c
CROSS JOIN generate_series(1, 5) AS g(n);

INSERT INTO sample.order_item (order_id, line_no, product_id, quantity, unit_price)
SELECT o.order_id,
       row_number() OVER (PARTITION BY o.order_id ORDER BY p.product_id),
       p.product_id,
       1 + ((o.order_id + p.product_id) % 3),
       p.unit_price
FROM sample.sales_order o
JOIN sample.product p ON (o.order_id + p.product_id) % 2 = 0;
