-- ======================================================================================================================================
-- 																		Subqueries
-- ======================================================================================================================================
/*
================================================================================
Challenge #1 (MySQL): Level 1 - The Elite Vanguard Filter
================================================================================

1. SQL Task
The Justice League tactical core needs to identify top-tier operatives for an 
upcoming deployment. Write a single MySQL query using an independent Scalar 
Subquery inside your WHERE clause to satisfy these parameters:

-- Columns Required: 
   Output the HeroName, OperationalBase, and MissionsCompleted.

-- Filter Rule: 
   Restrict your output to display only those heroes who have completed strictly 
   more missions than the overall mathematical average of all missions completed 
   across the entire table.

-- SARGability Check: 
   Ensure your filter comparison leaves the table's physical column bare on the 
   left side of your comparison operator so it remains completely index-friendly.
*/

DROP TABLE IF EXISTS dc_heroes_registry;

CREATE TABLE dc_heroes_registry (
    HeroID INT PRIMARY KEY,
    HeroName VARCHAR(50),
    RealName VARCHAR(100),
    OperationalBase VARCHAR(100),
    MissionsCompleted INT
);

INSERT INTO dc_heroes_registry VALUES 
(1, 'Batman', 'Bruce Wayne', 'Batcave', 450),
(2, 'Nightwing', 'Dick Grayson', 'Batcave', 210),
(3, 'Batgirl', 'Barbara Gordon', 'Batcave', 120),
(4, 'Martian Manhunter', 'J\'onn J\'onzz', 'Watchtower', 315),
(5, 'Green Lantern', 'John Stewart', 'Watchtower', 420),
(6, 'Hawkgirl', 'Shayera Hol', 'Watchtower', 185),
(7, 'Aquaman', 'Arthur Curry', 'Atlantis', 240),
(8, 'Superman', 'Clark Kent', 'Metropolis', 512);

SELECT
	HeroName,
    OperationalBase,
    MissionsCompleted
FROM dc_heroes_registry
WHERE MissionsCompleted > (SELECT AVG(MissionsCompleted) FROM dc_heroes_registry);

/*
================================================================================
Challenge #2 (Subqueries): Level 2 - Independent Multi-Row Filtering with IN
================================================================================

Let's step up to your next roadmap requirement: Independent Table-Result 
Subqueries utilizing the IN operator for dynamic and complex filtering.

1. SQL Task
The Arkham Asylum Security Grid is tracking recent inmate cell transfers. 
System administrators need to isolate logs belonging to inmates classified as 
"High Threat Level" who have triggered system overrides. Write a single MySQL 
query utilizing an independent Multi-Row Subquery to produce this asset:

-- Columns Required: 
   Project LogID, InmateName, TransferDate, and SecurityOverrideCode.

-- Filter Rule: 
   Restrict your output to display only those transfer records where the 
   InmateName is found within the set of inmates marked with a ThreatLevel = 'Critical' 
   inside the profile registry table.

-- Constraint: 
   Do not use a JOIN statement for this challenge. Solve it purely by passing 
   an independent table subquery to a WHERE ... IN clause.
*/

DROP TABLE IF EXISTS arkham_inmate_profiles;
DROP TABLE IF EXISTS arkham_transfer_logs;

CREATE TABLE arkham_inmate_profiles (
    InmateID INT PRIMARY KEY,
    InmateName VARCHAR(50),
    ThreatLevel VARCHAR(20)
);

CREATE TABLE arkham_transfer_logs (
    LogID INT PRIMARY KEY,
    InmateName VARCHAR(50),
    TransferDate DATE,
    SecurityOverrideCode VARCHAR(10)
);

INSERT INTO arkham_inmate_profiles VALUES 
(1, 'Joker', 'Critical'),
(2, 'Harley Quinn', 'High'),
(3, 'Riddler', 'Medium'),
(4, 'Bane', 'Critical'),
(5, 'Poison Ivy', 'High');

INSERT INTO arkham_transfer_logs VALUES 
(101, 'Joker', '2026-03-01', 'OR-999'),
(102, 'Riddler', '2026-03-02', 'OR-112'),
(103, 'Bane', '2026-03-05', 'OR-884'),
(104, 'Harley Quinn', '2026-03-06', 'OR-441');


SELECT * 
FROM arkham_transfer_logs
WHERE InmateName IN (SELECT InmateName FROM arkham_inmate_profiles WHERE ThreatLevel = 'Critical');


/*
================================================================================
Challenge #3 (Subqueries): Level 3 - The Correlated Subquery (Row-by-Row Evaluation)
================================================================================

Let's move straight to the premier hotspot of subquery technical interviews, a 
concept explicitly called out at the bottom of your revision blueprint: 
Correlated Subqueries.

Unlike the independent queries we just wrote, a correlated subquery possesses 
a direct biological link to the outer query. It cannot be run on its own because 
it requires a value from the current outer row to evaluate its inner logic.

1. SQL Task
The Gotham City Police Department (GCPD) Evidence Matrix tracks contraband 
seized across different criminal cases. High-ranking detectives need to identify 
standout evidence pieces to present to the District Attorney. Write a single 
MySQL query utilizing a Correlated Subquery to produce this tactical asset:

-- Columns Required: 
   Project EvidenceID, CaseCategory, ItemName, and StreetValue_USD.

-- Filter Rule (The Correlation Constraint): 
   Restrict your final grid output to display only those individual evidence 
   records whose StreetValue_USD is strictly greater than the mathematical 
   average value of all evidence items belonging to that exact same CaseCategory.

-- Core Requirement: 
   You must explicitly correlate the inner subquery table reference to the outer 
   query table reference row-by-row using table aliases 
   (e.g., outer_table.col = inner_table.col).
*/

DROP TABLE IF EXISTS gcpd_evidence_matrix;

CREATE TABLE gcpd_evidence_matrix (
    EvidenceID INT PRIMARY KEY,
    CaseCategory VARCHAR(50),
    ItemName VARCHAR(100),
    StreetValue_USD DECIMAL(10,2)
);

INSERT INTO gcpd_evidence_matrix VALUES 
(1, 'Cyber Crime', 'Encrypted Server Rig',  15000.00), -- Avg for Cyber: (15k + 5k)/2 = 10k. 15k > 10k -> KEEP!
(2, 'Cyber Crime', 'Decryption USB Drive',   5000.00), -- 5k < 10k -> DROP
(3, 'Heist Operations', 'Thermal Drill',      45000.00), -- Avg for Heist: (45k + 80k + 25k)/3 = 50k. 45k < 50k -> DROP
(4, 'Heist Operations', 'Diamond Cache',       80000.00), -- 80k > 50k -> KEEP!
(5, 'Heist Operations', 'Laser Grid Bypass',  25000.00), -- 25k < 50k -> DROP
(6, 'Smuggling',        'Submersible Drone',  95000.00); -- Only 1 item in Smuggling! Avg is 95k. 95k NOT > 95k -> DROP

SELECT
	EvidenceID,
    CaseCategory,
    ItemName,
    StreetValue_USD
FROM
(
SELECT
	*,
    (SELECT AVG(s.StreetValue_USD) FROM gcpd_evidence_matrix s GROUP BY CaseCategory HAVING 
	m.CaseCategory = s.CaseCategory AND m.StreetValue_USD > AVG(s.StreetValue_USD)) as avg_value
FROM gcpd_evidence_matrix m) t
WHERE avg_value is not null;

SELECT
	EvidenceID,
    CaseCategory,
    ItemName,
    StreetValue_USD
FROM gcpd_evidence_matrix m
WHERE StreetValue_USD > (
SELECT AVG(StreetValue_USD) FROM gcpd_evidence_matrix s WHERE s.CaseCategory = m.CaseCategory);

/*
================================================================================
Challenge #4 (Subqueries): Level 4 - Semi-Joins & Existence Verification with EXISTS
================================================================================

Let's test another major item directly from your revision list: Checking the 
existence of rows from another table. This focuses on the behavioral difference 
between IN and EXISTS—a classic senior-level technical interview hotspot.

1. SQL Task
Wayne Enterprises Aerospace Division runs high-profile satellite projects. They 
have a core table of operational_projects and a secondary tracking table of 
system_incident_reports.

Management wants a list of all projects that are currently experiencing safety 
concerns. Write a single MySQL query utilizing a Correlated EXISTS subquery 
to satisfy these rules:

-- Columns Required: 
   Project ProjectID, ProjectName, and Budget_Millions.

-- Filter Rule: 
   Display a project only if it has at least one recorded incident inside the 
   system_incident_reports table where the Severity is marked as 'Critical'.

-- Strict Constraint: 
   Do not use a standard JOIN or a WHERE ... IN clause. Solve this purely by 
   utilizing the boolean EXISTS operator coupled with an inner correlation link.
*/

DROP TABLE IF EXISTS system_incident_reports;
DROP TABLE IF EXISTS operational_projects;

CREATE TABLE operational_projects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(50),
    Budget_Millions DECIMAL(10,2)
);

CREATE TABLE system_incident_reports (
    IncidentID INT PRIMARY KEY,
    ProjectID INT,
    IncidentDescription VARCHAR(100),
    Severity VARCHAR(20)
);

INSERT INTO operational_projects VALUES 
(1, 'Project Icarus',  45.50),
(2, 'Project Gaea',    120.00),
(3, 'Project Chronos',  85.00),
(4, 'Project Atlas',    210.00);

INSERT INTO system_incident_reports VALUES 
(501, 1, 'Thruster fuel line pressure drop', 'High'),
(502, 1, 'Thermal shield micro-fracture',    'Critical'), -- Icarus has a Critical incident!
(503, 2, 'Communication latency anomaly',     'Low'),
(504, 3, 'Navigation gyroscope desync',       'Critical'); -- Chronos has a Critical incident!
-- Project Atlas (4) has no incidents at all.

SELECT * FROM system_incident_reports;
SELECT 
	* 
FROM operational_projects m
WHERE EXISTS (SELECT 1 FROM system_incident_reports s WHERE s.ProjectID = m.ProjectID AND s.Severity = 'High');

/*
================================================================================
Challenge #5 (Subqueries): Level 5 - Derived Tables (Subqueries in the FROM Clause)
================================================================================

Let's move directly to another core classification on your checklist: 
Location-based subqueries, specifically targeting Derived Tables (Subqueries 
embedded inside the FROM clause).

In data engineering pipelines, this pattern is heavily utilized to calculate 
aggregated totals or pre-filter massive datasets before joining tables, 
preventing the engine from performing resource-heavy cartesian computations.

1. SQL Task
The Gotham Central Bank Vault is auditing high-volume cash accounts. To spot 
unusual asset hoarding, auditors need a report that matches account details 
with aggregated transaction metrics. Write a single MySQL query that uses a 
Derived Table Subquery inside the FROM clause to fulfill these parameters:

-- Columns Required: 
   Output AccountID, AccountHolder, AccountType, and Total_Deposits_USD.

-- Derived Table Requirement: 
   Your subquery must scan the vault_transactions table, grouping records by 
   AccountID to calculate the total sum of deposits (TransactionType = 'Deposit') 
   for each account. Alias this calculated column as Total_Deposits_USD. 
   Assign a mandatory alias to the derived table itself (e.g., tx_summary).

-- Outer Filtering Rule: 
   Join this derived summary table back to the primary account details table 
   on AccountID. Filter the final report to display only those accounts whose 
   total deposit value is strictly greater than 500000.00.
*/

DROP TABLE IF EXISTS vault_transactions;
DROP TABLE IF EXISTS bank_accounts;

CREATE TABLE bank_accounts (
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(50),
    AccountType VARCHAR(20)
);

CREATE TABLE vault_transactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT,
    TransactionType VARCHAR(20), -- 'Deposit' or 'Withdrawal'
    Amount_USD DECIMAL(15,2)
);

INSERT INTO bank_accounts VALUES 
(1001, 'Bruce Wayne', 'Corporate'),
(1002, 'Selina Kyle',  'Personal'),
(1003, 'Harvey Dent',  'Escrow'),
(1004, 'Oswald C.',    'Corporate');

INSERT INTO vault_transactions VALUES 
(1, 1001, 'Deposit',    400000.00),
(2, 1001, 'Deposit',    250000.00), -- Bruce total deposits = 650,000 (Keep!)
(3, 1002, 'Deposit',    450000.00), -- Selina total deposits = 450,000 (Drop)
(4, 1003, 'Withdrawal', 900000.00), -- Harvey has a withdrawal, no deposits! (Drop)
(5, 1004, 'Deposit',    600000.00); -- Oswald total deposits = 600,000 (Keep!)

SELECT 
	m.AccountID,
    m.AccountHolder,
    m.AccountType,
    s.Total_Deposits_USD
FROM bank_accounts m
JOIN (
	SELECT 
		AccountID,
		TransactionType,
		SUM(Amount_USD) as Total_Deposits_USD
	FROM vault_transactions
    WHERE TransactionType = 'Deposit'
	GROUP BY AccountID,TransactionType) s
ON m.AccountID = s.AccountID
WHERE s.Total_Deposits_USD > 500000;

/*
================================================================================
Challenge #6 (Subqueries): Level 6 - Row-Constructor Subqueries
================================================================================

1. SQL Task
The Gotham City Port Authority shipping yards track container arrivals. Cargo 
auditors want a report identifying the "Peak Configuration Containers"—the 
specific shipments that match the absolute maximum cargo weight recorded for 
their respective Hazard Classification.

Write a single MySQL query utilizing an independent Multi-Column Row-Constructor 
Subquery inside your WHERE clause to satisfy these rules:

-- Columns Required: 
   Project ShipmentID, HazardClass, ContainerType, and CargoWeight_Tons.

-- The Subquery Metric: 
   Find the maximum CargoWeight_Tons for each unique HazardClass using a 
   GROUP BY operation.

-- The Matching Rule: 
   Your outer query filter must evaluate both columns (HazardClass, CargoWeight_Tons) 
   together as a single composite structural tuple against the subquery list 
   using a single IN expression:
   Syntax Pattern: WHERE (col1, col2) IN (SELECT col1, col2 FROM ...)

-- Strict Constraint: 
   Do not use a JOIN statement or a correlated subquery for this solution. Solve 
   it purely through independent multi-column tuple matching.
*/

DROP TABLE IF EXISTS port_shipments;

CREATE TABLE port_shipments (
    ShipmentID INT PRIMARY KEY,
    HazardClass VARCHAR(20),
    ContainerType VARCHAR(20),
    CargoWeight_Tons INT
);

INSERT INTO port_shipments VALUES 
(1, 'Class-A', 'Reefer',  25),
(2, 'Class-A', 'Dry Van', 35), -- Peak configuration for Class-A! (35 Tons)
(3, 'Class-B', 'Tanker',  50), -- Peak configuration for Class-B! (50 Tons)
(4, 'Class-B', 'Reefer',  42),
(5, 'Class-A', 'Dry Van', 35); -- Another matching peak tuple!

SELECT 
	ShipmentID,
    HazardClass,
    ContainerType,
    CargoWeight_Tons
FROM port_shipments
WHERE (HazardClass, CargoWeight_Tons) IN 
(SELECT HazardClass, MAX(CargoWeight_Tons) FROM port_shipments GROUP BY HazardClass);














