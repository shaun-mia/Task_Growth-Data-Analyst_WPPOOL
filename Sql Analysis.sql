create database wppool;

use wppool;



-- Check for missing values in all columns
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS missing_user_id,
    SUM(CASE WHEN install_date IS NULL THEN 1 ELSE 0 END) AS missing_install_date,
    SUM(CASE WHEN last_active_date IS NULL THEN 1 ELSE 0 END) AS missing_last_active_date,
    SUM(CASE WHEN subscription_type IS NULL THEN 1 ELSE 0 END) AS missing_subscription_type,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN total_sessions IS NULL THEN 1 ELSE 0 END) AS missing_total_sessions,
    SUM(CASE WHEN page_views IS NULL THEN 1 ELSE 0 END) AS missing_page_views,
    SUM(CASE WHEN download_clicks IS NULL THEN 1 ELSE 0 END) AS missing_download_clicks,
    SUM(CASE WHEN activation_status IS NULL THEN 1 ELSE 0 END) AS missing_activation_status,
    SUM(CASE WHEN days_active IS NULL THEN 1 ELSE 0 END) AS missing_days_active,
    SUM(CASE WHEN pro_upgrade_date IS NULL THEN 1 ELSE 0 END) AS missing_pro_upgrade_date,
    SUM(CASE WHEN plan_type IS NULL THEN 1 ELSE 0 END) AS missing_plan_type,
    SUM(CASE WHEN monthly_revenue IS NULL THEN 1 ELSE 0 END) AS missing_monthly_revenue,
    SUM(CASE WHEN churned IS NULL THEN 1 ELSE 0 END) AS missing_churned
FROM users;

-- Data Exploration --
-- task 1.3 Summary of Free vs. Pro users 
SELECT subscription_type, COUNT(*) AS user_count
FROM users
GROUP BY subscription_type;

-- 2. User Engagement Analysis

-- 2.1 Average number of sessions for Free vs. Pro users
SELECT subscription_type, AVG(total_sessions) AS avg_sessions
FROM users
GROUP BY subscription_type;
-- 2.2 Top 5 most active users based on total sessions
SELECT user_id, SUM(total_sessions) AS total_sessions
FROM users
GROUP BY user_id
ORDER BY total_sessions DESC
LIMIT 5;

-- Step 3: Churn Analysis
-- 3.1 Overall Churn Rate for Free vs. Pro Users
SELECT subscription_type, 
       COUNT(*) AS total_users,
       SUM(CASE WHEN churned = 1 THEN 1 ELSE 0 END) AS churned_users,
       (SUM(CASE WHEN churned = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS churn_rate
FROM users
GROUP BY subscription_type;
-- 3.2 Top 3 Factors Contributing to Churn

WITH stats AS (
    SELECT
        AVG(total_sessions) AS avg_sessions,
        AVG(page_views) AS avg_page_views,
        AVG(days_active) AS avg_days_active,
        AVG(monthly_revenue) AS avg_monthly_revenue,
        AVG(churned) AS avg_churned,
        STDDEV(total_sessions) AS stddev_sessions,
        STDDEV(page_views) AS stddev_page_views,
        STDDEV(days_active) AS stddev_days_active,
        STDDEV(monthly_revenue) AS stddev_revenue,
        STDDEV(churned) AS stddev_churned
    FROM users
),
covariance AS (
    SELECT
        AVG(total_sessions * churned) - AVG(total_sessions) * AVG(churned) AS cov_sessions,
        AVG(page_views * churned) - AVG(page_views) * AVG(churned) AS cov_page_views,
        AVG(days_active * churned) - AVG(days_active) * AVG(churned) AS cov_days_active,
        AVG(monthly_revenue * churned) - AVG(monthly_revenue) * AVG(churned) AS cov_revenue
    FROM users
)
SELECT
    cov_sessions / (stats.stddev_sessions * stats.stddev_churned) AS sessions_churn_corr,
    cov_page_views / (stats.stddev_page_views * stats.stddev_churned) AS page_views_churn_corr,
    cov_days_active / (stats.stddev_days_active * stats.stddev_churned) AS days_active_churn_corr,
    cov_revenue / (stats.stddev_revenue * stats.stddev_churned) AS revenue_churn_corr
FROM stats, covariance;

-- 3.3 Compare Churn Trends Between Free and Pro Users
SELECT subscription_type, 
       AVG(churned) AS avg_churn_rate,
       AVG(total_sessions) AS avg_sessions,
       AVG(days_active) AS avg_days_active
FROM users
GROUP BY subscription_type;