-- Q15. Units sold per product, with movement class by quartile of units
WITH units AS (
    SELECT p.product_key, p.product_name, p.sub_category,
           SUM(oi.quantity)            AS units_sold,
           COUNT(DISTINCT o.order_id)  AS orders,
           MAX(o.order_date)           AS last_sold
    FROM order_items oi
    JOIN orders o   ON o.order_id = oi.order_id
    JOIN products p ON p.product_key = oi.product_key
    GROUP BY p.product_key, p.product_name, p.sub_category
)
SELECT movement,
       COUNT(*)         AS products,
       SUM(units_sold)  AS units,
       MIN(units_sold)  AS min_units,
       MAX(units_sold)  AS max_units
FROM (
    SELECT *,
           CASE NTILE(4) OVER (ORDER BY units_sold DESC)
                WHEN 1 THEN 'Fast'
                WHEN 2 THEN 'Medium-fast'
                WHEN 3 THEN 'Medium-slow'
                ELSE 'Slow' END AS movement
    FROM units
) t
GROUP BY movement
ORDER BY MIN(units_sold) DESC;

-- Q16. Products with no sale in the last 12 months of data (stale)
SELECT COUNT(*) AS stale_products
FROM (
    SELECT product_key, MAX(o.order_date) AS last_sold
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY product_key
) s
WHERE last_sold < DATE '2017-01-01';