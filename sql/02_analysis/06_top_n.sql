-- Q11. Top 10 customers by revenue, with profit
SELECT c.customer_id, c.customer_name, c.segment,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.sales)::numeric, 2)  AS revenue,
       ROUND(SUM(oi.profit)::numeric, 2) AS profit
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY revenue DESC
LIMIT 10;

-- Q12. 10 worst products by profit
SELECT p.product_key, p.product_name, p.sub_category,
       ROUND(SUM(oi.sales)::numeric, 2)  AS revenue,
       ROUND(SUM(oi.profit)::numeric, 2) AS profit
FROM order_items oi
JOIN products p ON p.product_key = oi.product_key
GROUP BY p.product_key, p.product_name, p.sub_category
ORDER BY profit ASC
LIMIT 10;