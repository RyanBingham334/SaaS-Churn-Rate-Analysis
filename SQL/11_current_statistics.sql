-- Current user base, churn, and revenue 
SELECT 
    COUNT(*) AS total_users,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_users,
    SUM(CASE WHEN churn = 'No' THEN 1 ELSE 0 END) AS active_users,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS current_churn_rate,
    ROUND(AVG(monthly_fee), 2) AS avg_monthly_fee,
    ROUND(SUM(monthly_fee * 12), 2) AS total_annual_revenue
FROM customer_churn_usage_patterns;
