---- 1. Create and switch to the practice database
--CREATE DATABASE MCU_Practice_DB;
--GO

--USE MCU_Practice_DB;
--GO

---- 2. Create the Avengers table
--CREATE TABLE mcu_avengers_roster (
--    HeroID INT PRIMARY KEY,
--    Codename VARCHAR(50),
--    RealName VARCHAR(100),
--    DeploymentDate DATE,
--    BaseSalary DECIMAL(12,2)
--);
--GO

---- 3. Insert the sample data
--INSERT INTO mcu_avengers_roster (HeroID, Codename, RealName, DeploymentDate, BaseSalary)
--VALUES 
--(1, 'Iron Man', 'Tony Stark', '2008-05-02', 9999999.99),
--(2, 'Captain America', 'Steve Rogers', '2011-07-22', 150000.00),
--(3, 'Thor', 'Thor Odinson', '2011-05-06', 0.00),
--(4, 'Black Widow', 'Natasha Romanoff', '2010-05-07', 220000.00),
--(5, 'Spider-Man', 'Peter Parker', '2016-05-06', 45000.00),
--(6, 'Captain Marvel', 'Carol Danvers', '2019-03-08', 180000.00),
--(7, 'Falcon', 'Sam Wilson', '2014-04-04', 115000.00),
--(8, 'Shang-Chi', 'Shaun / Shang-Chi', '2021-09-03', 85000.00);
--GO

/*
Challenge #1 (SQL Server): Temporal Slicing & Age Calculations
Deployment_Year: Extract just the 4-digit year of when the hero was officially deployed.
Deployment_Month_Name: Extract the full text name of the month they were deployed (e.g., 'May', 'October').
Days_Active: Calculate the exact number of days between their DeploymentDate and the system audit date baseline of May 1, 2026 ('2026-05-01').
Filter Criteria: Only include heroes who were deployed before the year 2020.
*/

SELECT 
	HeroID, 
	YEAR(DeploymentDate) as Deployment_Year,
	DATENAME(MONTH,DeploymentDate) as Deployment_Month_Name,
	DATEDIFF(DAY,DeploymentDate,'2026-05-01') as Days_Active
FROM mcu_avengers_roster
WHERE DeploymentDate < '2020-01-01';


SELECT 
	HeroID,
	FORMAT(Adjusted_Deployment,'dd/MM/yyyy') as UN_Format_Date,
	DATEDIFF(MONTH,Adjusted_Deployment,'2026-05-01') as Months_Since_Adjustment
FROM
(
	SELECT 
	HeroID,
	DATEADD(YEAR,5,DeploymentDate) as Adjusted_Deployment
	FROM mcu_avengers_roster
)t
WHERE Adjusted_Deployment <= '2024-12-31';

-- SARGable solution
SELECT 
    HeroID,
    FORMAT(Adjusted_Deployment, 'dd/MM/yyyy') as UN_Format_Date,
    DATEDIFF(MONTH, Adjusted_Deployment, '2026-05-01') as Months_Since_Adjustment
FROM
(
    SELECT 
        HeroID,
        DATEADD(YEAR, 5, DeploymentDate) as Adjusted_Deployment
    FROM mcu_avengers_roster
    WHERE DeploymentDate <= '2019-12-31' -- Ideal: Inclusive filter applied to raw column!
) t;

/*
Challenge #3 (Date & Time): Truncation, Deadlines, and Validation
Now that your sandbox is locked in with the ideal logic, let's execute Challenge #3, focusing on contract calculations and validation loops.

The Avengers Finance & Legal division is reconciling active deployment contracts:
Month_Start: Truncate the hero's DeploymentDate down to the absolute first day of that month (e.g., '2014-04-12' becomes '2014-04-01'). (Use DATETRUNC).
Grace_Period_Deadline: Find the absolute last day of the month following their deployment month. (For example, if they deployed on any day in May 2008, their contract grace period ends on the last day of June 2008). (Use EOMONTH combined with inner parameter math).
Is_Date_Valid: The World Security Council passed down a messy string tracking tag: '2026-02-31'. Use a validation function to verify if this string is a real calendar date. Return 1 if it is valid, and 0 if it is invalid. (Use ISDATE).
*/


SELECT
	HeroID,
	DATETRUNC(MONTH,DeploymentDate) as Month_Start,
	EOMONTH(DATEADD(MONTH,1,DeploymentDate)) as Grace_Period_Deadline,
	ISDATE('2026-02-31') as Is_Date_Valid
FROM mcu_avengers_roster;

/*
Challenge #4 (Date & Time Functions): Weekday Parsing & Fiscal AlignmentsLet's look at how date structures are broken down to analyze specific business metrics like days of the week and fiscal tracking quarters.
SQL TaskThe Avengers Operational Costing team needs a strategic schedule optimization layout:
- Day_Of_Week_Deployed: Extract the full text name of the day of the week the hero was deployed (e.g., 'Friday', 'Monday').
- Fiscal_Quarter: Determine which financial quarter they were deployed in ($1$, $2$, $3$, or $4$). Format the final output string exactly as a 'Q' followed by the number (e.g., 'Q1', 'Q2'). (Hint: Look into the QUARTER interval parameter inside DATEPART).
- Years_To_Retire: Avengers contracts state that automatic retirement triggers exactly 25 years from their initial DeploymentDate. Calculate how many total years remain between the system audit baseline date of '2026-05-01' and that computed retirement date.
- Filter Criteria: To ensure maximum index optimization, write a SARGable filter constraint that ensures we only return rows where the initial DeploymentDate occurred after January 1, 2010.
*/


SELECT
	HeroID,
	Codename,
	DATENAME(WEEKDAY,DeploymentDate) as Day_Of_Week_Deployed,
	CONCAT('Q',CAST(DATEPART(QUARTER,DeploymentDate) AS varchar)) AS Fiscal_Quarter,
	DATEDIFF(YEAR,'2026-05-01',DATEADD(YEAR,25,DeploymentDate)) AS Years_To_Retire
FROM mcu_avengers_roster
WHERE DeploymentDate > '2010-01-01';	

/*
Challenge #5 (Date & Time Functions): The SQL Server Grand Finale 🏁
Let's conclude this SQL Server segment with a composite challenge designed to test your mastery of date validation, formatting overrides, and complex interval math before returning to your MySQL database.
The Stark Industries Payroll and Compliance division requires a final operational projection file:
- True_Deployment_Quarter: Extract the year and quarter of the deployment date, combined into a single 7-character code formatted exactly as 'YYYY-QX' (e.g., '2011-Q2').
- Probation_End_Date: The standard superhero probation window closes precisely 90 days after their DeploymentDate. Extract that new expiration timestamp, but format it using native CONVERT style code 101 to output the standard US date string format: 'MM/DD/YYYY' (e.g., '05/02/2008').
- Active_Days_In_Deployment_Year: Calculate the total number of days between the hero's actual DeploymentDate and the absolute last day of that same calendar year (e.g., if they deployed on 2011-05-06, calculate the days between that date and 2011-12-31).
*/
SELECT * FROM mcu_avengers_roster;
SELECT
	HeroID,
	Codename,
	CONCAT(DATENAME(YEAR,DeploymentDate),'-Q',CAST(DATEPART(QUARTER,DeploymentDate) as Varchar)) as True_Deployment_Quarter,
	CONVERT(varchar,DATEADD(DAY,90,DeploymentDate),101) as Probation_End_Date,
	DATEDIFF(DAY,DeploymentDate,DATEFROMPARTS(YEAR(DeploymentDate),12,31)) as Active_Days_In_Deployment_Year
FROM mcu_avengers_roster

/*
Challenge #6 (Date & Time Functions): Precision Time Slicing & Operational Shifts
Let's expand your toolkit to handle exact hours, minutes, and time-of-day classification matrices.
SQL Task: The Avengers Global Tactical Command tracks incidents down to the precise millisecond. They need an operational shift monitoring report:
- Local_Wakanda_Time: The mission logs are stored globally in UTC. The Wakanda base operates exactly 2 hours ahead of UTC. Calculate the local Wakanda timestamp for each mission using your calculation functions.
- Clean_Time_Only: Extract just the Time portion (Hour:Minute:Second) from the computed Local_Wakanda_Time, dropping the calendar date entirely.
- Operational_Shift: Evaluate the hour of the calculated Local_Wakanda_Time and bucket it into one of three tactical shifts:
	- Hours from 06:00:00 up to 11:59:59 $\rightarrow$ 'Morning Ops'
	- Hours from 12:00:00 up to 17:59:59 $\rightarrow$ 'Afternoon Ops'
	- Any other hour $\rightarrow$ 'Night Ops'
*/

--CREATE TABLE mcu_mission_logs (
--    MissionID INT PRIMARY KEY,
--    TargetCode VARCHAR(50),
--    UTCTimestamp DATETIME2
--);

--INSERT INTO mcu_mission_logs VALUES 
--(101, 'Hydra Labs', '2015-04-22 04:15:30.000'),
--(102, 'Sokovia Evac', '2015-05-01 11:45:00.000'),
--(103, 'Lagos Intercept', '2016-04-28 15:20:12.500'),
--(104, 'Titan Ambush', '2018-04-27 21:05:00.000'),
--(105, 'Endgame Portal', '2023-10-23 13:00:00.000');