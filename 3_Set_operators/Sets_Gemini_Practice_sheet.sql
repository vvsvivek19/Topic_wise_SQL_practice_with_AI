-- ======================================================================================================================================
-- 															SETS
-- ======================================================================================================================================

-- CREATE TABLE external_partners (
--     PartnerID INT PRIMARY KEY,
--     FirstName VARCHAR(50),
--     LastName VARCHAR(50),
--     Company VARCHAR(100)
-- );

-- INSERT INTO external_partners (PartnerID, FirstName, LastName, Company) VALUES
-- (1, 'Alice', 'Johnson', 'CloudTech'),
-- (2, 'Bruce', 'Wayne', 'WayneEnt'),
-- (3, 'Diana', 'Prince', 'AmazonLogistics'),
-- (4, 'Peter', 'Parker', 'DailyBugle'),
-- (5, 'Clark', 'Kent', 'PlanetNews');

/*
Challenge #1 (Set Operators): The Master Contact List
Create a "Master Contact List" by retrieving a unique list of all FirstName and LastName entries found in both the Permanent Employees table and the External Partners table.
Requirement: Ensure that if an individual appears in both tables, they are listed only once in the final result.
*/
SELECT FirstName, LastName FROM employees_joins
UNION
SELECT FirstName, LastName FROM external_partners;

/*
Challenge #2 (Set Operators): Tracking the Source
Now let's look at how to preserve every record and identify where it came from.
Create a combined list of FirstName, LastName, and a new column called ContactType.
Requirement 1: For records from the employees_joins table, the ContactType should be 'Internal'.
Requirement 2: For records from the external_partners table, the ContactType should be 'External'.
Requirement 3: Include every single record from both tables, even if the same person appears in both.
*/

SELECT FirstName, LastName, 'Internal' as ContactType FROM employees_joins
UNION ALL
SELECT FirstName, LastName, 'External' as ContactType FROM external_partners;

/*
Challenge #3 (Set Operators): Finding Commonality
Identify the FirstName and LastName of people who are both permanent employees and external partners.
Requirement: Use the INTERSECT operator (available in MySQL 8.0.31+) to find only the "Intersection" between the two tables.
*/
SELECT FirstName, LastName FROM employees_joins
INTERSECT
SELECT FirstName, LastName FROM external_partners;

/*
Challenge #4 (Set Operators): Finding the Difference
Identify the FirstName and LastName of people who are permanent employees but are NOT listed as external partners.
Requirement: Use the EXCEPT operator to find the "Difference" between the two sets.
*/
SELECT FirstName, LastName FROM employees_joins
EXCEPT
SELECT FirstName, LastName FROM external_partners;

/*
Challenge #5 (Set Operators): Set Operations with Complex Filtering
Now that you've mastered the basic set operators, let's combine them with filtering and multiple logic layers.
- Generate a list of FirstName and LastName for the following group:
- All Permanent Employees who work in the 'Engineering' department.
- EXCEPT for any individuals who are also External Partners.
- UNION the result with all External Partners who work for the company 'CloudTech'.
*/

SELECT FirstName, LastName 
FROM employees_joins ej JOIN department_joins dj ON ej.DeptID = dj.DeptID
WHERE dj.DeptName = 'Engineering'
EXCEPT
SELECT FirstName, LastName FROM external_partners
UNION
SELECT FirstName, LastName FROM external_partners WHERE company = 'CloudTech';

/*
Challenge #6 (Set Operators): The Symmetric Difference
Now that you've mastered combining operators, let's try a classic set theory problem known as the Symmetric Difference.
Identify all "Exclusive Individuals"—people who appear in one table but NOT both.
Retrieve the FirstName and LastName of people who are only permanent employees (in employees_joins) OR are only external partners (in external_partners).
Constraint: Your result must exclude anyone who exists in both tables (like Alice Johnson).
Constraint: You must solve this using only Set Operators (UNION, EXCEPT, INTERSECT).
*/
(SELECT FirstName, LastName FROM employees_joins
EXCEPT
SELECT FirstName, LastName FROM external_partners)
UNION ALL
(SELECT FirstName, LastName FROM external_partners
EXCEPT
SELECT FirstName, LastName FROM employees_joins);

/*
Challenge #7 (Set Operators): Sorting and Global Aliases
Now that we've mastered complex set-based logic, let's look at how to format the final output.
Create a unified list of all FirstName and LastName from both employees_joins and external_partners.
Requirement 1: Alias the columns as First_Name and Last_Name.
Requirement 2: Combine the sets using UNION.
Requirement 3: Sort the entire final list alphabetically by Last_Name.
*/
SELECT FirstName as First_Name, LastName as Last_Name FROM external_partners
UNION
SELECT FirstName as First_Name, LastName as First_Name FROM employees_joins
ORDER BY Last_Name;

/*
Challenge #8 (Set Operators): Set Operations with Aggregates
Now let's use set operators to build a Comparison Report. This is a common requirement for high-level management dashboards.
Create a "Headcount Comparison Report" that shows the following two rows:
- The first row should show the label 'Internal Staff' and the total number of employees in the employees_joins table.
- The second row should show the label 'External Partners' and the total number of partners in the external_partners table.
- Requirement: Alias your result columns as UserGroup and TotalCount.
- Requirement: Use a set operator to combine these two aggregate results into a single report.
*/
SELECT 'Internal Staff' as UserGroup, COUNT(*) as TotalCount 
FROM employees_joins 
GROUP BY UserGroup
UNION ALL
SELECT 'External Partners' as UserGroup, COUNT(*) as TotalCount 
FROM external_partners 
GROUP BY UserGroup;

/*
Challenge #9 (Set Operators): Sets in Subqueries (The Finale)
The company is planning a "Loyalty Bonus" for staff.
- Retrieve: The FirstName, LastName, and Salary from the employees_joins table.
- Filter 1: The results must only include employees who do NOT appear in the external_partners table.
- Filter 2: Only show those with a Salary greater than 60,000.
- Constraint: You must use the EXCEPT operator inside a subquery (within the WHERE clause) to generate the list of people to exclude.
*/
SELECT FirstName, LastName, Salary 
FROM employees_joins
WHERE Salary > 60000 AND (FirstName, LastName) IN (SELECT FirstName, LastName FROM employees_joins EXCEPT SELECT FirstName, LastName FROM external_partners);




