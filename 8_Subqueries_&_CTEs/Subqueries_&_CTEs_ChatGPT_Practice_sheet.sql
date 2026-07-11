-- ======================================================================================================================================
-- 																		Subqueries
-- ======================================================================================================================================


CREATE TABLE employees_sub (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    manager_id INT
);

INSERT INTO employees_sub VALUES
(1,'Amit','IT',70000,3),
(2,'Neha','IT',60000,3),
(3,'Raj','IT',90000,NULL),
(4,'Sneha','HR',55000,6),
(5,'Pooja','HR',50000,6),
(6,'Vikas','HR',65000,NULL),
(7,'Karan','Finance',80000,9),
(8,'Ankit','Finance',75000,9),
(9,'Riya','Finance',85000,NULL),
(10,'Manish','Sales',45000,12),
(11,'Priya','Sales',50000,12),
(12,'Rohit','Sales',55000,NULL);

/*
================================================================================
🔥 Challenge #1 (Warm-up)
================================================================================

Business Scenario:
Management wants to know the highest salary in the company.

SQL Task:
Return the following columns:
- emp_name
- salary
- company_max_salary

Rules:
- Use a scalar subquery in the SELECT clause to fetch the company maximum.
- Do not use a window function (No OVER() clause allowed for this challenge).
*/

SELECT
	emp_name,
    salary,
    (SELECT MAX(salary) FROM employees_sub) company_max_salary
FROM employees_sub;

/*
================================================================================
🔥 Challenge #2 (Slightly Harder)
================================================================================

Now let's use a scalar subquery in the WHERE clause.

Business Scenario:
Management wants to find employees earning above the company average salary.

SQL Task:
Return the following columns:
- emp_name
- department
- salary

Rules:
- Use a scalar subquery in the WHERE clause to isolate the company average baseline.
- Do not use a window function.

Note: This is one of the most common scalar subquery interview questions!
*/

SELECT
	emp_name,
    department,
    salary
FROM employees_sub
WHERE salary > (SELECT AVG(salary) from employees_sub);

/*
================================================================================
🔥 Challenge #3 (Derived Table)
================================================================================

Now let's switch from a scalar subquery to a table subquery.

Business Scenario:
HR wants to know the average salary of each department and then display all 
employees along with their department's average salary.

SQL Task:
Return the following columns:
- emp_name
- department
- salary
- department_avg_salary

Rules:
- Prepare the department averages in a FROM clause subquery (derived table).
- Join this derived table back to the primary employees table on the department column.
- Do not use window functions.

Note: This illustrates one of the primary reasons derived tables exist: aggregating 
or preparing a structural dataset at a different granularity before joining it back 
to detail rows!
*/
-- 1st solution: Correlated subquery
SELECT
	emp_name,
    department,
    salary,
    (SELECT AVG(salary) FROM employees_sub s GROUP BY department HAVING s.department = m.department) department_avg_salary
FROM employees_sub m;

-- 2nd solution: with derived table
SELECT
	m.emp_name,
    m.department,
    m.salary,
    d.department_avg_salary
FROM employees_sub m
JOIN (
	SELECT 
		department, 
        AVG(salary) as department_avg_salary
	FROM employees_sub
    GROUP BY department
    )d
ON m.department = d.department;

CREATE TABLE projects (
    project_id INT,
    emp_id INT,
    project_name VARCHAR(50)
);

INSERT INTO projects VALUES
(1,1,'Migration'),
(2,3,'Cloud'),
(3,3,'Security'),
(4,5,'Payroll'),
(5,9,'Budget');

/*
================================================================================
🔥 Challenge #4
================================================================================

Business Scenario:
HR wants to find employees who are assigned to at least one project.

SQL Task:
Return the following columns to isolate active personnel:
- emp_name
- department

Rules:
- Use an EXISTS clause to verify the presence of matching project rows.
- Do not use a JOIN statement.
- Establish a correlated link between the inner query and the outer employee table.

Note: This is one of the most classic interview questions for EXISTS, highlighting 
a highly efficient pattern for checking existence without duplicating detail records.
*/

SELECT
	emp_name,
    department
FROM employees_sub 
WHERE EXISTS (SELECT 1 FROM projects WHERE projects.emp_id = employees_sub.emp_id);















