# SaaS Customer Churn Analysis - Full Walkthrough

## Question: Based on the given data, can you determine why this company is struggling to retain customers for an extended tenure?

---

## Step 1: Initial Data Assessment

Downloaded the data from Kaggle and added 4 supplementary tables via Python.

Exported data to SQL database for querying. Selected SQLite as the database engine.

To begin, I executed 2 queries targeting what I consider the most critical baseline metrics:

- **a.** What is the current churn rate? (Industry benchmark is typically 10-15%)
- **b.** What is the average customer lifespan, segmented by plan type?

---

## Step 2: Overall Churn Rate Analysis

**Query:** [`01_churn_rate_percentage.sql`](SQL/01_churn_rate_percentage.sql)

**Finding:** [`01_churn_rate_percentage.csv`](Results/01_churn_rate_percentage.csv)

The churn data reveals a significant discrepancy. The overall churn rate is 25.52%, substantially above industry standards.

---

## Step 3: Churn Rate by Plan Type

**Query:** [`02_churn_plan_type.sql`](SQL/02_churn_plan_type.sql)

**Finding:** [`02_churn_plan_type.csv`](Results/02_churn_plan_type.csv)

The analysis shows churn rates are relatively consistent across subscription tiers.

---

## Step 4: Support Ticket Analysis

Next, I executed a query to analyze:

- **a.** Average support tickets per active vs. churned user
- **b.** Distribution of ticket severity (low, medium, high)

**Query:** [`03_churn_analysis.sql`](SQL/03_churn_analysis.sql)

**Finding:** [`03_churn_analysis.csv`](Results/03_churn_analysis.csv)

**Key findings:**

- **a.** Churned users generate nearly 3x more support tickets than active users.
- **b.** Severity distribution appears normal for low and medium tickets. However, 18-20% of all tickets are high severity, indicating significant product quality issues.

---

## Step 5: Ticket Category Distribution

I then analyzed ticket category distribution to identify specific problem areas.

**Query:** [`04_ticket_type.sql`](SQL/04_ticket_type.sql)

**Finding:** [`04_ticket_type.csv`](Results/04_ticket_type.csv)

![Ticket Categories](Visualizations/percentage_of_tickets_by_category.png)

Access-related tickets (the simplest category) show minimal correlation with churn. The primary churn drivers are technical issues (bugs) and billing problems (which lock users out of the application).

---

## Step 6: Support Response Time Analysis

To understand the root cause, I investigated whether support response times contribute to churn.

**Query:** [`05_avg_resolution_time.sql`](SQL/05_avg_resolution_time.sql)

**Finding:** [`05_avg_resolution_time.csv`](Results/05_avg_resolution_time.csv)

Resolution times are evenly distributed between churned and active users. If anything, active users experience slightly longer resolution times. This suggests support speed is not the primary churn driver.

---

## Step 7: Payment Failures Impact

Next, I examined the relationship between payment failures and churn.

**Query:** [`06_payment_failure_churn.sql`](SQL/06_payment_failure_churn.sql)

**Finding:** [`06_payment_failure_churn.csv`](Results/06_payment_failure_churn.csv)

![Payment Failures vs Churn](Visualizations/payment_failure_vs_churn_rate.png)

This reveals a critical issue. Payment failures correlate strongly with churn. 4 failures = 90% churn rate, 3 = 75%, 2 = 60%. These are severe retention failures.

---

## Step 8: Customer Tenure Analysis

I hypothesized that users are experiencing a short-term tenure pattern. This would suggest an onboarding problem where new users encounter too many issues and churn early.

**Query:** [`07_tenure_churn_rate.sql`](SQL/07_tenure_churn_rate.sql)

**Finding:** [`07_tenure_churn_rate.csv`](Results/07_tenure_churn_rate.csv)

![Average User Tenure](Visualizations/avg_user_tenure.png)

The data confirms a significant onboarding issue. In the first 5 months, approximately 40% of users churn each month. Long-term users show declining churn rates. This indicates that those who survive the initial period develop tolerance or find value despite issues. Users who persist beyond 5-6 months demonstrate increasingly strong retention.

---

## Step 9: Billing Ticket Analysis

To determine whether billing issues originate from user error or system problems, I compared billing ticket volume to payment failures.

**Query:** [`08_billing_ticket_per_failure.sql`](SQL/08_billing_ticket_per_failure.sql)

**Finding:** [`08_billing_ticket_per_failure.csv`](Results/08_billing_ticket_per_failure.csv)

The data indicates the issue is primarily system-side. Customers submit billing tickets even without payment failures. Additionally, billing ticket volume is initially high (suggesting users want to resolve issues). However, it eventually declines (suggesting users give up as frustration mounts).

---

## Step 10: Technical Ticket Impact

Finally, I conducted a similar analysis for technical tickets to compare severity against billing issues.

**Query:** [`09_technical_ticket_churn.sql`](SQL/09_technical_ticket_churn.sql)

**Finding:** [`09_technical_ticket_churn.csv`](Results/09_technical_ticket_churn.csv)

![Churned Users by Ticket Type](Visualizations/churned_vs_ticket_type.png)

Technical issues, while problematic, are less severe than billing issues. They occur less frequently and have a higher tolerance threshold. Payment issues cause immediate, sharp churn spikes with a threshold at 3 failures. Technical issues have a threshold at 4-5 tickets. Some users persist even beyond that point—a pattern rarely seen with billing failures.

---

## Step 11: Initial Analysis

The application exhibits clear quality issues. While technical bugs are prevalent, the more critical problem is the comparable volume of payment-related failures.

Payment failures create cascading problems. Unlike technical bugs, which can sometimes be worked around, payment issues lock users out entirely. They create confusion and prevent businesses from completing work. This represents a mission-critical failure mode.

Users initially engage support at rates proportional to issue frequency. However, they eventually disengage. The churn threshold is 3 billing tickets or 4-5 technical tickets.

**Initial recommendation:** Halt new feature development for 2-4 weeks to address billing infrastructure problems driving rapid churn. Technical issues should also be addressed but represent a secondary priority.

---

## Step 12: Inactivity Window Analysis

To develop more targeted interventions, I analyzed user inactivity patterns preceding churn.

**Query:** [`10_gap_before_churn.sql`](SQL/10_gap_before_churn.sql)

**Finding:** [`10_gap_before_churn.csv`](Results/10_gap_before_churn.csv)

![Login Gap Distribution](Visualizations/gap_before_churn.png)

The majority of churned users show 7-9 days of inactivity before churning.

**Recommendation:** The 7-9 day inactivity window represents a critical intervention opportunity. Proactive outreach during this period (satisfaction surveys, support offers) could recover at-risk users.

---

## Step 13: Re-evaluating the Original Question

The original question asks why the company struggles to retain customers "for an extended tenure." Based on the data, this framing may be incorrect.

The primary issue is not long-term retention but rather an acute onboarding failure. New users experience 40% monthly churn during months 1-5. However, users who survive this period show strong retention (≤20%). This pattern indicates that billing and technical issues disproportionately affect new users during the critical evaluation period. During this time, tolerance for friction is minimal.

---

## Step 14: Current Baseline Metrics

I executed 3 additional queries to quantify intervention impact:

- **a.** Current baseline metrics (churn rate and revenue)
- **b.** Users recoverable through specific interventions
- **c.** Projected outcomes if interventions are successfully implemented

**Query:** [`11_current_statistics.sql`](SQL/11_current_statistics.sql)

**Finding:** [`11_current_statistics.csv`](Results/11_current_statistics.csv)

Current churn rate confirmed at 25.5%, establishing the baseline for comparison.

---

## Step 15: Intervention Effectiveness Analysis

**Query:** [`12_users_saved.sql`](SQL/12_users_saved.sql)

**Finding:** [`12_users_saved.csv`](Results/12_users_saved.csv)

**Intervention effectiveness projections:**

- **a.** Reducing users experiencing 4+ support tickets: Highest impact
- **b.** Reducing payment failures by ~30%: Second-highest impact
- **c.** Proactive outreach during 7-9 day inactivity window: Tertiary impact

---

## Step 16: Projected Impact Analysis

**Query:** [`13_predicted_statistics.sql`](SQL/13_predicted_statistics.sql)

**Finding:** [`13_predicted_statistics.csv`](Results/13_predicted_statistics.csv)

**Projected results if all interventions are successfully implemented:**

- **a.** Current churn rate: 25.5% → Projected churn rate: 7.1%
- **b.** Total churn reduction: 18.4 percentage points
- **c.** Annual revenue retained: $151,289 (from current base of $820,440)
- **d.** Revenue increase: 15.57%

---

## Final Recommendations:

### Priority 1: Fix Billing Infrastructure
Immediately address payment processing failures. Target: reduce failures from current rate to <5%. This represents the highest ROI intervention.

### Priority 2: Improve Onboarding Experience
Target months 1-3 where churn peaks at 40-49%. Focus on eliminating critical bugs that new users encounter during evaluation period.

### Priority 3: Implement Proactive Intervention System
Deploy automated alerts for:
- **a.** Users with 1+ payment failures (36.6% churn risk)
- **b.** 7-9 day login gaps (47% of churned users show this pattern)
- **c.** Users approaching 3 technical tickets (before 88.7% churn threshold at 4-5 tickets)

---

## Executive Summary

![Executive Dashboard](Visualizations/executive_dashboard.png)
