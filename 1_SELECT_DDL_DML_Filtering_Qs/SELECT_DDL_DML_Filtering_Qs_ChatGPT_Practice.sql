-- ======================================================================================================================================
-- 															SELECT, DDL, DML, Filtering Qs
-- ======================================================================================================================================

-- CREATE TABLE employees (
--    emp_id INT
--    emp_name VARCHAR(50),
--    department VARCHAR(50),
--    salary INT
-- );

-- INSERT INTO employees (emp_id, emp_name, department, salary) VALUES
-- (1, 'Amit', 'IT', 60000),
-- (2, 'Neha', 'HR', 45000),
-- (3, 'Raj', 'IT', 70000),
-- (4, 'Sneha', 'Finance', 50000),
-- (5, 'Karan', 'IT', 48000),
-- (6, 'Pooja', 'HR', 52000);

SELECT * FROM employees;
/*Find all employees who: Have salary greater than 50,000, Belong to the "IT" department*/
SELECT emp_id, emp_name, salary FROM employees 
WHERE department = 'IT' AND salary > 50000
ORDER BY salary DESC;

/*Find unique departments where: Salary is greater than or equal to 50,000 Return: Only department names Sort results alphabetically*/
SELECT DISTINCT department 
FROM employees
WHERE salary >= 50000
ORDER BY department ASC;

/*Find departments where: The average salary is greater than 55,000
Return: department, avg_salary
Sort results by avg_salary descending*/
SELECT
	department,
	AVG(salary) as avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 55000
ORDER BY avg_salary DESC;

/*Find departments where: The number of employees is at least 2 AND the minimum salary in that department is greater than 45,000
Return: department, employee_count, min_salary
Sort by: employee_count DESC*/
SELECT
	department,
	COUNT(*) as employee_count,
	MIN(salary) as min_salary
FROM employees
GROUP BY department
HAVING MIN(salary) > 45000 AND COUNT(department) >= 2
ORDER BY employee_count DESC;

/*Find employees who: Have salary between 45,000 and 65,000 AND belong to either 'IT' or 'HR'
Return: emp_name, department, salary
Sort by: salary ascending*/
SELECT 
	emp_name,
	department,
	salary
FROM employees
WHERE salary BETWEEN 45000 AND 65000
AND 
department IN ('IT','HR')
ORDER BY salary asc;

/*
Find employees who: Name starts with 'A' OR ends with 'a' AND salary is greater than 50,000
Return: emp_name, salary
Sort by: emp_name alphabetically
*/
SELECT 
	emp_name,
	salary
FROM employees
WHERE (emp_name like 'A%' OR emp_name like '%a') AND salary > 50000
ORDER BY emp_name;

/*
Update salary by +10% for employees who: Belong to 'IT' AND currently have salary less than 60,000
*/
START TRANSACTION;
UPDATE employees 
SET salary = salary * 1.10
WHERE department = 'IT' AND salary < 60000;
-- ROLLBACK;
-- COMMIT;

/*
Delete employees who: Belong to 'HR' AND have salary less than 50,000
*/
START TRANSACTION;

-- Step 1: Check rows BEFORE delete
SELECT * FROM employees WHERE department = 'HR' AND salary < 50000;

-- Step 2: Perform delete
DELETE FROM employees WHERE department = 'HR' AND salary < 50000;

-- Step 3: Verify AFTER delete (within transaction)
SELECT * FROM employees WHERE department = 'HR' AND salary < 50000;

-- Step 4: Decide
-- ROLLBACK; -- if not correct
-- COMMIT;   -- if correct

/*
Remove all records from the employees table Use the most efficient method
*/
START TRANSACTION;

-- Wait for exactly 2 seconds
-- WAITFOR DELAY '00:00:02';
-- PRINT 'Transaction started';

-- before truncate
SELECT * FROM employees;

-- Wait for exactly 3 seconds
-- WAITFOR DELAY '00:00:02';
-- PRINT 'Before truncate';

-- truncate table
truncate table employees;
-- Wait for exactly 3 seconds
-- WAITFOR DELAY '00:00:02';
-- PRINT ' truncate Done';

-- after truncate truncate
SELECT * FROM employees;
-- Wait for exactly 3 seconds
-- WAITFOR DELAY '00:00:02';
-- PRINT 'After truncate';

ROLLBACK;

/*
Find departments where: Only consider employees with salary greater than 40,000 Department must have more than 2 employees AND maximum salary in that department is at least 70,000
Return: department, employee_count, max_salary
Sort by: max_salary DESC
*/
SELECT 
	department,
	COUNT(*) as employee_count,
	MAX(salary) as max_salary
FROM employees
WHERE salary > 40000
GROUP BY department
HAVING COUNT(*) > 2 AND MAX(salary) >= 70000
ORDER BY max_salary DESC;

/*
Update salaries as follows:
If department = 'IT' ? increase by 10%
If department = 'HR' ? increase by 5%
Others ? no change
*/

START TRANSACTION;

-- Step 1: Check rows BEFORE delete
SELECT * FROM employees;

-- Step 2: Perform Update
UPDATE employees
SET salary = CASE 
	WHEN department = 'IT' THEN salary * 1.10
	WHEN department = 'HR' THEN salary * 1.05
END
WHERE department IN ('IT','HR');

-- Step 3: Verify Update (within transaction)
SELECT * FROM employees;

-- Step 4: Decide
-- ROLLBACK; -- if not correct
-- COMMIT;   -- if correct

/*Delete employees who:
Have duplicate salaries (same salary as someone else)
BUT keep only one employee per salary
*/
START TRANSACTION;

-- Step 1: Check rows BEFORE delete
SELECT * FROM employees_dup;

-- Step 2: Perform DELETE
DELETE FROM employees_dup
WHERE emp_id NOT IN (SELECT 
	MIN(emp_id)
FROM employees_dup
GROUP BY Salary);

-- Step 3: Verify DELETE (within transaction)
SELECT * FROM employees_dup;

-- Step 4: Decide
-- ROLLBACK; -- if not correct
-- COMMIT;   -- if correct

/*
Find employees who: Have salary greater than the average salary of all employees
Return: emp_id, emp_name, salary
Sort by: salary DESC
*/
SELECT 
    emp_id,
    emp_name,
    salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

/*
Find departments where: The average salary of that department is greater than the overall average salary of the company
Return: department, avg_salary
Sort by: avg_salary DESC
*/
SELECT 
	department,
	AVG(salary) as department_avg
FROM employees
GROUP BY department
HAVING AVG(salary) > (SELECT AVG(salary) FROM employees)
ORDER BY department_avg;

/*
Find employees who: Do NOT belong to departments where minimum salary is less than 50,000
Return: emp_name, department, salary
Sort by: salary DESC
*/
SELECT 
	emp_name,department,salary
FROM employees
WHERE department not in (SELECT department FROM employees GROUP BY department HAVING MIN(Salary) < 50000)
ORDER BY salary DESC;

/*
-- Correlated Subquery: https://www.datacamp.com/tutorial/correlated-subquery
Find employees who: Earn more than the average salary of their own department
Return: emp_name, department, salary
Sort by: salary DESC
*/
SELECT e1.emp_name, e1.department, e1.salary 
FROM employees as e1 
WHERE e1.salary > (SELECT AVG(e2.salary) FROM employees as e2 where e1.department = e2.department);

/*Find employees who: Have the highest salary in their department
Return: emp_name, department, salary
Sort by: salary DESC*/
SELECT e1.emp_name, e1.department, e1.salary 
FROM employees as e1 WHERE e1.salary = 
(SELECT MAX(e2.salary) FROM employees as e2 where e1.department = e2.department);

/*
Find employees who: Earn more than the average salary of their department AND also earn less than the overall maximum salary in the company
Return: emp_name, department, salary
Sort by: salary DESC
*/
SELECT e1.emp_name, e1.department, e1.salary FROM employees as e1
WHERE e1.salary > (select avg(salary) from employees e2 where e2.department = e1.department) 
AND e1.salary < (SELECT MAX(salary) from employees);

/*
Challenge #19 (Twist — Conditional Aggregation)
SQL Task - Find departments where: Number of employees earning more than 50,000 is at least 2
Return: department, high_earners_count
Sort by: high_earners_count DESC
*/
SELECT department, count(*) as high_earners_count
FROM employees
WHERE Salary > 50000
GROUP BY department
HAVING count(*) >= 2
ORDER BY high_earners_count;

/*
Find employees who: Belong to departments where total salary is greater than 120,000
Return: emp_name, department, salary
Sort by: department, then salary DESC
*/
SELECT emp_name, department, salary 
FROM employees WHERE department IN (
SELECT department
FROM employees
GROUP BY department
HAVING SUM(salary) > 120000)
order by department,salary desc;