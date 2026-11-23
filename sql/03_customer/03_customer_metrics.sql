-- Q13. New vs returning customers per year
WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS first_date
    FROM orders GROUP BY customer_id
),
yearly AS (
    SELECT DISTINCT EXTRACT(YEAR FROM o.order_date)::int AS year,
           o.customer_id,
           EXTRACT(YEAR FROM f.first_date)::int AS first_year
    FROM orders o
    JOIN first_order f ON f.customer_id = o.customer_id
)
SELECT year,
       COUNT(*) FILTER (WHERE year = first_year) AS new_customers,
       COUNT(*) FILTER (WHERE year > first_year) AS returning_customers,
       COUNT(*) AS active_customers
FROM yearly
GROUP BY year
ORDER BY year;

-- Q14. Lifetime value and AOV by segment (customer-level)
SELECT c.segment,
       COUNT(DISTINCT c.customer_id) AS customers,
       ROUND((SUM(oi.sales) / COUNT(DISTINCT c.customer_id))::numeric, 2)  AS avg_lifetime_revenue,
       ROUND((SUM(oi.profit) / COUNT(DISTINCT c.customer_id))::numeric, 2) AS avg_lifetime_profit,
       ROUND((SUM(oi.sales) / COUNT(DISTINCT o.order_id))::numeric, 2)     AS avg_order_value
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.segment
ORDER BY avg_lifetime_revenue DESC;