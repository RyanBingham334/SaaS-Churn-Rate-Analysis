-- Calculate overall churn rate across all users
-- Compares churned vs active users and calculates churn percentage
-- Industry benchmark for SaaS churn is typically 10-15%

SELECT 
    COUNT(CASE WHEN churn = 'Yes' THEN 1 END) AS churned_users,
    COUNT(CASE WHEN churn = 'No' THEN 1 END) AS active_users,
    COUNT(*) AS total_users,
    ROUND(COUNT(CASE WHEN churn = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_percent
FROM customer_churn_usage_patterns;