-- Compare support ticket volume and severity between churned and active users
-- Analyzes average tickets per user and breakdown by severity level (High/Medium/Low)
-- Identifies if churned users experienced more or higher-severity issues

SELECT 
    cp.churn,
    COUNT(DISTINCT cp.user_id) AS user_count,
    AVG(cp.support_tickets) AS avg_total_tickets,
    AVG(CASE WHEN st.severity = 'High' THEN 1 ELSE 0 END) AS pct_high_severity,
    AVG(CASE WHEN st.severity = 'Medium' THEN 1 ELSE 0 END) AS pct_medium_severity,
    AVG(CASE WHEN st.severity = 'Low' THEN 1 ELSE 0 END) AS pct_low_severity
FROM customer_churn_usage_patterns cp
LEFT JOIN fact_support_tickets st ON cp.user_id = st.user_id
GROUP BY cp.churn;