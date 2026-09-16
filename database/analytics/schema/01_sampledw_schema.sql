-- Analytics (OLAP) schema 'sampledw' backed by TimescaleDB.
-- Star schema mirroring the OLTP 'sample' schema.
CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE SCHEMA IF NOT EXISTS sampledw;

CREATE TABLE sampledw.dim_customer (
    customer_key  bigint PRIMARY KEY,           -- natural key from sample.customer
    email         text    NOT NULL,
    full_name     text    NOT NULL,
    country_code  char(2) NOT NULL
);

CREATE TABLE sampledw.dim_product (
    product_key  bigint PRIMARY KEY,            -- natural key from sample.product
    sku          text           NOT NULL,
    name         text           NOT NULL,
    category     text           NOT NULL,
    list_price   numeric(12, 2) NOT NULL
);

-- Time-series fact: one row per order line, keyed by order time.
CREATE TABLE sampledw.fact_sales (
    sale_time     timestamptz    NOT NULL,
    order_id      bigint         NOT NULL,
    line_no       int            NOT NULL,
    customer_key  bigint         NOT NULL REFERENCES sampledw.dim_customer (customer_key),
    product_key   bigint         NOT NULL REFERENCES sampledw.dim_product (product_key),
    quantity      int            NOT NULL,
    unit_price    numeric(12, 2) NOT NULL,
    net_amount    numeric(14, 2) NOT NULL,
    currency      char(3)        NOT NULL,
    status        text           NOT NULL
);

SELECT create_hypertable(
    'sampledw.fact_sales',
    'sale_time',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists       => TRUE
);

ALTER TABLE sampledw.fact_sales
    ADD CONSTRAINT pk_fact_sales PRIMARY KEY (sale_time, order_id, line_no);

CREATE INDEX ix_fact_sales_product ON sampledw.fact_sales (product_key, sale_time DESC);
CREATE INDEX ix_fact_sales_customer ON sampledw.fact_sales (customer_key, sale_time DESC);
