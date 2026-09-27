# Triggers - Revision with ChatGPT

## Q1. What is a Database Trigger?

### Interview-ready answer

- A database trigger is a database object that automatically executes in response to a specified database event. 
- In SQL Server, triggers can respond to DML events such as INSERT, UPDATE, and DELETE, as well as certain DDL and logon events. 
- Unlike a stored procedure, a trigger is **not normally called manually**.
- The triggering event causes the trigger to execute automatically.
- A common use case is auditing, where a trigger records changes to a critical table in an audit table.

### Common Trigger Events

- **DML:** `INSERT`, `UPDATE`, `DELETE`
- **DDL:** `CREATE`, `ALTER`, `DROP`
- **LOGON:** Login-related events in SQL Server

### Common Use Case — Auditing

A trigger can automatically record information such as:

- Operation type (`INSERT`, `UPDATE`, `DELETE`)
- Who performed the operation
- When the operation occurred
- Old/new row values where applicable

Example:
```text
UPDATE Customer
       ↓
Trigger automatically fires
       ↓
Audit information inserted into AuditTable
```

### Stored Procedure vs Trigger
- Stored Procedure: Explicitly invoked by the caller.
- Trigger: Automatically fired by a triggering event.
- Interview Trigger: Stored Procedure = explicitly called; Trigger = event-driven and automatically executed.

## Q2. AFTER vs INSTEAD OF Triggers

### AFTER Trigger

- Executes **after** the triggering DML operation has successfully occurred.
- The original operation happens first.
- Commonly used for:
  - Auditing
  - Logging
  - Performing related actions after a change

```text
UPDATE Employees
       ↓
UPDATE happens
       ↓
AFTER trigger fires
```

### INSTEAD OF Trigger

* Executes **instead of** the triggering operation.
* The original operation does **not** happen automatically.
* The trigger takes control and can decide whether/how the operation should be performed.
* Useful when the original operation needs to be intercepted or controlled.

```text
UPDATE Employees
       ↓
INSTEAD OF trigger fires
       ↓
Original UPDATE is replaced
       ↓
Trigger decides what to do
```

### Key Difference

* **AFTER:** Operation happens → Trigger executes
* **INSTEAD OF:** Trigger executes → Original operation is replaced

**Interview Trigger:** `AFTER` = perform additional logic after the operation; `INSTEAD OF` = intercept/replace the operation.


## Q3. What are `inserted` and `deleted` Logical Tables?

SQL Server provides two special **logical tables** inside DML triggers:

- `inserted` → contains the **new version** of affected rows.
- `deleted` → contains the **old/removed version** of affected rows.

They are automatically provided by SQL Server inside the trigger and are **not permanent tables or tables created by the developer**.

### Behavior by DML Operation

| Operation | `inserted` | `deleted` |
|---|---|---|
| `INSERT` | New rows | Empty |
| `DELETE` | Empty | Deleted/old rows |
| `UPDATE` | New values | Old values |

### Example — UPDATE

Before:

```text
Employee
ID    Salary
101   50000
```

After:

```sql
UPDATE Employee
SET Salary = 60000
WHERE ID = 101;
```

Inside the trigger:

```text
deleted
ID    Salary
101   50000

inserted
ID    Salary
101   60000
```

This allows the trigger to compare the old and new values.

### Important: Multi-Row Operations

`inserted` and `deleted` can contain **multiple rows**.

For example:

```sql
UPDATE Employee
SET Salary = Salary * 1.10
WHERE DepartmentID = 10;
```

If 500 employees are affected:

* `inserted` contains 500 new rows.
* `deleted` contains 500 old rows.

Therefore, triggers should be written using **set-based logic** rather than assuming only one row is affected.

**Interview Trigger:**

* `INSERT` → `inserted`
* `DELETE` → `deleted`
* `UPDATE` → both (`deleted` = old, `inserted` = new)

## Q4. Why should SQL Server triggers generally be written with set-based logic rather than assuming that only one row is affected?

### Interview-ready answer

> The problem is that a DML trigger can handle multiple rows because `inserted` and `deleted` can contain all rows affected by the statement. In this example, 100 employees could be present in `inserted`, but the trigger stores `EmployeeID` in a single scalar variable. Therefore, the subsequent logic cannot correctly process all 100 rows.
>
> Triggers should generally use set-based operations that operate on the entire `inserted` or `deleted` result set rather than assuming that only one row was affected. This ensures the trigger works correctly for both single-row and multi-row DML operations.

## Multi-Row Operations and Set-Based Trigger Logic

A DML trigger can be fired by a statement that affects **multiple rows**.

For example:

```sql
UPDATE Employees
SET Salary = Salary * 1.10
WHERE DepartmentID = 10;
````

If 100 employees are affected, the `inserted` logical table can contain **100 rows**.

### Problem with Scalar Variables

This trigger design is problematic:

```sql
DECLARE @EmployeeID INT;

SELECT @EmployeeID = EmployeeID
FROM inserted;
```

The `inserted` table may contain multiple EmployeeIDs, but `@EmployeeID` can hold only **one value**.

Therefore, subsequent logic based on `@EmployeeID` cannot correctly process all affected rows.

### Set-Based Approach

Instead of extracting one row into a scalar variable, operate directly on the entire `inserted` set:

```sql
INSERT INTO EmployeeAudit (EmployeeID, Action)
SELECT EmployeeID, 'UPDATE'
FROM inserted;
```

If 100 employees were updated:

```text
inserted
    ↓
100 rows
    ↓
INSERT ... SELECT
    ↓
100 audit records
```

### Key Concept

Triggers should generally be written using **set-based logic** rather than assuming that only one row is affected.

**Interview Trigger:**
`inserted` / `deleted` can contain multiple rows → avoid scalar-variable or single-row assumptions → use set-based operations.

## Q5. What are the key differences between a Stored Procedure and a Trigger?

### Interview-ready answer

> A stored procedure is a database object that is explicitly invoked by a user, application, or another piece of database code. It is commonly used to encapsulate reusable database operations and can contain parameters, variables, conditional logic, transactions, and error handling.
>
> A trigger, on the other hand, executes automatically in response to a specified database event such as an `INSERT`, `UPDATE`, or `DELETE`. It is commonly used for auditing, enforcing certain database-side rules, or performing related actions automatically.
>
> A stored procedure can perform a DML operation that causes a trigger to fire, but the trigger itself is event-driven rather than explicitly called like a stored procedure.


### Stored Procedure vs Trigger

| Stored Procedure | Trigger |
|---|---|
| Explicitly invoked | Automatically executed |
| Can be called by a user, application, or database code | Fired by a specified database event |
| Can accept parameters | Triggered based on the event rather than caller-supplied parameters |
| Used for reusable database operations | Used for event-driven database logic |
| Can contain procedural logic, transactions, and error handling | Can contain SQL and procedural logic that responds to the triggering event |

### Execution

**Stored Procedure:**

```text
Application/User
      ↓
EXEC StoredProcedure
      ↓
Stored Procedure executes
````

**Trigger:**

```text
INSERT / UPDATE / DELETE
      ↓
Trigger automatically fires
```

### Relationship Between Them

A stored procedure can perform a DML operation that causes a trigger to fire:

```text
Stored Procedure
      ↓
UPDATE Employees
      ↓
Trigger fires automatically
```

The trigger is not explicitly called by the stored procedure. The **DML operation performed by the procedure causes the trigger to execute**.

### Typical Use Cases

**Stored Procedure:**

* Reusable database operations
* Complex database workflows
* Parameterized operations
* Transactions
* Data processing

**Trigger:**

* Auditing
* Automatic logging
* Event-driven actions
* Enforcing certain database-side rules

**Interview Trigger:**
Stored Procedure = **explicitly invoked**
Trigger = **automatically fired by an event**


## Q6. Practical Audit Scenario

You have a critical `EmployeeSalary` table.

Whenever someone **updates an employee's salary**, you want to automatically record:

- Employee ID
- Old salary
- New salary
- Who made the change
- When it happened

**How would you design this using a SQL Server trigger?**

You don't need to write perfect SQL. Explain **which trigger type you'd use and how you'd get the old and new salary values**.

### Interview-ready answer

> I would create an `AFTER UPDATE` trigger on the `EmployeeSalary` table. The trigger would use the `deleted` logical table to obtain the old salary and the `inserted` logical table to obtain the new salary. I would also capture the employee ID, the current SQL Server user, and the current timestamp, and insert these details into an audit table. The trigger should be written using set-based logic so that it correctly handles updates affecting multiple employees.

### Audit Logging Using a Trigger

Suppose we need to audit salary changes in an `EmployeeSalary` table.

Whenever an employee's salary is updated, we want to capture:

- Employee ID
- Old salary
- New salary
- User who performed the change
- Timestamp of the change

### Trigger Design

Use an **`AFTER UPDATE` trigger** because the audit should be recorded after the salary update has successfully occurred.

The trigger can use:

- `deleted` → old salary
- `inserted` → new salary
- `SUSER_SNAME()` → current SQL Server login
- `SYSDATETIME()` → current timestamp

```text
AFTER UPDATE Trigger
        ↓
inserted + deleted
        ↓
Employee ID
Old Salary
New Salary
Current User
Current Timestamp
        ↓
Audit Table
````

### Important: Multi-Row Updates

The trigger must use **set-based logic** because a single `UPDATE` statement can affect multiple employees.

```text
deleted                 inserted
--------                --------
Emp 101  50K            Emp 101  55K
Emp 102  60K            Emp 102  66K
Emp 103  70K            Emp 103  77K
        ↓
       Audit Table
```

The old and new rows can be matched using the employee's key.

**Interview Trigger:**
`AFTER UPDATE` + `deleted` (old values) + `inserted` (new values) + user + timestamp → audit table.



## Final Trigger Question — Q7

You've now covered the mechanics. Let's finish with the **design/trade-off question**:

> **What are the disadvantages or risks of using database triggers?**

Think about things like **performance, debugging, hidden behavior, and complexity**.


### Interview-ready answer

> Triggers can introduce several disadvantages. First, they can affect performance because their work becomes part of the operation that fired them. If a trigger performs expensive queries or additional DML operations, the original operation can become significantly slower, especially for large multi-row operations.
>
> Second, triggers can make debugging more difficult because they execute automatically and can introduce hidden side effects that aren't obvious from the original DML statement.
>
> Finally, complex triggers can make database logic harder to understand and maintain. Therefore, triggers should generally be kept focused and used when automatic, event-driven behavior is genuinely required.

### Disadvantages and Risks of Triggers

#### 1. Performance Impact

Trigger execution becomes part of the operation that fired the trigger.

If a trigger performs expensive queries or additional DML operations, it can significantly increase the cost of the original operation.

```text
UPDATE 100,000 rows
        ↓
Trigger fires
        ↓
Expensive processing
        ↓
UPDATE takes longer
````

This can become particularly significant when large numbers of rows are affected.

### 2. Debugging Difficulty

Triggers execute automatically and can introduce **hidden side effects**.

For example:

```text
UPDATE Employees
       ↓
Trigger fires
       ↓
UPDATE AuditTable
       ↓
INSERT AnotherTable
       ↓
Additional logic
```

A developer looking only at the original `UPDATE` may not immediately realize that additional operations are being performed.

#### 3. Complexity and Maintainability

Triggers can become difficult to understand and maintain if they contain too much logic.

Complex triggers can make it difficult to determine:

* What operations are being performed
* What caused a particular change
* Where an error originated
* What other database objects are affected

Therefore, triggers should generally be kept **small, focused, and predictable**.

#### 4. Implicit Behavior

Unlike a stored procedure, which is explicitly called:

```sql
EXEC SomeProcedure;
```

a trigger executes automatically when its triggering event occurs.

This makes triggers powerful for event-driven behavior, but it can also make the database behavior less obvious to developers.

### Key Takeaway

Triggers are useful when **automatic, event-driven database behavior** is required, but they should be used carefully to avoid unnecessary performance overhead, hidden side effects, and excessive complexity.

**Interview Trigger:**
Triggers = automatic + powerful → but can introduce performance overhead, hidden behavior, and maintenance/debugging complexity.







