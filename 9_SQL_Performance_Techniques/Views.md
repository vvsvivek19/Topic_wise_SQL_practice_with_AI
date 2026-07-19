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

## Q4. What happens if the underlying table structure changes?

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

## Q5. Can we perform INSERT, UPDATE, and DELETE operations on a View?

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