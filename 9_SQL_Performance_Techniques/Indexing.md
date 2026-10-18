# Indexes - Revision with ChatGPT

## Q1. What is an Index?

- An **index** is a data structure that helps SQL Server retrieve data efficiently by providing a faster access path to the required rows.
- Without a suitable index, SQL Server may need to perform a **table scan**, examining the table's data pages to find matching rows.
- With an appropriate index, SQL Server can locate the required data more efficiently without necessarily scanning the entire table.

### Analogy — Hotel Room Directory

- **Without an index:** Search every room until the required room is found.
- **With an index:** Use the directory to locate the correct floor and room quickly.

### Trade-offs of Indexes

- **Advantages:** Faster data retrieval for suitable queries.
- **Disadvantages:** Additional storage and maintenance overhead; can slow down `INSERT`, `UPDATE`, and `DELETE` operations.

**Interview Trigger:** Index = faster data retrieval, but additional storage and write-maintenance overhead.

## Q2: What is a Heap in SQL Server?
Explain these three things:
1. What makes a table a heap?
2. How does SQL Server find a row in a heap when no suitable index exists?
3. Why might a heap be suitable for some workloads but inefficient for others?

### Heap in SQL Server

- A **heap** is a table that does not have a clustered index.
- Its rows are not organized according to a clustered index key.
- Without a suitable index, SQL Server may perform a **table scan**, reading data pages to locate matching rows.
- A heap can still have nonclustered indexes.

#### Advantages
- Avoids maintaining a clustered index.
- Can be useful for staging tables and certain bulk-loading workloads.

#### Disadvantages
- Queries without suitable indexes may require a full table scan.
- Forwarded records can occur when an update makes a row too large to fit on its original page, potentially adding read overhead.

**Important:** Rows in a heap are not guaranteed to remain in insertion order. A heap is not automatically faster for writes or slower for reads; performance depends on the workload.

## Q3: What is a Clustered Index, and How Does It Work?
Explain these points:
1. What happens to the table's data when you create a clustered index?
2. What is a B-tree, and what role do its root, intermediate, and leaf levels play?
3. Why can a clustered index help SQL Server locate data efficiently?

### Clustered Index in SQL Server

> A clustered index organizes a SQL Server table's data according to the clustered index key. It uses a B-tree structure, where the root and intermediate levels contain index keys and pointers to lower-level pages, while the leaf level contains the actual data rows.
>
> When a query filters on the clustered index key, SQL Server can navigate from the root through the intermediate levels to the relevant leaf page instead of scanning the entire table. This can significantly improve data retrieval, particularly for selective lookups and range queries. A table can have only one clustered index because it can have only one clustered data organization.

### B-Tree Structure

- **Root Page:** The starting point for index navigation.
- **Intermediate Pages:** Contain index keys and pointers to lower-level pages.
- **Leaf Level:** Contains the actual table data rows.

```text
Root Index Page
       ↓
Intermediate Index Page(s)
       ↓
Leaf Level (Data Pages)
       ↓
Required Row
```

### How It Works

1. SQL Server starts at the root page.
2. It uses index keys to identify the appropriate child page.
3. It navigates through intermediate pages, if present.
4. It reaches the relevant leaf page containing the data row.

This can avoid scanning every data page when an efficient index seek is possible.

### Important Notes

- A primary key is clustered by default only when SQL Server can create it as a clustered index; a primary key can also be nonclustered.
- Creating a clustered index establishes the table's organization according to the index key.
- Logical key ordering does not guarantee that all data pages are physically contiguous on disk.

### Interview Trigger: Clustered index → B-tree → root/intermediate index pages → leaf level containing actual data rows.

## Q4: Clustered Index vs Heap

Suppose two tables contain the same million employee records:

- **Table A:** A heap with no indexes.
- **Table B:** A clustered index on `EmployeeID`.

You run this query on both tables:

```sql
SELECT *
FROM Employees
WHERE EmployeeID = 500000;
```

Why might Table B perform much better than Table A?
Explain what SQL Server needs to do in each case. Also, is the clustered index always faster than the heap for every query? Why or why not?

### Answer

> A heap without a suitable index may require SQL Server to scan its data pages to find a particular employee. With a clustered index on `EmployeeID`, SQL Server can navigate the B-tree from the root through intermediate pages to the leaf page containing the required row. This can significantly reduce the number of pages that need to be read.
>
> However, a clustered index isn't always faster for every query. Queries that retrieve most or all rows may benefit from a scan, and the best execution plan depends on the query, data distribution, indexes, and estimated costs.

Consider a table containing millions of employee records.

```sql
SELECT *
FROM Employees
WHERE EmployeeID = 500000;
```

### Heap

- A heap has no clustered index.
- Without a suitable index, SQL Server may perform a table scan.
- It reads data pages to find the matching employee.
- This can be expensive for selective lookups on large tables.

### Clustered Index

- A clustered index organizes table data according to its index key.
- SQL Server navigates the B-tree to locate the relevant leaf page.
- This can significantly reduce the number of pages read for selective lookups.

### Important Qualification

A clustered index is not always faster for every query.

- Selective lookup: An index seek may be much more efficient than a full scan.
- Full-table retrieval: A table or clustered index scan may be appropriate.
- Actual performance: Depends on the query, data distribution, available indexes, and execution plan.

Interview Trigger: A clustered index can reduce page reads for selective lookups, but it does not guarantee better performance for every query.


## Q5: What is a Nonclustered Index?

Suppose you have a clustered index on `EmployeeID`, but you frequently run this query:

```sql
SELECT *
FROM Employees
WHERE LastName = 'Sharma';
```

There is no index on `LastName`.

Explain:

1. Why might SQL Server still need to scan the table?
2. What does a nonclustered index on `LastName` provide?
3. What is a row locator, and how does SQL Server use it to retrieve the complete employee record?

### Answer

> A nonclustered index is a separate B-tree structure that helps SQL Server locate rows using the indexed columns without requiring a scan of the entire table. Its leaf level contains index keys and row locators. For a table with a clustered index, the row locator includes the clustered index key; for a heap, it is a RID. SQL Server can use these locators to retrieve the corresponding rows from the underlying table when necessary.


### Nonclustered Index in SQL Server

- A **nonclustered index** is a separate B-tree structure that provides an efficient access path to rows based on the indexed columns.
- It does not replace the table's existing clustered data organization.
- Its leaf level contains index keys and row locators.

### How It Works

1. SQL Server navigates the nonclustered index's B-tree.
2. It locates matching index entries at the leaf level.
3. It uses the row locators to retrieve the corresponding table rows when necessary.

### Row Locators

- **Clustered table:** The row locator uses the clustered index key.
- **Heap:** The row locator uses a RID (Row Identifier), identifying the file, page, and slot containing the row.

### Example

```sql
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees (LastName);
```

This index can help SQL Server locate employees by `LastName` without scanning the entire table.

Important: A table with a clustered index does not become a heap when queried using an unindexed column. SQL Server may perform a clustered index scan instead.

Interview Trigger: Nonclustered index = separate B-tree + index keys + row locators.

## Q6: Clustered Index vs Nonclustered Index

Let's bring the two concepts together.

Suppose a table has:

- A clustered index on `EmployeeID`
- A nonclustered index on `LastName`

**Compare these two indexes in terms of:**

1. Where the actual table data is stored
2. What the leaf level contains
3. How many of each type can exist on a table
4. Their impact on read and write performance


### Answer

> A clustered index organizes the table's data according to its key, and its leaf level contains the actual data rows. A nonclustered index is a separate B-tree structure whose leaf level contains index keys, row locators, and any included columns.
>
> A table can have only one clustered index but multiple nonclustered indexes. Neither type is universally faster: performance depends on the query, selectivity, and whether additional lookups are required. Both introduce write-maintenance overhead, and nonclustered indexes also require additional storage.
>
> I would choose the clustered key based on data organization and common access patterns, while using nonclustered indexes for other frequently queried columns when the performance benefit justifies their maintenance cost.


### Clustered Index vs Nonclustered Index

| Feature           | Clustered Index                                               | Nonclustered Index                                               |
| ----------------- | ------------------------------------------------------------- | ---------------------------------------------------------------- |
| Structure         | B-tree that organizes the table's data by the clustered key   | Separate B-tree structure                                        |
| Leaf level        | Contains the actual table data rows                           | Contains index keys, row locators, and optional included columns |
| Number per table  | One                                                           | Multiple                                                         |
| Storage           | Defines the table's primary data organization                 | Requires additional storage                                      |
| Read performance  | Efficient for suitable lookups, ranges, and ordered retrieval | Efficient for queries that use its indexed columns               |
| Write performance | Requires maintenance when data changes                        | Requires maintenance when indexed data changes                   |
| Common use        | Organizing table data around a suitable key                   | Optimizing additional query access patterns                      |

### Important Considerations

- Neither index type is universally faster for reads or writes.
- A nonclustered index may require a **Key Lookup** to retrieve columns not stored in the index.
- Both index types incur maintenance overhead when relevant data changes.
- A clustered key should ideally be narrow and stable, with its selection guided by query patterns.
- Creating too many nonclustered indexes increases storage use and write overhead.

**Interview Trigger:** Clustered index = table's data organization; nonclustered index = separate access structure for selected columns.

## Q7: Composite Index and Column Order

Suppose you create this index:

```
CREATE NONCLUSTERED INDEX IX_Employees_Department_Salary
ON Employees (DepartmentID, Salary);
```

Now consider these queries:

```
-- Query A
SELECT *
FROM Employees
WHERE DepartmentID = 10;

-- Query B
SELECT *
FROM Employees
WHERE DepartmentID = 10
  AND Salary > 50000;

-- Query C
SELECT *
FROM Employees
WHERE Salary > 50000;
```

### Answer
```
A composite index contains multiple key columns in a defined order. SQL Server organizes its index entries using that key order, so the leading column is particularly important for efficient index seeks.
For an index on (DepartmentID, Salary), queries filtering by DepartmentID alone or by both DepartmentID and Salary can benefit from the index. A query filtering only by Salary generally cannot perform a direct seek using this index because the leading key is unconstrained, although an index scan may still be possible.
```

## Q8: Index Seek vs Index Scan

Suppose SQL Server has a nonclustered index on `EmployeeID`.

Consider these two queries:

```
-- Query A
SELECT *
FROM Employees
WHERE EmployeeID = 101;

-- Query B
SELECT *
FROM Employees;
```

Explain:

1. What is an Index Seek, and how does SQL Server perform it?
2. What is an Index Scan, and how is it different?
3. Which query is more likely to use a seek, and which might use a scan?
4. Is an index scan always bad for performance?

### Answer

### Index Seek
- Navigates an index to locate specific keys or key ranges.
- Often efficient for selective queries that return a small subset of rows.
- Example:

```sql
SELECT *
FROM Employees
WHERE EmployeeID = 101;
```

### Index Scan
- Examines index entries across a range to identify matching rows.
- May scan all or part of an index.
- Can be appropriate when a query needs many rows.

### Important Distinctions

- An Index Seek is often efficient for selective lookups, but it is not always faster than a scan.
- An Index Scan is not inherently bad; it may be the most efficient plan when many rows are required.
- `SELECT * FROM Employees` may use a clustered index scan or a heap scan, depending on the table structure and execution plan.
- SQL Server chooses the plan based on estimated costs, statistics, available indexes, and the query.

**Interview Trigger:** Seek = navigate to specific keys or ranges; Scan = examine entries across a range. Neither operator is automatically good or bad.


## Q9: Covering Index and Key Lookup

Suppose your table has a clustered index on EmployeeID and this nonclustered index:

```sql
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees (LastName);
```


You run:
``` sql
SELECT EmployeeID, LastName, Salary
FROM Employees
WHERE LastName = 'Sharma';
```

The nonclustered index can help locate employees named Sharma, but it doesn't contain Salary.

Explain:

1. What is a Key Lookup, and why might SQL Server perform one here?
2. What is a covering index?
3. How could you modify the nonclustered index to cover this query?

### Key Lookup and Covering Index

#### Key Lookup

- A **Key Lookup** occurs when SQL Server uses a nonclustered index to locate matching rows but needs additional columns from the clustered index.
- SQL Server uses the clustered index key stored in the nonclustered index as a row locator to retrieve the missing columns.
- Repeated Key Lookups can increase query cost when many rows match.

#### Covering Index

- A **covering index** contains all the columns required by a particular query.
- SQL Server can retrieve the required columns directly from the index without performing additional lookups.

#### Example

Query:

```sql
SELECT EmployeeID, LastName, Salary
FROM Employees
WHERE LastName = 'Sharma';
```

Existing index:

```sql
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees (LastName);
```

This index doesn't contain `Salary`, so SQL Server may perform a Key Lookup to retrieve it.

#### Create a Covering Index

```sql
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees (LastName)
INCLUDE (Salary);
```

- `LastName` is the index key used for searching.
- `Salary` is stored at the leaf level as an included column.
- `EmployeeID` is available through the clustered key carried by the nonclustered index.

The index can now cover the query without a Key Lookup.

**Interview Trigger:** Key Lookup = retrieve missing columns from the clustered index; Covering Index = all required columns are available in the index.

## Q10: What is a Unique Index?

Suppose your Employees table must not contain duplicate values for Email.

**Explain:**

1. What does a unique index guarantee?
2. How does SQL Server behave if you try to insert a duplicate email?
3. What's the difference between a unique index and a primary key?

### Answer

### Unique Index

- A **unique index** guarantees that duplicate key values cannot exist in the indexed key columns.
- It serves two purposes:
  - **Data integrity:** Prevents duplicate key values.
  - **Query performance:** Provides an index that SQL Server can use for suitable queries.
- A unique index can be clustered or nonclustered.
- If an attempt is made to insert a duplicate key value, SQL Server rejects the operation with an error.

### Example

```sql
CREATE UNIQUE NONCLUSTERED INDEX IX_Employees_Email
ON Employees (Email);
```

This index prevents duplicate non-`NULL` email values.

### Unique Index vs Primary Key

| Feature | Unique Index | Primary Key |
|---|---|---|
| Uniqueness | Enforces unique key values | Enforces unique row identification |
| `NULL` values | A single-column unique index permits at most one `NULL` | Not allowed |
| Table constraint | No | Yes |
| Index in SQL Server | Is itself an index | Enforced using an appropriate unique index |

**Important:** SQL Server creates an appropriate unique index for a primary key if an existing suitable index cannot be used. A primary key can be clustered or nonclustered.

**Interview Trigger:** Unique index = uniqueness + data integrity + an index access path.

## Q11: What is a Filtered Index?

Suppose your Orders table contains 10 million rows, but your application frequently queries only orders whose status is 'Pending'.

```sql
SELECT OrderID, OrderDate
FROM Orders
WHERE Status = 'Pending';
```

**Explain:**

1. What is a filtered index?
2. How could it help this query compared with a regular nonclustered index on Status?
3. What are its benefits and limitations?

### Answer

### Filtered Index

- A **filtered index** is a nonclustered rowstore index that contains only rows satisfying a specified filter condition.
- It is useful when queries frequently target a particular subset of a table.

### Example

```sql
CREATE NONCLUSTERED INDEX IX_Orders_Pending
ON Orders (OrderDate)
INCLUDE (OrderID)
WHERE Status = 'Pending';
```

This index contains only orders whose status is `Pending`.

### Benefits

- **Targeted optimization:** Optimizes queries that access a specific subset of rows.
- **Reduced storage:** Stores fewer index entries than a comparable full-table index.
- **Lower maintenance overhead:** Changes to rows outside the filter generally do not require index-entry maintenance.

### Limitations

- In SQL Server, filtered indexes are supported on nonclustered rowstore indexes, not clustered indexes or columnstore indexes.
- The query predicate must be compatible with the filter condition for the optimizer to use the index.
- The optimizer chooses whether to use the index based on the query and estimated costs.

**Interview Trigger:** Filtered index = subset of rows + targeted optimization + reduced storage and maintenance.

## Q12: Rowstore vs Columnstore Index

This is an important topic for Data Engineering interviews.

Imagine two workloads:
- Workload A: A banking application frequently inserts transactions and retrieves individual customer records.
- Workload B: A data warehouse analyzes 100 million sales records, calculating total sales by year, region, and product.

Explain:
1. How does rowstore storage differ from columnstore storage?
2. Why is rowstore generally suitable for OLTP workloads?
3. Why can columnstore be much more efficient for analytical queries?
4. What are the trade-offs of columnstore indexes?

### Answer

### Rowstore vs. Columnstore Index

### Rowstore
- Data is stored row by row in 8 KB data pages; each page can contain multiple rows.
- Suitable for OLTP workloads involving frequent inserts, updates, deletes, and point lookups.
- Efficient when queries need most or all columns of a small number of rows.

### Columnstore
- Data is organized into **rowgroups**, with each column stored separately in compressed **column segments**.
- Suitable for OLAP workloads involving large scans, aggregations, and analytical queries.
- Improves analytical performance through column elimination, compression, and batch-mode processing where applicable.
- The real advantage of columnstore is that SQL Server can read only the required column segments, benefit from compression, and use batch-mode processing where applicable. This can substantially reduce I/O and improve analytical query performance.

### Clustered vs. Nonclustered Columnstore
- **Clustered columnstore index:** Stores the table primarily in columnstore format. Supported SQL Server versions can also allow nonclustered rowstore indexes on the table.
- **Nonclustered columnstore index:** Adds a separate columnstore structure to a rowstore table, allowing transactional and analytical access patterns to coexist.

### Trade-offs
- Columnstore indexes can require additional storage and maintenance, especially when data changes frequently.
- Choose rowstore for workloads centered on individual records and columnstore for workloads processing large volumes of analytical data.


## Q13: Indexing for OLTP vs. OLAP

Let's build on what you've just explained.

A company has a Sales table containing 100 million records. It supports two workloads:
- Workload A: An application frequently retrieves a particular order using OrderID and inserts new orders throughout the day.
- Workload B: Analysts frequently calculate total sales by year, region, and product across millions of records.

How would you approach indexing this table to support both workloads? Explain which index types you'd consider, why, and what trade-offs you'd keep in mind.

### Answer

### Indexing for OLTP vs. OLAP

- **OLTP workload:** Use a rowstore B-tree index on frequently searched columns, such as `OrderID`, to support efficient lookups. Use a unique index when uniqueness must be enforced.
- **OLAP workload:** Consider a nonclustered columnstore index containing the columns required for analytical queries, including filtering, grouping, and aggregation.
- **Trade-offs:** Additional indexes consume storage and add maintenance overhead to inserts, updates, and deletes.
- **Best practice:** Choose indexes based on query patterns, selectivity, execution plans, and the overall read/write workload. Validate performance before and after creating indexes.


### Q14: Index Maintenance

Suppose a SQL Server database has several indexes, and over time, queries start running slower. You discover that some indexes have high fragmentation, and the statistics may be outdated.

Explain:
1. What index fragmentation is and why it can matter.
2. The difference between ALTER INDEX ... REORGANIZE and ALTER INDEX ... REBUILD.
3. What index statistics are and why SQL Server needs them.
4. Whether you would automatically rebuild every index on a fixed schedule.

### Answer

### Index Maintenance: Fragmentation and Statistics

### Index Fragmentation
- **Logical fragmentation:** The physical order of index leaf pages differs from their logical key order.
- **Page density:** The proportion of a page occupied by data; low density can increase the number of pages needed.
- Page splits caused by inserts and updates can contribute to fragmentation.

### REORGANIZE vs. REBUILD
- **REORGANIZE:** Reorganizes leaf-level index pages; generally lighter on resources.
- **REBUILD:** Recreates the index structure; more resource-intensive and can address fragmentation more comprehensively.
- Traditional thresholds such as 10% and 30% fragmentation are rules of thumb, not universal requirements.

### Index Statistics
- Statistics describe data distribution and help the query optimizer estimate cardinality.
- Inaccurate or outdated statistics can lead to poor execution plans.
- Rebuilding an index updates its associated statistics, generally with a full scan; reorganizing does not provide the same statistics update.
- Statistics can also be updated independently of index maintenance.

### Best Practices
- Consider index size, fragmentation, page density, query patterns, and actual performance before performing maintenance.
- Monitor statistics freshness and update statistics when appropriate.
- Avoid blindly rebuilding every index on a fixed schedule; maintenance should be workload-driven.


## Q15: — Choosing Indexes in a Real-World Scenario

You're designing a SQL Server database for an employee management system with this table:

```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    DepartmentID INT,
    Email VARCHAR(200),
    Salary DECIMAL(10,2),
    HireDate DATE,
    IsActive BIT
);
```

The application frequently performs these queries:
1. Retrieves an employee by EmployeeID.
2. Retrieves an employee by Email.
3. Retrieves all active employees in a particular department.
4. Calculates the average salary for each department.
5. Lists employees hired within a date range.

How would you decide which indexes to create for these queries? You don't need to write every CREATE INDEX statement immediately. Explain your reasoning, which columns you'd consider indexing, and how you'd avoid creating too many indexes.

### Answer

### Index Selection: Real-World Scenarios

- **Primary-key lookup:** A primary key is enforced by a unique index. Check whether the existing index is clustered or nonclustered before creating another index.
- **Unique email lookup:** Consider a unique nonclustered index when email addresses must be unique. Use `NOT NULL` or another appropriate constraint if every employee must have an email.
- **Filtered query:** For queries that consistently retrieve active employees, consider a filtered index such as `ON Employees (DepartmentID) WHERE IsActive = 1`.
- **Analytical aggregation:** Consider a nonclustered columnstore index containing the columns needed for grouping and aggregation when the workload justifies its overhead.
- **Date-range filtering:** Consider a nonclustered index on `HireDate`, provided an existing index does not already support the query.
- **Avoid over-indexing:** Check for overlapping indexes, query selectivity, execution plans, storage requirements, and write overhead before adding indexes.

**Core principle:** Design indexes around actual query patterns, validate their benefits, and balance read performance against the cost of maintaining them.
