-- SIMULATED: stock status and reorder list
-- Q17. Stock status counts
SELECT CASE WHEN stock_on_hand = 0 THEN 'Stock-out'
            WHEN stock_on_hand < reorder_level THEN 'Below reorder level'
            ELSE 'Healthy' END AS status,
       COUNT(*) AS products
FROM sim_inventory
GROUP BY 1
ORDER BY products DESC;

-- Q18. Reorder list: 15 most urgent, with real profit context
SELECT p.product_name, p.sub_category, i.stock_on_hand, i.reorder_level,
       s.supplier_name, s.lead_time_days,
       ROUND(SUM(oi.profit)::numeric, 2) AS real_profit
FROM sim_inventory i
JOIN products p      ON p.product_key = i.product_key
JOIN sim_suppliers s ON s.supplier_id = i.supplier_id
JOIN order_items oi  ON oi.product_key = i.product_key
WHERE i.stock_on_hand < i.reorder_level
GROUP BY p.product_name, p.sub_category, i.stock_on_hand, i.reorder_level,
         s.supplier_name, s.lead_time_days
ORDER BY real_profit DESC
LIMIT 15;

-- Q19. Inventory turnover and days inventory outstanding (SIMULATED stock, REAL cost of goods sold)
SELECT ROUND((SUM(oi.cost) / NULLIF(AVG(i.stock_on_hand * i.unit_cost), 0))::numeric, 2) AS placeholder_check
FROM sim_inventory i
JOIN order_items oi ON oi.product_key = i.product_key;