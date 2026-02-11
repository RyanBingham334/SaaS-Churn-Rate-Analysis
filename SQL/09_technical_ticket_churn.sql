-- Analyze churn rate by number of technical support tickets
-- Compares technical issue impact to billing issues (from previous query)
-- Identifies the "breaking point" - how many tech bugs before users give up

SELECT 
    CASE 
        WHEN tech_tickets = 0 THEN '0 technical tickets'
        WHEN tech_tickets = 1 THEN '1 technical ticket'
        WHEN tech_tickets BETWEEN 2 AND 3 THEN '2-3 technical tickets'
        WHEN tech_tickets BETWEEN 4 AND 5 THEN '4-5 technical tickets'
        ELSE '6+ technical tickets'
    END AS tech_ticket_bucket,
    COUNT(*) AS user_count,
    SUM(CASE WHEN cp.churn = 'Yes' THEN 1 ELSE 0 END) AS churned_count,
    ROUND(100.0 * SUM(CASE WHEN cp.churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM customer_churn_usage_patterns cp
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(*) AS tech_tickets
    FROM fact_support_tickets
    WHERE category = 'Technical'
    GROUP BY user_id
) tech ON cp.user_id = tech.user_id
GROUP BY tech_ticket_bucket
ORDER BY 
    CASE tech_ticket_bucket
        WHEN '0 technical tickets' THEN 0
        WHEN '1 technical ticket' THEN 1
        WHEN '2-3 technical tickets' THEN 2
        WHEN '4-5 technical tickets' THEN 3
        ELSE 4
    END;