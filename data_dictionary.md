# Data Dictionary

## Overview
This database contains SaaS customer subscription data, usage patterns, support tickets, billing transactions, and churn outcomes used to analyze customer retention and identify churn drivers.

## Data Quality Notes

**Schema Quality**: The dataset uses well-structured relational design with proper foreign key relationships. User IDs are consistently used across all tables, enabling efficient joins and comprehensive customer analysis.

**Recommendation**: Data is production-ready for analysis. All tables use appropriate data types and maintain referential integrity through user_id as the primary linking key.

---

## Tables

### 1. `customer_churn_usage_patterns`
**Description**: Customer subscription details, usage metrics, support interaction history, and churn status

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| user_id | INTEGER | Unique identifier for each customer | 1, 2, 3 |
| signup_date | TEXT | Date customer signed up for service | 10/16/2024, 4/25/2023 |
| plan_type | TEXT | Subscription tier | Basic, Standard, Premium |
| monthly_fee | REAL | Monthly subscription cost in dollars | 14.99, 29.99, 49.99 |
| avg_weekly_usage_hours | REAL | Average hours of product usage per week | 1.2, 2.7, 3.8 |
| support_tickets | INTEGER | Total number of support tickets submitted | 2, 4, 9 |
| payment_failures | INTEGER | Count of failed payment attempts | 0, 1, 2 |
| tenure_months | INTEGER | Length of customer relationship in months | 2, 20, 16 |
| last_login_days_ago | INTEGER | Days since last product login | 0, 4, 665 |
| churn | TEXT | Whether customer churned | Yes, No |

**Primary Key**: `user_id`

**Business Context**: 
- Basic plan = $14.99/month (entry-tier)
- Standard plan = $29.99/month (mid-tier)
- Premium plan = $49.99/month (full-featured)

**Key Metrics**:
- Industry benchmark churn rate: 10-15%
- Actual churn rate: 25.5% (requires investigation)

---

### 2. `dim_users`
**Description**: Customer dimension table with signup details and final churn status

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| user_id | INTEGER | Unique identifier for each customer | 1, 2, 3 |
| signup_date | TEXT | Date customer signed up for service | 10/16/2024, 4/25/2023 |
| plan_type | TEXT | Subscription tier | Basic, Standard, Premium |
| monthly_fee | REAL | Monthly subscription cost in dollars | 14.99, 29.99, 49.99 |
| churn | TEXT | Whether customer churned | Yes, No |
| churn_date | TEXT | Date customer churned (NULL if active) | 5/23/2023, 12/31/2024 |

**Primary Key**: `user_id`

**Note**: This table provides the dimensional backbone for customer analysis. The `churn_date` field enables time-series analysis of churn patterns.

---

### 3. `fact_billing`
**Description**: Transaction-level billing events showing payment success/failure history

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| transaction_id | INTEGER | Unique identifier for each billing transaction | 1, 2, 3 |
| user_id | INTEGER | Foreign key linking to customer | 1, 2, 3 |
| payment_date | TEXT | Date payment was attempted | 10/16/2024, 11/15/2024 |
| amount | REAL | Payment amount in dollars | 14.99, 29.99, 49.99 |
| status | TEXT | Payment outcome | Success, Failed |

**Primary Key**: `transaction_id`  
**Foreign Key**: `user_id` → `dim_users.user_id`

**Critical Finding**: Payment failures strongly correlate with churn:
- 1 failure = 36.6% churn risk
- 2 failures = 60% churn risk  
- 3 failures = 75% churn risk
- 4+ failures = 90% churn risk

---

### 4. `fact_support_tickets`
**Description**: Customer support interaction records categorized by issue type and severity

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| ticket_id | INTEGER | Unique identifier for each support ticket | 1, 2, 3 |
| user_id | INTEGER | Foreign key linking to customer | 1, 2, 3 |
| date_opened | TEXT | Date ticket was submitted | 12/11/2024, 6/26/2024 |
| category | TEXT | Type of issue | Billing, Technical, Access |
| severity | TEXT | Priority level | Low, Medium, High |
| resolution_time_hours | INTEGER | Hours from open to resolution | 43, 61, 46 |

**Primary Key**: `ticket_id`  
**Foreign Key**: `user_id` → `dim_users.user_id`

**Ticket Categories**:
- **Billing**: Payment issues, account access problems (locks users out)
- **Technical**: Bugs, performance issues (impacts usability)
- **Access**: Login problems, password resets (easiest to resolve)

**Key Findings**:
- Churned users submit 3x more tickets than active users
- 18-20% of tickets are high severity (product quality issue)
- Billing tickets drive higher churn than technical tickets
- Churn threshold: 3 billing tickets OR 4-5 technical tickets

---

### 5. `fact_usage_logs`
**Description**: Session-level usage tracking showing customer engagement patterns

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| log_id | INTEGER | Unique identifier for each usage session | 31, 610, 2005 |
| user_id | INTEGER | Foreign key linking to customer | 1, 4, 12 |
| date | TEXT | Date of usage session | 12/31/2024 |
| session_duration_minutes | REAL | Length of session in minutes | 13.7, 5, 39.9 |

**Primary Key**: `log_id`  
**Foreign Key**: `user_id` → `dim_users.user_id`

**Usage Patterns**:
- 7-9 day login gap precedes 47% of churn events
- Early-tenure users (months 1-5) show 40% monthly churn
- Long-tenure users (6+ months) show <20% churn

---

## Table Relationships
```
dim_users (user_id, signup_date, plan_type, churn, churn_date)
    ↓ (via user_id)
customer_churn_usage_patterns (user_id, support_tickets, payment_failures, tenure_months, last_login_days_ago, churn)
    ↓ (via user_id)
fact_billing (transaction_id, user_id, payment_date, amount, status)
    ↓ (via user_id)
fact_support_tickets (ticket_id, user_id, category, severity, resolution_time_hours)
    ↓ (via user_id)
fact_usage_logs (log_id, user_id, date, session_duration_minutes)
```

**Schema Design**: The database follows a star schema with `dim_users` at the center and multiple fact tables radiating outward, all connected via `user_id`. This design enables efficient multi-dimensional analysis of customer behavior.

---

## Business Context

### Churn Drivers (by severity)
1. **Payment Failures** (Critical)
   - 3+ failures = 75-90% churn
   - Locks users out of product
   - Mission-critical failure mode

2. **Technical Issues** (High)
   - 4-5+ tickets = 88.7% churn
   - Impacts usability but users show tolerance
   - Secondary priority after billing fixes

3. **Onboarding Problems** (High)
   - 40-49% churn in months 1-3
   - First 5 months are critical evaluation period
   - Users who survive show strong retention

4. **Engagement Gaps** (Medium)
   - 7-9 day inactivity window = intervention opportunity
   - 47% of churned users show this pattern
   - Proactive outreach could recover at-risk customers

### Revenue Impact
- Current annual revenue: $820,440
- Addressable churn losses: $151,289 (18.4% improvement potential)
- Target churn rate: <10% (from current 25.5%)

---

## Data Type Considerations

**Date Fields**: All dates stored as TEXT in format MM/DD/YYYY. For time-series analysis, convert to proper DATE type:
```sql
DATE(date_field) 
```

**Monetary Values**: All prices stored as REAL with 2 decimal precision (e.g., 14.99, 29.99, 49.99)

**Categorical Fields**: 
- `plan_type`: 3 values (Basic, Standard, Premium)
- `churn`: 2 values (Yes, No)
- `status`: 2 values (Success, Failed)
- `category`: 3 values (Billing, Technical, Access)
- `severity`: 3 values (Low, Medium, High)

---

## Usage Notes

- All monetary values are in USD
- Analysis period: January 2023 - December 2024
- Support resolution times measured in hours
- Usage duration measured in minutes/hours per week
- Tenure measured in complete months since signup
- Customer retention analysis excludes users with <30 days tenure
