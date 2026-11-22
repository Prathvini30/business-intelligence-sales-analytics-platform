-- Q5. Monthly sales with month-over-month growth (LAG)
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date)::date AS month,
           SUM(oi.sales) AS revenue
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT month,
       ROUND(revenue::numeric, 2) AS revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- Q6. Yearly sales, profit and year-over-year growth
WITH yearly AS (
    SELECT EXTRACT(YEAR FROM o.order_date)::int AS year,
           SUM(oi.sales) AS revenue,
           SUM(oi.profit) AS profit
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT year,
       ROUND(revenue::numeric, 2) AS revenue,
       ROUND(profit::numeric, 2)  AS profit,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY year))
             / LAG(revenue) OVER (ORDER BY year), 1) AS yoy_growth_pct
FROM yearly
ORDER BY year;