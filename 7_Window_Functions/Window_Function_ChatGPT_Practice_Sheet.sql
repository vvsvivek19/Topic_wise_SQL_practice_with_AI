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













