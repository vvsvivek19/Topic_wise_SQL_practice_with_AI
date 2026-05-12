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








