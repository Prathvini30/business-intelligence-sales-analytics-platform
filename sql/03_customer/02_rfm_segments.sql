WITH base AS (
    SELECT o.customer_id,
           DATE '2017-12-31' - MAX(o.order_date) AS recency_days,
           COUNT(DISTINCT o.order_id)            AS frequency,
           SUM(oi.sales)                         AS monetary,
           SUM(oi.profit)                        AS profit
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
),
segmented AS (
    SELECT *,
           CASE
             WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
             WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal'
             WHEN r_score >= 4 AND f_score <= 2                  THEN 'New / Promising'
             WHEN r_score <= 2 AND f_score >= 4                  THEN 'At Risk'
             WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost'
             ELSE 'Needs Attention'
           END AS segment
    FROM scored
)
SELECT segment,
       COUNT(*)                          AS customers,
       ROUND(AVG(recency_days), 0)       AS avg_recency_days,
       ROUND(AVG(frequency), 1)          AS avg_orders,
       ROUND(SUM(monetary)::numeric, 2)  AS revenue,
       ROUND(SUM(profit)::numeric, 2)    AS profit
FROM segmented
GROUP BY segment
ORDER BY revenue DESC;