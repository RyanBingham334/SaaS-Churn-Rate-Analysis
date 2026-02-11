-- Calculate combined impact of all three interventions on churn and revenue
-- Combines results from query 11 to show total business impact
-- Projects new churn rate, percentage reduction, and annual revenue retained

WITH current_state AS (
    SELECT 
        COUNT(*) AS total_users,
        SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_users,
        AVG(monthly_fee) AS avg_monthly_fee,
        ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS current_churn_rate
    FROM customer_churn_usage_patterns
),
interventions AS (
    SELECT 
        ROUND(SUM(CASE WHEN payment_failures >= 1 AND churn = 'Yes' THEN 1 ELSE 0 END) * 0.30) +
        ROUND(SUM(CASE WHEN last_login_days_ago >= 7 AND churn = 'Yes' THEN 1 ELSE 0 END) * 0.25) +
        ROUND(SUM(CASE WHEN support_tickets >= 4 AND churn = 'Yes' THEN 1 ELSE 0 END) * 0.40) AS total_users_saved
    FROM customer_churn_usage_patterns
)
SELECT 
    cs.total_users,
    cs.churned_users,
    cs.current_churn_rate,
    i.total_users_saved,
    ROUND(100.0 * (cs.churned_users - i.total_users_saved) / cs.total_users, 1) AS new_churn_rate,
    ROUND(cs.current_churn_rate - (100.0 * (cs.churned_users - i.total_users_saved) / cs.total_users), 1) AS churn_reduction_pct,
    ROUND(i.total_users_saved * cs.avg_monthly_fee * 12, 2) AS annual_revenue_saved
FROM current_state cs, interventions i;