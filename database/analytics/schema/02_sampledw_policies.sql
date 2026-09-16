-- Continuous aggregates and data lifecycle policies for 'sampledw'.

CREATE MATERIALIZED VIEW sampledw.cagg_sales_daily
WITH (timescaledb.continuous) AS
SELECT time_bucket(INTERVAL '1 day', sale_time) AS bucket,
       product_key,
       currency,
       count(*)          AS line_count,
       sum(quantity)     AS total_quantity,
       sum(net_amount)   AS total_net_amount
FROM sampledw.fact_sales
GROUP BY bucket, product_key, currency
WITH NO DATA;

SELECT add_continuous_aggregate_policy(
    'sampledw.cagg_sales_daily',
    start_offset      => INTERVAL '30 days',
    end_offset        => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);

ALTER TABLE sampledw.fact_sales SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'product_key',
    timescaledb.compress_orderby   = 'sale_time DESC, order_id, line_no'
);

SELECT add_compression_policy('sampledw.fact_sales', INTERVAL '90 days');

SELECT add_retention_policy('sampledw.fact_sales', INTERVAL '2 years');
