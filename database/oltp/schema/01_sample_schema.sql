-- Minimal sample OLTP schema.
CREATE SCHEMA IF NOT EXISTS sample;

SET search_path = sample, public;

CREATE TABLE sample.customer (
    customer_id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email         text        NOT NULL UNIQUE,
    full_name     text        NOT NULL,
    country_code  char(2)     NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sample.product (
    product_id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku          text           NOT NULL UNIQUE,
    name         text           NOT NULL,
    category     text           NOT NULL,
    unit_price   numeric(12, 2) NOT NULL CHECK (unit_price >= 0),
    created_at   timestamptz    NOT NULL DEFAULT now()
);

CREATE TABLE sample.sales_order (
    order_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  bigint      NOT NULL REFERENCES sample.customer (customer_id),
    ordered_at   timestamptz NOT NULL DEFAULT now(),
    status       text        NOT NULL DEFAULT 'NEW'
                 CHECK (status IN ('NEW', 'PAID', 'SHIPPED', 'CANCELLED')),
    currency     char(3)     NOT NULL DEFAULT 'EUR'
);

CREATE TABLE sample.order_item (
    order_id    bigint         NOT NULL REFERENCES sample.sales_order (order_id) ON DELETE CASCADE,
    line_no     int            NOT NULL,
    product_id  bigint         NOT NULL REFERENCES sample.product (product_id),
    quantity    int            NOT NULL CHECK (quantity > 0),
    unit_price  numeric(12, 2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, line_no)
);

CREATE INDEX ix_sales_order_customer ON sample.sales_order (customer_id);
CREATE INDEX ix_sales_order_ordered_at ON sample.sales_order (ordered_at);
CREATE INDEX ix_order_item_product ON sample.order_item (product_id);

CREATE VIEW sample.v_order_total AS
SELECT o.order_id,
       o.customer_id,
       o.ordered_at,
       o.status,
       o.currency,
       sum(i.quantity * i.unit_price) AS order_total
FROM sample.sales_order o
JOIN sample.order_item i USING (order_id)
GROUP BY o.order_id, o.customer_id, o.ordered_at, o.status, o.currency;
