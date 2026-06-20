-- ======================================================================================================================================
-- 														NULL Functions and Case statements
-- ======================================================================================================================================

-- CREATE TABLE employees_null (
--     emp_id INT,
--     emp_name VARCHAR(50),
--     department VARCHAR(50),
--     salary DECIMAL(10,2),
--     bonus DECIMAL(10,2),
--     manager_name VARCHAR(50)
-- );

-- INSERT INTO employees_null VALUES
-- (1, 'Amit',  'IT',      70000, 5000,  'Rajesh'),
-- (2, 'Neha',  'HR',      60000, NULL,  'Priya'),
-- (3, 'Raj',   'Finance', 80000, 8000,  NULL),
-- (4, 'Sneha', 'IT',      75000, NULL,  NULL),
-- (5, 'Karan', 'Admin',   50000, 3000,  'Anil');


/*
🔥 Challenge #1 (NULL Handling Basics)
Scenario: HR data is incomplete.
Some employees: have no bonus assigned and some have no manager assigned
SQL Task - Return:
emp_name, bonus, bonus_after_null_handling, manager_name, manager_display
Rules:
- Replace NULL bonus with 0
- Replace NULL manager with: 'Not Assigned'
*/
SELECT 
	emp_name,
    bonus,
    coalesce(bonus,0) as bonus_after_null_handling,
    manager_name,
    IFNULL(manager_name,'Not Assigned') AS manager_display
FROM employees_null;

/*
================================================================================
🔥 Challenge #2 (NULLIF — One of the Most Important Use Cases)
================================================================================

Scenario:
The company stores:
- projects_completed
- working_days

To calculate productivity:
- projects_completed / working_days

But some employees have:
- working_days = 0

...which causes a divide-by-zero error.
*/

-- CREATE TABLE employee_productivity (
--     emp_id INT,
--     emp_name VARCHAR(50),
--     projects_completed INT,
--     working_days INT
-- );

-- INSERT INTO employee_productivity VALUES
-- (1, 'Amit', 20, 10),
-- (2, 'Neha', 15, 0),
-- (3, 'Raj',  12, 6),
-- (4, 'Sneha', 8, 0),
-- (5, 'Karan', 5, 5);

SELECT 
	emp_name,
    projects_completed,
    working_days,
    projects_completed/NULLIF(working_days,0) as productivity
FROM employee_productivity;

/*
================================================================================
🔥 Challenge #3 (IS NULL / CASE)
================================================================================

SQL Task:
Classify employees into categories based on the following rules.

Rules:
- If manager_name IS NULL 
    -> 'Unmanaged'
- Else if bonus IS NULL 
    -> 'No Bonus'
- Else 
    -> 'Normal'

Return Columns:
- emp_name
- manager_name
- bonus
- employee_status
*/

SELECT 
	emp_name,
    manager_name,
    bonus,
    CASE 
		WHEN manager_name IS NULL AND bonus IS NULL THEN 'Unmanaged & No Bonus'
        WHEN manager_name is null then 'Unmanaged'
        WHEN bonus is null then 'No Bonus'
        ELSE 'Normal'
	END as employee_status
FROM employees_null;

/*
================================================================================
🔥 Challenge #4 (NULL and Aggregates)
================================================================================

Scenario:
Management wants department-wise bonus statistics.
But some employees don't have bonuses assigned (NULL).
You need to understand how aggregate functions behave with NULLs.

SQL Task:
Return the following columns:
- department
- total_employees
- employees_with_bonus
- avg_bonus
- avg_bonus_treating_null_as_zero
*/

-- CREATE TABLE employee_bonus (
--     emp_id INT,
--     emp_name VARCHAR(50),
--     department VARCHAR(50),
--     bonus DECIMAL(10,2)
-- );

-- INSERT INTO employee_bonus VALUES
-- (1, 'Amit',  'IT',      5000),
-- (2, 'Neha',  'IT',      NULL),
-- (3, 'Raj',   'HR',      3000),
-- (4, 'Sneha', 'HR',      NULL),
-- (5, 'Karan', 'Finance', NULL),
-- (6, 'Pooja', 'Finance', NULL);

SELECT 
	department,
    COUNT(*) as total_employees,
	SUM(CASE WHEN bonus is not null then 1 ELSE 0 END) AS employees_with_bonus,
    AVG(bonus) as avg_bonus,
    AVG(coalesce(bonus,0)) as avg_bonus_treating_null_as_zero
FROM employee_bonus
GROUP BY department;

/*
================================================================================
🔥 Challenge #5 (Difficulty ↑)
================================================================================

This one combines:
- NULLIF
- COALESCE
- CASE
- Aggregation

SQL Task:
Find departments where all employees have NULL bonuses.

Return Columns:
- department
- employee_count
- status

Where:
- status = 'No Bonus Department' (if every employee in that department has a NULL bonus).
*/

SELECT * FROM employee_bonus;
SELECT * FROM
(
	SELECT
		department,
		count(*) as employee_count,
		SUM(CASE WHEN bonus is not null THEN 0 ELSE 1 END) as status
	FROM employee_bonus
	GROUP BY department
)t
WHERE employee_count = status;

/*
================================================================================
🔥 Challenge #6 (Difficulty ↑↑)
================================================================================

This one combines:
- COALESCE
- CASE
- Aggregation
- Business logic

SQL Task:
Calculate department compensation based on the following parameters.

Rules:
- Total Compensation = Salary + Bonus
- Note: NULL Bonus = 0

Return Columns:
- department
- total_compensation
- compensation_status

Where compensation_status is determined by:
- 'High Compensation'   -> total_compensation > 150000
- 'Normal Compensation' -> otherwise
*/

SELECT * FROM employees_null;
SELECT
	*,
    CASE 
		WHEN total_compensation > 150000 THEN 'High Compensation'
        ELSE 'Normal Compensation'
	END as compensation_status
FROM
(		
	SELECT 
		department,
		SUM(IFNULL(salary,0.00)+IFNULL(bonus,0.00)) as total_compensation
	FROM employees_null
	GROUP BY department
)t;

/*
================================================================================
🔥 Challenge #7 (Noticeably Harder)
================================================================================

Now let's combine:
- NULL handling
- Aggregation
- HAVING
- Conditional aggregation

SQL Task:
Find departments where more than 50% of employees have NULL bonuses.

Return Columns:
- department
- total_employees
- employees_with_null_bonus
- null_bonus_percentage
*/
SELECT * FROM employees_null;
SELECT 
	*,
    CONCAT(CAST((employees_with_null_bonus * 1.0/total_employees)*100 AS CHAR),'%') as null_bonus_percentage
FROM
(
SELECT 
	department,
    COUNT(*) as total_employees,
    SUM(CASE WHEN bonus is null THEN 1 ELSE 0 end) as employees_with_null_bonus
FROM employees_null
GROUP BY department
)t
WHERE (employees_with_null_bonus * 1.0 /total_employees)*100 > 50.00;































