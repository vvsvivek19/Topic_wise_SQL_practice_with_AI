-- ======================================================================================================================================
-- 														SELECT, DDL, DML, Filtering Qs
-- ======================================================================================================================================

-- CREATE TABLE Employees_new (
--    EmployeeID INT PRIMARY KEY,
--    FirstName VARCHAR(50),
--    LastName VARCHAR(50),
--    Department VARCHAR(50),
--    Salary DECIMAL(10, 2)
-- );

-- INSERT INTO Employees_new (EmployeeID, FirstName, LastName, Department, Salary) VALUES
-- (1, 'Alice', 'Johnson', 'Sales', 60000),
-- (2, 'Bob', 'Smith', 'Engineering', 75000),
-- (3, 'Charlie', 'Davis', 'Sales', 45000),
-- (4, 'Diana', 'Prince', 'Marketing', 55000),
-- (5, 'Evan', 'Wright', 'Sales', 52000);

/*
Retrieve the FirstName, LastName, and Salary of all employees who work in the 'Sales' department and have a salary greater than 50,000. Sort the results by Salary from highest to lowest.
*/
SELECT FirstName, LastName, Salary 
FROM Employees_new
WHERE Department = 'Sales' AND Salary > 50000 
ORDER BY Salary DESC;

/*
Find the FirstName, LastName, and Department of all employees whose LastName starts with the letter 'S' and whose Salary is between 55,000 and 80,000 (inclusive).
*/

SELECT
	FirstName, LastName, Department
FROM Employees_new
WHERE LastName Like 'S%' AND Salary BETWEEN 55000 AND 80000;

/*
Find the Department and the Total Number of Employees in that department.
Filter the results to only include the 'Sales' and 'Engineering' departments.
Only include departments that have more than one employee.
*/
SELECT * FROM Employees_new;
SELECT
	Department, COUNT(*) as total_employees
FROM Employees_new
GROUP BY Department
HAVING Department IN ('Engineering','Sales') AND COUNT(*) > 1;

/*
Perform the following two operations:
- Update the salary of all employees in the 'Sales' department by increasing it by 10%.
- Retrieve the TOP 3 highest-paid employees (FirstName, LastName, Salary) from the entire company after the update, sorted from highest to lowest salary.
*/
UPDATE Employees_new
SET Salary = Salary * 1.10
WHERE Department = 'Sales';

SELECT * FROM Employees_new ORDER BY Salary DESC LIMIT 3;

/*
Retrieve a list of unique (distinct) Departments that have at least one employee with a Salary greater than 60,000.
Delete all records from Employees_new where the LastName contains the letter 'i' (case-insensitive) OR the Department is 'Marketing'.
*/
-- Query 1:
SELECT DISTINCT Department FROM Employees_new WHERE Salary > 60000;
-- Query 2:
DELETE FROM Employees_new
WHERE LastName LIKE '%i%' OR Department = 'Marketing';

-- Resetting the table with fresh data for Challenge 6
-- TRUNCATE TABLE Employees_new;

-- INSERT INTO Employees_new (EmployeeID, FirstName, LastName, Department, Salary) VALUES
-- (1, 'Alice', 'Johnson', 'Sales', 66000),
-- (2, 'Bob', 'Smith', 'Engineering', 75000),
-- (3, 'Charlie', 'Davis', 'Sales', 49500),
-- (4, 'Diana', 'Prince', 'Marketing', 55000),
-- (5, 'Evan', 'Wright', 'Sales', 57200),
-- (6, 'Frank', 'Stevens', 'Engineering', 80000),
-- (7, 'Gina', 'Adams', 'Engineering', 72000),
-- (8, 'Henry', 'Ford', 'Sales', 62000);
/*
Find the Department and the highest salary (Max_Salary) within that department, subject to these conditions:
Exclude any employees whose FirstName starts with the letter 'F'.
Only include departments where that highest salary is greater than 60,000.
Sort the final results by the highest salary in descending order.
*/
SELECT Department, MAX(Salary) as Max_Salary
FROM employees_new
WHERE FirstName NOT LIKE 'F%'
GROUP BY Department HAVING MAX(Salary) > 60000
ORDER BY Max_Salary DESC;

/*
Challenge #7: Advanced Cleanup and Constraints
Let's test your ability to combine multiple logical operators and the IN operator.
SQL Task 
Update: Increase the salary by 5% for all employees in the 'Engineering' or 'Sales' departments, but only if their LastName ends with the letter 's'.
Select: Retrieve the Department and the Average Salary (aliased as Avg_Salary) for all departments.
Filter: Only show departments where the Avg_Salary is between 50,000 and 75,000.
Exclude: Do not include the 'Marketing' department in the final list.
*/
UPDATE employees_new SET salary = salary * 1.05 WHERE Department IN ('Engineering','Sales') AND LastName LIKE '%s';
SELECT Department, AVG(Salary) as Avg_Salary FROM employees_new WHERE  Department != 'Marketing' GROUP BY Department HAVING AVG(Salary) between 50000 AND 75000;

/*
Challenge #8: Complex Constraints and Top-N Analysis
SQL Task
- Delete: Remove all records where the FirstName contains the letter 'a' AND the Salary is less than 60,000.
- Retrieve: Find the TOP 2 highest-paid employees remaining in the company.
- Requirements: Include their FirstName, LastName, and Department. Sort them first by Salary (highest to lowest), and then by LastName (alphabetically) as a tie-breaker.
*/

DELETE FROM employees_new
WHERE FirstName LIKE '%a%' AND Salary < 60000;
SELECT FirstName, LastName, Department
FROM employees_new
ORDER BY Salary DESC, LastName ASC
LIMIT 2;

/*
Challenge #9: Advanced Aggregation & Pattern Logic
Find the Department, Total Salary (sum), and Average Salary for departments that meet these criteria:
Only include employees whose Salary is between 50,000 and 80,000.
The Department name must NOT contain the word 'Sales'.
Only show departments where the Average Salary is greater than 60,000.
Order the results by Total Salary in descending order.
*/
SELECT * FROM employees_new;
SELECT Department, SUM(Salary) as total_salary, AVG(Salary) as avg_salary
FROM employees_new
WHERE Salary BETWEEN 50000 AND 80000 AND Department NOT LIKE '%sales%'
GROUP BY Department
HAVING AVG(Salary) > 60000
ORDER BY total_salary DESC;

/*
Challenge #10: Conditional Updates and Pattern Filtering
SQL Task
- Update: For any employee in the 'Engineering' department whose Salary is less than 80,000, increase their salary by 12%.
- Delete: Remove all employees whose FirstName has the letter 'a' as the second character (e.g., "Gary", "Janet").
- Retrieve: List the Department, Total Employees, and Max Salary for each department.
- Exclude departments that currently have only 1 employee.
Sort the results by Max Salary from highest to lowest.
*/
UPDATE employees_new
SET salary = salary * 1.12
WHERE department = 'Engineering';
DELETE FROM employees_new WHERE FirstName LIKE '_a%';
SELECT department, count(*) total_employees, MAX(salary) as max_salary 
FROM employees_new 
GROUP BY Department
HAVING count(*) > 1;