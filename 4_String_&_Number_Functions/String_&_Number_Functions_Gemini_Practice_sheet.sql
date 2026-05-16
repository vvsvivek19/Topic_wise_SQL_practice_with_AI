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

SELECT * FROM
(
SELECT 
	UPPER(CONCAT(LEFT(TRIM(e.FirstName),3),LEFT(TRIM(e.LastName),3),TRIM(CAST(e.EmployeeID as char)))) as SystemID,
    REPLACE(TRIM(d.DeptName),'Engineering','Tech') as CleanDeptName,
    ABS(75000 - e.Salary) as Deviation
FROM employees_joins e LEFT JOIN department_joins d 
ON e.DeptID = d.DeptID)t
WHERE SystemID like 'B%' OR SystemID LIKE 'L%';

/*
Challenge #3 (String & Number Functions): Advanced Extractions & Character Counts
Let's continue expanding your mastery over text manipulation, focusing on case matching, character lengths, and suffix extraction.
The IT Infrastructure team is preparing a user provisioning report for a corporate migration:
- Generate a Corporate_Email: Combine the lowercase first character of the FirstName, the lowercase full LastName, and the domain text _@company.com_ (e.g., Alice Johnson becomes ajohnson@company.com). Ensure all trailing/leading spaces are removed.
- Calculate Name_Length: Find the total number of characters in their full name (total characters of FirstName plus LastName combined, ignoring any spaces).
- Extract Dept_Suffix: Retrieve the last 3 characters of their DeptName in all UPPERCASE. (If an employee has no department, it should show as NULL).
- Requirement: Only include individuals whose LastName is strictly longer than 5 characters.
*/
SELECT 
	CONCAT(LOWER(LEFT(TRIM(e.FirstName),1)),LOWER(TRIM(e.LastName)),'@company.com') as Corporate_Email,
    length(TRIM(e.FirstName)) + length(TRIM(e.LastName)) as Name_Length,
    CASE 
		WHEN d.DeptName is NULL THEN d.DeptName
        WHEN d.DeptName is NOT NULL THEN UPPER(RIGHT(TRIM(d.DeptName),3))
	END as Dept_Suffix
FROM employees_joins e LEFT JOIN department_joins d 
ON e.DeptID = d.DeptID
WHERE length(TRIM(e.LastName)) > 5;

/*
Challenge #4 (String & Number Functions): 
Product Code Masking and Financial AdjustmentsLet's step up the difficulty by introducing multi-table manipulation alongside sophisticated masking techniques and precise financial rounding.
he Data Security and Finance teams require an "Anonymized Cost Allocation Summary":
- Masked Name (Masked_Name): Transform the employee's name into an obfuscated format containing the first 2 characters of their FirstName in lowercase, followed by a static string string '***', followed by the last 2 characters of their LastName in lowercase (e.g., "Alice Johnson" becomes "al***on").
- Project Allocation Tag (Proj_Tag): Extract a 4-character substring from the middle of the ProjectName starting exactly from character position 3. If the extracted substring contains any spaces, REPLACE them with an underscore _. The final tag must be in all UPPERCASE.
- Hourly Compensation Rate (Hourly_Rate): Calculate a nominal hourly rate assuming a standard $2080$-hour corporate work year (Salary / 2080). This calculated value must be ROUNDED to exactly 2 decimal places.
Filter Requirement: Only return employees who are actively assigned to a project and whose calculated Hourly_Rate is greater than or equal to 30.00.
*/
SELECT * FROM
(SELECT 
	CONCAT(LOWER(LEFT(TRIM(e.FirstName),2)),'***',LOWER(RIGHT(TRIM(e.LastName),2))) as Masked_Name,
    upper(substring(REPLACE(p.ProjectName,' ','_'),3,4) ) as Proj_Tag,
    ROUND(e.Salary/2080,2) as Hourly_Rate
FROM employees_joins e
JOIN employee_projects ep ON e.EmployeeID = ep.EmployeeID
JOIN projects p ON ep.ProjectID = p.ProjectID)t
WHERE Hourly_Rate >= 30.00;

/*
Challenge #5 (String & Number Functions): Dynamic Conditional String Profiling
Let's increase the difficulty by combining your string length and mathematical functions inside conditional comparison expressions.
The Operations team is building a management exception dashboard to audit active employee allocations:
- Dynamic Metric (Staff_Code): Formulate a single string code based on name length comparisons:If an employee's FirstName has strictly more characters than their LastName, extract the first $3$ characters of their FirstName in all lowercase.If their LastName has more or equal characters than their FirstName, extract the last $3$ characters of their LastName in all uppercase.Note: Strip all trailing and leading spaces before evaluating lengths or extractions.
Budget Variance (Budget_Variance): Calculate the absolute difference between the employee's current Salary and a corporate project baseline value of 85,000.
Filter Criteria: Only display employees who are actively assigned to a project and whose computed Budget_Variance is strictly less than or equal to 25,000.
*/
SELECT * FROM
(SELECT 
	CASE 
		WHEN length(TRIM(e.FirstName)) > length(TRIM(e.LastName)) THEN Lower(LEFT(TRIM(e.FirstName),3))
        WHEN length(TRIM(e.FirstName)) <= length(TRIM(e.LastName)) THEN UPPER(RIGHT(TRIM(e.LastName),3)) 
	END as Staff_Code,
    ABS(85000 - e.Salary) as Budget_Variance
FROM employees_joins e
JOIN employee_projects ep ON e.EmployeeID = ep.EmployeeID
JOIN projects p ON ep.ProjectID = p.ProjectID)t
WHERE Budget_Variance <= 25000;

SELECT 
	*
FROM employees_joins e
JOIN employee_projects ep ON e.EmployeeID = ep.EmployeeID
JOIN projects p ON ep.ProjectID = p.ProjectID;

/*
Challenge #6 (String & Number Functions): Advanced Data Redaction & Swapping
Let's step up the difficulty by focusing on deep string replacement, positional nesting, and numeric normalization.
The Compliance and Analytics teams require a "Vendor & Project Standardization Report":
Redacted Code (Redacted_Code): Take the Staff_Code computed in the previous challenge. REPLACE any occurrence of vowels ('a', 'e', 'i', 'o', 'u') inside that code with an asterisk ('*'). The final string must remain in its evaluated casing.
Normalized Variance (Normalized_Variance): Take the absolute budget variance (ABS(85000 - Salary)) and divide it by the maximum possible variance threshold of 50,000. ROUND this final decimal ratio to exactly 3 decimal places.
Filter Criteria: Only display active project allocations where the employee's Salary is strictly less than 85,000.
*/






 