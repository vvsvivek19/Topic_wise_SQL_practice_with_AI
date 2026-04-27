

-- ======================================================================================================================================
-- 														JOINS
-- ======================================================================================================================================
-- Resetting the relational structure with updated table names
-- DROP TABLE IF EXISTS Employees_Joins;
-- DROP TABLE IF EXISTS department_joins;

-- CREATE TABLE department_joins (
--     DeptID INT PRIMARY KEY,
--     DeptName VARCHAR(50),
--     Location VARCHAR(50)
-- );

-- CREATE TABLE Employees_Joins (
--     EmployeeID INT PRIMARY KEY,
--     FirstName VARCHAR(50),
--     LastName VARCHAR(50),
--     DeptID INT,
--     Salary DECIMAL(10, 2)
-- );

-- INSERT INTO department_joins (DeptID, DeptName, Location) VALUES
-- (101, 'Sales', 'New York'), 
-- (102, 'Engineering', 'San Francisco'), 
-- (103, 'Marketing', 'London'), 
-- (104, 'HR', 'New York'),
-- (105, 'Finance', 'Singapore'),
-- (106, 'R&D', 'Berlin'),
-- (107, 'Legal', 'London');

-- INSERT INTO Employees_Joins (EmployeeID, FirstName, LastName, DeptID, Salary) VALUES
-- (1, 'Alice', 'Johnson', 101, 66000),
-- (2, 'Bob', 'Smith', 102, 78750),
-- (3, 'Charlie', 'Davis', 101, 51975),
-- (4, 'Diana', 'Prince', 103, 55000),
-- (5, 'Evan', 'Wright', NULL, 57200),
-- (6, 'Frank', 'Stevens', 102, 84000),
-- (7, 'Gina', 'Adams', 102, 75600),
-- (8, 'Henry', 'Ford', 101, 62000),
-- (9, 'Irene', 'Adler', 105, 92000),
-- (10, 'Jack', 'Sparrow', NULL, 45000),
-- (11, 'Kelly', 'Kapoor', 103, 48000),
-- (12, 'Liam', 'Neeson', 106, 88000),
-- (13, 'Monica', 'Geller', 104, 67000),
-- (14, 'Ned', 'Stark', 102, 71000),
-- (15, 'Oscar', 'Wilde', NULL, 59000);

/*
Challenge #1 (Joins): The Basic Connection (Rich Edition)
Retrieve the FirstName, LastName, and DeptName for all employees who are currently assigned to a department.
*/

SELECT e.FirstName, e.LastName, d.DeptName
FROM
employees_joins as e 
INNER JOIN department_joins as d ON e.DeptID = d.DeptID;

/*
Challenge #2 (Joins): Handling Missing Data
Retrieve a list of all employees (FirstName, LastName) along with their DeptName.
Requirement: Include employees even if they are not assigned to any department (those with NULL DeptID).
If an employee has no department, the DeptName should appear as NULL.
*/
SELECT e.FirstName,e.LastName,d.DeptName FROM 
employees_joins as e LEFT JOIN department_joins as d ON e.DeptID = d.DeptID;

/*
Challenge #3 (Joins): Finding the "Orphans" (Anti-Joins)
Identify the Departments that currently have no employees assigned to them.
Retrieve only the DeptName and its Location.
Use an "Anti-Join" pattern (a RIGHT JOIN or LEFT JOIN combined with a WHERE clause) to find these empty departments.
*/
SELECT * FROM employees_joins;
SELECT * FROM department_joins;
SELECT d.DeptID, d.DeptName, d.Location
FROM department_joins as d LEFT JOIN employees_joins e ON d.DeptID = e.DeptID
WHERE e.DeptID IS NULL;

/*
Challenge #4 (Joins): Data Expansion with CROSS JOIN
The company is launching a mandatory "Cybersecurity Training" program. Every employee must complete every available training module.
Retrieve the FirstName, LastName, and ModuleName for every possible combination of employees and modules.
*/
-- CREATE TABLE TrainingModules (
--     ModuleID INT PRIMARY KEY,
--     ModuleName VARCHAR(100)
-- );

-- INSERT INTO TrainingModules (ModuleID, ModuleName) VALUES
-- (1, 'Phishing Awareness'),
-- (2, 'Password Security'),
-- (3, 'Remote Access Safety');
SELECT *
FROM employees_joins CROSS JOIN trainingmodules
ORDER BY FirstName, ModuleID;































