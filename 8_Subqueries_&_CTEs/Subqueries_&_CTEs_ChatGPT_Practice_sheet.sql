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

/*
================================================================================
🔥 Challenge #5 — NOT EXISTS
================================================================================

Business Scenario:
HR wants to identify employees who are not assigned to any project.

SQL Task:
Return the following columns to isolate unallocated personnel:
- emp_name
- department

Rules:
- Use a NOT EXISTS clause to filter out anyone present in the projects table.
- Do not use a JOIN statement.
- Do not use a NOT IN clause (which can fail completely if null values exist).
- Correlate the inner table with the outer employee table.

--------------------------------------------------------------------------------
🔥 Final Challenge — The Correlated Subquery Classic
--------------------------------------------------------------------------------

This is one of the most frequently asked SQL interview questions of all time.

Business Scenario:
Management wants to identify employees who earn more than the average salary 
of their own department.

SQL Task:
Return the following columns:
- emp_name
- department
- salary

Rules:
- Use a correlated subquery in the WHERE clause.
- Do not use a window function.
- Do not use a derived table.
- The inner query must depend row-by-row on the current row of the outer query.
*/

SELECT
	emp_name,
    department
FROM employees_sub 
WHERE NOT EXISTS (SELECT 1 FROM projects WHERE projects.emp_id = employees_sub.emp_id);

SELECT
	emp_name,
    department,
    salary
FROM employees_sub m
WHERE salary > (SELECT AVG(salary) FROM employees_sub s WHERE s.department = m.department);


/*
================================================================================
Challenge 1 — IN
================================================================================

Business Scenario:
Return employees who belong to departments that have at least one employee 
earning more than ₹80,000.

SQL Task:
Return the employee detail rows where the department identifier matches the list 
of departments containing high-earning personnel.

Rules:
- Use an independent subquery within a WHERE ... IN clause.
- Ensure the inner query targets the list of department names or IDs based 
  on the ₹80,000 salary filter threshold.
*/

/*
================================================================================
Challenge 2 — ANY
================================================================================

Business Scenario:
Return employees whose salary is greater than at least one salary in the HR department.

SQL Task:
Isolate employee rows where the individual compensation exceeds the minimum threshold 
found within the human resources team.

Rules:
- Use the quantified comparison operator: > ANY (subquery)
- The subquery must isolate all salaries explicitly belonging to the 'HR' department.
*/

/*
================================================================================
Challenge 3 — ALL
================================================================================

Business Scenario:
Return employees whose salary is greater than every salary in the HR department.

SQL Task:
Isolate employee records where the individual compensation strictly exceeds the 
absolute maximum benchmark within the human resources team.

Rules:
- Use the quantified comparison operator: > ALL (subquery)
- The subquery must isolate all salaries explicitly belonging to the 'HR' department.
- Note the operational shift here: while > ANY targets greater than the minimum, 
  > ALL demands the value be greater than the maximum!
*/


-- ======================================================================================================================================
--                                                             CTEs
-- ======================================================================================================================================

/*
================================================================================
🔥 Challenge #1 (Warm-up) — Common Table Expressions (CTEs)
================================================================================

Business Requirement:
Show employees whose salary is greater than the company average.

SQL Task:
Create a Common Table Expression (CTE) that calculates and isolates the single, 
global company average salary first. Then, reference that CTE in your primary 
query to perform the filtering and map the metrics side-by-side.

Columns to Return:
- emp_name
- department
- salary
- company_avg_salary

Rules:
- You must use a WITH clause to initialize the CTE container before the main query.
- Do not write the scalar subquery directly inline inside the WHERE clause.
- Ensure the final result grid only includes records where salary strictly 
  exceeds the calculated company average.
*/

WITH CTE_company_avg AS
(
SELECT
	AVG(salary) as company_avg_salary
FROM employees_sub)
SELECT
	emp_name,
    department,
    salary,
    (SELECT company_avg_salary FROM CTE_company_avg) company_avg_salary
FROM employees_sub
WHERE salary > (SELECT company_avg_salary FROM CTE_company_avg);

/*
================================================================================
🔥 Challenge #2 — Multiple CTEs
================================================================================

Business Scenario:
Management wants to identify departments whose average salary is above the 
company average salary.

SQL Task:
Construct a modular query utilizing two distinct Common Table Expressions (CTEs) 
chained together sequentially. The first CTE isolates the global corporate baseline, 
the second calculates localized department metrics, and the outer query handles 
the cross-granularity filter evaluation.

Columns to Return:
- department
- department_avg_salary
- company_avg_salary

Rules:
- Initialize the query using a single WITH clause containing two comma-separated CTE blocks.
  - CTE 1: Compute the global company_avg_salary across the entire employees_sub table.
  - CTE 2: Group by department to calculate the department_avg_salary for each team.
- Combine and filter these datasets in the final query using a cross-join or relational key join.
- Restrict the output grid exclusively to rows where department_avg_salary strictly 
  exceeds the company_avg_salary.
*/

WITH CTE_company_avg as
(
	SELECT AVG(salary) as company_avg_salary
    FROM employees_sub
)
, CTE_depart_avg as
(
	SELECT
		department,
        AVG(salary) as department_avg_salary
	FROM employees_sub
    GROUP BY department
)
SELECT
	da.department,
    da.department_avg_salary,
    ca.company_avg_salary
FROM CTE_depart_avg da
CROSS JOIN CTE_company_avg ca
WHERE da.department_avg_salary > ca.company_avg_salary;

/*
================================================================================
🔥 Challenge #3 (This is where CTEs shine) — The Metric Pipeline
================================================================================

Business Scenario:
Management wants to identify employees who earn above their department average, 
while projecting detailed variance analysis fields.

SQL Task:
Construct a multi-tiered data pipeline utilizing two chained Common Table 
Expressions (CTEs) to isolate team-level benchmarks, combine granular data, 
and filter outliers in the final query block.

Columns to Return:
- emp_name
- department
- salary
- department_avg_salary
- salary_difference

Rules:
- Use two CTEs initialized via a single WITH clause.
  - CTE 1 (Department Averages): Compute the average salary for each unique 
    department using a GROUP BY clause.
  - CTE 2 (Enriched Detail Staging): Read from the base employees table and 
    JOIN it directly to CTE 1 on the department key. Project the employee 
    details along with the calculated department_avg_salary.
- The Final Query:
  - Query from CTE 2.
  - Apply the mathematical variance expression: (salary - department_avg_salary) 
    aliased as salary_difference.
  - Filter the results using a WHERE clause to restrict the output grid strictly 
    to employees whose individual salary is greater than their department_avg_salary.
*/

WITH CTE_department_avgs AS
(
	SELECT
        department,
        AVG(salary) as department_avg_salary
	FROM employees_sub
    GROUP BY department
)
, CTE_salary_diff as
(
SELECT
	es.emp_name,
    es.department,
    es.salary,
    da.department_avg_salary,
    es.salary - da.department_avg_salary as salary_difference
FROM employees_sub es
JOIN CTE_department_avgs da 
ON es.department = da.department
)
SELECT
	*
FROM CTE_salary_diff
WHERE salary > department_avg_salary;

/*
================================================================================
🔥 Challenge #4 (The Last Non-Recursive One) — CTE Reusability
================================================================================

Business Scenario:
Management wants to identify departments that have:
1. More than 2 employees, and
2. An average salary above the company average.

SQL Task:
Construct a multi-tiered pipeline using three chained Common Table Expressions 
(CTEs) to isolate global metrics, aggregate departmental statistics, and handle 
the final complex multi-conditional filtering layer.

Columns to Return:
- department
- employee_count
- department_avg_salary
- company_avg_salary

Rules:
- Use three chained CTEs initialized via a single WITH clause.
  - CTE 1 (Company Average): Calculate the single, global company average 
    salary across all records.
  - CTE 2 (Department Statistics): Group by department to calculate the 
    employee count (COUNT) and the department average salary (AVG).
  - CTE 3 (Final Filtered Result): Chain from the previous blocks, combining the 
    departmental stats with the global benchmark to isolate teams meeting 
    both target parameters.
- The Outer Primary Query: 
  - Select all columns directly from your final filtered CTE to display 
    the completed asset.
*/

WITH CTE_company_avg as
(
	SELECT
		AVG(salary) as company_avg_salary
	FROM employees_sub
)
, CTE_department_statistics as
(
	SELECT
		department,
        COUNT(*) as total_employees,
        AVG(salary) as department_avg_salary
	FROM employees_sub
    GROUP BY department
    HAVING COUNT(*) > 2 AND (AVG(salary) > (SELECT company_avg_salary FROM CTE_company_avg))
)

SELECT
	*
FROM CTE_department_statistics;

CREATE TABLE employee_hierarchy (
    emp_id INT,
    emp_name VARCHAR(50),
    manager_id INT
);

INSERT INTO employee_hierarchy VALUES
(1,'CEO',NULL),
(2,'CTO',1),
(3,'CFO',1),
(4,'IT Manager',2),
(5,'HR Manager',3),
(6,'Developer A',4),
(7,'Developer B',4),
(8,'HR Executive',5),
(9,'Intern',6);

/*
================================================================================
🔥 Challenge: Recursive CTE — Hierarchical Organization Tree Levels
================================================================================

Business Requirement:
Map out the organizational hierarchy of the company, tracking the direct reporting 
lines and calculating the explicit management depth level for each employee.

SQL Task:
Construct a Recursive Common Table Expression (CTE) to traverse the reporting chain 
from the absolute root node down to the bottom tier.

Columns to Return:
- emp_id
- emp_name
- manager_id
- level

Rules:
- Use a single recursive WITH clause to establish the looping structure.
- The Anchor Query: 
  - Isolate the absolute root executive of the organization (the CEO where 
    manager_id IS NULL).
  - Explicitly hardcode the starting baseline level as 1.
- The Recursive Query:
  - Join the base employee table back onto the recursive CTE alias.
  - Establish the parent-child relationship by matching: base_table.manager_id = cte_alias.emp_id
  - Increment the level column row-by-row on each subsequent loop by exactly +1 (level + 1).
- Combine the anchor and recursive result sets using a UNION ALL operator.
- Do not build a hierarchy tracking path string yet; focus purely on the baseline level recursion.
*/

WITH RECURSIVE CTE_Hierarchy AS
(
	SELECT
		emp_id,
        emp_name,
        manager_id,
        1 as level
    FROM employee_hierarchy
    WHERE manager_id is null
    UNION ALL
    SELECT
		eh.emp_id,
        eh.emp_name,
        eh.manager_id,
        ch.Level + 1 as Level
	FROM employee_hierarchy eh
    JOIN CTE_Hierarchy ch
    ON eh.manager_id = ch.emp_id
)
SELECT * FROM CTE_Hierarchy;

/*
================================================================================
🔥 Final Recursive Challenge — Path Concatenation Hierarchy Matrix
================================================================================

Business Requirement:
Trace the full reporting path from the absolute top executive down to every 
individual employee, projecting the structured organizational tree depth level 
along with a dynamic text visualization of the management chain.

SQL Task:
Construct a highly optimized Recursive Common Table Expression (CTE) to build 
a multi-hop lineage path across reporting layers.

Columns to Return:
- emp_name
- level
- hierarchy_path

Rules:
- The Anchor Query:
  - Isolate the absolute root employee node (where manager_id IS NULL).
  - Explicitly initialize the tree depth baseline level as 1.
  - Define the base tracking lineage field (hierarchy_path) by using the 
    employee name. Proactively enforce a wide character type bounds format 
    (e.g., CAST(emp_name AS CHAR(1000))) to prevent downstream recursive string 
    truncation failures.
- The Recursive Query:
  - Reference your recursive CTE block and perform an INNER JOIN against the 
    base employee table to build the hierarchy connection.
  - Link the parent-child node pointers on the manager mapping keys.
  - Increment the active execution loop layer by exactly +1 (level + 1).
  - Construct the progressive lineage path string by combining the parent's 
    inherited string with a specific text structural divider and the current 
    row's name asset: CONCAT(parent.hierarchy_path, ' -> ', child.emp_name)
- Combine both execution limbs using a UNION ALL operator.
- The Outer Pass:
  - Query from the completed recursive container.
  - Sort the final grid cleanly to align the reporting structure chronologically.
*/














