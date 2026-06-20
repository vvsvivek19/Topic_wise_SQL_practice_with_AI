-- ======================================================================================================================================
-- 														Date & Time Functions
-- ======================================================================================================================================
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
	- Hours from 06:00:00 up to 11:59:59 - 'Morning Ops'
	- Hours from 12:00:00 up to 17:59:59 - 'Afternoon Ops'
	- Any other hour - 'Night Ops'
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

SELECT 
	*,
	CASE 
		WHEN Clean_Time_Only BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning Ops'
		WHEN Clean_Time_Only BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon Ops'
		ELSE 'Night Ops'
	END AS Operational_Shift
FROM
(
SELECT 
	*,
	DATEADD(HOUR,2,UTCTimestamp) as Local_Wakanda_Time,
	CAST(DATEADD(HOUR,2,UTCTimestamp) AS TIME) as Clean_Time_Only
FROM mcu_mission_logs)t;

/*
Challenge #7 (Date & Time Functions): Temporal Aggregations & Activity Trends
Let's merge your date extraction skills with advanced group level analysis—a combination frequently featured in technical assessments.
SQL Task: The New Asgard Bureau of Analytics wants to evaluate patterns in global threat incidents to optimize patrol schedules:
	- Day_Name: Extract the full text name of the day of the week the incident occurred ('Monday', 'Tuesday').	
	- Incident_Count: Count the total number of incidents handled on that specific day of the week.
	- Avg_Severity_Score: Calculate the average threat scale score for that day, rounded to 1 decimal place.
	- Ordering: Order the final summary report so that the day with the highest number of incidents appears first.
*/
--CREATE TABLE global_threat_incidents (
--    IncidentID INT PRIMARY KEY,
--    ThreatType VARCHAR(50),
--    IncidentTimestamp DATETIME2,
--    SeverityScale INT
--);

--INSERT INTO global_threat_incidents VALUES 
--(1, 'Alien Incursion', '2026-06-01 08:15:00', 8),  -- Monday
--(2, 'Ultron Remnant', '2026-06-01 14:30:00', 6),   -- Monday
--(3, 'Sorcery Anomaly', '2026-06-02 23:10:00', 9),  -- Tuesday
--(4, 'Alien Incursion', '2026-06-03 11:00:00', 7),  -- Wednesday
--(5, 'Hydra Cell Ops', '2026-06-05 19:45:00', 4),   -- Friday
--(6, 'Ultron Remnant', '2026-06-05 02:15:00', 5),   -- Friday
--(7, 'Sorcery Anomaly', '2026-06-05 13:00:00', 8);  -- Friday

SELECT
	Day_name,
	COUNT(Day_Name) as Incident_Count,
	ROUND(AVG(CAST(SeverityScale AS DECIMAL(3,1))), 1) as Avg_Severity_Score
FROM
(SELECT 
	*,
	DATENAME(WEEKDAY,IncidentTimestamp) as Day_Name
FROM global_threat_incidents)t
GROUP BY Day_Name
ORDER BY Incident_Count DESC;

/*
Challenge #8 (Date & Time Functions): Operational SLAs & Containment Latency
Let's step up the complexity by testing your ability to handle multiple precise time parameters (DATETIME2), compute time deltas down to the minute, and evaluate strict Service Level Agreements (SLAs).
SQL Task: The S.H.I.E.L.D. Global Command Center tracks response performance using an elite "Threat Containment Service Level Agreement". Write a report that calculates the following:
- Response_Minutes: Calculate the exact number of minutes it took to contain the threat after it was first detected (DATEDIFF between DetectionTimestamp and ContainmentTimestamp).
- Target_SLA_Time: Programmatically calculate the maximum allowable containment deadline by adding exactly 45 minutes to the DetectionTimestamp via your calculation functions.
- SLA_Status: Using a conditional CASE statement, compare the actual ContainmentTimestamp to your calculated Target_SLA_Time
	-If containment occurred after the deadline, label it 'SLA Breached'.
	- If it was completed on or before the deadline, label it 'SLA Met'.
- Filter Criteria: Ensure maximum index optimization (SARGability) by filtering for threats that were detected strictly during the month of June 2026. (Do not wrap your column in any extraction functions inside the WHERE clause!).
*/

--CREATE TABLE shield_sla_audit (
--    IncidentID INT PRIMARY KEY,
--    ThreatCodename VARCHAR(50),
--    DetectionTimestamp DATETIME2,
--    ContainmentTimestamp DATETIME2
--);

--INSERT INTO shield_sla_audit VALUES 
--(1, 'Winter Soldier', '2026-06-01 08:00:00.000', '2026-06-01 08:35:12.000'), -- 35 mins (Met)
--(2, 'Abomination Rampage', '2026-06-01 14:15:00.000', '2026-06-01 15:10:00.000'), -- 55 mins (Breached)
--(3, 'Mystic Rift', '2026-06-15 23:30:00.000', '2026-06-16 00:12:45.000'), -- 42 mins (Met)
--(4, 'Whiplash Malfunction', '2026-06-30 11:00:00.000', '2026-06-30 12:05:00.000'), -- 65 mins (Breached)
--(5, 'Ultron Drone Skirmish', '2026-07-01 02:00:00.000', '2026-07-01 02:22:00.000'); -- July (Filter Out)

SELECT
	*,
	CASE
		WHEN ContainmentTimestamp > Target_SLA_Time THEN 'SLA Breached'
		WHEN ContainmentTimestamp <= Target_SLA_Time THEN 'SLA Met'
	END AS SLA_Status
FROM
(SELECT 
	*,
	DATEDIFF(MINUTE,DetectionTimestamp,ContainmentTimestamp) as Response_Minutes,
	DATEADD(MINUTE,45,DetectionTimestamp) as Target_SLA_Time
FROM shield_sla_audit
WHERE DetectionTimestamp >= '2026-06-01' AND DetectionTimestamp < '2026-07-01')t;

/*
Challenge #9 (Date & Time Functions): Weekend SLA Postponement
Let's test your ability to handle complex operational business shifts. In enterprise logistics and financial systems, if a deadline lands on a weekend, it must dynamically roll forward to the next open business day.
SQL Task: The Stark Industries Logistics Core needs an advanced "Operational Briefing Tracker". Write a query that computes the following metrics for active supply chain missions:
	- Day_Number: Extract the weekday integer of the ShipmentTimestamp (Assume standard US settings where 1 = Sunday and 7 = Saturday). (Use DATEPART).
	- Standard_SLA_Deadline: Calculate a baseline deadline by adding exactly 24 hours to the ShipmentTimestamp. (Use DATEADD).
	- Postponed_Briefing_Date: Stark compliance states that if a shipment goes out on a weekend, the briefing is delayed. Using a conditional CASE block:
		- If Day_Number is 7 (Saturday), add exactly 2 days to the ShipmentTimestamp to roll it to Monday.
		- If Day_Number is 1 (Sunday), add exactly 1 day to the ShipmentTimestamp to roll it to Monday.
		- If it is a standard weekday (2 through 6), keep it at the Standard_SLA_Deadline calculated in requirement 2.
	- Final_Report_String: Format that calculated Postponed_Briefing_Date into a clean text string displaying just the year, month name, and day number separated by spaces (e.g., '2026 June 15'). (Use CONCAT mixed with DATENAME and DATEPART parts).
*/
--CREATE TABLE stark_logistics_sla (
--    ShipmentID INT PRIMARY KEY,
--    CargoType VARCHAR(50),
--    ShipmentTimestamp DATETIME2
--);

--INSERT INTO stark_logistics_sla VALUES 
--(501, 'Vibranium Alloys', '2026-06-04 10:00:00'), -- Thursday (Weekday)
--(502, 'Arc Reactor Cores', '2026-06-06 14:30:00'), -- Saturday (Weekend! Push to Monday)
--(503, 'Nanotech Mesh', '2026-06-07 08:15:00'),    -- Sunday (Weekend! Push to Monday)
--(504, 'Drones Chassis', '2026-06-08 16:00:00');    -- Monday (Weekday)

SELECT
	*,
	CONCAT(DATENAME(YEAR,Postponed_Briefing_Date),' ',DATENAME(MONTH,Postponed_Briefing_Date), ' ',DATENAME(DAY,Postponed_Briefing_Date)) as Final_Report_String
FROM
(
	SELECT 
	*,
	DATEPART(WEEKDAY,ShipmentTimestamp) as Day_Number,
	DATEADD(HOUR,24,ShipmentTimestamp) as Standard_SLA_Deadline,
	CASE
		WHEN DATEPART(WEEKDAY,ShipmentTimestamp) = 7 THEN DATEADD(DAY,2,ShipmentTimestamp)
		WHEN DATEPART(WEEKDAY,ShipmentTimestamp) = 1 THEN DATEADD(DAY,1,ShipmentTimestamp)
		ELSE DATEADD(HOUR,24,ShipmentTimestamp) 
	END AS Postponed_Briefing_Date
	FROM stark_logistics_sla
)t;

/*
⏳ Challenge #10: The Ultimate Time-Zone Finale
Let's close this chapter out in style. Here is Challenge #10 again so you have it right in front of you. Solve this, and we will pack up your SQL Server sandbox and head right back to MySQL!
SQL Task: The Time Variance Authority (TVA) monitors temporal discrepancies across multiple target realities. Help them assemble a master reality synchronization ledger:
	- Timeline_UTC: Convert the raw naive BranchTimestamp into a true, global UTC Time Zone Offset (+00:00) line. (Hint: Look into the TODATETIMEOFFSET(date, offset) function).
	- Asgard_Local_Time: Asgard's chronometers run exactly +05 hours and 30 minutes ahead of UTC. Take your computed Timeline_UTC timestamp and dynamically convert it to show the local Asgard target clock. (Hint: Look into SWITCHOFFSET(datetimeoffset, new_offset)).
	- Truncated_Asgard_Hour: Clean up the calculated Asgard_Local_Time line by truncating it down to the absolute beginning of that hour (dropping trailing minutes, seconds, and milliseconds cleanly).
	- Paradox_Flag: If the Truncated_Asgard_Hour occurs strictly between 12:00:00 (Noon) and 16:00:00 (4 PM) local time inclusive, label the event 'High Risk Window'. For any other time windows, label it 'Monitored Flow'.
*/
--CREATE TABLE tva_nexus_branches (
--    BranchID INT PRIMARY KEY,
--    TimelineVariant VARCHAR(50),
--    BranchTimestamp DATETIME2
--);

--INSERT INTO tva_nexus_branches VALUES 
--(901, 'Earth-616 Variant', '2026-06-15 08:15:00.000'),
--(902, 'Loki Prime Branch', '2026-06-15 10:45:30.500'),
--(903, 'Sacred Timeline Delta', '2026-06-15 22:00:00.000');
SELECT
	*,
	CASE
		WHEN  CAST(Truncated_Asgard_Hour AS TIME) BETWEEN '12:00:00' AND '16:00:00' THEN 'High Risk Window'
		ELSE 'Monitored Flow'
	END AS Paradox_Flag
FROM 
(
	
SELECT 
	* ,
	TODATETIMEOFFSET(BranchTimestamp,'+00:00') as Timeline_UTC,
	SWITCHOFFSET(TODATETIMEOFFSET(BranchTimestamp,'+00:00'),'+05:30') as Asgard_Local_Time,
	DATETRUNC(HOUR,SWITCHOFFSET(TODATETIMEOFFSET(BranchTimestamp,'+00:00'),'+05:30'))  as Truncated_Asgard_Hour
FROM tva_nexus_branches
)t;