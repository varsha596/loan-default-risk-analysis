Loan Default Risk Analysis

Analysis of 148,670 loan records to identify the key factors driving loan default, using SQL for data cleaning and analysis, and Power BI for visualization.

Dashboard_screenshot.png

Overview
Dataset: Kaggle Loan Default Dataset — 148,670 rows
Tools: MySQL (data cleaning + analysis), Power BI (dashboard)
Goal: Identify which borrower and loan characteristics are most associated with default, to support underwriting decisions
Key Findings
Income is the strongest predictor of default. Borrowers earning under Rs. 3,000 defaulted at nearly double the rate (36.4%) of borrowers earning Rs. 10,000+ (20.4%).
Loan purpose matters. Loans categorized as purpose "p2" defaulted at 33.1%, notably higher than other categories (23–26%).
Credit worthiness label is predictive. Loans marked "l2" defaulted at 31.8% vs. 24.3% for "l1".
Region shows a gap. South region loans defaulted at 26.6% vs. 22.5% in the North, despite similar loan volume.
Overall default rate: 24.6% (36,639 of 148,670 loans).
Data Cleaning Notes
~7% of rows had missing/zero income, ~10% had missing/zero property value — these were excluded only from analyses specific to those fields, not dropped from the dataset entirely.
Discovered that rate_of_interest = 0 was not a real value — it was a placeholder appearing almost exclusively on defaulted loans (36,439 of 36,440 zero-rate rows had Status = 1). Excluded these from interest rate averages accordingly.
SQL Techniques Used
GROUP BY + aggregate functions (COUNT, SUM, AVG) to calculate default rates by category
CASE WHEN to bucket continuous income data into brackets
Data quality checks (NULL/zero handling) before drawing conclusions

See Loan_default_analysis.sql for the full script with comments explaining each query and its finding.

Dashboard

The Power BI dashboard (Loan_default_dashboard.pbix) includes:

Default rate by income bracket, loan purpose, and region
Overall default rate and total loan count KPI cards
A summary insight callout
Author

Varsha Nemalikonda LinkedIn | varshanemalikonda0308@gmail.com
