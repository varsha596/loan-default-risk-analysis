-- ============================================
-- LOAN DEFAULT ANALYSIS PROJECT
-- Author: Varsha Nemalikonda
-- Dataset: Kaggle Loan Default Dataset (148,670 rows)
-- Tools: MySQL, Power BI
-- ============================================

-- ============================================
-- 1. SETUP
-- ============================================
CREATE DATABASE IF NOT EXISTS loan_analysis;
USE loan_analysis;

CREATE TABLE loans (
    ID BIGINT,
    year INT,
    loan_limit VARCHAR(20),
    Gender VARCHAR(20),
    approv_in_adv VARCHAR(20),
    loan_type VARCHAR(20),
    loan_purpose VARCHAR(20),
    Credit_Worthiness VARCHAR(20),
    open_credit VARCHAR(20),
    business_or_commercial VARCHAR(20),
    loan_amount DECIMAL(15,2),
    rate_of_interest DECIMAL(6,3),
    Interest_rate_spread DECIMAL(6,3),
    Upfront_charges DECIMAL(12,2),
    term INT,
    Neg_ammortization VARCHAR(20),
    interest_only VARCHAR(20),
    lump_sum_payment VARCHAR(20),
    property_value DECIMAL(15,2),
    construction_type VARCHAR(20),
    occupancy_type VARCHAR(20),
    Secured_by VARCHAR(20),
    total_units VARCHAR(20),
    income DECIMAL(15,2),
    credit_type VARCHAR(20),
    Credit_Score INT,
    `co-applicant_credit_type` VARCHAR(20),
    age VARCHAR(20),
    submission_of_application VARCHAR(20),
    LTV DECIMAL(10,2),
    Region VARCHAR(20),
    Security_Type VARCHAR(20),
    Status INT,
    dtir1 DECIMAL(6,2)
);

-- Data loaded via command line (148,670 rows):
-- mysql -u root -p --local-infile=1
-- USE loan_analysis;
-- LOAD DATA LOCAL INFILE 'C:\\Users\\Varsha Nemalikonda\\OneDrive\\Desktop\\data analyst 1\\Loan_Default.csv'
-- INTO TABLE loans
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- ============================================
-- 2. DATA QUALITY CHECKS
-- ============================================

-- Missing/zero income check (result: 10,410 rows ~7%)
SELECT COUNT(*) FROM loans WHERE income IS NULL OR income = 0;

-- Missing/zero property value check (result: 15,098 rows ~10%)
SELECT COUNT(*) FROM loans WHERE property_value IS NULL OR property_value = 0;

-- Confirmed rate_of_interest = 0 is a placeholder for defaulted loans, not real data
-- (36,439 of 36,440 zero-rate rows are Status = 1)
SELECT Status, COUNT(*) FROM loans WHERE rate_of_interest = 0 GROUP BY Status;

-- Status distribution (target variable): 24.6% default rate overall
SELECT Status, COUNT(*) FROM loans GROUP BY Status;

-- ============================================
-- 3. CORE ANALYSIS QUERIES
-- ============================================

-- Q1: Default rate by loan purpose
-- Finding: 'p2' defaults at 33.08% vs 22-26% for other categories
SELECT 
    loan_purpose,
    COUNT(*) AS total_loans,
    SUM(Status) AS defaulted_loans,
    ROUND(SUM(Status) / COUNT(*) * 100, 2) AS default_rate_pct
FROM loans
GROUP BY loan_purpose
ORDER BY default_rate_pct DESC;

-- Q2: Default rate by credit worthiness
-- Finding: 'l2' defaults at 31.77% vs 24.33% for 'l1'
SELECT 
    Credit_Worthiness,
    COUNT(*) AS total_loans,
    SUM(Status) AS defaulted_loans,
    ROUND(SUM(Status) / COUNT(*) * 100, 2) AS default_rate_pct
FROM loans
GROUP BY Credit_Worthiness
ORDER BY default_rate_pct DESC;

-- Q3: Default rate by income bracket (KEY FINDING)
-- Finding: Under 3,000 income defaults at 36.40% vs 20.37% for 10,000+
SELECT 
    CASE 
        WHEN income IS NULL OR income = 0 THEN 'Missing'
        WHEN income < 3000 THEN 'Under 3000'
        WHEN income < 6000 THEN '3000-5999'
        WHEN income < 10000 THEN '6000-9999'
        ELSE '10000+'
    END AS income_bracket,
    COUNT(*) AS total_loans,
    SUM(Status) AS defaulted_loans,
    ROUND(SUM(Status) / COUNT(*) * 100, 2) AS default_rate_pct
FROM loans
GROUP BY income_bracket
ORDER BY default_rate_pct DESC;

-- Q4: Default rate by region
-- Finding: South (26.63%) defaults more than North (22.51%) despite similar volume
SELECT 
    Region,
    COUNT(*) AS total_loans,
    SUM(Status) AS defaulted_loans,
    ROUND(SUM(Status) / COUNT(*) * 100, 2) AS default_rate_pct
FROM loans
GROUP BY Region
ORDER BY default_rate_pct DESC;

-- Q5: Loan amount, interest rate, and income comparison by default status
-- Finding: Defaulted loans have lower income (6,021 vs 6,695) and slightly higher rates
SELECT 
    Status,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(CASE WHEN rate_of_interest > 0 THEN rate_of_interest END), 2) AS avg_interest_rate,
    ROUND(AVG(income), 2) AS avg_income
FROM loans
GROUP BY Status;