-- ======================================================================================================================================
-- 																		Window Functions
-- ======================================================================================================================================

CREATE TABLE employees_wf (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    joining_date DATE
);

INSERT INTO employees_wf VALUES
(1,'Amit','IT',70000,'2022-01-15'),
(2,'Neha','IT',60000,'2022-03-10'),
(3,'Raj','IT',70000,'2022-06-20'),

(4,'Sneha','HR',55000,'2021-11-05'),
(5,'Pooja','HR',50000,'2022-02-18'),
(6,'Vikas','HR',65000,'2022-09-01'),

(7,'Karan','Finance',80000,'2021-07-12'),
(8,'Ankit','Finance',75000,'2022-04-25'),
(9,'Riya','Finance',80000,'2023-01-14'),

(10,'Manish','Sales',45000,'2022-05-16'),
(11,'Priya','Sales',50000,'2022-07-22'),
(12,'Rohit','Sales',55000,'2023-03-10'),

(13,'Deepak','IT',90000,'2023-06-01'),
(14,'Megha','HR',65000,'2023-08-11');

/*
================================================================================
🔥 Challenge #1 (Most Important Window Function Question)
================================================================================

This is the question that usually makes window functions "click."

SQL Task:
Return the following columns using window functions:
- emp_name
- department
- salary
- total_company_salary
*/

SELECT 
	emp_name,
    department, 
    salary,
    SUM(Salary) OVER() as total_company_salary
FROM employees_wf;

SELECT
    emp_name,
    salary,
    SUM(salary) OVER() AS total_company_salary,
    ROUND(
        salary * 100.0
        / SUM(salary) OVER(),
        2
    ) AS salary_percentage
FROM employees_wf;

/*
================================================================================
🔥 Challenge #2 (The Question That Makes PARTITION BY Click)
================================================================================

Using the same dataset:

SQL Task:
Return the following columns:
- emp_name
- department
- salary
- department_total_salary
*/

SELECT 
	emp_name,
    department, 
    salary,
    SUM(Salary) OVER(PARTITION BY department) as total_company_salary
FROM employees_wf;

/*
================================================================================
🔥 Challenge #3 (This is where Window Functions become powerful)
================================================================================

Using the same dataset:

SQL Task:
Perform a Part-to-Whole Analysis by returning the following columns:
- emp_name
- department
- salary
- department_total_salary
- salary_percentage_of_department

Example calculation for IT department:
- Department Total = 290000
- Amit's Salary    = 70000
- Percentage       = (70000 / 290000) * 100

Analytical Pattern:
-- Part-to-Whole Analysis (One of the most common analytics patterns).
*/

SELECT 
	emp_name,
    department, 
    salary,
    SUM(Salary) OVER(PARTITION BY department) as department_total_salary,
    ROUND(salary * 100.00 / SUM(Salary) OVER(PARTITION BY department),2) salary_percentage_of_department
FROM employees_wf;

/*
================================================================================
🔥 Challenge #4 (AVG Window Function)
================================================================================

Now let's move into Comparison Analysis, one of the most common interview 
patterns.

SQL Task:
Return the following columns:
- emp_name
- department
- salary
- department_avg_salary
- salary_vs_department_avg

Where:
- salary_vs_department_avg = salary - department_avg_salary
*/

SELECT 
	emp_name,
    department,
    salary,
    AVG(salary) OVER(Partition by department) as department_avg_salary,
    salary - AVG(salary) OVER(Partition by department) as salary_vs_department_avg
FROM employees_wf;

/*
================================================================================
🔥 Next Challenge (#5)
================================================================================

Now we're moving to MIN() and MAX() OVER(). This is your first outlier 
detection style question.

SQL Task:
Return the following columns:
- emp_name
- department
- salary
- department_max_salary
- department_min_salary
- salary_gap_from_max
- salary_gap_from_min

Where:
- salary_gap_from_max = department_max_salary - salary
- salary_gap_from_min = salary - department_min_salary
*/

SELECT
	emp_name,
    department,
    salary,
    MAX(salary) OVER(Partition BY department) as department_max_salary,
    MIN(salary) OVER(Partition BY department) as department_min_salary,
    MAX(salary) OVER(Partition BY department) - salary as salary_gap_from_max,
    salary - MIN(salary) OVER(Partition BY department) as salary_gap_from_min
FROM employees_wf;

/*
================================================================================
🔥 Next Challenge (#6)
================================================================================

Now let's hit a pattern that appears constantly in data quality and ETL interviews:
Duplicate Detection

SQL Task:
Return the following columns to detect matching salary frequencies within 
individual departments:
- emp_name
- department
- salary
- employee_count_same_salary_in_department

Example Scenario:
If the IT department has the following salaries: [70000, 60000, 70000, 90000]
Then both employees earning 70000 should show:
- employee_count_same_salary_in_department = 2
*/

select 
	emp_name,
    department,
    salary,
    COUNT(*) OVER(partition by department,salary) employee_count_same_salary_in_department
FROM employees_wf;

/*
================================================================================
🔥 Challenge #7 — Running Total
================================================================================

Using the same employees_wf table.

SQL Task:
Return the following columns:
- emp_name
- department
- joining_date
- salary
- running_department_salary

Rules:
- Running total should be calculated within each department.
- Employees should be processed in joining date order.
*/

SELECT
	emp_name,
    department,
    joining_date,
    salary,
    SUM(salary) OVER(PARTITION BY department ORDER BY joining_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_department_salary
FROM employees_wf;

/*
================================================================================
🔥 Challenge #8 — Running Average
================================================================================

Now let's build directly on what you just learned.

SQL Task:
Return the following columns:
- emp_name
- department
- joining_date
- salary
- running_avg_salary

Rules:
- Within each department
- Ordered by joining date
- Average salary up to the current employee
*/

SELECT 
	emp_name,
    department,
    joining_date,
    salary,
    AVG(salary) OVER(PARTITION BY department ORDER BY joining_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_avg_salary
FROM employees_wf;

/*
================================================================================
🔥 Challenge #9 — Rolling 3-Employee Average
================================================================================

Unlike a running average:
- Row 1 → Row 1
- Row 2 → Rows 1-2
- Row 3 → Rows 1-3
- Row 4 → Rows 1-4

A rolling average looks at a fixed-size moving window.

Scenario:
HR wants to smooth salary trends by averaging the salaries of:
- Current employee
- Previous employee
- Employee before that

Within the same department, ordered by joining date chronologically.

SQL Task:
Return the following columns:
- emp_name
- department
- joining_date
- salary
- rolling_3_employee_avg
*/

SELECT
	emp_name,
    department,
    joining_date,
    salary,
    AVG(salary) OVER(PARTITION BY department ORDER BY joining_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_3_employee_avg
FROM employees_wf;

/*
================================================================================
🚀 Challenge #1 (Ranking)
================================================================================

Using the same employees_wf table.

SQL Task:
Return the following columns using a ranking window function:
- emp_name
- department
- salary
- salary_rank

Rules:
- Highest salary in each department gets rank 1 (Descending Order).
- Employees with the same salary should receive the same rank (Tie Handling).
- The next rank should skip numbers if there is a tie (Standard Competition Rank).

Example Scenario:
If a department has salaries: [90000, 80000, 80000, 70000]
The assigned ranks must be:  [1, 2, 2, 4]
*/

SELECT 
	emp_name,
    department, 
    salary,
    rank() OVER(PARTITION BY department ORDER BY salary DESC) as salary_rank
FROM employees_wf;

/*
================================================================================
🔥 Challenge #2
================================================================================

Using the same employees_wf table.

SQL Task:
Return the following columns using the appropriate dense ranking window function:
- emp_name
- department
- salary
- salary_rank

Rules:
- Highest salary in each department gets rank 1 (Descending Order).
- Employees with the same salary receive the same rank (Tie Handling).
- No ranks should be skipped after a tie (Consecutive/Dense Ranking).
*/

SELECT 
    emp_name,
    department,
    salary,
    DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) as salary_rank
FROM employees_wf;

/*
================================================================================
🔥 Challenge #3 (Slightly Harder)
================================================================================

Business Scenario:
HR wants to identify only the highest-paid employee(s) in each department.
If there is a tie, everyone tied for the highest salary should be returned.

SQL Task:
Return the following columns:
- emp_name
- department
- salary

Rules:
- No rank column is required in the final output.
*/

SELECT
	emp_name,
    department,
    salary
FROM(
SELECT
	emp_name,
    department,
    salary,
    DENSE_RANK() OVER(Partition by department ORDER BY salary DESC) as salary_rank
FROM employees_wf
)t
WHERE salary_rank = 1;

/*
================================================================================
🔥 Next Challenge (A Real Interview Favorite)
================================================================================

This is one of the most frequently asked window function questions.

Business Scenario:
The HR team accidentally imported duplicate employee records. 
Two records are considered duplicates if they have the same:
- department
- salary

Rule:
- Keep only one record from each duplicate group.

SQL Task:
Return the following columns with duplicates removed:
- emp_name
- department
- salary
*/

SELECT
	*
FROM (
SELECT
	emp_name,
    department,
    salary,
    ROW_NUMBER() OVER(Partition by department, salary ORDER BY salary) as emp_rank
FROM employees_wf
)t
WHERE emp_rank = 1;

/*
================================================================================
🔥 Challenge #5
================================================================================

Using the same employees_wf table.

SQL Task:
Return the following columns to divide corporate compensation tiers:
- emp_name
- department
- salary
- salary_quartile

Rules:
- Employees should be ordered by salary descending.
- Divide them into 4 equal groups (Quartiles).
- This is for the entire company, not per department (No Partitioning Clause).
*/

SELECT
	emp_name,
    department,
    salary,
    NTILE(4) OVER(ORDER BY salary DESC) as salary_quartile
FROM employees_wf;

/*
================================================================================
🎯 Challenge #1
================================================================================

Using the same employees_wf table.

SQL Task:
Return the following columns using a percentage-based ranking window function:
- emp_name
- department
- salary
- salary_percent_rank

Rules:
- Calculate the salary percent rank within each department (PARTITION BY).
- You decide the ordering (Typically descending for highest-to-lowest ranking).

Note: After this, we will hit exactly one CUME_DIST() challenge before advancing 
to the highly anticipated LAG() and LEAD() time-series functions!
*/

SELECT
	emp_name,
    department,
    salary,
    PERCENT_RANK() OVER(Partition by department ORDER BY salary DESC) salary_percent_rank
FROM employees_wf;

/*
================================================================================
🎯 One Final Question on Percentage Rankings
================================================================================

Using the same employees_wf table.

SQL Task:
Return the following columns using a cumulative distribution window function:
- emp_name
- department
- salary
- salary_cumulative_distribution

Rules:
- Calculate the metric within each department (PARTITION BY).
- Order the rows within each partition by salary descending (ORDER BY salary DESC).
*/

SELECT 
	emp_name,
    department,
    salary,
    CUME_DIST() OVER(PARTITION BY department ORDER BY salary) as salary_cumulative_distribution
FROM employees_wf;

CREATE TABLE monthly_sales (
    sales_month DATE,
    sales_amount INT
);

INSERT INTO monthly_sales VALUES
('2023-01-01',10000),
('2023-02-01',12000),
('2023-03-01',11000),
('2023-04-01',15000),
('2023-05-01',17000),
('2023-06-01',16000),
('2023-07-01',19000),
('2023-08-01',21000),
('2023-09-01',20500),
('2023-10-01',23000),
('2023-11-01',25000),
('2023-12-01',27000);

/*
================================================================================
Business Scenario:
The CEO asks: "For each month, show me the previous month's sales."

Challenge #1
Return the following columns:
- sales_month
- sales_amount
- previous_month_sales
================================================================================
*/

SELECT 
	*,
    LAG(sales_amount,1,0) OVER(Order by sales_month) as previous_month_sales
FROM monthly_sales;

/*
================================================================================
🚀 Challenge #2 (This is where LAG becomes powerful)
================================================================================

Management now asks:
"For every month, show me how much sales changed compared to the previous month."

SQL Task:
Return the following columns to perform a period-over-period variance analysis:
- sales_month
- sales_amount
- previous_month_sales
- sales_difference

Where:
- sales_difference = sales_amount - previous_month_sales
*/

SELECT 
	*,
    LAG(sales_amount,1,0) OVER(Order by sales_month) as previous_month_sales,
    sales_amount - LAG(sales_amount,1,0) OVER(Order by sales_month) as sales_difference
FROM monthly_sales;

/*
================================================================================
🔥 Challenge #3 (A Very Common Interview Question)
================================================================================

Management asks:
"Show the percentage growth compared to the previous month."

SQL Task:
Return the following columns to perform a MoM growth tracking analysis:
- sales_month
- sales_amount
- previous_month_sales
- growth_percentage

Formula:
  ((sales_amount - previous_month_sales) / previous_month_sales) * 100

Operational Constraint:
- The first month has no historical baseline (Previous Sales = NULL or 0).
- Your query must implement structural defenses to avoid divide-by-zero crashes.
*/
SELECT
	*,
    ROUND((CAST((sales_amount - previous_month_sales) AS FLOAT)/NULLIF(previous_month_sales,0)) * 100,2) as growth_percentage
FROM (
SELECT 
	*,
    LAG(sales_amount,1) OVER(Order by sales_month) as previous_month_sales
FROM monthly_sales)t;

/*
================================================================================
🔥 Challenge #4 — LEAD()
================================================================================

Business Scenario:
The sales director asks:
"For each month, show me the next month's sales and calculate how much sales 
are expected to change compared to the current month."

SQL Task:
Return the following columns:
- sales_month
- sales_amount
- next_month_sales
- expected_change

Where:
  expected_change = next_month_sales - sales_amount

⭐ Bonus Challenge (Interview Level):
Extend your query logic (using an outer query layer or direct evaluation) 
to classify the expected direction by adding a final column:
- sales_trend

Rules for sales_trend:
- expected_change > 0    -> 'Growth'
- expected_change < 0    -> 'Decline'
- expected_change = 0    -> 'No Change'
- expected_change IS NULL -> 'No Future Data'
*/
SELECT
	*,
    CASE 
		WHEN expected_change > 0 THEN 'Growth'
        WHEN expected_change < 0 THEN 'Decline'
        WHEN expected_change is null then 'No Future Data'
        WHEN expected_change = 0 then 'No Change'
	END as sales_trend
FROM
(
SELECT 
	*,
    LEAD(sales_amount,1) OVER(Order by sales_month) as next_month_sales,
    LEAD(sales_amount,1) OVER(Order by sales_month) - sales_amount as expected_change
FROM monthly_sales)t;

/*
================================================================================
🔥 Challenge #5 — FIRST_VALUE()
================================================================================

Using the same monthly_sales table.

SQL Task:
Return the following columns to measure baseline corporate growth over time:
- sales_month
- sales_amount
- first_month_sales
- growth_since_first_month

Where:
- first_month_sales = The sales_amount from the very first month in the timeline.
- growth_since_first_month = sales_amount - first_month_sales
*/

SELECT 
	*,
    FIRST_VALUE(sales_amount) OVER(Order by sales_month) as first_month_sales,
    sales_amount -  FIRST_VALUE(sales_amount) OVER(Order by sales_month) as growth_since_first_month
FROM monthly_sales;

/*
================================================================================
🔥 Challenge #6 — LAST_VALUE()
================================================================================

Using the same monthly_sales table.

SQL Task:
Return the following columns to measure variance against your final benchmark:
- sales_month
- sales_amount
- last_month_sales
- difference_from_last_month

Where:
- last_month_sales = The sales_amount from the absolute final month in the timeline (December).
- difference_from_last_month = last_month_sales - sales_amount

⚠️ Architectural Reminder: 
Remember how the default frame clause changes when an ORDER BY is introduced! 
Ensure your window frame is explicitly configured to look ahead to the end of 
the partition, or your LAST_VALUE() will get stuck on the current row.
*/

SELECT 
	*,
    LAST_VALUE(sales_amount) OVER(Order by sales_month ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as last_month_sales,
    LAST_VALUE(sales_amount) OVER(Order by sales_month ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) - sales_amount as difference_from_last_month
FROM monthly_sales;







