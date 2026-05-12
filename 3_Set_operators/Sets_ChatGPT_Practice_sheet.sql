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

/*
Challenge #5 (Advanced Set Thinking)
Find employee names that: Exist in both tables BUT with different casing
*/
SELECT @@collation_database;
INSERT INTO employees_current VALUES ('Raj');
WITH CTE_employees_current AS (
    SELECT emp_name, COUNT(*) AS current_count FROM employees_current GROUP BY emp_name
),
CTE_employees_old AS (
    SELECT emp_name, COUNT(*) AS old_count FROM employees_old GROUP BY emp_name
)
SELECT 
    c.emp_name, c.current_count, o.old_count
FROM CTE_employees_current c
JOIN CTE_employees_old o ON c.emp_name = o.emp_name
WHERE c.current_count <> o.old_count;

/*
Challenge #6 (UNION ALL + Source Tracking)
Combine employee names from: employees_current, employees_old
But also show: 👉 Which table each employee came from
*/
SELECT emp_name, 'Current' as source_table from employees_current
UNION ALL
SELECT emp_name, 'Old' as source_table from employees_old;

/*
Challenge #7 (EXCEPT + INTERSECT Combo Thinking)
Find employee names that: Exist in employees_current AND also exist in employees_old BUT exclude employees whose name starts with 'S'
*/
SELECT emp_name
FROM
(
	SELECT emp_name from employees_current
	INTERSECT
	SELECT emp_name from employees_old
)t
WHERE emp_name not like 's%';

/*
Challenge #8
Find employee names that: Exist only in one table AND appear more than once in that table
*/
-- INSERT INTO employees_current VALUES ('Amit');
-- INSERT INTO employees_old VALUES ('Pooja');
-- My Solution: Its wrong because except also removes duplicates
SELECT emp_name, COUNT(*) as total_count
FROM
(
(SELECT emp_name from employees_current
EXCEPT
SELECT emp_name from employees_old)
UNION ALL
(SELECT emp_name from employees_old
EXCEPT
SELECT emp_name from employees_current )
)t
GROUP BY emp_name
HAVING COUNT(*) > 1;

-- chatgpt solution: 
WITH current_counts AS (
    SELECT 
        emp_name,
        COUNT(*) AS total_count,
        'Current' AS source_table
    FROM employees_current
    GROUP BY emp_name
    HAVING COUNT(*) > 1
),

old_counts AS (
    SELECT 
        emp_name,
        COUNT(*) AS total_count,
        'Old' AS source_table
    FROM employees_old
    GROUP BY emp_name
    HAVING COUNT(*) > 1
)

SELECT *
FROM current_counts
WHERE emp_name NOT IN (
    SELECT emp_name FROM employees_old
)

UNION ALL

SELECT *
FROM old_counts
WHERE emp_name NOT IN (
    SELECT emp_name FROM employees_current
);

/*
Final Challenge #9 (Set Reconciliation Problem)
Scenario
You have: Current employee records, Old employee records
You need to identify: 👉 Employees whose status changed.
Return employee names that: Exist in both tables BUT their occurrence count changed between old and current datasets
*/
-- INSERT INTO employees_current VALUES ('Raj');
-- INSERT INTO employees_current VALUES ('Raj');
-- INSERT INTO employees_old VALUES ('Raj');
-- INSERT INTO employees_old VALUES ('RAJ')


WITH current_counts AS (
    SELECT 
        emp_name,
        COUNT(*) AS current_total_count
    FROM employees_current
    GROUP BY emp_name
),
old_counts AS (
    SELECT 
        emp_name,
        COUNT(*) AS old_total_count
    FROM employees_old
    GROUP BY emp_name
)
SELECT 
    c.emp_name,
    c.current_total_count,
    o.old_total_count
FROM current_counts c
JOIN old_counts o
    ON c.emp_name = o.emp_name
WHERE c.current_total_count <> o.old_total_count;











