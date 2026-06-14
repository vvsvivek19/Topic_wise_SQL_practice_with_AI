--CREATE TABLE employees_date (
--    emp_id INT,
--    emp_name VARCHAR(50),
--    joining_date DATETIME
--);

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2022-05-15 09:30:00'),
--(2, 'Neha',  '2021-11-22 14:45:00'),
--(3, 'Raj',   '2023-01-10 08:15:00'),
--(4, 'Sneha', '2020-07-05 18:00:00');

SELECT * FROM employees_date;

/*
🔥 Challenge #1 (DAY, MONTH, YEAR)
Return: employee_name, joining_date, joining_day, joining_month, joining_year
*/

SELECT 
	emp_name,
	joining_date,
	DAY(joining_date) as joining_day,
	MONTH(joining_date) as joining_month,
	YEAR(joining_date) as joining_year
FROM employees_date;

SELECT * FROM employees_date;

--CREATE TABLE employees_date (
--    emp_id INT,
--    emp_name VARCHAR(50),
--    joining_date DATE
--);

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-01-01'),
--(2, 'Neha',  '2023-02-20'),
--(3, 'Raj',   '2023-03-25'),
--(4, 'Sneha', '2023-05-01'),
--(5, 'Karan', '2023-03-20');

/*
Challenge #2 (Date Logic)

HR defines an employee's Probation End Date as: Joining Date + 90 Days
Find employees whose probation period:
Has already ended
But ended less than 30 days ago

Assume today's date is: '2023-06-15'
Return: emp_name, joining_date, probation_end_date, days_since_probation_end
*/

SELECT * 
FROM
(
SELECT 
	emp_name,
	joining_date,
	DATEADD(DAY,90,joining_date) as probation_end_date,
	DATEDIFF(DAY,DATEADD(DAY,90,joining_date),'2023-06-15') as days_since_probation_end
FROM employees_date)t
WHERE days_since_probation_end > 0 AND days_since_probation_end < 30;

--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-01-10'),
--(2, 'Neha',  '2023-01-25'),
--(3, 'Raj',   '2023-02-05'),
--(4, 'Sneha', '2023-03-01'),
--(5, 'Karan', '2023-03-20'),
--(6, 'Pooja', '2023-04-15');

/*
🔥 Challenge #3 (Much Harder)
SQL Task: Find employees who joined in the same calendar month and year as at least one other employee.
Return: emp_name, joining_date, joining_month, joining_year
Rules
- Don't return employees who are alone in their month.
- Return all employees belonging to months having 2+ joiners.
*/

SELECT 
	e.emp_name,
	e.joining_date,
	DATENAME(MONTH,e.joining_date) as joining_month,
	DATENAME(YEAR, e.joining_date) as joining_year
FROM employees_date as e
JOIN (SELECT 
	DATENAME(MONTH,joining_date) as joining_month,
	DATENAME(YEAR, joining_date) as joining_year
FROM employees_date
GROUP BY DATENAME(MONTH,joining_date),DATENAME(YEAR, joining_date)
HAVING COUNT(*) >= 2)t
ON DATENAME(MONTH,e.joining_date) = t.joining_month AND  DATENAME(YEAR, e.joining_date) = t.joining_year;

/*
Challenge #4 (Harder)
This one introduces a very common reporting requirement.
SQL Task - Find employees who joined in the last 30 days of their joining year.
Example:
If employee joined in: 2023-12-10
Year ends: 2023-12-31
Days remaining: 21
Include them.
*/

--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-12-10'),
--(2, 'Neha',  '2023-11-15'),
--(3, 'Raj',   '2023-12-25'),
--(4, 'Sneha', '2023-01-05'),
--(5, 'Karan', '2023-12-02');

SELECT * FROM employees_date;
SELECT
* FROM
(SELECT 
	emp_name,
	joining_date,
	DATEDIFF(DAY,joining_date,DATEADD(MONTH,11,EOMONTH(DATENAME(YEAR,joining_date)))) as days_until_year_end
FROM employees_date)t
WHERE days_until_year_end <= 30;
-- using DATEFROMPARTS
SELECT
* FROM
(SELECT 
	emp_name,
	joining_date,
	DATEDIFF(DAY,joining_date,DATEFROMPARTS(YEAR(joining_date),12,31)) as days_until_year_end
FROM employees_date)t
WHERE days_until_year_end <= 30;

/*
🔥 Challenge #5 (EOMONTH + DATEADD + DATEDIFF)
Scenario: The company reviews employee performance at the end of the month following their joining month.
SQL Task - Assume today's date is: '2023-05-15'
Find employees whose review date is due within the next 20 days.
*/

--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-03-15'),
--(2, 'Neha',  '2023-04-10'),
--(3, 'Raj',   '2023-02-20'),
--(4, 'Sneha', '2023-01-25'),
--(5, 'Karan', '2023-04-28');

SELECT * FROM
(
SELECT 
	emp_name,
	joining_date,
	EOMONTH(DATEADD(MONTH,1,joining_date)) as review_date,
	DATEDIFF(DAY,'2023-05-15',EOMONTH(DATEADD(MONTH,1,joining_date))) as days_until_review
FROM  employees_date
)t
WHERE days_until_review > 0 AND days_until_review < 20;

/*
🔥 Challenge #6 (Noticeably Harder)
This one introduces DATEPART + aggregation + join-back-to-details, similar to the pattern you rediscovered earlier.
SQL Task: Find employees who joined in the same quarter and year as at least one other employee.
Rules:
- Return employees belonging to quarters having 2 or more employees.
- Return the employee rows, not just the quarter.
*/

--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-01-10'),
--(2, 'Neha',  '2023-03-20'),
--(3, 'Raj',   '2023-04-15'),
--(4, 'Sneha', '2023-05-05'),
--(5, 'Karan', '2023-09-01'),
--(6, 'Pooja', '2024-01-10');

WITH CTE_Year_quater AS
(
SELECT 
	YEAR(joining_date) as joining_year,
	DATEPART(QUARTER, joining_date) as joining_quarter
FROM employees_date
GROUP BY YEAR(joining_date), DATEPART(QUARTER, joining_date)
HAVING COUNT(*) >=2)

, CTE_main_enhanced AS
(
SELECT 
	emp_name,
	joining_date,
	YEAR(joining_date) as joining_year,
	DATEPART(QUARTER, joining_date) as joining_quarter
FROM employees_date
)
SELECT CM.emp_name, CM.joining_date, CM.joining_year, CM.joining_quarter
FROM CTE_main_enhanced as CM
JOIN CTE_Year_quater as CYQ
ON CM.joining_year = CYQ.joining_year AND CM.joining_quarter = CYQ.joining_quarter;

/*
🔥 Challenge #7 (Hard)

This one mixes: EOMONTH, DATEDIFF, DATEPART, Business logic
SQL Task: The company considers an employee a "Late-Year Joiner" if they joined in the last 15 days of any month.
Find all such employees.
*/

--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-01-20'),
--(2, 'Neha',  '2023-02-10'),
--(3, 'Raj',   '2023-03-25'),
--(4, 'Sneha', '2023-04-16'),
--(5, 'Karan', '2023-05-30'),
--(6, 'Pooja', '2023-06-14');

SELECT 
	*,
	CASE 
		WHEN days_until_month_end < 15 THEN 'Late-Year Joiner'
		ELSE 'Joined on Time'
	END AS	status
FROM 
(SELECT 
	emp_name,
	joining_date,
	DATEDIFF(DAY,joining_date,EOMONTH(joining_date)) as days_until_month_end
FROM employees_date)t;

/*
Scenario: Employees become eligible for annual appraisal exactly 1 year after joining.
The HR team starts the appraisal process 30 days before the eligibility date.
Assume today's date is: '2024-06-15'
Find employees whose appraisal process should start today.
*/
--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-07-15'),
--(2, 'Neha',  '2023-06-20'),
--(3, 'Raj',   '2023-07-10'),
--(4, 'Sneha', '2022-12-01'),
--(5, 'Karan', '2023-07-15'),
--(6, 'Pooja', '2023-08-01');

SELECT 
	*
FROM
(
SELECT 
	emp_name,
	joining_date,
	DATEADD(YEAR,1,joining_date) as eligibility_date,
	DATEADD(DAY,-30,DATEADD(YEAR,1,joining_date)) as appraisal_start_date
FROM employees_date
)t
WHERE appraisal_start_date ='2024-06-15';

/*
🔥 Challenge #9 (Dirty Data Cleaning)
Scenario: You receive employee data from an external system.
Unfortunately, dates are stored as strings, and some rows contain invalid dates.
You need to identify only the valid records.
*/

--CREATE TABLE employee_import (
--    emp_id INT,
--    emp_name VARCHAR(50),
--    joining_date_str VARCHAR(20)
--);

--INSERT INTO employee_import VALUES
--(1, 'Amit',  '2023-05-15'),
--(2, 'Neha',  '2023-02-29'),
--(3, 'Raj',   '2024-02-29'),
--(4, 'Sneha', '15/08/2023'),
--(5, 'Karan', '2023-13-10'),
--(6, 'Pooja', '2023-12-01');

SELECT 
	emp_name,
	joining_date_str,
	CAST(joining_date_str AS date) as joining_date
FROM employee_import
WHERE ISDATE(joining_date_str) = 1;

/*
🔥 Challenge #10 (DATETRUNC + Aggregation)
Scenario
Management wants to know how many employees joined each month.
However, they don't want:
2023-01-10
2023-01-25
2023-01-30
as separate dates.
They want all these grouped under: 2023-01-01 (the beginning of the month).
*/

--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-01-10'),
--(2, 'Neha',  '2023-01-25'),
--(3, 'Raj',   '2023-02-05'),
--(4, 'Sneha', '2023-02-15'),
--(5, 'Karan', '2023-02-20'),
--(6, 'Pooja', '2023-03-01'),
--(7, 'Vikas', '2023-03-18');

SELECT
	month_start_date,
	COUNT(*) as employee_count
FROM
(
	SELECT 
	*,
	DATETRUNC(MONTH,joining_date) as month_start_date
FROM employees_date
)t
GROUP BY month_start_date;

/*
🔥 Challenge #11 (Formatting & Reporting)
Scenario
The HR team wants employee joining dates displayed in multiple formats for reports.
*/
--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-01-10'),
--(2, 'Neha',  '2023-08-15'),
--(3, 'Raj',   '2024-02-29'),
--(4, 'Sneha', '2023-12-05');

SELECT 
	emp_name,
	joining_date,
	FORMAT(joining_date,'dd-MMM-yyyy') as formatted_date,
	FORMAT(joining_date,'MMM yyyy') as month_year
FROM employees_date;

/*
🔥 Final Date Challenge #12 (Mixed Concepts)
Scenario
Employees become eligible for contract renewal at the end of the month in which they complete 2 years in the company.
The HR team wants to identify employees whose contract renewal is due within the next 45 days.
Assume today's date is: '2025-06-15'
*/
--TRUNCATE TABLE employees_date;

--INSERT INTO employees_date VALUES
--(1, 'Amit',  '2023-05-20'),
--(2, 'Neha',  '2023-06-10'),
--(3, 'Raj',   '2023-07-25'),
--(4, 'Sneha', '2022-12-15'),
--(5, 'Karan', '2023-05-01'),
--(6, 'Pooja', '2023-08-12');

SELECT
	*,
	CASE 
		WHEN days_until_renewal < 0 THEN 'Expired'
		WHEN days_until_renewal >=0 AND days_until_renewal <=45 THEN 'Due Soon'
		WHEN days_until_renewal > 45 THEN 'Future'
	END AS Status
FROM
(
SELECT 
	emp_name,
	joining_date,
	EOMONTH(DATEADD(YEAR,2,joining_date)) as renewal_date,
	DATEDIFF(DAY,'2025-06-15',EOMONTH(DATEADD(YEAR,2,joining_date))) as days_until_renewal
FROM employees_date)t;