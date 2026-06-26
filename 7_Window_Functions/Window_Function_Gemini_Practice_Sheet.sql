-- ======================================================================================================================================
-- 														Window Functions
-- ======================================================================================================================================
DROP TABLE IF EXISTS dc_heroes_registry;

CREATE TABLE dc_heroes_registry (
    HeroID INT PRIMARY KEY,
    HeroName VARCHAR(50),
    RealName VARCHAR(100),
    OperationalBase VARCHAR(100),
    AnnualFunding DECIMAL(12,2),
    MissionsCompleted INT,
    StatusCode CHAR(1)
);

INSERT INTO dc_heroes_registry VALUES 
(1, 'Batman', 'Bruce Wayne', 'Batcave', 9999999.99, 450, 'A'),
(2, 'Nightwing', 'Dick Grayson', 'Batcave', 75000.00, 210, 'A'),
(3, 'Batgirl', 'Barbara Gordon', 'Batcave', 45000.00, 120, 'I'),
(4, 'Martian Manhunter', 'J\'onn J\'onzz', 'Watchtower', 0.00, 315, 'A'),
(5, 'Green Lantern', 'John Stewart', 'Watchtower', 0.00, 420, 'A'),
(6, 'Hawkgirl', 'Shayera Hol', 'Watchtower', 35000.00, 185, 'I'),
(7, 'Aquaman', 'Arthur Curry', 'Atlantis', 600000.00, 240, 'A'),
(8, 'Mera', 'Mera', 'Atlantis', 200000.00, 95, 'I'),
(9, 'Superman', 'Clark Kent', 'Metropolis', 120000.00, 512, 'A'),
(10, 'Wonder Woman', 'Diana Prince', 'Themyscira', NULL, 340, 'S');

/*
================================================================================
Challenge #1 (MySQL): Watchtower Financial Projections
================================================================================

1. SQL Task
The Watchtower Tactical Core requires a strategic financial breakdown to understand 
resource allocations without losing track of individual hero deployments. 
Write a single MySQL query that provides the following columns:

-- HeroName: 
   The operational identity of the hero.

-- OperationalBase: 
   The designated headquarters.

-- AnnualFunding: 
   The hero's personal corporate stipend.

-- Total_League_Budget (Overall Analysis): 
   Calculate the grand sum total of AnnualFunding across the entire table, 
   projected onto every single row.

-- Base_Total_Budget (Total Per Group Analysis): 
   Calculate the sum total of AnnualFunding allocated only to heroes sharing 
   that specific row's OperationalBase.

-- Defensive Rule: 
   Ensure that missing or NULL values in AnnualFunding are treated as 0 inside 
   your window calculations so they do not cause calculation anomalies.
*/

SELECT 
	HeroName,
    OperationalBase,
    coalesce(AnnualFunding,0) as AnnualFunding,
    SUM(coalesce(AnnualFunding,0)) OVER() as Total_league_Budget,
    SUM(coalesce(AnnualFunding,0)) OVER(Partition by OperationalBase) as Base_Total_Budget
FROM dc_heroes_registry;

/*
================================================================================
Challenge #2 (Window Aggregates): Part-to-Whole & Comparison Analysis
================================================================================

Let's step up the complexity by exploring two major analytical pillars: 
Part-to-Whole Analysis and Comparison Analysis. We will also see how window 
functions interact dynamically with conditional logic inside the SELECT clause.

1. SQL Task
The Watchtower Oversight Committee needs an efficiency audit profile for every 
hero. Write a single MySQL query that produces these advanced analytical metrics:

-- Columns Required: 
   Keep HeroName, OperationalBase, and AnnualFunding (sanitized to default to 0 
   if NULL).

-- Base_Average_Funding (Comparison Analysis): 
   Calculate the average AnnualFunding of all heroes belonging only to that 
   row's specific OperationalBase.

-- Hero_Contribution_Pct (Part-to-Whole Analysis): 
   Compute what percentage of their total base budget an individual hero consumes. 
   Formula: (Hero's AnnualFunding / Total Base Funding) * 100.
   
   - Defensive Rule: If an entire base has a total budget of 0 (like the Watchtower), 
     a direct division will crash with a division-by-zero error. Use NULLIF() 
     dynamically on your partitioned sum denominator so that if it is 0, it yields 
     a safe fallback percentage of 0.00.

-- Funding_Allocation_Profile (Conditional Window Mapping): 
   Use a searched CASE statement inside your SELECT clause to dynamically evaluate 
   the hero's position. Compare their individual AnnualFunding directly against 
   the calculated Base Average Funding window:
   - If their personal funding is strictly greater than their base's average 
     funding -> 'Premium Resource Allocation'
   - For any other condition (or if funding is 0/NULL) -> 'Standard Resource Allocation'
*/

SELECT * FROM dc_heroes_registry;

SELECT
	*,
    CASE
		WHEN coalesce(AnnualFunding,0) > Base_Average_Funding THEN 'Premium Resource Allocation'
        WHEN coalesce(AnnualFunding,0) = 0.00 OR coalesce(AnnualFunding,0) is null THEN 'Standard Resource Allocation'
        ELSE 'Standard Resource Allocation'
	END AS Funding_Allocation_Profile
FROM
(
SELECT 
	HeroName,
    OperationalBase,
    AnnualFunding,
    AVG(coalesce(AnnualFunding,0)) OVER(PARTITION BY OperationalBase) as Base_Average_Funding,
    COALESCE(coalesce(AnnualFunding,0)*100.0 / NULLIF(SUM(coalesce(AnnualFunding,0)) OVER(Partition by OperationalBase), 0), 0.00) as Hero_Contribution_Pct
FROM dc_heroes_registry)t;

/*
================================================================================
Challenge #3 (Window Aggregates): Analytics Use Cases - Duplicate Tracking & Outlier Detection
================================================================================

Let's move directly into the analytics patterns specified in your blueprint: 
Identifying Duplicates and Outlier Detection/Extreme Comparison.

1. SQL Task
The Watchtower Security Core monitors teleportation terminal logs. Due to 
recent multiversal interference, clone signatures (duplicate telemetry records) 
are appearing, and power surges are threatening the station. Write a single 
MySQL query that scans the security logs to project these diagnostic insights:

-- Columns Required: 
   Keep LogID, TerminalName, HeroAlias, and EnergyDraw_GW.

-- Terminal_Log_Count: 
   Use a window function to count how many total times this specific HeroAlias 
   has logged into this specific TerminalName.

-- Is_Duplicate_Signal: 
   Use a searched CASE statement to analyze your windowed count. 
   - If a hero has logged into the exact same terminal more than once 
     (Terminal_Log_Count > 1), label the row 'CLONE ALERT: DUPLICATE'. 
   - Otherwise, label it 'Pristine Signal'.

-- Power_Variance_Category: 
   Use a searched CASE statement to flag energy consumption anomalies by 
   comparing the row's EnergyDraw_GW against the extreme thresholds of that 
   specific terminal group:
   - If the row's EnergyDraw_GW is exactly equal to the MAXIMUM energy draw 
     observed for that terminal -> 'Peak Surge Anchor'
   - If the row's EnergyDraw_GW is exactly equal to the MINIMUM energy draw 
     observed for that terminal -> 'Baseline Idle'
   - For any other value -> 'Standard Operational Load'
*/

DROP TABLE IF EXISTS watchtower_teleport_logs;

CREATE TABLE watchtower_teleport_logs (
    LogID INT PRIMARY KEY,
    TerminalName VARCHAR(50),
    HeroAlias VARCHAR(50),
    EnergyDraw_GW DECIMAL(10,2)
);

INSERT INTO watchtower_teleport_logs VALUES 
(1001, 'Platform Alpha', 'Superman', 450.00),
(1002, 'Platform Alpha', 'Flash', 120.00),
(1003, 'Platform Alpha', 'Superman', 520.00),   -- Duplicate Superman on Alpha! Peak Surge!
(1004, 'Platform Beta',  'Batman', 85.00),     -- Minimum on Beta
(1005, 'Platform Beta',  'Wonder Woman', 310.00),
(1006, 'Platform Beta',  'Batman', 940.00);    -- Duplicate Batman on Beta! Peak Surge!

SELECT
	*,
    CASE
		WHEN Terminal_Log_Count > 1 THEN 'CLONE ALERT: DUPLICATE'
        ELSE 'Pristine Signal'
	END as Is_Duplicate_Signal,
    CASE 
		WHEN EnergyDraw_GW = max_energydraw_gw THEN 'Peak Surge Anchor'
        WHEN EnergyDraw_GW = min_energydraw_gw THEN 'Baseline Idle'
        ELSE 'Standard Operational Load'
	END as Power_Variance_Category
FROM(SELECT 
	* ,
    COUNT(*) OVER(PARTITION BY TerminalName,HeroAlias) as Terminal_Log_Count,
    MAX(EnergyDraw_GW) OVER(Partition by TerminalName) max_energydraw_gw,
    MIN(EnergyDraw_GW) OVER(Partition by TerminalName) min_energydraw_gw
FROM watchtower_teleport_logs)t;

/*
================================================================================
Challenge #4 (Window Aggregates): Accumulating Streams - Running Totals & Rolling Averages
================================================================================

Let's move straight into the crown jewel of your window aggregate syllabus: 
Running Totals and Rolling/Moving Averages utilizing the explicit Frame Clause 
(ROWS BETWEEN ...).

1. SQL Task
The Watchtower Engineering Division is tracking continuous power cell depletion 
spikes across the main reactor grid during a high-intensity defense sequence. 
Write a single MySQL query that computes these dynamic streaming metrics:

-- Columns Required: 
   Project LogTime, ReactorCore, and EnergyDraw_MW.

-- Running_Total_Power (Running Total Analysis): 
   Calculate an accumulating, progressive running sum of EnergyDraw_MW for each 
   reactor core. The power must accumulate chronologically based on LogTime.

-- Three_Point_Moving_Avg (Rolling Average / Outlier Smoothing): 
   Calculate a moving average of power consumption for each reactor core. 
   The frame must be restricted to calculate the average of the current record 
   and the immediate 2 preceding records inside that timeline. 
   (Hint: Look into ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
*/

DROP TABLE IF EXISTS watchtower_reactor_telemetry;

CREATE TABLE watchtower_reactor_telemetry (
    LogID INT PRIMARY KEY,
    ReactorCore VARCHAR(50),
    LogTime TIME,
    EnergyDraw_MW DECIMAL(12,2)
);

INSERT INTO watchtower_reactor_telemetry VALUES 
(1, 'Core-Alpha', '01:00:00', 100.00),
(2, 'Core-Alpha', '02:00:00', 150.00),
(3, 'Core-Alpha', '03:00:00', 200.00), -- Moving Avg should combine rows 1, 2, 3
(4, 'Core-Alpha', '04:00:00', 0.00),   -- Moving Avg should combine rows 2, 3, 4
(5, 'Core-Beta',  '01:00:00', 500.00), -- Window resets for Core-Beta!
(6, 'Core-Beta',  '02:00:00', 600.00);

SELECT * FROM watchtower_reactor_telemetry;
SELECT 
	LogTime, 
	ReactorCore, 
    EnergyDraw_MW,
    SUM(EnergyDraw_MW) OVER(PARTITION BY ReactorCore ORDER BY LogTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as Running_Total_Power,
    AVG(EnergyDraw_MW) OVER(PARTITION BY ReactorCore ORDER BY LogTime ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as Three_Point_Moving_Avg
FROM watchtower_reactor_telemetry;

/*
================================================================================
Challenge #5 (Window Aggregates): Null Elimination Mechanics & Patient Telemetry
================================================================================

Let's explore another core entry on your blueprint checklist: Understanding how 
NULL behaves in the context of each window aggregate function. Specifically, we 
will test the hidden behavioral differences between running a window COUNT(*) 
versus a window COUNT(column).

1. SQL Task
The Watchtower Medical Bay is tracking recovering field agents. Due to dynamic 
trauma monitoring, some medical sensor metrics contain missing data. Write a 
single MySQL query that produces these reporting columns:

-- Columns Required: 
   Project PatientID, AgentName, InjurySeverity, and HeartRate_BPM.

-- Total_Monitored_Patients: 
   Use a window function to find the total count of all logs belonging to that 
   specific row's InjurySeverity tier. Include every single row in the 
   calculation, regardless of whether individual columns have missing metrics.

-- Patients_With_Active_Telemetry: 
   Use a window function to count how many patients in that InjurySeverity tier 
   actually have a valid, non-null value recorded inside the HeartRate_BPM column.

-- Tier_Peak_Heartrate: 
   Project the absolute highest (MAX) heart rate observed within that specific 
   severity tier onto every row. Ensure that any missing database nulls do not 
   poison or crash the evaluation.
*/

DROP TABLE IF EXISTS watchtower_medbay_telemetry;

CREATE TABLE watchtower_medbay_telemetry (
    PatientID INT PRIMARY KEY,
    AgentName VARCHAR(50),
    InjurySeverity VARCHAR(30),
    HeartRate_BPM INT -- Contains explicit NULL entries
);

INSERT INTO watchtower_medbay_telemetry VALUES 
(1, 'Nightwing', 'Critical', 145),
(2, 'Red Hood',  'Critical', NULL), -- Heart rate missing!
(3, 'Tim Drake', 'Critical', 132),
(4, 'Batgirl',   'Stable',   72),
(5, 'Spoiler',   'Stable',   NULL);  -- Heart rate missing!

SELECT 
	*,
    COUNT(*) OVER(PARTITION BY InjurySeverity) Total_Monitored_Patients,
    COUNT(HeartRate_BPM) OVER(PARTITION BY InjurySeverity) Patients_With_Active_Telemetry,
    MAX(HeartRate_BPM) OVER(PARTITION BY InjurySeverity) Tier_Peak_Heartrate
FROM watchtower_medbay_telemetry;


/*
================================================================================
🚀 Challenge #6: Aggregating the Aggregates (The S.T.A.R. Labs Velocity Matrix)
================================================================================

Let's test one of the most advanced rules on your windowing blueprint: 
"Window functions execute AFTER the GROUP BY clause and can be combined with 
group aggregates." In enterprise environments, you frequently have to collapse 
raw transactional records first, and then run rolling windows or outlier 
comparisons directly across those aggregated timeline summaries.

1. SQL Task
The scientists at S.T.A.R. Labs are monitoring particle accelerator velocity 
runs across different testing dates. Write a single MySQL query that computes 
these high-level diagnostic statistics:

-- Group Aggregation: 
   Group the raw test runs by ExperimentDate. For each unique date, calculate 
   the total velocity generated across all runs on that day. 
   Name this column Daily_Total_Velocity.

-- Three_Day_Rolling_Avg (Rolling Average on Aggregates): 
   On top of your daily groupings, use a window function to calculate a moving 
   average of the Daily_Total_Velocity. The frame must calculate the average of 
   the current date's total and the previous 2 dates' totals sequentially.

-- Global_Peak_Day_Velocity (Outlier Detection/Benchmark Analysis): 
   Use a window function to look across your daily totals and project the 
   absolute maximum daily total velocity observed across the entire testing 
   timeline onto every row as a baseline benchmark.
*/

DROP TABLE IF EXISTS star_labs_accelerator_runs;

CREATE TABLE star_labs_accelerator_runs (
    RunID INT PRIMARY KEY,
    ExperimentDate DATE,
    TestRunNumber INT,
    Velocity_Mach DECIMAL(10,2)
);

INSERT INTO star_labs_accelerator_runs VALUES 
(1, '2026-07-01', 1, 150.00),
(2, '2026-07-01', 2, 250.00), -- Total for July 1st = 400.00
(3, '2026-07-02', 1, 500.00), -- Total for July 2nd = 500.00
(4, '2026-07-03', 1, 100.00), -- Total for July 3rd = 100.00 (Rolling avg handles 400 + 500 + 100)
(5, '2026-07-04', 1, 900.00), -- Total for July 4th = 900.00 (This will be your Global Peak!)
(6, '2026-07-04', 2, 100.00); -- Total for July 4th combined = 1000.00

SELECT * FROM star_labs_accelerator_runs;
SELECT 
	ExperimentDate,
    SUM(Velocity_Mach) as Daily_Total_Velocity,
    AVG(SUM(Velocity_Mach)) OVER(ORDER BY ExperimentDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) Three_Day_Rolling_Avg,
    MAX(SUM(Velocity_Mach)) OVER() Global_Peak_Day_Velocity
FROM star_labs_accelerator_runs
GROUP BY ExperimentDate;

/*
================================================================================
Challenge #7 (Window Aggregates): Core Synthesis - Outlier Filtering via CTE Anchors
================================================================================

Let's combine your window aggregate skills with your newly unlocked CTE 
architecture tool to solve a high-stakes data engineering task: Outlier Detection 
and Data Cleansing.

1. SQL Task
The Watchtower Defense Grid is experiencing duplicate, faulty ping signals from 
deep-space monitoring satellites. They need a clean data stream. Write a single 
MySQL query using a Common Table Expression (CTE) that performs the following 
processing cascade:

-- The CTE Layer (Analyze & Flag): 
   Scan the logs and compute these window metrics:
   - Total_Ping_Count: For each row, count how many total times that specific 
     SatelliteID has sent a ping with that exact same SignalHash.
   - System_Average_Db: For each row, calculate the flat overall average 
     SignalStrength_Db across the entire table as a system baseline.

-- The Outer Layer (Filter & Project): 
   Query your CTE to return a clean manifest matching these strict analytical 
   parameters:
   - Columns to Output: Return LogID, SatelliteID, SignalHash, and SignalStrength_Db.
   - Filter Rule 1 (Deduplication): Exclude clone signatures. Only return records 
     where the Total_Ping_Count is exactly 1.
   - Filter Rule 2 (Outlier Detection): Exclude hardware degradation noise. 
     Only return rows where the individual SignalStrength_Db is strictly greater 
     than the calculated System_Average_Db.
*/

DROP TABLE IF EXISTS watchtower_satellite_pings;

CREATE TABLE watchtower_satellite_pings (
    LogID INT PRIMARY KEY,
    SatelliteID VARCHAR(30),
    SignalHash VARCHAR(50),
    SignalStrength_Db INT
);

INSERT INTO watchtower_satellite_pings VALUES 
(501, 'Sat-Alpha', 'HASH-99', 85),  -- Valid (Above system average, no duplicates)
(502, 'Sat-Alpha', 'HASH-10', 40),  -- Dropped (Below system average)
(503, 'Sat-Beta',  'HASH-22', 90),  -- Duplicate Signal 1! (Must be completely cleaned out)
(504, 'Sat-Beta',  'HASH-22', 92),  -- Duplicate Signal 2! (Must be completely cleaned out)
(505, 'Sat-Gamma', 'HASH-77', 95);  -- Valid (Above system average, no duplicates)

SELECT * FROM watchtower_satellite_pings;

WITH CTE_analysis AS
(
SELECT 
	*,
    COUNT(*) OVER(PARTITION BY SatelliteID,SignalHash) Total_Ping_Count,
    AVG(SignalStrength_Db) OVER() System_Average_Db
FROM watchtower_satellite_pings
)
SELECT
	LogID, SatelliteID, SignalHash, SignalStrength_Db
FROM CTE_analysis
WHERE Total_Ping_Count = 1 and SignalStrength_Db > System_Average_Db;

/*
================================================================================
🏆 Challenge #8: The Window Aggregate Capstone (The Metropolis Power Grid Crisis)
================================================================================

Let's do one final, comprehensive master challenge to completely lock down your 
Window Aggregate Functions & Frames checklist before you sign off on this section! 
This challenge combines multi-layer groupings, dynamic running accumulations, and 
precise text mapping metrics inside MySQL.

1. SQL Task
Metropolis is experiencing a sudden power drain due to an external temporal threat. 
The Daily Planet news desk is tracking emergency backup cells. Write a single 
MySQL query using a CTE or Subquery that creates a master tactical grid showing 
these specific metrics:

-- Accumulated_Base_Drain (Running Total with Precise Sorting): 
   For each unique row, calculate an accumulating, chronological running total of 
   PowerDrain_MW for each SubstationName. The power must accumulate sequentially 
   sorted by LogTime. Use an explicit, physical frame layout.

-- Moving_Grid_Max (Rolling Outlier Tracking): 
   Look closely at your substation timelines. Calculate a moving maximum power 
   spike observed for each substation across a dynamic frame: include the current 
   record and the immediate 2 preceding logs only. 
   (Hint: Use ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).

-- Grid_Risk_Assessment (Conditional Logic on Frames): 
   Use a searched CASE statement in your outer query to flag load thresholds:
   - If the calculated Accumulated_Base_Drain crosses strictly above 1000.00 
     -> 'CRITICAL LOAD EXCEEDED'
   - If the row's individual PowerDrain_MW is exactly equal to its localized 
     Moving_Grid_Max -> 'Active Surge Point'
   - For any other row, output 'Stable Grid Flow'
*/

DROP TABLE IF EXISTS metropolis_power_logs;

CREATE TABLE metropolis_power_logs (
    LogID INT PRIMARY KEY,
    SubstationName VARCHAR(50),
    LogTime TIME,
    PowerDrain_MW DECIMAL(12,2)
);

INSERT INTO metropolis_power_logs VALUES 
(1, 'Sector-Gotham-Border', '20:00:00', 350.00),
(2, 'Sector-Gotham-Border', '21:00:00', 450.00), -- Running Total = 800.00
(3, 'Sector-Gotham-Border', '22:00:00', 300.00), -- Running Total = 1100.00 (Critical Exceeded!)
(4, 'Sector-Downtown-Core', '20:00:00', 900.00), -- New Substation window partition!
(5, 'Sector-Downtown-Core', '21:00:00', 200.00), -- Max of rows 4 & 5 is 900
(6, 'Sector-Downtown-Core', '22:00:00', 950.00); -- Surge Point! (950 = Moving Max)

SELECT * FROM metropolis_power_logs;

WITH CTE_Master_tactical_grid
AS(
SELECT 
	*,
    SUM(PowerDrain_MW) OVER(PARTITION BY SubstationName ORDER BY LogTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as Accumulated_Base_Drain,
    MAX(PowerDrain_MW) OVER(PARTITION BY SubstationName ORDER BY LogTime ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as Moving_Grid_Max
FROM metropolis_power_logs)

SELECT
	*,
    CASE 
		WHEN Accumulated_Base_Drain > 1000.00 THEN 'CRITICAL LOAD EXCEEDED'
        WHEN PowerDrain_MW = Moving_Grid_Max THEN 'Active Surge Point'
        ELSE 'Stable Grid Flow'
	END AS Grid_Risk_Assessment
FROM CTE_Master_tactical_grid;











