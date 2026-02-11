-- Compare support resolution times between churned and active users by ticket type and severity
-- Tests hypothesis: Are churned users leaving due to slow support response times?
-- Analyzes if IT is resolving issues fast enough across different ticket categories

SELECT 
    cp.churn,
    st.category,
    st.severity,
    COUNT(*) AS ticket_count,
    ROUND(AVG(st.resolution_time_hours), 1) AS avg_resolution_hours
FROM fact_support_tickets st
JOIN customer_churn_usage_patterns cp ON st.user_id = cp.user_id
GROUP BY cp.churn, st.category, st.severity
ORDER BY cp.churn, st.severity, ticket_count DESC;