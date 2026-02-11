-- Calculate potential users saved through three targeted interventions
-- Intervention 1: Fix billing infrastructure (30% effectiveness assumption)
-- Intervention 2: Proactive outreach at 7-day inactivity (25% effectiveness assumption)
-- Intervention 3: Reduce product defects preventing 4+ ticket users (40% effectiveness assumption)

SELECT 
    '30% reduction in payment failures' AS intervention,
    SUM(CASE WHEN payment_failures >= 1 AND churn = 'Yes' THEN 1 ELSE 0 END) AS current_at_risk,
    ROUND(SUM(CASE WHEN payment_failures >= 1 AND churn = 'Yes' THEN 1 ELSE 0 END) * 0.30) AS users_saved
FROM customer_churn_usage_patterns

UNION ALL

SELECT 
    '7-day login gap intervention' AS intervention,
    SUM(CASE WHEN last_login_days_ago >= 7 AND churn = 'Yes' THEN 1 ELSE 0 END) AS current_at_risk,
    ROUND(SUM(CASE WHEN last_login_days_ago >= 7 AND churn = 'Yes' THEN 1 ELSE 0 END) * 0.25) AS users_saved
FROM customer_churn_usage_patterns

UNION ALL

SELECT 
    'Prevent 4+ tickets' AS intervention,
    SUM(CASE WHEN support_tickets >= 4 AND churn = 'Yes' THEN 1 ELSE 0 END) AS current_at_risk,
    ROUND(SUM(CASE WHEN support_tickets >= 4 AND churn = 'Yes' THEN 1 ELSE 0 END) * 0.40) AS users_saved
FROM customer_churn_usage_patterns;