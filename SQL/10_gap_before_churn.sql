-- Calculate distribution of longest login gaps before churn
-- Identifies the typical "inactive period" before users permanently leave
-- Key finding: Reveals the intervention window (e.g., 7-9 days) for proactive outreach to at-risk users

SELECT 
    longest_gap_days,
    COUNT(*) AS user_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM (
        WITH user_churn_dates AS (
            SELECT 
                cp.user_id,
                cp.churn,
                cp.last_login_days_ago,
                DATE('2026-02-07', '-' || cp.last_login_days_ago || ' days') AS estimated_churn_date
            FROM customer_churn_usage_patterns cp
            WHERE cp.churn = 'Yes'
        ),
        login_gaps AS (
            SELECT 
                ul1.user_id,
                ul1.date AS login_date,
                MIN(ul2.date) AS next_login_date,
                JULIANDAY(MIN(ul2.date)) - JULIANDAY(ul1.date) AS gap_days
            FROM fact_usage_logs ul1
            LEFT JOIN fact_usage_logs ul2 
                ON ul1.user_id = ul2.user_id 
                AND ul2.date > ul1.date
            GROUP BY ul1.user_id, ul1.date
        ),
        max_gaps AS (
            SELECT 
                user_id,
                MAX(gap_days) AS longest_gap_days
            FROM login_gaps
            GROUP BY user_id
        )
        SELECT user_id FROM max_gaps
    )), 2) AS percentage
FROM (
    WITH user_churn_dates AS (
        SELECT 
            cp.user_id,
            cp.churn,
            cp.last_login_days_ago,
            DATE('2026-02-07', '-' || cp.last_login_days_ago || ' days') AS estimated_churn_date
        FROM customer_churn_usage_patterns cp
        WHERE cp.churn = 'Yes'
    ),
    login_gaps AS (
        SELECT 
            ul1.user_id,
            ul1.date AS login_date,
            MIN(ul2.date) AS next_login_date,
            JULIANDAY(MIN(ul2.date)) - JULIANDAY(ul1.date) AS gap_days
        FROM fact_usage_logs ul1
        LEFT JOIN fact_usage_logs ul2 
            ON ul1.user_id = ul2.user_id 
            AND ul2.date > ul1.date
        GROUP BY ul1.user_id, ul1.date
    ),
    max_gaps AS (
        SELECT 
            user_id,
            MAX(gap_days) AS longest_gap_days
        FROM login_gaps
        GROUP BY user_id
    )
    SELECT longest_gap_days FROM max_gaps
)
GROUP BY longest_gap_days
ORDER BY longest_gap_days;