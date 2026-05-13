-- ======================================================================================================================================
-- 														String and Number Functions
-- ======================================================================================================================================
/*
1. SQL Task
The HR department needs a "Clean Payroll Report."
	- Retrieve: A column called Full_Name that combines the FirstName and LastName in the format: "LASTNAME, Firstname" (where the Last Name is in all UPPERCASE and the First Name is in its original casing).
	- Retrieve: A column called Adjusted_Salary that shows their current Salary increased by 8.5%.
	- Requirement: The Adjusted_Salary must be rounded to the nearest whole number.
	- Requirement: Only include employees whose Salary is greater than 60,000.
*/

SELECT 
	CONCAT(UPPER(TRIM(LastName)),', ',TRIM(FirstName)) as full_name,   
    ROUND(salary * 1.085,0) as Adjusted_Salary
FROM employees_joins
WHERE Salary > 60000;

/*
Challenge #2 (String & Number Functions): Data Transformation & Masking
- Now let's step up the difficulty by manipulating parts of strings and analyzing salary deviations.
Create a "Security & Audit Report":
- Create a SystemID: Combine the first 3 characters of the FirstName and the first 3 characters of the LastName, then add the EmployeeID at the end. The whole ID must be in UPPERCASE (e.g., "ALIJOH1").
- Clean Department Names: In the result, display the DeptName, but REPLACE any occurrence of the word 'Engineering' with 'Tech'.
- Salary Deviation: Find the absolute difference between the employee's Salary and the company average of 75,000. Alias this as Deviation.
- Requirement: Only include employees whose SystemID starts with the letter 'B' or 'L'.
*/

SELECT 
	CONCAT(LEFT(TRIM(e.FirstName),3),LEFT(TRIM(e.LastName),3),)
FROM employees_joins e LEFT JOIN department_joins d 
ON e.DeptID = d.DeptID;










