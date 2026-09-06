# Views - Revision with ChatGPT

## Basic view syntax inforcing
```
CREATE VIEW vw_ITEmployees AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM Employees
WHERE department = 'IT';
```

## Q1. Why do we use Views instead of executing the original query every time?

### Answer

Views are created to encapsulate complex and commonly used business logic into a reusable database object. Instead of writing the same complex query with multiple joins and filters in different reports or applications, we create a view once and query it like a table.

This reduces code duplication, improves readability, and makes applications easier to maintain. If the business logic changes, only the view definition needs to be updated, and every application or report using that view automatically benefits from the updated logic.

Views also hide the complexity of the underlying database schema, allowing users to work with a simple and user-friendly interface. Additionally, they can improve security by exposing only the required rows and columns while restricting access to sensitive data.

### Key Points

- Encapsulates complex business logic.
- Promotes code reusability.
- Reduces redundancy across reports and applications.
- Simplifies maintenance by centralizing logic.
- Hides database complexity from end users.
- Can enforce row-level or column-level security.

### Interview Tip

Start your answer by describing the business problem (multiple reports and applications needing the same logic) rather than directly defining a view. This makes the explanation more practical and demonstrates real-world understanding.

## Q2. How does SQL Server execute a View?

### Answer

A normal view stores only its SQL query definition in the database metadata (system catalog), not the actual data.

When a user queries a view, SQL Server retrieves the view definition from the system catalog and expands (inlines) it into the user's query, creating a single combined query. The query optimizer then generates an execution plan for this combined query and executes it against the underlying base tables.

Since a normal view does not store data, SQL Server accesses the base tables every time the view is queried. Therefore, normal views mainly improve code reusability, maintainability, and abstraction rather than query performance.

### Execution Flow

```text
User Query
      │
      ▼
Retrieve View Definition (System Catalog)
      │
      ▼
Expand (Inline) the View into the User Query
      │
      ▼
Query Optimizer
      │
      ▼
Generate Execution Plan
      │
      ▼
Read Base Tables
      │
      ▼
Return Result
```

### Key Points

- A normal view stores only its query definition.
- The definition is stored in the system catalog.
- SQL Server expands the view into the calling query before optimization.
- The optimizer creates a single execution plan for the combined query.
- Data is always retrieved from the underlying base tables.
- Normal views improve maintainability, reusability, and abstraction—not execution speed.

### Interview Tip

Avoid saying that SQL Server executes the view first and then runs the outer query. Instead, explain that the view is **expanded (inlined)** into the user's query before optimization, allowing SQL Server to optimize the entire query as a single unit.

## Q3. What happens if the underlying table structure changes?

### Answer

A view depends on the schema of its underlying tables. Whether the view continues to work depends on the type of schema change.

- **Adding a new column:** If the view does not reference the new column, it continues to work normally.
- **Dropping a referenced column:** The view becomes invalid because its definition still references a column that no longer exists.
- **Renaming a referenced column:** The view also becomes invalid since it still points to the old column name.

If the schema change affects columns used by the view, the view definition must be updated using `ALTER VIEW` (or recreated if necessary).

In SQL Server, views created using `SELECT *` may require a metadata refresh after schema changes (for example, using `sp_refreshview`) so that the view reflects the updated table structure.

### Key Points

- Views depend on the schema of their underlying tables.
- Adding unused columns does not affect existing views.
- Renaming or dropping referenced columns breaks the view.
- The view definition must be updated if referenced columns change.
- `SELECT *` in SQL Server views can require `sp_refreshview` after schema changes.

### Interview Tip

Avoid using `SELECT *` when creating production views. Explicitly listing required columns makes the view more stable, easier to understand, and less susceptible to unexpected schema changes.

## Q4. Can we perform INSERT, UPDATE, and DELETE operations on a View?

### Answer

A view is **not always read-only**. Whether a view is updatable depends on how it is defined.

A **simple view** based on a single table is generally updatable. Operations such as `INSERT`, `UPDATE`, and `DELETE` are applied to the underlying base table.

However, if the view contains operations that transform or combine data (such as `GROUP BY`, aggregate functions, `DISTINCT`, `UNION`, or complex joins), the view is generally not updatable because SQL Server cannot uniquely determine how the changes should be applied to the underlying tables.

### Updatable View Example

```sql
CREATE VIEW vw_ITEmployees AS
SELECT emp_id, emp_name, department, salary
FROM Employees
WHERE department = 'IT';
```

The following operations are generally allowed:

- `INSERT`
- `UPDATE`
- `DELETE`

because the view maps directly to a single base table.

### Non-Updatable View Examples

- Views using `GROUP BY`
- Views using aggregate functions (`SUM`, `AVG`, `COUNT`, etc.)
- Views using `DISTINCT`
- Views using `UNION`
- Many views involving complex joins

### Key Points

- Views are **not inherently read-only**.
- Simple single-table views are generally updatable.
- Complex views that summarize or combine data are generally not updatable.
- SQL Server must be able to determine exactly which base table row should be modified.

### Interview Tip

Instead of memorizing rules, ask yourself:

> **"Can SQL Server uniquely determine which row in which base table should be modified?"**

If the answer is **yes**, the view is often updatable. If the answer is **no**, it usually isn't.

## Q5. What is the difference between a View and a CTE? When would you choose one over the other?

### Answer

The main difference is their **scope, persistence, and intended purpose**.

A **View** is a persistent database object whose query definition is stored in the database. It can be reused by multiple queries, reports, dashboards, and applications by authorized users.

A **CTE (Common Table Expression)** exists only for the duration of a single SQL statement. It is mainly used to break a complex query into multiple logical steps and improve readability and organization.

Therefore, if the same business logic needs to be reused across multiple reports or applications, I would choose a **View**. If I only need to organize a complicated query into logical steps within a single statement, I would choose a **CTE**.

### Comparison

| Aspect | View | CTE |
|---|---|---|
| Scope | Persistent database object | Single SQL statement |
| Persistence | Definition stored in database | Exists only during query execution |
| Reusability | Across multiple queries/consumers | Within the current statement |
| Main Purpose | Reusable business logic and abstraction | Organizing complex queries |
| Maintenance | View definition must be maintained | No persistent object to maintain |
| Access | Can be shared with authorized users/applications | Only available within the statement |

### Decision Rule

> **Use a CTE when you need to organize logic within a single query; use a View when that logic needs to become a reusable database object across multiple queries or consumers.**

### Interview Tip

Don't describe a CTE as something that SQL Server "maintains and cleans up." A CTE is not a persistent database object. It exists only for the duration of the SQL statement.

## Q6. View vs Table — When would you choose one over the other?

### Answer

A View and a physical Table solve different problems.

A **View** is useful when we want reusable logic over the current data without physically storing another copy of the result. It requires very little storage because it stores the query definition rather than the result set. Since the data is derived from the base tables when the view is queried, it reflects the current state of the underlying data.

A **physical table** stores the actual data and therefore requires additional storage and a mechanism to keep the data refreshed. However, materializing data into a table can improve read performance when an expensive transformation is repeatedly required by many consumers. The transformation can be performed during an ETL/ELT process, allowing downstream reports to read the already-prepared data.

Therefore, a View is not inherently better than a Table. The choice depends on factors such as data freshness, transformation cost, query performance, storage, refresh requirements, and how frequently the data is consumed.

### View

Use a View when:

- Current/fresh data is required.
- Business logic needs to be reused across multiple consumers.
- We want to avoid physically duplicating data.
- The underlying query is acceptable to execute at query time.
- We need abstraction or controlled access to data.

### Physical Table

Use a physical Table when:

- The result needs to be physically persisted.
- The transformation is expensive.
- The same transformed data is queried frequently.
- Predictable/faster read performance is important.
- The organization is willing to manage data refresh/ETL processes.
- Some level of data duplication is acceptable.

### Comparison

| Aspect | View | Physical Table |
|---|---|---|
| Data storage | Stores query definition, not result data | Stores actual rows |
| Freshness | Reflects current base-table data | Depends on refresh/update process |
| Storage | Minimal storage for definition/metadata | Storage required for actual data |
| Data duplication | Avoids additional copy | May introduce data duplication |
| Query performance | Underlying query still executes | Can be faster if data is precomputed |
| Maintenance | No separate data-refresh process | Requires data loading/refresh |
| Best suited for | Reusable logic and abstraction | Materialized/precomputed datasets |

### Interview Tip

Do not say that a normal View is slower because it requires an additional execution step. A normal View is expanded into the user's query and optimized as part of the overall query.

The key trade-off is:

> **View = compute when queried**

> **Table = materialize and maintain the result**

Therefore, the choice should be based on freshness, transformation cost, performance requirements, and data-refresh overhead.

## Q7. Can a View be created on top of another View? Is it a good practice?

### Answer

Yes, a View can be created on top of another View. This is known as **nested or layered Views**.

For example:

```text
Employees
    ↓
vw_EmployeeDetails
    ↓
vw_ITEmployees
    ↓
vw_HighSalaryITEmployees
```

Nested Views can be useful for **modularity and reusability**, where each View encapsulates a specific layer of business logic.

When the final View is queried, SQL Server can expand the underlying View definitions into the overall query rather than necessarily executing each View independently.

However, excessive View nesting can create several problems:

- **Debugging becomes difficult** because the logic is distributed across multiple Views.
- **Dependency management becomes complex** because changes to underlying tables or upstream Views can affect downstream Views.
- **Performance analysis becomes harder** because the final expanded query can become very complex.
- **Hidden complexity** can increase because business logic is spread across many database objects.

Therefore, nested Views are not inherently bad. A small, well-designed hierarchy can improve modularity, but deep chains of Views should generally be avoided.

### Key Points

- Views can be created on top of other Views.
- Nested Views can provide modularity and reusable business logic.
- View definitions can be expanded into the final query.
- Excessive nesting makes debugging and dependency management difficult.
- Deep View chains can make performance troubleshooting harder.
- Use layered Views when they genuinely improve organization, but avoid unnecessary nesting.

### Interview Tip

Don't say that nested Views are always bad. Explain the trade-off:

> **Small, purposeful View hierarchies can improve modularity; excessive nesting can create a maintenance and troubleshooting nightmare.**

## Q8. Why are Views called "Virtual Tables"?

### Answer

Views are called **Virtual Tables** because they can be queried like a physical table, but they do not physically store the result rows as a separate table.

A View itself exists as a persistent database object and stores its SQL query definition. When the View is queried, the underlying query is executed against the base tables and the result set is generated.

Therefore, the View is **physically present as a database object**, but the result data is not permanently stored as part of the View.

### Physical Table vs View

```text
Physical Table
      │
      ▼
Rows are physically stored
      │
      ▼
SELECT retrieves stored data


View
      │
      ▼
SQL query definition is stored
      │
      ▼
Query is executed against base tables
      │
      ▼
Result set is generated
```

### Key Points

- A View is a persistent database object.
- Its query definition is stored in the database.
- The result rows are not physically stored as a separate table in a normal View.
- Users can query a View using `SELECT` in a similar way to querying a table.
- The result set is generated when the View is queried.

### Interview Tip

Don't say that the View itself "doesn't exist." The View **does exist** as a database object. What is virtual is the **result set**, because it is generated from the underlying query rather than being permanently stored as rows.

## Q9. How can Views be used to improve data security?

### Answer

Views can improve data security by controlling **what data is exposed** to users.


### 1. Column-Level Security

A View can expose only the columns required by a particular group of users while hiding sensitive columns.

```sql
CREATE VIEW vw_EmployeeReporting AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM Employees;
```

Sensitive columns such as `phone_number`, `email`, or `bank_account_number` are not exposed through the View.

### 2. Row-Level Security

A View can also restrict which rows users can see by applying filtering conditions.

```sql
CREATE VIEW vw_ITEmployees AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM Employees
WHERE department = 'IT';
```

This View exposes only employees belonging to the IT department.

### 3. Data Transformation / Masking

Values can also be transformed within the View so that sensitive information is not fully exposed.

```sql
SELECT
    emp_id,
    LEFT(phone_number, 3) + 'XXXXXXX' AS masked_phone
FROM Employees;
```

This is query-level masking/transformation and should be distinguished from SQL Server's separate **Dynamic Data Masking (DDM)** feature.

### 4. Permissions

Database permissions can be applied to Views so that users are granted access to the View without necessarily being given direct access to the underlying table.

Therefore:

> **View controls what data is exposed, while permissions control who can access the exposed data.**

### Key Points

- Views can restrict **columns**.
- Views can restrict **rows** using filtering conditions.
- Views can transform or mask sensitive values.
- Permissions can be granted on Views to control access.
- Users can be given access to a View without direct access to the underlying table.

### Interview Tip

Explain View-based security in layers:

```text
Column Filtering → What columns can be seen?
Row Filtering    → What rows can be seen?
Transformation   → How are values presented?
Permissions      → Who can access the View?
```

## Q10. What is an Indexed View and how can it improve performance?

### Answer

A normal View stores only the query definition and does not physically store its result. Therefore, expensive operations such as aggregations may need to be performed whenever the View is queried.

An **Indexed View** in SQL Server allows the result of a View to be physically persisted through an index. This means that expensive computations, such as aggregations, can be precomputed and stored, allowing SQL Server to read the already-maintained result instead of repeatedly performing the same computation.

For example, if an aggregation over a very large `Sales` table is queried frequently, an Indexed View can store the aggregated result and make subsequent reads significantly faster.

### Normal View

```text
Base Tables
     ↓
View Query
     ↓
Compute Result
     ↓
Return Result
```

### Indexed View

```text
Base Tables
     ↓
Indexed View
     ↓
Materialized / Persisted Result
     ↓
Index
     ↓
Faster Reads
```

### Trade-offs

The performance improvement comes with additional costs:

- Additional storage is required.
- SQL Server must maintain the Indexed View when the underlying data changes.
- `INSERT`, `UPDATE`, and `DELETE` operations on the base tables can become more expensive.
- Indexed Views have additional SQL Server-specific restrictions and requirements.
- They add complexity to database design and maintenance.

Therefore, Indexed Views are most useful for **read-heavy workloads** where expensive computations are performed frequently and the performance benefit justifies the additional storage and maintenance cost.

## trade-off in more detail

#### You said: "the aggregated result will already be stored in the physical disk"

Correct—but now ask: What happens when the underlying Sales table changes?

Suppose:

INSERT INTO Sales
VALUES (..., 500);

The indexed view's stored result is now potentially outdated.

SQL Server therefore has to maintain the indexed view as the base table changes.

Conceptually:
```text
INSERT / UPDATE / DELETE
          ↓
    Base Table
          ↓
Update Indexed View
          ↓
Update its Index
```

So you get:

🚀 Faster reads

but

🐌 More expensive writes

plus:

Additional storage
Additional maintenance
Restrictions on what the view can contain
More complexity

This is the classic trade-off.

### Key Concept

> **Normal View → Calculate when queried**

> **Indexed View → Precompute and maintain the result**

### Terminology

SQL Server uses the term **Indexed View**. Other database systems commonly use **Materialized View**. They are conceptually similar because both physically persist derived results for faster reads.

### Interview Tip

If asked whether Views improve performance, distinguish between normal and indexed views:

- **Normal View:** Generally does not improve performance because the underlying query is executed when referenced.
- **Indexed View:** Can improve read performance by physically maintaining the computed result.


## Q11. What is `WITH CHECK OPTION` in a View, and why would you use it?

### Answer

`WITH CHECK OPTION` is used with an **updatable View** to ensure that any `INSERT` or `UPDATE` performed through the View does not create a row that falls outside the View's filtering condition.

For example:

```sql
CREATE VIEW vw_ITEmployees AS
SELECT emp_id, emp_name, department, salary
FROM Employees
WHERE department = 'IT'
WITH CHECK OPTION;

```

The View only exposes employees whose department is IT.

Now consider:

```sql
UPDATE vw_ITEmployees
SET department = 'HR'
WHERE emp_id = 101;

```

This operation would cause the employee to no longer satisfy:

```sql
department = 'IT'

```

Therefore, with `WITH CHECK OPTION`, SQL Server rejects the update.

However:

```sql
UPDATE vw_ITEmployees
SET salary = 70000
WHERE emp_id = 101;

```

is allowed because the employee still satisfies the View's condition.

Similarly, an attempt to insert a row that does not satisfy the View's filtering condition is rejected.

---

### Without `WITH CHECK OPTION`

* A row can potentially be modified through the View in a way that causes it to no longer satisfy the View's `WHERE` condition.
* As a result, the row may disappear from the View after the update.

---

### With `WITH CHECK OPTION`

* SQL Server ensures that the resulting row continues to satisfy the View's filtering condition.

---

### Mental Model

> "If I modify data through this View, don't allow the modification if the resulting row would fall outside the View."

---

### Key Points

* Used with updatable Views.
* Applies to `INSERT` and `UPDATE` operations performed through the View.
* Ensures modified/inserted rows continue to satisfy the View's filtering condition.
* Prevents rows from being modified through the View in a way that makes them disappear from that View.
* It is not a general-purpose security feature.

---

### Interview Tip

**Don't say:**

> "WITH CHECK OPTION prevents updates to rows returned by the View."

**Instead say:**

> "WITH CHECK OPTION prevents `INSERT` or `UPDATE` through the View when the resulting row would no longer satisfy the View's filtering condition."

Absolutely. Here's the Markdown for **Q13**, keeping the same format as the previous View questions.


## Q12. Scenario: How would you choose between a View, CTE, Table, and Indexed View?

### Scenario

You have a large `Sales` table:

- 20 different reports need the same business logic.
- The logic contains several joins and filters.
- One report needs to further filter the result.
- The logic is queried very frequently.
- The underlying data changes throughout the day.
- An expensive aggregation is becoming a performance problem.

### Answer

I would first identify the **scope and purpose** of each requirement.

Since 20 different reports need the same business logic, I would encapsulate that reusable logic in a **View**. This avoids duplicating the same joins, filters, and business rules across multiple reports and provides a centralized object that can be maintained in one place.

If one report needs additional filtering, I do not necessarily need to create another View. I can simply query the existing View with an additional `WHERE` condition.

For example:

```sql
SELECT *
FROM vw_Sales
WHERE region = 'North';
````

If that additional filtered logic is itself reused by multiple consumers, then creating another layered/nested View may make sense.

A **CTE** would be appropriate when a particular report needs to organize complex logic into multiple logical steps within a single SQL statement. A CTE would not be suitable for sharing the same logic across 20 independent reports because its scope is limited to one SQL statement.

Now, if the common logic contains an expensive aggregation that is executed frequently, I would consider an **Indexed View**. An Indexed View can physically persist the computed result, allowing SQL Server to avoid repeatedly performing the same expensive computation and potentially improving read performance.

However, the underlying `Sales` table changes throughout the day. Every relevant `INSERT`, `UPDATE`, or `DELETE` may require SQL Server to maintain the Indexed View. This introduces additional write overhead.

Therefore, I would not automatically choose an Indexed View simply because the query is expensive. I would evaluate whether the improvement in read performance justifies the additional storage and write-maintenance cost.

### Decision Framework

| Requirement                                 | Best Fit                          |
| ------------------------------------------- | --------------------------------- |
| Reusable business logic across many reports | **View**                          |
| Complex logic within one SQL statement      | **CTE**                           |
| One report needs additional filtering       | **Query the View**                |
| Filtered logic reused by multiple consumers | **Layered View**                  |
| Expensive, frequently repeated computation  | **Consider Indexed View**         |
| Need physically persisted/precomputed data  | **Table / Indexed View**          |
| Very write-heavy workload                   | Be cautious with **Indexed View** |

### View

Use a View when:

* The same business logic is required by multiple consumers.
* Joins and business rules need to be centralized.
* Data can be computed when queried.
* Reusability and abstraction are important.

### CTE

Use a CTE when:

* The logic is required only within one SQL statement.
* A complex query needs to be broken into logical steps.
* Readability and query organization are the primary concerns.

### Physical Table

Use a physical table when:

* The transformed result needs to be physically persisted.
* Repeated query-time computation is too expensive.
* A data refresh/ETL process can be used to populate and maintain the table.
* Faster and more predictable reads are more important than having completely real-time derived data.

### Indexed View

Consider an Indexed View when:

* The same expensive computation is queried frequently.
* The workload is sufficiently read-heavy.
* Precomputing and physically maintaining the result can provide significant performance benefits.
* The additional storage and write-maintenance cost is acceptable.

### Important Trade-off

An Indexed View provides:

> **Faster Reads**

but can introduce:

> **More Expensive Writes + Additional Storage + Additional Maintenance**

because changes to the underlying tables may require the Indexed View and its indexes to be updated.

### Key Concept

> **View → Reusable business logic**

> **CTE → Organize logic within one query**

> **Table → Persist data**

> **Indexed View → Persist expensive derived results for faster reads**

### Interview Tip

Do not choose a technology based on a single factor such as query complexity or frequency.

Consider the overall workload:

**Reusability → Scope → Persistence → Read Frequency → Computation Cost → Data Change Frequency → Read/Write Trade-off**

The important point is that these objects solve **different problems**, so the correct choice depends on the workload rather than one being universally better than the others.

```

Now we can move on to **CTAS & Temporary Tables**.
```
