-- Calculate churn rate by user tenure (months as customer)
-- Identifies at what point in the customer lifecycle churn is highest
-- Tests hypothesis: Is there an onboarding problem affecting new users vs long-term retention issue?

SELECT 
    tenure_months,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_users,
    ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM customer_churn_usage_patterns
GROUP BY tenure_months
HAVING total_users >= 10  -- Filter out months with too few users
ORDER BY tenure_months;