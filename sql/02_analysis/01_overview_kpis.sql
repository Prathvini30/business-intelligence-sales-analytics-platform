-- Q1. Headline KPIs
SELECT COUNT(DISTINCT o.order_id)    AS total_orders,
       COUNT(DISTINCT o.customer_id) AS total_customers,
       ROUND(SUM(oi.sales)::numeric, 2)  AS total_revenue,
       ROUND(SUM(oi.cost)::numeric, 2)   AS total_cost,
       ROUND(SUM(oi.profit)::numeric, 2) AS total_profit,
       ROUND(100 * SUM(oi.profit) / SUM(oi.sales), 1) AS profit_margin_pct,
       ROUND(SUM(oi.sales) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id;

-- Q2. Category profitability
SELECT p.category,
       ROUND(SUM(oi.sales)::numeric, 2)  AS revenue,
       ROUND(SUM(oi.profit)::numeric, 2) AS profit,
       ROUND(100 * SUM(oi.profit) / SUM(oi.sales), 1) AS margin_pct
FROM order_items oi
JOIN products p ON p.product_key = oi.product_key
GROUP BY p.category
ORDER BY profit DESC;