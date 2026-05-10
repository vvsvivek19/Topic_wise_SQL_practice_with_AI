-- ======================================================================================================================================
-- 															SETS
-- ======================================================================================================================================

/*
Challenge #1 (UNION vs UNION ALL Foundation)
Combine employees from: employees_current, employees_old
Return: All employee names
*/
-- CREATE TABLE employees_current (
--     emp_name VARCHAR(50)
-- );

-- CREATE TABLE employees_old (
--     emp_name VARCHAR(50)
-- );

-- INSERT INTO employees_current VALUES
-- ('Amit'),
-- ('Neha'),
-- ('Raj'),
-- ('Sneha');

-- INSERT INTO employees_old VALUES
-- ('Raj'),
-- ('Karan'),
-- ('Sneha'),
-- ('Pooja');

SELECT * FROM employees_current
UNION
SELECT * FROM employees_old;

SELECT * FROM employees_current
UNION ALL
SELECT * FROM employees_old;


/*
🔥 Challenge #2 (INTERSECT)
Find employee names that exist in:
BOTH employees_current AND employees_old
Return: emp_name
*/

SELECT emp_name FROM employees_current
INTERSECT 
SELECT emp_name FROM employees_old;

/*
Challenge #3 (EXCEPT)
Find employee names that: Exist in employees_current BUT NOT in employees_old
Return: emp_name
*/
SELECT emp_name FROM employees_current
EXCEPT
SELECT emp_name FROM employees_old;

/*
Challenge #4 (Set Operators + Aggregation Thinking)
Find employee names that: Exist in either table (current or old) BUT appear only once overall
Return: emp_name
*/
SELECT emp_name, COUNT(*) as total_count
FROM
(
SELECT emp_name FROM employees_current
UNION ALL
SELECT emp_name FROM employees_old
)t
GROUP BY emp_name
HAVING COUNT(*) = 1;

