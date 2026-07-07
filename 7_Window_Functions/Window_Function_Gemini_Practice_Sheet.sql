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

/*
================================================================================
Challenge #1 (MySQL): The Justice League Combat Training Leaderboard
================================================================================

1. SQL Task
The Watchtower Tactical Core is tracking training simulation scores for various 
heroes across different combat sectors. They need a ranked leaderboard to award 
commendations. Write a single MySQL query that projects the following columns:

-- SectorName: 
   The training environment sector.

-- HeroName: 
   The identity of the operative.

-- Score: 
   The raw combat score achieved.

-- Row_Num: 
   Assign a strict, sequential row integer to every record within each combat 
   sector, ordered from highest score to lowest score. (No duplicates allowed).

-- Rank_Skip: 
   Assign a rank to each hero within their sector based on their score (highest 
   to lowest). If two heroes have matching scores, they must receive the same 
   rank number, and the next rank down the line must skip ahead to account for 
   the tie.

-- Rank_Dense: 
   Assign a rank to each hero within their sector based on their score (highest 
   to lowest). If two heroes tie, they must receive the same rank number, but 
   the next rank down must continue sequentially without skipping any numbers.
*/

DROP TABLE IF EXISTS watchtower_combat_training;

CREATE TABLE watchtower_combat_training (
    TrainingID INT PRIMARY KEY,
    SectorName VARCHAR(50),
    HeroName VARCHAR(50),
    Score INT
);

INSERT INTO watchtower_combat_training VALUES 
(1, 'Sector Delta', 'Batman', 98),
(2, 'Sector Delta', 'Nightwing', 95),
(3, 'Sector Delta', 'Robin', 95),       -- Tie score with Nightwing!
(4, 'Sector Delta', 'Batgirl', 88),
(5, 'Sector Gamma', 'Superman', 100),
(6, 'Sector Gamma', 'Flash', 100),      -- Tie score with Superman!
(7, 'Sector Gamma', 'Cyborg', 90);

SELECT 
	SectorName,
    HeroName,
    Score,
    ROW_NUMBER() OVER(Partition by SectorName ORDER BY Score DESC) as Row_Num,
    RANK() OVER(Partition by SectorName ORDER BY Score DESC) as Rank_Skip,
    DENSE_RANK() OVER(Partition by SectorName ORDER BY Score DESC) as Rank_Dense
FROM watchtower_combat_training;

/*
================================================================================
Challenge #2 (Ranking Functions): Level 2 - Top N Analysis with Dense Ties
================================================================================

Let's step up the difficulty by implementing a core use case from your syllabus: 
Top N Analysis combined with an explicit logical data filter via a CTE.

1. SQL Task
The S.T.A.R. Labs Weapon Testing Matrix is assessing high-energy artillery 
prototypes across different developmental tiers. They want a report showing the 
elite tier leaders. Write a single MySQL query utilizing a Common Table 
Expression (CTE) to produce this clean data asset:

-- Columns Required: 
   Project TierName, WeaponName, EnergyOutput_Terawatts, and your calculated 
   rank column.

-- Filter Rule (Top 2 Distinct Tiers): 
   Restrict the final output grid to display only the weapons that fall into 
   the top 2 unique highest energy output brackets within each TierName.

-- Tie Handling: 
   If multiple weapons tie for the top outputs, your filter must look past the 
   row counts and return all weapons occupying those top 2 distinct performance 
   plateaus.
*/
DROP TABLE IF EXISTS star_labs_weapon_tests;

CREATE TABLE star_labs_weapon_tests (
    TestID INT PRIMARY KEY,
    TierName VARCHAR(30),
    WeaponName VARCHAR(50),
    EnergyOutput_Terawatts INT
);

INSERT INTO star_labs_weapon_tests VALUES 
(1, 'Tier 1', 'Laser Cannon A', 500),
(2, 'Tier 1', 'Laser Cannon B', 500), -- Tied for 1st!
(3, 'Tier 1', 'Plasma Rifle',   450), -- 2nd unique highest output!
(4, 'Tier 1', 'Sonic Blaster',  400), -- 3rd
(5, 'Tier 2', 'Quantum Beam',    900),
(6, 'Tier 2', 'Gravity Waver',   850),
(7, 'Tier 2', 'Antimatter Core', 850), -- Tied for 2nd unique highest!
(8, 'Tier 2', 'Photon Missile',  700);

with cte_weapons_ranking as
(
SELECT 
	TierName,
    WeaponName,
    EnergyOutput_Terawatts,
    DENSE_RANK() OVER(PARTITION BY TierName ORDER BY EnergyOutput_Terawatts DESC) as weapon_rank
FROM star_labs_weapon_tests)

SELECT *
FROM cte_weapons_ranking
WHERE weapon_rank <= 2;

/*
================================================================================
Challenge #3 (Ranking Functions): Level 3 - Data Segmentation & Equalizing Processing Loads
================================================================================

Let's expand your integer-based ranking mastery to cover another high-impact 
data engineering and analytics pattern from your blueprint checklist: 
Data Segmentation & Equalizing Load Processing utilizing NTILE().

1. SQL Task
Wayne Enterprises operates an array of defense monitoring satellites. Due to 
sudden bandwidth constraints, the telemetry data pipeline is congested. They 
need to distribute incoming telemetry logs across multiple background servers. 
Write a single MySQL query that satisfies these load-balancing rules:

-- Columns Required: 
   Project LogID, SectorCode, ThreatSeverity, and your segmented bucket ID.

-- ServerBucketID (Data Segmentation): 
   Divide the logs inside each SectorCode into exactly 3 equal-sized processing 
   buckets.

-- Priority Distribution: 
   Within each sector partition, the data streams must be sorted sequentially 
   from the absolute highest ThreatSeverity score down to the lowest before 
   being bucketed. This ensures that critical, high-alert threats are grouped 
   together into the top operational segments.
*/

DROP TABLE IF EXISTS wayne_satellite_load;

CREATE TABLE wayne_satellite_load (
    LogID INT PRIMARY KEY,
    SectorCode VARCHAR(20),
    ThreatSeverity INT
);

INSERT INTO wayne_satellite_load VALUES 
(1, 'Sector-X', 95),
(2, 'Sector-X', 88), -- Sector-X has 5 total rows!
(3, 'Sector-X', 72),
(4, 'Sector-X', 60),
(5, 'Sector-X', 45),
(6, 'Sector-Y', 99),
(7, 'Sector-Y', 91), -- Sector-Y has 3 total rows!
(8, 'Sector-Y', 30);

SELECT 
	LogID,
    SectorCode,
    ThreatSeverity,
    NTILE(3) OVER(Partition by SectorCode ORDER BY ThreatSeverity DESC) ServerBucketID
FROM wayne_satellite_load;

/*
================================================================================
Challenge #4 (Ranking Functions): Level 4 - Percentage-Based Data Distribution Analysis
================================================================================

Let's transition directly to the next vital bullet point on your list: 
Percentage-Based Ranking Functions utilizing CUME_DIST() and PERCENT_RANK(). 

1. SQL Task
The Watchtower Core Grid is monitoring deep-space communications array frequencies 
for potential alien interception signatures. They need to analyze signal strength 
anomalies based on relative percentiles to flag high-risk anomalies. Write a 
single MySQL query that provides these analytical columns:

-- Columns Required: 
   Project ArrayID, SignalFrequency_MHz, and NoiseFloor_Db.

-- Percent_Rank_Score (PERCENT_RANK Analysis): 
   Calculate the relative rank of each row's NoiseFloor_Db within the entire 
   table, expressed as a fraction between 0 and 1. Sort the signals from lowest 
   noise floor to highest noise floor to track progression.

-- Cumulative_Dist_Score (CUME_DIST Analysis): 
   Calculate the cumulative distribution of each row's NoiseFloor_Db across 
   the entire table. Sort from lowest noise floor to highest.

-- Risk_Classification (Conditional Percentile Profiling): 
   Use a standard derived table subquery or CTE layer to check your 
   Cumulative_Dist_Score. If a signal occupies the top 20% highest noise floors 
   of the entire system (meaning its cumulative distribution score is strictly 
   greater than 0.80), label it 'CRITICAL FREQUENCY SURGE'. 
   Otherwise, label it 'Normal Background Static'.
*/
DROP TABLE IF EXISTS watchtower_signals;

CREATE TABLE watchtower_signals (
    ArrayID INT PRIMARY KEY,
    SignalFrequency_MHz DECIMAL(10,2),
    NoiseFloor_Db INT
);

INSERT INTO watchtower_signals VALUES 
(101, 1420.40, 30),  -- Pristine baseline signal
(102, 1665.00, 45),
(103, 1720.10, 45),  -- Tied values!
(104, 2200.00, 60),  
(105, 4800.00, 95);  -- Extreme Outlier (Top 20% bracket anchor)

SELECT
	*,
    CASE 
		WHEN Cumulative_Dist_Score > 0.80 THEN 'CRITICAL FREQUENCY SURGE'
        ELSE 'Normal Background Static'
	END Risk_Classification
FROM (
SELECT 
	*,
    PERCENT_RANK() OVER(ORDER BY NoiseFloor_Db) Percent_Rank_Score,
    CUME_DIST() OVER(ORDER BY NoiseFloor_Db) Cumulative_Dist_Score
FROM watchtower_signals)t;

/*
================================================================================
Challenge #5: Time Series Analysis — Month-over-Month (MoM) Tactical Incursions
================================================================================

1. SQL Task
The Watchtower Strategic Command is tracking monthly alien incursion counts 
across different planetary sectors. They need a continuous chronological 
timeline report to identify escalation rates. Write a single MySQL query that 
produces these exact analytical columns:

-- SectorName: 
   The designated spatial sector.

-- IncursionMonth: 
   The numeric representation of the calendar month.

-- Current_Month_Incursions: 
   The raw number of attacks recorded for that month.

-- Prior_Month_Incursions (LAG Analysis): 
   Use a value window function to fetch the incursion count from the immediate 
   prior month within that specific sector. If a month has no historical 
   baseline data (like the very first month of tracking), cleanly default the 
   output value to 0.

-- MoM_Escalation_Delta (Time-Series Comparison): 
   Calculate the literal net change in attacks between periods by running the 
   subtraction: (Current Month Incursions - Prior Month Incursions).
*/

DROP TABLE IF EXISTS watchtower_incursion_timeline;

CREATE TABLE watchtower_incursion_timeline (
    LogID INT PRIMARY KEY,
    SectorName VARCHAR(30),
    IncursionMonth INT, -- 1 = Jan, 2 = Feb, 3 = Mar
    IncursionCount INT
);

INSERT INTO watchtower_incursion_timeline VALUES 
(1, 'Sector-Arcturus', 1, 12),
(2, 'Sector-Arcturus', 2, 18), -- Feb vs Jan: Delta +6
(3, 'Sector-Arcturus', 3, 15), -- Mar vs Feb: Delta -3
(4, 'Sector-Vega',     1, 40), -- New Sector Partition!
(5, 'Sector-Vega',     2, 38); -- Feb vs Jan: Delta -2

SELECT
	*,
    Current_Month_Incursions - Prior_Month_Incursions as MoM_Escalation_Delta
FROM (
SELECT 
	SectorName,
    IncursionMonth,
    IncursionCount as Current_Month_Incursions,
    LAG(IncursionCount,1,0) OVER(PARTITION BY SectorName ORDER BY IncursionMonth) as Prior_Month_Incursions
FROM watchtower_incursion_timeline
)t;

/*
================================================================================
Challenge #6 (Value Functions): Level 2 - Time Gaps Analysis (User Retention & Event Contiguity)
================================================================================

Let's pivot directly to another heavy data engineering and analytics pattern 
explicitly detailed in your blueprint checklist: Time Gaps Analysis / Event 
Contiguity Profiling.

1. SQL Task
The Watchtower Core Shield Network is monitoring sudden chronological security 
breaches across various power nodes. To calculate defensive response windows, 
engineers must identify how much time elapses between consecutive attacks on 
the same asset. Write a single MySQL query utilizing a CTE or Subquery to 
provide this advanced tracking diagnostic:

-- Columns Required: 
   Project NodeID, BreachTime, and your calculated metrics.

-- Next_Breach_Time (LEAD Analysis): 
   Use a value window function to scan forward inside your timeline and project 
   the timestamp of the very next breach targeting that specific NodeID.

-- Minutes_Between_Breaches (Time-Gap Delta Analysis): 
   Calculate the exact length of time that passed between the current breach 
   and the next breach expressed as a whole integer count of total minutes.
   (MySQL Engine Tool: TIMESTAMPDIFF(MINUTE, start_time, end_time))

-- Asset_Status (Conditional Stream Boundary Mapping): 
   Use a searched CASE statement on your outer layer to categorize the node's 
   temporal risk state:
   - If Minutes_Between_Breaches is strictly less than or equal to 30 
     -> 'RAPID REPEAT ATTACK: CRITICAL'
   - If a breach represents the absolute last recorded event for that node 
     timeline (Next_Breach_Time IS NULL) -> 'System Stable: Monitoring active'
   - For any other window duration -> 'Standard Tactical Delta'
*/

DROP TABLE IF EXISTS watchtower_shield_breaches;

CREATE TABLE watchtower_shield_breaches (
    LogID INT PRIMARY KEY,
    NodeID VARCHAR(30),
    BreachTime DATETIME
);

INSERT INTO watchtower_shield_breaches VALUES 
(101, 'Node-Alpha', '2026-07-01 08:00:00'),
(102, 'Node-Alpha', '2026-07-01 08:15:00'), -- Gap: 15 mins (Rapid!)
(103, 'Node-Alpha', '2026-07-01 09:30:00'), -- Gap: 75 mins (Standard)
(104, 'Node-Beta',  '2026-07-01 08:00:00'), -- New Node Partition!
(105, 'Node-Beta',  '2026-07-01 08:45:00'); -- Gap: 45 mins (Standard)

SELECT 
	*,
    CASE
		WHEN Minutes_Between_Breaches <= 30 THEN 'RAPID REPEAT ATTACK: CRITICAL'
        WHEN Minutes_Between_Breaches IS NULL THEN 'System Stable: Monitoring active'
        ELSE 'Standard Tactical Delta'
	END Asset_Status
FROM
(
SELECT 
	LogID,
    NodeID,
    BreachTime,
    LEAD(BreachTime) OVER(Partition by NodeID ORDER BY BreachTime) Next_Breach_Time,
    TIMESTAMPDIFF(Minute,BreachTime,LEAD(BreachTime) OVER(Partition by NodeID ORDER BY BreachTime)) Minutes_Between_Breaches
FROM watchtower_shield_breaches
)t;

/*
================================================================================
Challenge #7 (Value Functions): Level 3 - Anchor Extremes via FIRST_VALUE & LAST_VALUE
================================================================================

Let's explore the final pair of value functions on your technical syllabus: 
FIRST_VALUE() and LAST_VALUE(). These functions allow us to look across a 
timeline partition and pick out specific extreme values from the absolute 
beginning and the absolute end of our collection.

This challenge contains one of the most heavily exploited structural traps 
in intermediate SQL technical filters.

1. SQL Task
The Watchtower Aeronautical Deck is monitoring the flight velocity profiles of 
autonomous drone test flights. Engineers need to verify acceleration efficiency 
by comparing each point in time against the drone's absolute baseline anchors. 
Write a single MySQL query that computes these columns:

-- Columns Required: 
   Output LogID, DroneCode, LogTime, and Velocity_Mach.

-- Launch_Velocity (FIRST_VALUE Analysis): 
   Project the drone's absolute first recorded velocity (chronologically sorted 
   by LogTime) onto every row within that drone's partition.

-- Terminal_Velocity (LAST_VALUE Analysis): 
   Project the drone's absolute last recorded velocity (chronologically sorted 
   by LogTime) onto every row within that drone's partition.
*/

DROP TABLE IF EXISTS watchtower_drone_telemetry;

CREATE TABLE watchtower_drone_telemetry (
    LogID INT PRIMARY KEY,
    DroneCode VARCHAR(30),
    LogTime TIME,
    Velocity_Mach DECIMAL(10,2)
);

INSERT INTO watchtower_drone_telemetry VALUES 
(1, 'Drone-X1', '14:00:00', 1.20), -- First Launch Velocity for X1
(2, 'Drone-X1', '15:00:00', 3.50), 
(3, 'Drone-X1', '16:00:00', 4.80), -- Last Terminal Velocity for X1
(4, 'Drone-Y2', '14:00:00', 0.90), -- First Launch Velocity for Y2
(5, 'Drone-Y2', '15:00:00', 2.10); -- Last Terminal Velocity for Y2

SELECT
	*,
    FIRST_VALUE(Velocity_Mach) OVER(PARTITION BY DroneCode Order By LogTime) as Launch_Velocity,
    First_value(Velocity_Mach) OVER(PARTITION BY DroneCode Order By LogTime DESC) as Terminal_Velocity, -- using first_value to implement last value functionality
	Last_value(Velocity_Mach) OVER(PARTITION BY DroneCode Order By LogTime ASC ROWS BETWEEN CURRENT ROW and UNBOUNDED FOLLOWING) as Terminal_Velocity1
FROM watchtower_drone_telemetry;

/*
================================================================================
Challenge #8 (Value Functions Master Capstone): Time Gaps & Customer Retention
================================================================================

Let's conclude your Value Functions section with a comprehensive challenge that 
tests Time Gaps & Retention Analysis—a primary requirement on your syllabus.

1. SQL Task
The Watchtower Support Core monitors distress beacon transmissions from deep-space 
colonies. To optimize rescue response grids, engineers must track colony beacon 
session habits. Write a single MySQL query utilizing a CTE that creates a 
master diagnostics asset with these columns:

-- Columns Required: 
   Project ColonyID, LogTimestamp, and SignalStatus.

-- First_Signal_Type (FIRST_VALUE Analysis): 
   Identify the absolute first SignalStatus code sent by that colony 
   chronologically.

-- Mins_Since_Prior_Signal (LAG Delta Analysis): 
   Calculate the exact number of whole minutes that elapsed between the current 
   signal timestamp and the immediate prior signal timestamp for that specific 
   colony.
   - Defensive Rule: If it is the first signal from a colony, default the 
     elapsed minutes to 0.

-- Colony_Retention_Category (Conditional Retention Analysis): 
   Use a searched CASE statement inside your outer query layer to classify the 
   colony's network connection health:
   - If Mins_Since_Prior_Signal is strictly greater than 120 (2 hours) 
     -> 'DORMANT PROFILE: RETENTION RISK'
   - If Mins_Since_Prior_Signal is between 1 and 30 minutes inclusive 
     -> 'High Continuity Stream'
   - For any other row (including the 0 default placeholders) 
     -> 'Standard Connection Interval'
*/

DROP TABLE IF EXISTS watchtower_beacon_logs;

CREATE TABLE watchtower_beacon_logs (
    LogID INT PRIMARY KEY,
    ColonyID VARCHAR(30),
    LogTimestamp DATETIME,
    SignalStatus VARCHAR(20)
);

INSERT INTO watchtower_beacon_logs VALUES 
(1, 'Colony-Alpha', '2026-07-02 01:00:00', 'PING'),     -- First signal for Alpha
(2, 'Colony-Alpha', '2026-07-02 01:15:00', 'ALERT'),    -- Gap: 15 mins (High Continuity)
(3, 'Colony-Alpha', '2026-07-02 04:30:00', 'CRITICAL'), -- Gap: 195 mins (Dormant Risk!)
(4, 'Colony-Beta',  '2026-07-02 01:00:00', 'PING'),     -- New Colony Partition!
(5, 'Colony-Beta',  '2026-07-02 01:45:00', 'PING');     -- Gap: 45 mins (Standard)

SELECT
	*,
    CASE
		WHEN Mins_Since_Prior_Signal > 120 THEN 'DORMANT PROFILE: RETENTION RISK'
        WHEN Mins_Since_Prior_Signal BETWEEN 1 AND 30 THEN 'High Continuity Stream'
        ELSE 'Standard Connection Interval'
	END as Colony_Retention_Category
FROM (SELECT 
	ColonyID,
    LogTimestamp,
    SignalStatus,
    FIRST_VALUE(SignalStatus) OVER(PARTITION BY ColonyID Order by LogTimestamp) First_Signal_Type,
    LAG(LogTimestamp,1,0) OVER(Partition by ColonyID Order By LogTimestamp) as previous,
    coalesce(TIMESTAMPDIFF(Minute,LAG(LogTimestamp,1,0) OVER(Partition by ColonyID Order By LogTimestamp),LogTimestamp), 0) Mins_Since_Prior_Signal
FROM watchtower_beacon_logs
)t;

/*
================================================================================
Challenge #9 (MySQL): The Global Power Grid Anomaly Monitor
================================================================================

1. SQL Task
The Watchtower Engineering Sector needs to isolate extreme load spikes across 
the mainframe grid. Write a single MySQL query utilizing a Common Table 
Expression (CTE) layer to generate a high-level anomaly report satisfying 
these operational metrics:

-- The CTE Layer (Calculate Streaming Baselines):
   - Rolling_Avg_Energy (Moving Window): Calculate a 3-row moving average of 
     the EnergyDraw_GW column for each SubstationID, chronologically sorted 
     by LogTime. The frame must encompass the current record and the immediate 
     2 preceding records.
   - Prev_EnergyDraw (Value Look-back): Use a value function to capture the 
     EnergyDraw_GW of the immediate prior record within that substation's timeline.
   - Defensive Fallback Rule: If a record is the absolute first entry in a 
     timeline partition and has no prior row to look back at, dynamically 
     default its Prev_EnergyDraw value to match its current row's EnergyDraw_GW value.

-- The Outer Layer (Identify & Filter Peak Anomalies):
   - Query your CTE and use an advanced ranking function to identify the absolute 
     peak row (highest calculated Rolling_Avg_Energy) for each unique SubstationID.
   - Columns to Output: Return SubstationID, LogTime, EnergyDraw_GW, 
     Prev_EnergyDraw, and Rolling_Avg_Energy.
   - Tie Handling: If there is a tie for the highest moving average within a 
     substation, return all tied rows.
*/

DROP TABLE IF EXISTS watchtower_power_grid;

CREATE TABLE watchtower_power_grid (
    LogID INT PRIMARY KEY,
    SubstationID VARCHAR(30),
    LogTime TIME,
    EnergyDraw_GW DECIMAL(10,2)
);

INSERT INTO watchtower_power_grid VALUES 
(1, 'Sub-Alpha', '08:00:00', 120.00), -- Prev_EnergyDraw should be 120.00 (Self)
(2, 'Sub-Alpha', '09:00:00', 150.00), -- Prev: 120.00
(3, 'Sub-Alpha', '10:00:00', 180.00), -- Prev: 150.00 | Rolling Avg: (120+150+180)/3 = 150.00 (Peak!)
(4, 'Sub-Alpha', '11:00:00', 90.00),  -- Prev: 180.00 | Rolling Avg: (150+180+90)/3 = 140.00
(5, 'Sub-Beta',  '08:00:00', 300.00), -- Prev_EnergyDraw should be 300.00 (Self)
(6, 'Sub-Beta',  '09:00:00', 450.00), -- Prev: 300.00
(7, 'Sub-Beta',  '10:00:00', 210.00); -- Prev: 450.00 | Rolling Avg: (300+450+210)/3 = 320.00 (Peak!)

SELECT
	*
FROM(
With CTE_streaming_baselines AS
(
SELECT 
	*,
	AVG(EnergyDraw_GW) OVER(Partition by SubstationID ORDER BY LogTime ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) Rolling_Avg_Energy,
    LAG(EnergyDraw_GW,1,EnergyDraw_GW) OVER(PARTITION BY SubstationID ORDER BY LogTime) Prev_EnergyDraw
FROM watchtower_power_grid)

SELECT
	*,
	RANK() OVER(Partition by SubstationID ORDER BY Rolling_Avg_Energy DESC) as max_rolling_avg_energy
FROM CTE_streaming_baselines)t
WHERE max_rolling_avg_energy = 1;









