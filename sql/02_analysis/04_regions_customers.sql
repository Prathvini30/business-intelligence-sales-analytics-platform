-- Q7. Region performance and margin
SELECT o.region,
       ROUND(SUM(oi.sales)::numeric, 2)  AS revenue,
       ROUND(SUM(oi.profit)::numeric, 2) AS profit,
       ROUND(100 * SUM(oi.profit) / SUM(oi.sales), 1) AS margin_pct
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY profit DESC;

-- Q8. Repeat-customer rate
WITH cust AS (
    SELECT customer_id, COUNT(*) AS orders
    FROM orders
    GROUP BY customer_id
)
SELECT COUNT(*) AS customers,
       COUNT(*) FILTER (WHERE orders > 1) AS repeat_customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE orders > 1) / COUNT(*), 1) AS repeat_rate_pct
FROM cust;