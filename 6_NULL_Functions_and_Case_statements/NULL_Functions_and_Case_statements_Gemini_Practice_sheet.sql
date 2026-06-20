-- ======================================================================================================================================
-- 														NULL Functions and Case statements
-- ======================================================================================================================================

-- DROP TABLE IF EXISTS dc_heroes_registry;

-- CREATE TABLE dc_heroes_registry (
--     HeroID INT PRIMARY KEY,
--     HeroName VARCHAR(50),
--     RealName VARCHAR(100),
--     OperationalBase VARCHAR(100),
--     AnnualFunding DECIMAL(12,2),
--     MissionsCompleted INT,
--     StatusCode CHAR(1)
-- );

-- INSERT INTO dc_heroes_registry VALUES 
-- -- Batcave Cohort (Testing mixed active/inactive funding and counts)
-- (1, 'Batman', 'Bruce Wayne', 'Batcave', 9999999.99, 450, 'A'),
-- (2, 'Nightwing', 'Dick Grayson', 'Batcave', 75000.00, 210, 'A'),
-- (3, 'Batgirl', 'Barbara Gordon', 'Batcave', 45000.00, 120, 'I'),

-- -- Watchtower Native Cohort (Testing low/zero explicit funding rows)
-- (4, 'Martian Manhunter', 'J\'onn J\'onzz', 'Watchtower', 0.00, 315, 'A'),
-- (5, 'Green Lantern', 'John Stewart', 'Watchtower', 0.00, 420, 'A'),
-- (6, 'Hawkgirl', 'Shayera Hol', 'Watchtower', 35000.00, 185, 'I'),

-- -- Atlantis Sector (Testing standard mid-tier validation)
-- (7, 'Aquaman', 'Arthur Curry', 'Atlantis', 600000.00, 240, 'A'),
-- (8, 'Mera', 'Mera', 'Atlantis', 200000.00, 95, 'I'),

-- -- The "Orbiting Watchtower" Buckets (Testing NULL and 'Unknown' cleanup)
-- (9, 'Superman', 'Clark Kent', NULL, 120000.00, 512, 'A'),
-- (10, 'Wonder Woman', 'Diana Prince', NULL, NULL, 340, 'S'),
-- (11, 'The Flash', 'Barry Allen', 'Unknown', 45000.00, 195, 'A'),
-- (12, 'Cyborg', 'Victor Stone', 'Unknown', 150000.00, 160, 'I');

/*
================================================================================
Challenge #1 (MySQL): Watchtower Status & Resource Mapping
================================================================================

1. SQL Task
The Justice League Watchtower requires an optimized operational manifest. 
Write a single MySQL query that builds the following customized transformations:

-- Hero_Identity (Handling NULLs): 
   Display the hero's RealName. If their real identity is strictly confidential 
   or missing (NULL), fall back to their operational HeroName. (Use COALESCE).

-- Sanitized_Base (Handling NULLs): 
   Inspect the OperationalBase column. Use NULLIF to convert the lazy text 
   placeholder string 'Unknown' into a true database NULL. Then, wrap that 
   operation in an adjustment function so that if the base is missing or NULL, 
   it outputs 'Mobile/Orbiting'.

-- Activity_Tier (Categorizing Data via Searched CASE): 
   Evaluate the total MissionsCompleted into three clear tactical tiers:
   - If MissionsCompleted is NULL or exactly 0 -> 'Reserve Analyst'
   - If MissionsCompleted is between 1 and 200 inclusive -> 'Active Veteran'
   - If MissionsCompleted is greater than 200 -> 'League Legend'

-- Deployment_Status (Mapping Values via Simple CASE): 
   Map the single-character StatusCode column directly to its full English translation:
   - 'A' -> 'Fully Deployed'
   - 'I' -> 'Inactive/Stasis'
   - Any other value -> 'Suspended/On Leave'
*/
SELECT 
	HeroName,
    MissionsCompleted,
	coalesce(RealName,HeroName) as Hero_Identity,
    IFNULL(NULLIF(OperationalBase,'Unknown'),'Mobile/Orbiting') as Sanitized_Base,
    CASE
		WHEN MissionsCompleted is NULL or MissionsCompleted = 0 THEN 'Reserve Analyst'
        WHEN MissionsCompleted BETWEEN 1 AND 200 THEN 'Active Veteran'
        WHEN MissionsCompleted > 200 THEN 'League Legend'
	END AS Activity_Tier,
    CASE 
		WHEN StatusCode = 'A' THEN 'Fully Deployed'
        WHEN StatusCode = 'I' THEN  'Inactive/Stasis'
        ELSE 'Suspended/On Leave'
	END AS Deployment_Status
FROM dc_heroes_registry;

/*
================================================================================
Challenge #2 (Conditional Aggregation & Fleet Audits)
================================================================================

Task:
Whenever you're ready, write your single MySQL query against the 
dc_heroes_registry table to build this aggregate matrix:

-- Clean_Base: 
   Group NULL or 'Unknown' bases into 'Orbiting Watchtower'.

-- Fully_Deployed_Funding: 
   SUM() the funding only for active heroes (StatusCode = 'A'). 
   Return 0 if empty.

-- Stasis_Hero_Count: 
   COUNT() or SUM() heroes currently in stasis (StatusCode = 'I'). 
   Return 0 if empty.

-- Grouping: 
   Ensure each unique Clean_Base occupies exactly one row.
*/

SELECT * FROM dc_heroes_registry;

SELECT
	Clean_base,
    SUM(CASE WHEN StatusCode = 'A' THEN AnnualFunding ELSE 0 END) Fully_Deployed_Funding,
    SUM(CASE WHEN StatusCode = 'I' THEN 1 ELSE 0 END) Stasis_Hero_Count
FROM
(
SELECT 
	*,
    CASE 
		WHEN OperationalBase IS NULL THEN 'Orbiting Watchtower'
        WHEN OperationalBase = 'Unknown' THEN 'Orbiting Watchtower'
        ELSE OperationalBase
	END AS Clean_base
FROM dc_heroes_registry)t
GROUP BY Clean_base;

/*
================================================================================
Challenge #3
================================================================================

Now that you have mastered data structures that don't match, let's put your 
conditional skills to the test with multiple fallback paths and order 
dependencies.

1. SQL Task
The Watchtower Global Defense Grid handles automated threat monitoring logs. 
Write a priority evaluation script that projects these specific columns:

-- Active_Comms_Channel (Multi-Layer NULL Fallbacks): 
   Establish communications by testing your database backups. 
   - Inspect PrimaryComms. 
   - If it is NULL, fall back to BackupComms. 
   - If that is also NULL, fall back to the EmergencySignal. 
   - If all communication paths are missing/NULL, output the text: 'COMMUNICATION SILENCE'. 
   (Use COALESCE).

-- Response_Priority (Searched CASE Order of Operations): 
   Map the tactical priority code based on incoming telemetry metrics. 
   The exact order of these rules matters immensely because conditions overlap:
   
   - Rule 1: If the incident is not active (IsActive = 0), label it 
             'Archived Anomaly' regardless of how high or dangerous the threat level is.
   - Rule 2: If the threat level is high (DangerLevel >= 8), label it 
             'Omega Level Threat'.
   - Rule 3: If the target location is missing/NULL (SectorLocation IS NULL), 
             label it 'Uncharted Ghost Anomaly'.
   - Rule 4: For any other scenario, label it 'Standard Tactical Patrol'.
*/
-- CREATE TABLE watchtower_threat_logs (
--     ThreatID INT PRIMARY KEY,
--     ThreatName VARCHAR(100),
--     SectorLocation VARCHAR(50),
--     PrimaryComms VARCHAR(50),
--     BackupComms VARCHAR(50),
--     EmergencySignal VARCHAR(50),
--     DangerLevel INT,
--     IsActive INT
-- );

-- INSERT INTO watchtower_threat_logs VALUES 
-- (101, 'Darkseid Incursion', 'Sector 2814', 'Quantum-Link', 'Satellite-B', 'Beacon-7', 10, 1),
-- (102, 'Joker Gas Outbreak', 'Gotham City', NULL, 'Batarang-Frequency', 'Siren-Red', 7, 1),
-- (103, 'Brainiac Drone Probe', NULL, NULL, NULL, 'Sub-Space-Ping', 9, 1),
-- (104, 'LexCorp Smuggling Run', 'Metropolis', 'Laser-Comms', NULL, NULL, 4, 0), -- IsActive is 0!
-- (105, 'Bizarro Rampage', 'Metropolis', NULL, NULL, NULL, 8, 1), -- All comms are NULL!
-- (106, 'Rogue Parademon', NULL, NULL, 'Freq-9', NULL, 5, 1);

SELECT 
	*,
    coalesce(PrimaryComms,BackupComms,EmergencySignal,'COMMUNICATION SILENCE'),
    CASE 
		WHEN IsActive = 0 THEN 'Archived Anomaly'
        WHEN DangerLevel >= 8 THEN 'Omega Level Threat'
        WHEN SectorLocation IS NULL THEN 'Uncharted Ghost Anomaly'
        ELSE 'Standard Tactical Patrol'
	END AS Response_Priority
FROM watchtower_threat_logs;
    
/*
================================================================================
Challenge #4 (Nulls & CASE): Preventing Division-by-Zero & Empty String Sanitization
================================================================================

Scenario:
In production data pipelines, two major real-world anomalies crash reporting 
scripts: Division-by-Zero errors caused by empty activity counts, and dirty text 
data where empty strings ('') are mixed up with true database NULL states.

1. SQL Task
The Watchtower Fleet Command monitors Justice League starships and tactical 
vehicles. Write a single MySQL query that builds these clean indicators:

-- Damage_Rate (Preventing Division-by-Zero): 
   Calculate the rate of vehicle damage by dividing MissionsDamaged by 
   MissionsDeployed. 
   - If a vehicle has 0 deployments, a normal division (MissionsDamaged / 0) 
     will result in a blank metadata state or can break reporting tools. 
   - Use NULLIF() to turn a 0 deployment count into a true database NULL before 
     the division happens. 
   - Wrap that whole calculation inside a function so that if the result is 
     NULL, it cleanly outputs 0.0000.

-- Pilot_Classification (Sanitizing Empty Strings): 
   Inspect the PilotCode column. The field is dirty: some rows are true NULL, 
   others contain actual codes, and some contain a blank text empty string (''). 
   - Use NULLIF() to convert empty strings ('') into a true database NULL. 
   - Use a fallback function so that if the pilot code is missing or NULL, 
     it outputs 'Standard League Voluneteer'.

-- Maintenance_Urgency (Multi-Condition Mapping): 
   Use a searched CASE statement to assign a repair status based on multi-column 
   combinations:
   - If MissionsDeployed is greater than 100 AND MissionsDamaged is greater than 20 
     -> 'Immediate Refit Required'
   - If MissionsDeployed is greater than 50 but MissionsDamaged is exactly 0 
     -> 'Routine Diagnostics'
   - For any other combination, output 'Operational'
*/

/*
================================================================================
Challenge #4 (Nulls & CASE): Preventing Division-by-Zero & Empty String Sanitization
================================================================================

Scenario:
In production data pipelines, two major real-world anomalies crash reporting 
scripts: Division-by-Zero errors caused by empty activity counts, and dirty text 
data where empty strings ('') are mixed up with true database NULL states.

1. SQL Task
The Watchtower Fleet Command monitors Justice League starships and tactical 
vehicles. Write a single MySQL query that builds these clean indicators:

-- Damage_Rate (Preventing Division-by-Zero): 
   Calculate the rate of vehicle damage by dividing MissionsDamaged by 
   MissionsDeployed. 
   - If a vehicle has 0 deployments, a normal division (MissionsDamaged / 0) 
     will result in a blank metadata state or can break reporting tools. 
   - Use NULLIF() to turn a 0 deployment count into a true database NULL before 
     the division happens. 
   - Wrap that whole calculation inside a function so that if the result is 
     NULL, it cleanly outputs 0.0000.

-- Pilot_Classification (Sanitizing Empty Strings): 
   Inspect the PilotCode column. The field is dirty: some rows are true NULL, 
   others contain actual codes, and some contain a blank text empty string (''). 
   - Use NULLIF() to convert empty strings ('') into a true database NULL. 
   - Use a fallback function so that if the pilot code is missing or NULL, 
     it outputs 'Standard League Voluneteer'.

-- Maintenance_Urgency (Multi-Condition Mapping): 
   Use a searched CASE statement to assign a repair status based on multi-column 
   combinations:
   - If MissionsDeployed is greater than 100 AND MissionsDamaged is greater than 20 
     -> 'Immediate Refit Required'
   - If MissionsDeployed is greater than 50 but MissionsDamaged is exactly 0 
     -> 'Routine Diagnostics'
   - For any other combination, output 'Operational'
*/
-- CREATE TABLE dc_tactical_fleet (
--     VehicleID INT PRIMARY KEY,
--     VehicleName VARCHAR(50),
--     PilotCode VARCHAR(50), -- Contains NULLs, actual codes, and empty strings ''
--     MissionsDeployed INT,
--     MissionsDamaged INT
-- );

-- INSERT INTO dc_tactical_fleet VALUES 
-- (1, 'Batmobile (Aegis)', 'DARK-KNIGHT', 150, 25),
-- (2, 'Batwing (Stalth)', '', 65, 0),       -- Empty string pilot code!
-- (3, 'Invisible Jet', 'AMAZON-1', 120, 5),
-- (4, 'Super-Pod Delta', NULL, 0, 0),       -- MissionsDeployed is 0! (Division-by-zero risk)
-- (5, 'Flash-Cycle Prototype', 'SPEED-FORCE', 12, 1);

SELECT 
	*,
    COALESCE(MissionsDamaged / NULLIF(MissionsDeployed, 0), 0.0000) AS Damage_Rate,
    COALESCE(NULLIF(TRIM(PilotCode),''),'Standard League Voluneteer') as Pilot_Classification,
    CASE 
		WHEN MissionsDeployed > 100 AND MissionsDamaged > 20 THEN 'Immediate Refit Required'
        WHEN MissionsDeployed > 50 AND MissionsDamaged = 0 THEN 'Routine Diagnostics'
        ELSE 'Operational'
	END AS Maintenance_urgency
FROM dc_tactical_fleet;

/*
================================================================================
Challenge #5 (Nulls & CASE): The S.T.A.R. Labs Power Grid Matrix
================================================================================

Let's do one final, comprehensive challenge to fully lock down your Null Functions 
and Conditional Logic skills before transitioning to your next big architectural 
topic!

1. SQL Task
The S.T.A.R. Labs Central Core monitors backup batteries and particle accelerator 
arrays. Write a single MySQL query that builds the following custom telemetry 
indicators:

-- Grid_Identifier (Null Mapping): 
   Combine the ArrayName and SubGridCode columns. 
   - If SubGridCode is present, display it inside parentheses next to the name 
     (e.g., 'Beta Core (BG-2)'). 
   - If SubGridCode is missing or NULL, display just the ArrayName followed by 
     the text string ' (Standalone Node)'. 
   (Hint: Use a searched CASE statement containing IS NULL checks or explicit 
   conditional logic to handle the text assembly layout safely without losing data).

-- Operational_Capacity (Value Prioritization & Nulls): 
   S.T.A.R. Labs routes power using a priority chain. 
   - Check PrimaryMegawatts. If it is NULL or exactly 0, fall back to 
     AuxiliaryMegawatts. 
   - If that is also NULL or 0, default to a hardcoded emergency minimum value 
     of 50.00. 
   (Hint: Look closely at how COALESCE handles zeros versus NULLs; you might want 
   to combine NULLIF and COALESCE here to treat 0 as a missing state).

-- Risk_Profile (Complex Categorization): 
   Categorize the grid's risk profile using these multi-layer evaluation parameters:
   - If the grid is currently offline (IsOnline = 0), label it 
     'Decommissioned Grid' regardless of any other column value.
   - If PrimaryMegawatts is NULL AND AuxiliaryMegawatts is NULL, label it 
     'CRITICAL: TOTAL POWER LOSS'.
   - If the combined power (PrimaryMegawatts + AuxiliaryMegawatts) is strictly 
     less than 500.00, label it 'Low Energy Variance'.
   - For any other condition, label it 'Stable Grid Flow'.
*/

CREATE TABLE star_labs_power_grid (
    GridID INT PRIMARY KEY,
    ArrayName VARCHAR(100),
    SubGridCode VARCHAR(50),
    PrimaryMegawatts DECIMAL(10,2),
    AuxiliaryMegawatts DECIMAL(10,2),
    IsOnline INT
);

INSERT INTO star_labs_power_grid VALUES 
(1, 'Particle Accelerator Core', 'BG-2', 1200.00, 400.00, 1),
(2, 'Metahuman Containment Wing', NULL, 0.00, 250.00, 1),     -- Primary is 0! (Needs fallback)
(3, 'Cyborg Diagnostic Lab', 'CD-9', NULL, NULL, 1),         -- Total power loss!
(4, 'Time Vault Auxiliary', NULL, 150.00, 100.00, 1),        -- Combined < 500!
(5, 'Archived Pipeline Vault', 'AP-1', 900.00, 300.00, 0);   -- IsOnline is 0!

SELECT * FROM star_labs_power_grid;
SELECT
	*,
    CASE 
		WHEN SubGridCode is not null then CONCAT(ArrayName,' (',SubGridCode,')')
        ELSE CONCAT(ArrayName,' (Standalone Node)')
	END as Grid_Identifier,
    coalesce(NULLIF(PrimaryMegawatts,0.00),NULLIF(AuxiliaryMegawatts,0.00),50.00) as Operational_Capacity,
    CASE 
		WHEN IsOnline = 0 THEN 'Decommissioned Grid'
        WHEN PrimaryMegawatts is NULL AND AuxiliaryMegawatts is NULL THEN 'CRITICAL: TOTAL POWER LOSS'
        WHEN (IFNULL(PrimaryMegawatts,0.00) + IFNULL(AuxiliaryMegawatts,0.00)) < 500.00 THEN 'Low Energy Variance'
        ELSE 'Stable Grid Flow'
	END as Risk_Profile
FROM star_labs_power_grid;

/*
================================================================================
Challenge #6 (MySQL): The Vigilante Risk & Threat Audit
================================================================================

1. SQL Task
The Watchtower Cyber-Security Division is auditing unregistered street-level 
combatants operating across Gotham and Metropolis. Write a single MySQL query 
that builds the following clean columns:

-- Clean_Callsign (Handling NULLs & Empty Strings): 
   Inspect the VigilanteAlias column. The text data is dirty: some rows contain 
   blank text empty strings (''), while others are true database NULLs. 
   - Use NULLIF() to transform empty strings ('') into true NULL states.
   - Use a fallback function to display their LegalName. 
   - If their LegalName is also missing or NULL, output the final text fallback 
     string: 'Unregistered Meta'.

-- Calculated_Risk_Index (Defensive Arithmetic Operations): 
   Calculate a unified threat ranking using this mathematical expression: 
   (BaseDangerScale * 10) + SecondaryThreatWeight. 
   - Natively safeguard this equation so that if SecondaryThreatWeight is a 
     database NULL, it evaluates as 0 instead of completely wiping out the 
     entire mathematical result.

-- Sanitized_Apprehension_Status (Searched CASE Value Mapping): 
   Map the LastApprehensionYear column to its exact operational security status:
   - If the column is NULL -> 'Never Apprehended / Active'
   - If the year is strictly less than 2020 -> 'Legacy Case / Dormant'
   - For any other year value -> 'Recent Detention'
*/

CREATE TABLE dc_vigilante_audit (
    VigilanteID INT PRIMARY KEY,
    VigilanteAlias VARCHAR(50),
    LegalName VARCHAR(100),
    BaseDangerScale INT,
    SecondaryThreatWeight INT,
    LastApprehensionYear INT
);

INSERT INTO dc_vigilante_audit VALUES 
(1, 'Red Hood', 'Jason Todd', 7, 15, 2024),
(2, '', 'Selina Kyle', 5, NULL, 2019),          -- Empty string alias & NULL weight
(3, 'Deathstroke', 'Slade Wilson', 9, 25, 2025),
(4, NULL, NULL, 4, 5, NULL),                     -- NULL alias, NULL legal name, NULL year
(5, 'Spoiler', 'Stephanie Brown', 3, NULL, NULL);-- NULL weight and NULL year

SELECT * FROM dc_vigilante_audit;
SELECT 
	*,
    coalesce(NULLIF(TRIM(VigilanteAlias),''),LegalName,'Unregistered Meta') as Clean_Callsign,
    ((IFNULL(BaseDangerScale,0)*10) + IFNULL(SecondaryThreatWeight,0)) as Calculated_Risk_Index,
    CASE 
		WHEN LastApprehensionYear is NULL THEN 'Never Apprehended / Active'
        WHEN LastApprehensionYear < 2020 THEN 'Legacy Case / Dormant'
        ELSE 'Recent Detention'
	END AS Sanitized_Apprehension_Status
FROM dc_vigilante_audit;






















