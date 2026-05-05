-- ======================================================================================================================================
-- 															JOINS
-- ======================================================================================================================================
-- CREATE TABLE employees_j (
--     emp_id INT,
--     emp_name VARCHAR(50),
--     dept_id INT,
--     salary INT
-- );

-- CREATE TABLE departments_j (
--     dept_id INT,
--     dept_name VARCHAR(50),
--     location VARCHAR(50)
-- );

-- INSERT INTO employees_j VALUES
-- (1, 'Amit', 101, 60000),
-- (2, 'Neha', 102, 50000),
-- (3, 'Raj', 101, 70000),
-- (4, 'Sneha', 103, 65000),
-- (5, 'Karan', NULL, 48000),
-- (6, 'Pooja', 104, 52000),
-- (7, 'Vikas', 101, 55000),
-- (8, 'Anjali', 105, 58000); -- dept_id doesn't exist

-- INSERT INTO departments_j VALUES
-- (101, 'IT', 'Bangalore'),
-- (102, 'HR', 'Delhi'),
-- (103, 'Finance', 'Mumbai'),
-- (104, 'Admin', 'Pune'),
-- (106, 'Legal', 'Chennai'); -- no employees

/*
Challenge #1 (Revised — INNER JOIN)
Find: Employee name, Department name, Location. Only include employees who have valid department mapping
Return: emp_name, dept_name location
*/
SELECT e.emp_name, d.dept_name, d.location
FROM employees_j as e 
INNER JOIN departments_j as d ON e.dept_id = d.dept_id;

/*
Challenge #2 (LEFT JOIN — Behavior Shift)
Find: All employees, Along with their department name and location
Even if they don’t have a valid department
*/
SELECT e.emp_name, d.dept_name, d.location
FROM employees_j as e 
LEFT JOIN departments_j as d ON e.dept_id = d.dept_id;

/*
Challenge #3 (LEFT JOIN + Filtering — Classic Trap)
Find: Employees who do NOT have a valid department
*/
SELECT e.emp_name
FROM employees_j as e 
LEFT JOIN departments_j as d ON e.dept_id = d.dept_id
WHERE d.dept_name is null;

/*
Challenge #4 (RIGHT JOIN)
Find: All departments, Along with employee names. 👉 Include departments with no employees
*/
SELECT d.dept_name, e.emp_name FROM departments_j d LEFT JOIN employees_j e ON d.dept_id = e.dept_id;

/* 
Challenge #5 (FULL JOIN — Next Level)
Find: All employees, All departments
👉 Include: Unmatched employees, Unmatched departments
*/

SELECT e.emp_name, d.dept_name
FROM employees_j e LEFT JOIN departments_j d  ON e.dept_id = d.dept_id
UNION
SELECT e.emp_name, d.dept_name
FROM employees_j e RIGHT JOIN departments_j d  ON e.dept_id = d.dept_id WHERE e.emp_id IS NULL;

/*
Challenge #6 (LEFT ANTI JOIN — Formalizing Pattern)
Find: Departments that do NOT have any employees
Return - dept_name
*/
SELECT d.dept_name FROM departments_j d
LEFT JOIN employees_j e  ON d.dept_id = e.dept_id WHERE e.emp_id IS NULL;

/*
Challenge #7 (RIGHT ANTI JOIN — Reverse)
Find: 👉 Employees who do NOT belong to any valid department
*/
SELECT e.* FROM employees_j e
LEFT JOIN departments_j d  ON d.dept_id = e.dept_id WHERE d.dept_id IS NULL;


/*
Challenge #8 (FULL ANTI JOIN — Rare but Powerful)
Find: 👉 All records that do NOT have a match on either side
*/
SELECT e.emp_name, d.dept_name FROM employees_j e
LEFT JOIN departments_j d ON e.dept_id = d.dept_id WHERE d.dept_id IS NULL
UNION
SELECT e.emp_name, d.dept_name FROM departments_j d
LEFT JOIN employees_j e ON e.dept_id = d.dept_id WHERE e.emp_id IS NULL;

/*
Challenge #9 (CROSS JOIN — Final Type)
Generate All possible combinations of: Employees, Departments
*/
SELECT emp_name, dept_name FROM employees_j
CROSS JOIN departments_j;


















