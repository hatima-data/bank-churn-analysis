select * from Bank_churn;

SELECT
    Geography,
    count(*) as customer_count
    from Bank_churn
    group by  Geography;

SELECT
    Gender,
    COUNT(*) as gender_count
    from Bank_churn
    group by Gender
    ORDER BY gender_count desc;

SELECT
    Age,
    COUNT(*) as age_count
    from Bank_churn
    group by Age
    order by age_count desc;

SELECT
    Geography,
    count(*) as customer_count,
    round(avg(try_cast(CreditScore as float)),2) as avg_credit_score
    from Bank_churn
    group by Geography
    order by avg_credit_score;

SELECT
    count(*) as total_rows,
    count(Distinct CustomerId) as unique_customer
    from Bank_churn;

SELECT 
    top 1 *
    from Bank_churn;

SELECT *
    from Bank_churn
    where 
       CustomerId is Null
    or Surname is Null
    or CreditScore is Null
    or Geography is Null
    or Gender is Null
    or Age is null
    or Tenure is null
    or Balance is null
    or NumOfProducts is null
    or HasCrCard is null
    or IsActiveMember is null
    or EstimatedSalary is null
    or Exited is null;

SELECT 
    Balance,
    count(*) 
    from Bank_churn
    where Balance='0'
    group by  Balance;

create view dbo.bank_churn_silver as 
SELECT
    TRY_CAST(RowNumber AS INT) AS RowNumber,
    CustomerId,
    Surname,
    TRY_CAST(CreditScore AS INT) AS CreditScore,
    Geography,
    Gender,
    TRY_CAST(Age AS INT) AS Age,
    TRY_CAST(Tenure AS INT) AS Tenure,
    TRY_CAST(Balance AS DECIMAL(18, 2)) AS Balance,
    TRY_CAST(NumOfProducts AS INT) AS NumOfProducts,
    TRY_CAST(HasCrCard AS INT) AS HasCrCard,
    TRY_CAST(IsActiveMember AS INT) AS IsActiveMember,
    TRY_CAST(EstimatedSalary AS DECIMAL(18, 2)) AS EstimatedSalary,
    TRY_CAST(Exited AS INT) AS Exited
FROM dbo.Bank_churn;

select top 10 *
from dbo.bank_churn_silver;

CREATE VIEW dbo.bank_churn_gold_geography AS
SELECT
    Geography,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 2) AS churn_rate_pct,
    ROUND(AVG(Balance), 2) AS avg_balance,
    ROUND(AVG(CAST(CreditScore AS FLOAT)), 1) AS avg_credit_score
FROM dbo.bank_churn_silver
GROUP BY Geography;

SELECT *
FROM dbo.bank_churn_gold_geography
ORDER BY churn_rate_pct DESC;

CREATE VIEW dbo.bank_churn_gold_age_group AS
SELECT
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 2) AS churn_rate_pct,
    ROUND(AVG(Balance), 2) AS avg_balance
FROM dbo.bank_churn_silver
GROUP BY
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END;

Select * from dbo.bank_churn_gold_age_group;

CREATE VIEW dbo.bank_churn_gold_activity_products AS
SELECT
    CASE
        WHEN IsActiveMember = 1 THEN 'Active'
        ELSE 'Inactive'
    END AS activity_status,
    NumOfProducts,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 2) AS churn_rate_pct
FROM dbo.bank_churn_silver
GROUP BY
    CASE
        WHEN IsActiveMember = 1 THEN 'Active'
        ELSE 'Inactive'
    END,
    NumOfProducts;

select * from dbo.bank_churn_gold_activity_products;

CREATE VIEW dbo.bank_churn_gold_balance_status AS
SELECT
    CASE
        WHEN Balance = 0 THEN 'Zero Balance'
        ELSE 'Positive Balance'
    END AS balance_status,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 2) AS churn_rate_pct,
    ROUND(AVG(Balance), 2) AS avg_balance,
    ROUND(AVG(EstimatedSalary), 2) AS avg_estimated_salary
FROM dbo.bank_churn_silver
GROUP BY
    CASE
        WHEN Balance = 0 THEN 'Zero Balance'
        ELSE 'Positive Balance'
    END;

select * from dbo.bank_churn_gold_balance_status ;


-- 1. Yosh guruhlari bo'yicha
SELECT * FROM dbo.bank_churn_gold_age_group ORDER BY churn_rate_pct DESC;

-- 2. Faollik va mahsulotlar bo'yicha
SELECT * FROM dbo.bank_churn_gold_activity_products ORDER BY churn_rate_pct DESC;

-- 3. Balans holati bo'yicha
SELECT * FROM dbo.bank_churn_gold_balance_status ORDER BY churn_rate_pct DESC;
