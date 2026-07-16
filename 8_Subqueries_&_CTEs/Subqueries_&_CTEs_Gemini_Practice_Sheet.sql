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

/*
================================================================================
Challenge: The SELECT Clause Correlated Scalar Subquery
================================================================================

1. SQL Task
The Gotham City Meteorological Network monitors weather sensor installations 
across the region. Maintenance supervisors need a operational report that 
displays granular sensor metrics side-by-side with localized environmental 
reference baselines. Write a single MySQL query utilizing a Scalar Subquery 
inside the SELECT projection list to produce this asset:

-- Columns Required: 
   Project SensorID, LocationZone, Temperature_Celsius, and your calculated 
   baseline column (Zone_Average_Temperature).

-- Zone_Average_Temperature (The SELECT Clause Subquery): 
   For every individual sensor row evaluated, your query must execute an inline 
   scalar subquery that calculates the mathematical average temperature of all 
   sensors located within that exact same LocationZone.

-- Strict Constraint: 
   Do not use any JOIN statements or Window Functions (OVER()) for this 
   challenge. Solve it purely by applying a row-by-row correlated subquery 
   inside the main SELECT projection block.
*/

DROP TABLE IF EXISTS weather_sensors;

CREATE TABLE weather_sensors (
    SensorID INT PRIMARY KEY,
    LocationZone VARCHAR(30),
    SensorType VARCHAR(20),
    Temperature_Celsius DECIMAL(5,2)
);

INSERT INTO weather_sensors VALUES 
(1, 'Gotham-North', 'Thermal', 12.50),
(2, 'Gotham-North', 'Baro',    14.50), -- Avg for North: (12.5 + 14.5)/2 = 13.50
(3, 'Arkham-Island', 'Thermal',  8.00),
(4, 'Arkham-Island', 'Hydro',   10.00), -- Avg for Arkham: (8.0 + 10.0)/2 = 9.00
(5, 'Gotham-North', 'Hydro',   13.50); -- Wait, new row for North! (12.5+14.5+13.5)/3 = 13.50

SELECT 
	m.SensorID,
    m.LocationZone,
    m.Temperature_Celsius,
    (SELECT AVG(Temperature_Celsius) FROM weather_sensors s WHERE s.LocationZone = m.LocationZone) as Zone_Average_Temperature
FROM weather_sensors m;
/*
================================================================================
Challenge #8 (Subqueries): Level 8 - Advanced Staging in the JOIN Clause
================================================================================

1. SQL Task
The Wayne Enterprises Quantum Computing Division tracks server node processing 
errors (node_error_logs) alongside a main master inventory table (mainframe_nodes).

Data architects want a comprehensive stability report that shows all production 
nodes alongside their total error counts. Write a single MySQL query that satisfies 
these advanced engineering parameters:

-- Columns Required: 
   Project NodeID, NodeName, OperationalStatus, and Total_Critical_Errors.

-- The JOIN Subquery Layer: 
   You must write an independent table subquery nested directly inside a LEFT JOIN 
   clause that scans node_error_logs. This inner query must pre-filter for errors 
   marked strictly as ErrorSeverity = 'Critical' and group them by NodeID to 
   count total errors per node. Alias this counted column.

-- The Outer Preservation Rule: 
   Because we are using a LEFT JOIN against the master inventory, nodes that 
   have zero critical errors must still appear in the final report. For these 
   stable nodes, their Total_Critical_Errors column must display a clean 0 
   placeholder instead of a raw database NULL value.

-- Strict Constraint: 
   You cannot filter the error severity or perform the grouping aggregation 
   in the outer query's main WHERE or GROUP BY layers. All error consolidation 
   and filtering must occur entirely inside the JOIN clause subquery staging box.
*/
DROP TABLE IF EXISTS node_error_logs;
DROP TABLE IF EXISTS mainframe_nodes;

CREATE TABLE mainframe_nodes (
    NodeID INT PRIMARY KEY,
    NodeName VARCHAR(50),
    OperationalStatus VARCHAR(20)
);

CREATE TABLE node_error_logs (
    LogID INT PRIMARY KEY,
    NodeID INT,
    ErrorMessage VARCHAR(100),
    ErrorSeverity VARCHAR(20)
);

INSERT INTO mainframe_nodes VALUES 
(101, 'Quantum-Core-01', 'Active'),
(102, 'Quantum-Core-02', 'Active'),
(103, 'Storage-Vault-A', 'Maintenance'),
(104, 'Backup-Grid-Zero', 'Standby');

INSERT INTO node_error_logs VALUES 
(1, 101, 'Sub-atomic sync failure',  'Critical'),
(2, 101, 'Thermal baseline drift',  'Low'),
(3, 101, 'Entanglement collapse',   'Critical'), -- Node 101 has 2 Critical errors!
(4, 103, 'Magnetic cell discharge', 'Critical'); -- Node 103 has 1 Critical error!
-- Nodes 102 and 104 have absolutely zero error logs.

SELECT 
	m.NodeID,
    m.NodeName,
    m.OperationalStatus,
    coalesce(s.Total_Critical_Errors,0) as Total_Critical_Errors
FROM mainframe_nodes m
LEFT JOIN (
SELECT 
	NodeID,
    COUNT(*) as Total_Critical_Errors
FROM node_error_logs
WHERE ErrorSeverity = 'Critical'
GROUP BY NodeID)s
ON m.NodeID = s.NodeID;

-- ======================================================================================================================================
--                                                             CTEs
-- ======================================================================================================================================

/*
================================================================================
Challenge #1 (CTE): Level 1 - Standalone Non-Recursive CTE
================================================================================

1. SQL Task
The S.T.A.R. Labs Particle Accelerator Grid is recording raw metrics from its 
high-energy collision chambers. To calibrate the primary magnets, engineers 
require a report detailing adjusted particle speeds. Write a single MySQL 
query utilizing a standalone Common Table Expression (CTE) that fulfills 
these staging rules:

-- The CTE Staging Layer (CTE_accelerator_metrics):
   - Query the star_labs_accelerator_logs table.
   - Project LogID, CoreSection, SystemStatus, and the raw ParticleVelocity_kms.
   - Calculate a new column aliased as OptimizedVelocity by scaling the raw 
     ParticleVelocity_kms up by exactly 5% (multiply by 1.05).

-- The Outer Primary Query:
   - Reference your freshly staged CTE virtual table.
   - Project all columns (LogID, CoreSection, SystemStatus, ParticleVelocity_kms, 
     and OptimizedVelocity).
   - Filter the final output grid to display only those records where the 
     SystemStatus is strictly equal to 'Stable' AND the computed 
     OptimizedVelocity is strictly greater than 5000.00.
*/

DROP TABLE IF EXISTS star_labs_accelerator_logs;

CREATE TABLE star_labs_accelerator_logs (
    LogID INT PRIMARY KEY,
    CoreSection VARCHAR(30),
    ParticleVelocity_kms DECIMAL(10,2),
    SystemStatus VARCHAR(20)
);

INSERT INTO star_labs_accelerator_logs VALUES 
(1, 'Section-Alpha', 4800.00, 'Stable'),   -- Opt: 4800 * 1.05 = 5040 (Keep!)
(2, 'Section-Alpha', 5100.00, 'Warning'),  -- Opt: 5355 but Warning status! (Drop)
(3, 'Section-Beta',  4200.00, 'Stable'),   -- Opt: 4410 (Below 5000 baseline -> Drop)
(4, 'Section-Gamma', 4950.00, 'Stable');   -- Opt: 4950 * 1.05 = 5197.5 (Keep!)

WITH CTE_accelerator_metrics as
(
	SELECT
		LogID, 
        CoreSection,
        SystemStatus,
        ParticleVelocity_kms,
        ParticleVelocity_kms * 1.05 as OptimizedVelocity
	FROM star_labs_accelerator_logs
)
SELECT
	*
FROM CTE_accelerator_metrics
WHERE SystemStatus = 'Stable' and OptimizedVelocity > 5000;		

/*
================================================================================
Challenge #2 (CTEs): Level 2 - Multiple & Nested CTE Chaining
================================================================================

1. SQL Task
The Wayne Enterprises Quantum Computing Division monitors network traffic flows 
across active mainframe sectors. To audit pipeline strain, infrastructure 
architects want an operational report isolating high-volume server groups. 
Write a single MySQL query utilizing Nested/Chained CTEs to satisfy these metrics:

-- CTE Layer 1 (CTE_raw_filtering):
   - Scan the wayne_quantum_logs base physical table.
   - Extract the columns NodeGroup, DataProcessed_GB, and Status.
   - Filter out records early, keeping only rows where Status = 'Active'.
   - Create a calculated column aliased as DataProcessed_Bits by multiplying 
     DataProcessed_GB by exactly 8 (converting gigabytes to gigabits).

-- CTE Layer 2 (CTE_aggregated_nodes):
   - Crucial Nesting Constraint: This second CTE must read directly from your 
     first CTE (CTE_raw_filtering) rather than the base physical table.
   - Group rows by NodeGroup.
   - Calculate Avg_Bits_Processed (the mathematical average of your freshly 
     calculated DataProcessed_Bits column).
   - Calculate Total_Logs_Count (a structural count of total records processed 
     for that group).

-- Outer Primary Query:
   - Select all available aggregated metrics from CTE_aggregated_nodes.
   - Apply a strict filter constraint to return only those node groups that 
     have a Total_Logs_Count strictly greater than or equal to 2.
*/

	DROP TABLE IF EXISTS wayne_quantum_logs;

CREATE TABLE wayne_quantum_logs (
    LogID INT PRIMARY KEY,
    NodeGroup VARCHAR(30),
    DataProcessed_GB DECIMAL(10,2),
    Status VARCHAR(20)
);

INSERT INTO wayne_quantum_logs VALUES 
(1, 'Group-Omega',  50.00,  'Active'),   -- Bits: 400
(2, 'Group-Omega',  120.00, 'Active'),   -- Bits: 960  -> Omega: Avg = 680, Count = 2 (KEEP!)
(3, 'Group-Alpha',  80.00,  'Active'),   -- Bits: 640
(4, 'Group-Alpha',  90.00,  'Inactive'), -- Inactive! Dropped early in CTE 1. -> Alpha count becomes 1 (DROP)
(5, 'Group-Sigma',  200.00, 'Active');   -- Bits: 1600 -> Sigma count = 1 (DROP)

WITH CTE_raw_filtering AS
(
	SELECT 
		NodeGroup, 
        DataProcessed_GB,
        Status,
        DataProcessed_GB * 8 as DataProcessed_Bits
    FROM wayne_quantum_logs
    WHERE status = 'Active'
)
, CTE_aggregated_nodes as
(
SELECT
	NodeGroup,
    AVG(DataProcessed_Bits) as Avg_Bits_Processed,
    COUNT(*) as Total_Logs_Count
FROM CTE_raw_filtering
GROUP BY NodeGroup
)

SELECT * FROM CTE_aggregated_nodes
WHERE Total_Logs_Count >= 2;

/*
================================================================================
Challenge #3 (CTEs): Level 3 - The Recursive CTE (Self-Referencing Loops)
================================================================================

Let's complete your CTE module with the absolute peak requirement on your syllabus: 
Recursive CTEs.

Recursive CTEs are highly unique because they reference themselves in a loop. They 
are used extensively by Data Engineers to map out network graphs, hierarchical 
organizational charts, multi-tier product bills of materials, or to programmatically 
generate custom dates and sequence numbers on the fly.

1. SQL Task
The Watchtower Communication Relay Sector monitors signal beams hopping through 
deep-space communication nodes. To audit data routing efficiency, engineers need 
to trace the physical path and calculate total transmission hop levels from a 
master root node down to every connected leaf node. Write a single MySQL query 
utilizing a Recursive CTE to map this network tree:

-- Columns Required: 
   Project NodeID, ParentNodeID, HopLevel, and NetworkPath.

-- The Anchor Member: 
   - Identify the root entry of your system—the node that has no parent 
     (ParentNodeID IS NULL).
   - Set its initial structural HopLevel baseline to 1.
   - Construct its base NetworkPath string to display its own NodeID cast or 
     formatted as a character sequence.

-- The Recursive Member: 
   - Combine the anchor data by referencing the CTE back onto the physical base 
     table (using a UNION ALL operator) where the base table's ParentNodeID 
     matches the active CTE's NodeID.
   - For each recursive iteration, increment the HopLevel by exactly +1.
   - Dynamically append the newly discovered node to the end of your tracking 
     path string using the native text combiner: CONCAT(prior_path, ' -> ', current_node)

-- Outer Pass: 
   Select all records from your recursive container, sorted chronologically 
   by HopLevel ascending.
*/

DROP TABLE IF EXISTS watchtower_network_nodes;

CREATE TABLE watchtower_network_nodes (
    NodeID VARCHAR(30) PRIMARY KEY,
    ParentNodeID VARCHAR(30)
);

INSERT INTO watchtower_network_nodes VALUES 
('Root-Alpha',  NULL),          -- The anchor source node!
('Relay-Beta',  'Root-Alpha'),  -- Hop level 2
('Relay-Gamma', 'Root-Alpha'),  -- Hop level 2
('Pod-Delta',   'Relay-Beta'),   -- Hop level 3 (Child of Beta)
('Leaf-Epsilon', 'Pod-Delta');   -- Hop level 4 (Child of Delta)

SELECT
	*
FROM watchtower_network_nodes;

WITH RECURSIVE CTE_network_tree as
(
	SELECT
		NodeID, 
        ParentNodeID,
        1 as HopLevel,
        CAST(NodeID as CHAR(1000)) as NetworkPath
	FROM watchtower_network_nodes
    WHERE ParentNodeID is NULL
    UNION ALL
    -- rescursive query
    SELECT
		nn.NodeID,
        nn.ParentNodeID,
        nt.Hoplevel + 1 as HopLevel ,
        CONCAT(nt.NetworkPath,' -> ' ,nn.NodeID)
    FROM watchtower_network_nodes  nn
    INNER JOIN CTE_network_tree nt
    ON nn.ParentNodeID = nt.NodeID 
)
SELECT
	*
FROM CTE_network_tree;

/*
================================================================================
Challenge #4 (CTEs): Level 4 - Intermediate Data Engineering Nested Pipeline
================================================================================

1. SQL Task
The Watchtower Supply Chain Command regulates weapons and tech shipments from 
external corporate vendors. Data analysts need an aggregated breakdown of 
supplier logistics. Write a single MySQL query utilizing Nested/Chained CTEs 
to build this data model:

-- CTE Layer 1 (CTE_completed_sales):
   - Scan the watchtower_orders base physical table.
   - Project OrderID, SupplierID, ProductID, and calculate a new column 
     aliased as Gross_Value (Quantity * UnitPrice).
   - Filter out background noise early: only keep rows where 
     OrderStatus = 'Completed'.

-- CTE Layer 2 (CTE_supplier_aggregates):
   - Nesting Constraint: This CTE must read directly from your first CTE 
     (CTE_completed_sales) and perform a relational INNER JOIN against the 
     master registry table watchtower_suppliers on the SupplierID key.
   - Group the combined data stream by SupplierName.
   - Calculate Total_Spend_USD (the sum of your calculated Gross_Value column).
   - Calculate Unique_Products_Count (the count of distinct product IDs 
     supplied by that vendor).

-- Outer Primary Query:
   - Select all columns and records from CTE_supplier_aggregates.
   - Apply a strict filtering constraint to isolate high-value vendors where 
     Total_Spend_USD is strictly greater than 10000.00.
*/

DROP TABLE IF EXISTS watchtower_orders;
DROP TABLE IF EXISTS watchtower_suppliers;

CREATE TABLE watchtower_suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(50)
);

CREATE TABLE watchtower_orders (
    OrderID INT PRIMARY KEY,
    SupplierID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    OrderStatus VARCHAR(20)
);

INSERT INTO watchtower_suppliers VALUES 
(1, 'GothCorp Industrial'),
(2, 'LexCorp Labs'),
(3, 'Kord Industries');

INSERT INTO watchtower_orders VALUES 
(101, 1, 901, 10, 500.00,  'Completed'), -- GothCorp: 5,000
(102, 1, 901, 20, 400.00,  'Completed'), -- GothCorp: 8,000 -> Total = 13,000 | Unique Prod = 1 (KEEP!)
(103, 2, 902, 5,  1000.00, 'Cancelled'), -- Cancelled! Dropped early in CTE 1.
(104, 2, 903, 2,  1500.00, 'Completed'), -- LexCorp: 3,000 -> Total = 3,000 (Below 10k threshold -> DROP)
(105, 3, 904, 12, 1000.00, 'Completed'); -- Kord: 12,000 -> Total = 12,000 | Unique Prod = 1 (KEEP!)

WITH CTE_completed_sales AS
(
	SELECT
		OrderID,
        SupplierID,
        ProductID,
        Quantity * UnitPrice as GrossValue
    FROM watchtower_orders
    WHERE OrderStatus = 'Completed'
)
, CTE_supplier_aggregates as
(
	SELECT 
		ws.SupplierName,
        SUM(cs.GrossValue) as Total_Spend_USD,
        COUNT(DISTINCT cs.ProductID) as Unique_Products_Count
	FROM CTE_completed_sales as cs
    JOIN watchtower_suppliers ws
    ON cs.SupplierID = ws.SupplierID 
    GROUP BY ws.SupplierName
)
SELECT *
FROM CTE_supplier_aggregates
WHERE Total_Spend_USD > 10000;

/*
================================================================================
Challenge #5 (CTEs): Level 5 - Advanced Recursive CTE with Cumulative Rolling Calculations
================================================================================

1. SQL Task
The Watchtower Command Grid regulates military resource allocations across 
deep-space command branches. To audit funding distributions, system architects 
need to track the exact reporting line of each division alongside its cumulative 
upstream allocation footprint. Write a single MySQL query utilizing a Recursive 
CTE to satisfy these metrics:

-- Columns Required: 
   Project UnitID, CommandChainPath, HierarchyDepth, and Cumulative_Allocation_USD.

-- The Anchor Member: 
   - Isolate the absolute root of the command structure—the central headquarters 
     where ParentUnitID IS NULL.
   - Set its base HierarchyDepth value to 1.
   - Construct its initial CommandChainPath text tracking string to display its 
     own UnitID scaled to a safe variable characters width (CAST(UnitID AS CHAR(1000))).
   - Initialize its Cumulative_Allocation_USD to match its own base ResourceAllocation.

-- The Recursive Member: 
   - Loop down the tree structure by joining the base table (watchtower_command_units) 
     against your recursive container on the parent-child key relationship.
   - Increment HierarchyDepth by exactly +1 on each loop pass.
   - Dynamically append child units to the path tracking string: 
     CONCAT(parent_path, ' -> ', child_unit).
   - Accumulation Goal: Calculate Cumulative_Allocation_USD by adding the child unit's 
     current ResourceAllocation directly to the accumulated Cumulative_Allocation_USD 
     inherited from its immediate parent row.

-- Outer Primary Pass: 
   Select all columns from the recursive collection, ordered cleanly by 
   HierarchyDepth ascending.
*/

DROP TABLE IF EXISTS watchtower_command_units;

CREATE TABLE watchtower_command_units (
    UnitID VARCHAR(30) PRIMARY KEY,
    ParentUnitID VARCHAR(30),
    ResourceAllocation INT
);

INSERT INTO watchtower_command_units VALUES 
('HQ-Central',     NULL,             5000), -- Anchor: Cum = 5000 | Depth = 1
('Division-Alpha', 'HQ-Central',     2000), -- Alpha: Cum = 5000 + 2000 = 7000 | Depth = 2
('Division-Beta',  'HQ-Central',     3000), -- Beta:  Cum = 5000 + 3000 = 8000 | Depth = 2
('Squad-One',      'Division-Alpha',  800), -- Squad1: Cum = 7000 + 800 = 7800  | Depth = 3
('Squad-Two',      'Division-Alpha', 1200), -- Squad2: Cum = 7000 + 1200 = 8200 | Depth = 3
('Team-Titan',     'Squad-Two',       400); -- Titan:  Cum = 8200 + 400 = 8600  | Depth = 4

SELECT
	*
FROM watchtower_command_units;

WITH RECURSIVE CTE_Command_Structure AS
(
	SELECT
    UnitID,
    1 as HierarchyDepth,
    CAST(UnitID AS CHAR(1000)) as CommandChainPath,
    ResourceAllocation as Cumulative_Allocation_USD
    FROM watchtower_command_units
    WHERE ParentUnitID IS NULL
    UNION ALL
    -- Recursive Query
    SELECT
		wcu.UnitID,
        ccs.HierarchyDepth + 1 AS HierarchyDepth,
        CONCAT(ccs.CommandChainPath, ' -> ', wcu.UnitID) as CommandChainPath,
        wcu.ResourceAllocation + ccs.Cumulative_Allocation_USD as Cumulative_Allocation_USD
    FROM watchtower_command_units as wcu
    JOIN CTE_Command_Structure as ccs
    ON wcu.ParentUnitID = ccs.UnitID
)
SELECT
	*
FROM CTE_Command_Structure
ORDER BY HierarchyDepth;
/*
================================================================================
Challenge #6 (CTEs): Level 6 - The Capstone Window-CTE Synthesis
================================================================================

1. SQL Task
The Watchtower Defense Shield Core tracks raw radiation energy fluctuations across 
planetary shield sectors. To predict defensive wall fatigue, operations engineers 
need a report isolating the most recent ping from each sector, along with the 
immediate drop in signal value from its preceding chronological timeline.

Write a single MySQL query utilizing Chained/Nested CTEs that integrates window 
functions to satisfy these requirements:

-- CTE Layer 1 (CTE_Chronological_Offsets):
   - Scan the watchtower_shield_telemetry table.
   - Project SectorID, LogTime, and SignalStrength.
   - Use a value window function to fetch the SignalStrength of the immediate 
     prior row chronologically (sorted by LogTime ascending) within that 
     sector's partition. Alias this column as Prev_Signal.
   - Calculate a new column aliased as Signal_Drop by subtracting the current 
     row's SignalStrength directly from your calculated Prev_Signal column 
     (Prev_Signal - SignalStrength).

-- CTE Layer 2 (CTE_Recency_Ranking):
   - Chaining Constraint: Read directly from your first CTE block 
     (CTE_Chronological_Offsets).
   - Project all columns.
   - Use a ranking window function to compute a recency index number aliased 
     as RecencyRank for each unique SectorID, chronologically ordered so that 
     the latest (most recent) time record receives a rank of 1.

-- Outer Primary Pass:
   - Query from your second tier CTE (CTE_Recency_Ranking).
   - Filter the final output grid to display only the absolute latest record 
     for each sector (RecencyRank = 1).
   - If a sector only has a single log line in its history (meaning Prev_Signal 
     resolves to NULL), handle the boundary condition by using a clean 0 
     placeholder for its final output.
*/

DROP TABLE IF EXISTS watchtower_shield_telemetry;

CREATE TABLE watchtower_shield_telemetry (
    LogID INT PRIMARY KEY,
    SectorID VARCHAR(30),
    LogTime TIME,
    SignalStrength INT
);

INSERT INTO watchtower_shield_telemetry VALUES 
(1, 'Sector-Omega', '14:00:00', 100), -- First chronological row for Omega
(2, 'Sector-Omega', '15:00:00', 85),  -- Prev: 100 | Drop = 100 - 85 = 15
(3, 'Sector-Omega', '16:00:00', 60),  -- Latest Omega! Prev: 85 | Drop = 85 - 60 = 25 (KEEP Rank 1!)
(4, 'Sector-Zeta',  '14:00:00', 250), -- First chronological row for Zeta
(5, 'Sector-Zeta',  '15:00:00', 250), -- Latest Zeta! Prev: 250 | Drop = 250 - 250 = 0 (KEEP Rank 1!)
(6, 'Sector-Krypton', '12:00:00', 500);-- Only 1 log row! Prev: NULL -> Drop = 0 (KEEP Rank 1!)

WITH CTE_Chronological_Offsets AS
(
	SELECT
		SectorID,
		LogTime,
		SignalStrength,
		coalesce(LAG(SignalStrength,1,SignalStrength) OVER(PARTITION BY SectorID ORDER BY LogTime ASC),0)  as Prev_Signal,
		(LAG(SignalStrength,1,SignalStrength) OVER(PARTITION BY SectorID ORDER BY LogTime ASC) - SignalStrength) as Signal_Drop
	FROM watchtower_shield_telemetry
),
CTE_Recency_Ranking AS
(
	SELECT
		*,
        ROW_NUMBER() OVER(PARTITION BY SectorID ORDER BY LogTime DESC) as RecencyRank
	FROM CTE_Chronological_Offsets
)
SELECT
	*
FROM CTE_Recency_Ranking
WHERE RecencyRank = 1;































