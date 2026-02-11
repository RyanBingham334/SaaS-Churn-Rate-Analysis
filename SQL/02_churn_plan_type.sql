-- Calculate average subscription length for churned users by plan type
-- Shows how long users stayed before churning, broken down by subscription tier
-- Helps identify if certain plan types have longer/shorter retention periods

SELECT 
    plan_type,
    AVG(JULIANDAY(churn_date) - JULIANDAY(signup_date)) AS avg_subscription_days_churned_only
FROM dim_users
WHERE churn_date IS NOT NULL
GROUP BY plan_type;