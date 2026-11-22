-- Q3. Sub-category profit ranking with a window function
SELECT p.category, p.sub_category,
       ROUND(SUM(oi.sales)::numeric, 2)  AS revenue,
       ROUND(SUM(oi.profit)::numeric, 2) AS profit,
       RANK() OVER (ORDER BY SUM(oi.profit) DESC) AS profit_rank
FROM order_items oi
JOIN products p ON p.product_key = oi.product_key
GROUP BY p.category, p.sub_category
ORDER BY profit_rank;

-- Q4. Does discounting explain Furniture's low margin?
SELECT p.category,
       CASE WHEN oi.discount = 0 THEN 'No discount'
            WHEN oi.discount <= 0.2 THEN 'Up to 20%'
            ELSE 'Over 20%' END AS discount_band,
       COUNT(*) AS line_items,
       ROUND(SUM(oi.sales)::numeric, 2)  AS revenue,
       ROUND(SUM(oi.profit)::numeric, 2) AS profit
FROM order_items oi
JOIN products p ON p.product_key = oi.product_key
GROUP BY p.category, discount_band
ORDER BY p.category, discount_band;