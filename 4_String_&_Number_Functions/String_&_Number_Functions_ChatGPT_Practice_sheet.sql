-- ======================================================================================================================================
-- 														String and Number Functions
-- ======================================================================================================================================
-- CREATE TABLE employees_func (
--     emp_id INT,
--     emp_name VARCHAR(50),
--     department VARCHAR(50),
--     salary DECIMAL(10,2)
-- );

-- INSERT INTO employees_func VALUES
-- (1, 'amit', 'IT', 60555.75),
-- (2, ' Neha ', 'HR', 50234.40),
-- (3, 'raj', 'Finance', 70888.99),
-- (4, 'Sneha', 'Admin', 45000.12);

/*
Challenge #1 (CONCAT + UPPER)
Create a formatted employee label in this format:
AMIT - IT
NEHA - HR
Requirements:
- Employee name should be uppercase
- Combine: employee name, ' - ', department
*/
SELECT concat(UPPER(TRIM(emp_name)), ' - ', UPPER(TRIM(department))) as formatted_employee FROM employees_func;

/*
Challenge #2 (REPLACE + LOWER)
Create cleaned email IDs in this format:
amit@company.com
neha@company.com
Requirements: Use employee names, Convert to lowercase, Remove spaces from names
Append: @company.com
*/

SELECT 
	CONCAT(lower(TRIM(emp_name)),'@company.com') as clean_email
FROM employees_func;

/*
Challenge #3 (LEFT + RIGHT + LEN)
Generate employee codes in this format: AMI_75, NEH_40
Rules: First 3 letters of employee name (uppercase), _ , Last 2 digits of salary (without decimal)
*/
SELECT * FROM employees_func;
SELECT CONCAT(UPPER(LEFT(TRIM(emp_name),3)),'_',RIGHT(CAST(salary as unsigned),2)) as emp_code
FROM employees_func;

/*
Challenge #4 (SUBSTRING + REPLACE)
Create masked employee names in this format: a***t, n***a
Rules:
Keep: first character, last character
Replace all middle characters with: ***
*/
SELECT * FROM employees_func;
SELECT concat(LOWER(LEFT(TRIM(emp_name),1)),'***',LOWER(RIGHT(TRIM(emp_name),1))) as masked_emp
FROM employees_func;

/*
Challenge #5 (ROUND + ABS)
Show: Salary difference from 60000
Rules:
Difference should always be positive
Round result to nearest whole number
*/
SELECT 
    emp_name,
    ROUND(ABS(salary - 60000)) AS salary_difference
FROM employees_func;


/*
Challenge #6 (Mixed String Functions — Real Data Cleaning)
Generate usernames in this format:
amit_it
neha_hr
Rules: employee name: lowercase, remove spaces, department: lowercase, combine with _
*/
SELECT 
	CONCAT(LOWER(TRIM(emp_name)),'_',LOWER(TRIM(department)))
FROM employees_func;

/*
Challenge #7 (LEN + SUBSTRING)
Show:
Employee name
Length of employee name (excluding outer spaces)
Middle 2 characters from employee name
*/
SELECT
	TRIM(emp_name) AS emp_name,
    LENGTH(TRIM(emp_name)) AS name_length,
	CASE
		WHEN length(TRIM(emp_name)) % 2 = 0 THEN substring(TRIM(emp_name),length(TRIM(emp_name)) / 2,2 )
        WHEN length(TRIM(emp_name)) % 2 != 0 THEN substring(TRIM(emp_name),ROUND(length(TRIM(emp_name)) / 2,0),2 )
	END as middle_2
FROM employees_func;


/*
Challenge #8 (REPLACE + SUBSTRING + CONCAT)
Mask salary values in this format: 60XXX, 50XXX
Rules: Keep first 2 digits of salary
Replace remaining digits with: XXX
*/
SELECT 
	TRIM(emp_name),
	CONCAT(substring(CAST(salary as char),1,2),'XXX') as masked_Salary
FROM employees_func;





