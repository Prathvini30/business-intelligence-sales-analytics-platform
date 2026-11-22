-- Q9. Why is Central weak? Discount rate and loss share by region
SELECT o.region,
       ROUND(AVG(oi.discount)::numeric, 3) AS avg_discount,
       ROUND(100.0 * COUNT(*) FILTER (WHERE oi.discount > 0.2) / COUNT(*), 1) AS pct_lines_over_20,
       ROUND(SUM(oi.profit) FILTER (WHERE oi.discount > 0.2)::numeric, 2) AS profit_from_deep_discounts
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY avg_discount DESC;

-- Q10. Distribution of orders per customer
WITH cust AS (
    SELECT customer_id, COUNT(*) AS orders
    FROM orders
    GROUP BY customer_id
)
SELECT orders, COUNT(*) AS customers
FROM cust
GROUP BY orders
ORDER BY orders;