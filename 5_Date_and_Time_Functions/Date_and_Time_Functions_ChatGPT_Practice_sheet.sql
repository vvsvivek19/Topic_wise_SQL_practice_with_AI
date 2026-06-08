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