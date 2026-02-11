## Data Source & Acknowledgments

This project began with the [Customer Subscription Churn and Usage Patterns dataset](https://www.kaggle.com/datasets/jayjoshi37/customer-subscription-churn-and-usage-patterns/data) by Jay Joshi on Kaggle, which provided the initial customer behavior and subscription data structure (customer_churn_usage_patterns table).

I significantly expanded the dataset by creating additional tables with more data:
- **Created** `dim_users` table with customer dimension details and churn dates
- **Created** `fact_billing` table with transaction-level payment success/failure records
- **Created** `fact_support_tickets` table with categorized support interactions and resolution times
- **Created** `fact_usage_logs` table with session-level engagement tracking
- **Added** temporal data for time-series analysis of churn patterns
- **Generated** relational structure enabling multi-dimensional customer analysis

The original dataset provided the foundation for customer behavior metrics. The expanded star schema and fact table framework are my own additions to enable the comprehensive churn analysis presented in this project.
