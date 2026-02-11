-- Compare billing ticket volume to payment failure frequency
-- Determines if billing issues are caused by system problems (our fault) or user error (their fault)
-- If users have billing tickets WITHOUT payment failures, suggests internal billing system issues

SELECT 
    cp.payment_failures,
    ROUND(AVG(CASE WHEN st.category = 'Billing' THEN 1.0 ELSE 0 END) * COUNT(st.ticket_id) / COUNT(DISTINCT cp.user_id), 2) AS avg_billing_tickets_per_user
FROM customer_churn_usage_patterns cp
LEFT JOIN fact_support_tickets st ON cp.user_id = st.user_id
GROUP BY cp.payment_failures
ORDER BY cp.payment_failures;