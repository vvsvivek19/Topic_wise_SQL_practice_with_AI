

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

/*
Challenge #5 (Joins): The Self-Referential Connection (Self Join)
Retrieve the FirstName of each employee along with the FirstName of their Manager.
Requirement: Name the columns EmployeeName and ManagerName.
Requirement: Only include employees who actually have a manager assigned (exclude the "Big Boss" who has a NULL ManagerID).
*/
-- Step 1: Add the ManagerID column
-- ALTER TABLE employees_ins ADD COLUMN ManagerID INT;

-- Step 2: Assign managers (Alice reports to Bob, Diana reports to Alice, etc.)
-- UPDATE employees_joins SET ManagerID = 2 WHERE EmployeeID IN (1, 3, 6, 7, 14);
-- UPDATE employees_joins SET ManagerID = 1 WHERE EmployeeID IN (4, 8);
-- UPDATE employees_joins SET ManagerID = 9 WHERE EmployeeID IN (12, 13);
-- Note: Bob (EmployeeID 2) remains as the top-level manager with NULL ManagerID.

SELECT j.FirstName as EmployeeName, e.FirstName as ManagerName FROM employees_joins e
JOIN employees_joins j ON e.EmployeeID = j.ManagerID;

/*
Challenge #6 (Joins): Multi-Table Aggregation
Find each DeptName and the total number of employees assigned to it.
Requirement: Include all departments in the results, even if they have zero employees.
Requirement: Sort the final list by the number of employees from highest to lowest.
*/
SELECT d.DeptName, COUNT(e.EmployeeID) as total_employees FROM 
department_joins d 
LEFT JOIN employees_joins e ON d.DeptID = e.DeptID
GROUP BY d.DeptName
ORDER BY COUNT(e.EmployeeID) DESC;


/*
Challenge #7 (Joins): The "Mutual Misfits" (Full Anti-Join)
Identify all "mismatches" in the system. Retrieve the FirstName, LastName, and DeptName for:
	- Every employee who is not assigned to any department.
	- Every department that has no employees assigned to it.
Requirement: Since you are in a MySQL environment, you cannot use a FULL OUTER JOIN directly. You must simulate this "Full Anti-Join" by combining two sets using UNION.
*/
SELECT e.FirstName,e.LastName,d.DeptName FROM employees_joins e
LEFT JOIN department_joins d ON e.DeptID = d.DeptID WHERE d.DeptID IS NULL
UNION
SELECT e.FirstName,e.LastName,d.DeptName FROM department_joins d
LEFT JOIN employees_joins e ON e.DeptID = d.DeptID WHERE e.EmployeeID IS NULL;


/*
Challenge #8 (Joins): The Triple Connection
Retrieve a list of all employees who are working on the 'Cloud Migration' project.
Requirements: Include the FirstName, LastName, DeptName, and ProjectName.
Constraint: Only show employees who are actually assigned to that specific project.
*/

-- CREATE TABLE Projects (
--     ProjectID INT PRIMARY KEY,
--     ProjectName VARCHAR(100)
-- );

-- CREATE TABLE Employee_Projects (
--     EmployeeID INT,
--     ProjectID INT,
--     PRIMARY KEY (EmployeeID, ProjectID)
-- );

-- INSERT INTO Projects (ProjectID, ProjectName) VALUES
-- (501, 'Cloud Migration'),
-- (502, 'Security Audit');

-- INSERT INTO Employee_Projects (EmployeeID, ProjectID) VALUES
-- (2, 501), (6, 501), (9, 502), (14, 501);
SELECT e.FirstName, e.LastName, d.DeptName, p.ProjectName FROM employees_joins e
JOIN employee_projects ep ON e.EmployeeID = ep.EmployeeID
JOIN department_joins d ON d.DeptID = e.DeptID
JOIN projects p ON p.ProjectID = ep.ProjectID
WHERE p.ProjectName = 'Cloud Migration';



























