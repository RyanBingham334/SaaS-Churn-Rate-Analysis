-- Analyze ticket category distribution between churned and active users
-- Breaks down support tickets by type: Technical (bugs), Billing (payment issues), Access (login problems)
-- Identifies which issue types correlate most strongly with churn

SELECT 
    cp.churn,
    COUNT(DISTINCT cp.user_id) AS user_count,
    AVG(CASE WHEN st.category = 'Technical' THEN 1 ELSE 0 END) AS pct_technical,
    AVG(CASE WHEN st.category = 'Billing' THEN 1 ELSE 0 END) AS pct_billing,
    AVG(CASE WHEN st.category = 'Access' THEN 1 ELSE 0 END) AS pct_access
FROM customer_churn_usage_patterns cp
LEFT JOIN fact_support_tickets st ON cp.user_id = st.user_id
GROUP BY cp.churn;