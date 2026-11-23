WITH base AS (
    SELECT o.customer_id,
           DATE '2017-12-31' - MAX(o.order_date)  AS recency_days,
           COUNT(DISTINCT o.order_id)             AS frequency,
           SUM(oi.sales)                          AS monetary,
           SUM(oi.profit)                         AS profit
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id
),
scored AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
           NTILE(5) OVER (ORDER BY frequency)         AS f_score,
           NTILE(5) OVER (ORDER BY monetary)          AS m_score
    FROM base
)
SELECT customer_id, recency_days, frequency,
       ROUND(monetary::numeric, 2) AS monetary,
       ROUND(profit::numeric, 2)   AS profit,
       r_score, f_score, m_score
FROM scored
ORDER BY r_score DESC, f_score DESC, m_score DESC
LIMIT 20;