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


/*
Challenge #6 (String & Number Functions): Advanced Data Redaction & Swapping
Let's step up the difficulty by focusing on deep string replacement, positional nesting, and numeric normalization.
The Compliance and Analytics teams require a "Vendor & Project Standardization Report":
Redacted Code (Redacted_Code): Take the Staff_Code computed in the previous challenge. REPLACE any occurrence of vowels ('a', 'e', 'i', 'o', 'u') inside that code with an asterisk ('*'). The final string must remain in its evaluated casing.
Normalized Variance (Normalized_Variance): Take the absolute budget variance (ABS(85000 - Salary)) and divide it by the maximum possible variance threshold of 50,000. ROUND this final decimal ratio to exactly 3 decimal places.
Filter Criteria: Only display active project allocations where the employee's Salary is strictly less than 85,000.
*/

SELECT 
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Staff_Code,'a','*'),'i','*'),'o','*'),'e','*'),'u','*'),'A','*'),'I','*'),'O','*'),'E','*'),'U','*') as Redacted_Code,
    ROUND(Budget_Variance/50000,3) as Normalized_Variance
 FROM
	(SELECT 
		CASE 
			WHEN length(TRIM(e.FirstName)) > length(TRIM(e.LastName)) THEN Lower(LEFT(TRIM(e.FirstName),3))
			WHEN length(TRIM(e.FirstName)) <= length(TRIM(e.LastName)) THEN UPPER(RIGHT(TRIM(e.LastName),3)) 
		END as Staff_Code,
		ABS(85000 - e.Salary) as Budget_Variance
	FROM employees_joins e
	JOIN employee_projects ep ON e.EmployeeID = ep.EmployeeID
	JOIN projects p ON ep.ProjectID = p.ProjectID
    WHERE e.Salary < 85000)t
WHERE Budget_Variance <= 25000;

SELECT 
	*
FROM employees_joins e
JOIN employee_projects ep ON e.EmployeeID = ep.EmployeeID
JOIN projects p ON ep.ProjectID = p.ProjectID;

/*
Challenge #7 (String & Number Functions): Character Symmetry & Negative Rounding
Let's test an advanced number trick alongside deep positional extractions.
The Communications team wants an executive roster audit:
- Name Symmetry (Is_Symmetric): Evaluate the trimmed length of the FirstName. If the number of characters is even, return the text string 'Even'. If it is odd, return 'Odd'. (Hint: Use the modulo operator % or MOD()).
- Core Extraction (Core_Letters): Extract a specific middle piece of their text:
- If the trimmed FirstName length is strictly greater than 4, extract a 3-character substring starting exactly from character position 2.
- If it is 4 characters or fewer, return the full FirstName in all lowercase.
- Financial Cluster (Salary_Cluster): Group salaries into high-level tranches. Round the employee's Salary to the nearest 10,000. (Hint: Look into how a negative second argument in the ROUND() function behaves!)
- Filter Criteria: Only include employees whose trimmed FirstName length is strictly greater than 3.
*/

SELECT 
	CASE
		WHEN length(TRIM(FirstName))%2 = 0 THEN 'Even'
        WHEN length(TRIM(FirstName))%2 != 0 THEN 'Odd'
	END as Is_Symmetric,
    CASE
		WHEN length(TRIM(FirstName)) > 4 THEN substring(TRIM(FirstName),2,3)
        WHEN length(TRIM(FirstName)) <= 4 THEN Lower(TRIM(FirstName))
	END as Core_Letters,
    ROUND(Salary,-4) as Salary_Cluster
FROM employees_joins
WHERE length(TRIM(FirstName))>3;

/*

*/
-- If you already created the table, you can just run the INSERTs below.
-- Otherwise, here is the full script:

-- CREATE TABLE external_audit_clean (
--     FirstName VARCHAR(50),
--     LastName VARCHAR(50),
--     Corporate_Email VARCHAR(100),
--     Salary INT
-- );

-- INSERT INTO external_audit_clean VALUES 
-- ('Bruce', 'Wayne', 'bwayne@gothamtech.org', 115000),
-- ('Clark', 'Kent', 'ckent@metrodaily.com', 52000),
-- ('Diana', 'Prince', 'dprince@amazoncorp.net', 94000),
-- ('Barry', 'Allen', 'ballen@centralpd.gov', 68000),
-- ('Hal', 'Jordan', 'hjordan@ferrisair.com', 82000),
-- ('Arthur', 'Curry', 'acurry@atlantiscorp.gov', 145000),
-- ('Lois', 'Lane', 'llane@metrodaily.com', 76000),
-- ('Selina', 'Kyle', 'skyle@catburglar.net', 48000),
-- ('Lex', 'Luthor', 'lluthor@lexcorp.com', 350000);

SELECT * FROM external_audit_clean;

SELECT 
	UPPER(LEFT(TRIM(Corporate_Email),LOCATE('@', TRIM(Corporate_Email))-1)) as User_Name,
    length(SUBSTRING(TRIM(Corporate_Email),LOCATE('@', TRIM(Corporate_Email))+1))as Domain_Len,
    Salary - 75000 as Signed_Deviation
FROM external_audit_clean;

/*
Challenge #9 (String & Number Functions): Fixed-Width Ledger Formatting
Let's look at how text and numeric padding functions are used to generate standardized flat files, system logs, or fixed-width accounting ledger data.
The IT Auditing team needs a stylized, fixed-width report string to feed into a legacy reporting system. Generate a single column named Ledger_Record that formats the data into a single line matching this exact structure:
- Begin with the User_Name (everything before the @ symbol in uppercase, using your logic from the last challenge).
- This username must be Right-Padded with periods ('.') so that it occupies a fixed space of exactly 15 characters (e.g., 'BWAYNE.........').
- Append a static separator string: ' -> '.
- Append the Signed_Deviation value (Salary - 75000).
- This deviation value must be converted to text and Left-Padded with zeros ('0') so that it occupies a fixed space of exactly 7 characters (including its negative sign if present, e.g., '0040000' or '-023000').

Final Output Example: BWAYNE......... -> 0040000 or CKENT.......... -> -023000
*/


/*
Challenge #10 (String & Number Functions): The Grand Finale 🏁Let's close out this chapter with a master challenge that combines string slicing, domain categorization, and macro-financial scaling using our updated DC universe dataset!
The Justice League Oversight Committee requires a high-level "Risk and Contribution Matrix":
- Hero_Initials: Combine the first letter of their FirstName and the first letter of their LastName in uppercase, separated by a hyphen (e.g., Bruce Wayne becomes 'B-W').
- Salary_Scale: Round their Salary to the nearest 100,000 using negative rounding scale math.
- Email_Safety_Check: Analyze the domain extension of their Corporate_Email:If the email ends in '.gov', label it as 'Secure Gov'.If it ends in '.com' or '.org', label it as 'Standard Corporate'.For any other extension (like '.net'), label it as 'Unsecured/Private'.
- Filter Criteria: Only include heroes whose Salary is strictly greater than $50,000$ and whose LastName does not contain the letter 'e' (case-insensitive).
*/
SELECT 
	UPPER(CONCAT(LEFT(TRIM(FirstName),1),'-',LEFT(TRIM(LastName),1))) as Hero_Initials,
    ROUND(Salary,-5) as Salary_Scale,
    CASE 
		WHEN RIGHT(TRIM(Corporate_Email),4) = '.gov' THEN 'Secure Gov'
        WHEN RIGHT(TRIM(Corporate_Email),4) = '.com' OR  RIGHT(TRIM(Corporate_Email),4) = '.org' THEN 'Standard Corporate'
        ELSE 'Unsecured/Private'
	END as Email_Safety_Check
FROM external_audit_clean
WHERE Salary > 50000 AND LastName Not Like '%e%';













 