-- Analyze correlation between payment failures and churn rate
-- Shows how payment/billing issues impact customer retention
-- Critical metric: Identifies if billing infrastructure problems are driving churn

SELECT 
    payment_failures,
    COUNT(*) AS user_count,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_count,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM customer_churn_usage_patterns
GROUP BY payment_failures
ORDER BY payment_failures;