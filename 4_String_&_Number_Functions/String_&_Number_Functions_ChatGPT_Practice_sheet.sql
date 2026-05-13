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










