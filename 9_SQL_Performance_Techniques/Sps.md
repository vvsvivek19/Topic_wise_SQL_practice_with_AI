# Stored Procedures - Revision with ChatGPT

## Q1. What is a Stored Procedure, and why would you use one instead of executing SQL queries directly?

### Answer

A **Stored Procedure (SP)** is a named database object that contains a set of SQL statements and procedural logic that can be executed repeatedly.

One of the main reasons to use a Stored Procedure is to **encapsulate reusable and potentially complex database logic** in one place.

Instead of repeatedly writing the same SQL statements, joins, conditions, loops, transactions, and error-handling logic, we can define them once inside a Stored Procedure and call it whenever required.

Stored Procedures can also accept **parameters**, allowing the same procedure to work with different input values.

For example, if an operation needs to be performed regularly with different inputs, instead of rewriting the entire T-SQL logic each time, we can create a parameterized Stored Procedure and call it whenever needed.

This improves:

- Code reusability
- Maintainability
- Consistency
- Encapsulation of database logic
- Ability to handle complex procedural logic
- Parameterized execution

### Mental Model

```text
Define Logic Once
       ↓
Stored Procedure
       ↓
Call with Parameters
       ↓
Execute Logic
       ↓
Result / Action
```

### Stored Procedure vs Direct Query

| Aspect          | Direct Query                                        | Stored Procedure                              |
| --------------- | --------------------------------------------------- | --------------------------------------------- |
| Reusability     | Query usually written/executed directly             | Logic can be called repeatedly                |
| Complexity      | Can contain SQL logic                               | Can contain SQL + procedural logic            |
| Parameters      | Can use parameters depending on execution method    | Can explicitly define input/output parameters |
| Error Handling  | Limited to the individual execution context         | Can include structured error handling         |
| Transactions    | Can use transactions                                | Can contain and control transaction logic     |
| Maintainability | Logic may be duplicated across applications/scripts | Centralized database logic                    |

### Key Points

* A Stored Procedure is a named database object containing SQL statements and procedural logic.
* It can be executed repeatedly.
* It can accept parameters.
* It can contain variables, conditions, loops, transactions, and error handling.
* It helps centralize and reuse database logic.
* It reduces duplication when the same database operation is required repeatedly.

### Interview Tip

A useful analogy is:

> **Stored Procedure ≈ Function in a programming language**

Both encapsulate reusable logic so that it can be defined once and executed multiple times.

However, don't say that Stored Procedures are used because a query might produce errors. **Error handling is a capability of Stored Procedures, not the primary reason for creating one.**

The strongest opening is:

> **"A Stored Procedure is a reusable database object that encapsulates SQL and procedural logic so that the same operation can be executed consistently without rewriting the logic each time."**


## Q2. If we can execute a normal SQL query, why do we need a Stored Procedure?

### Answer

A normal SQL query and a Stored Procedure can sometimes produce the same result, so the main difference is not simply the output they return.

The advantage of a **Stored Procedure** is that it encapsulates database logic into a **named, reusable database object**.

A Stored Procedure can contain:

- Multiple SQL statements
- Parameters
- Variables
- Conditional logic
- Loops
- Transactions
- Error handling

This allows applications or users to call the same database operation repeatedly without duplicating the underlying implementation.

For example:

```sql
EXEC GetEmployeesByDepartment 'IT';
EXEC GetEmployeesByDepartment 'HR';
EXEC GetEmployeesByDepartment 'Sales';
````

The caller only needs to know the procedure name and the required parameters. The internal implementation remains encapsulated inside the Stored Procedure.

### Important Clarification About Parameters

Parameters are **not exclusive to Stored Procedures**.

A normal SQL query can also be parameterized:

```sql
SELECT *
FROM Employees
WHERE department = @department;
```

Therefore, parameterization alone is not the primary reason to use a Stored Procedure.

The bigger advantage is the ability to **encapsulate and reuse a complete database operation** containing multiple statements and procedural logic.

### Comparison

| Aspect              | Normal SQL Query                          | Stored Procedure                                |
| ------------------- | ----------------------------------------- | ----------------------------------------------- |
| Reusability         | Query must be supplied/executed by caller | Named database object can be called repeatedly  |
| Parameters          | Can be parameterized                      | Supports input/output parameters                |
| Multiple statements | Possible in a SQL batch/script            | Can contain multiple statements                 |
| Procedural logic    | Depends on the SQL/batch context          | Can contain variables, conditions, loops, etc.  |
| Transactions        | Can be used                               | Can encapsulate transaction logic               |
| Error handling      | Depends on execution context              | Can contain structured error handling           |
| Encapsulation       | Logic remains with the query/application  | Logic is centralized in the database            |
| Abstraction         | Caller generally sees the query           | Caller can interact through procedure interface |

### Mental Model

```text
Normal Query

Caller
  ↓
SQL Query
  ↓
Database
  ↓
Result
```

```text
Stored Procedure

Caller
  ↓
Procedure Name + Parameters
  ↓
Stored Procedure
  ↓
Internal SQL + Procedural Logic
  ↓
Result / Action
```

### Key Concept

> **Normal Query → Execute SQL logic**

> **Stored Procedure → Encapsulate and reuse a complete database operation**

### Interview Tip

Do not say:

> "Stored Procedures are useful because normal queries cannot accept parameters."

Normal SQL queries can also be parameterized.

Instead, emphasize:

> **"The main advantage of a Stored Procedure is centralized encapsulation and reuse of database logic, especially when the operation involves multiple statements, procedural logic, transactions, and error handling."**


## Q3. Stored Procedure vs View — Why would you use a Stored Procedure instead of a View?

### Answer

Although both Views and Stored Procedures store database logic, they serve different purposes.

A **View** primarily encapsulates a `SELECT` query and provides a reusable interface for retrieving data. A View can contain joins and other SQL logic, but it is generally intended for presenting/querying data. Its ability to perform `INSERT`, `UPDATE`, or `DELETE` depends on whether the View is updatable.

A **Stored Procedure** is designed for executing a complete database operation. It can accept input and output parameters and can contain multiple SQL statements, variables, conditional logic, loops, transactions, and structured error handling.

It can also perform operations such as:

- `INSERT`
- `UPDATE`
- `DELETE`

Therefore, if I only need to expose or retrieve data, I would generally consider a **View**. If I need to execute a multi-step operation involving parameters, procedural logic, DML, transactions, or error handling, I would use a **Stored Procedure**.

### Example

A View might be used to expose employee information:

```sql
CREATE VIEW vw_EmployeeDepartment AS
SELECT
    e.emp_id,
    e.emp_name,
    d.department_name
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id;
````

A Stored Procedure could perform a more complex operation:

```sql
CREATE PROCEDURE UpdateEmployeeSalary
    @emp_id INT,
    @new_salary DECIMAL(10,2)
AS
BEGIN
    UPDATE Employees
    SET salary = @new_salary
    WHERE emp_id = @emp_id;
END;
```

### Comparison

| Aspect                         | View                                                          | Stored Procedure                          |
| ------------------------------ | ------------------------------------------------------------- | ----------------------------------------- |
| Primary purpose                | Retrieve/present data                                         | Execute database operations               |
| Main SQL                       | Primarily `SELECT`                                            | Can contain multiple SQL statements       |
| Parameters                     | Does not accept procedure-style parameters                    | Supports input/output parameters          |
| Joins                          | Can contain joins                                             | Can contain joins                         |
| `INSERT` / `UPDATE` / `DELETE` | Possible only for updatable Views and subject to restrictions | Can perform DML                           |
| Variables                      | No procedural variables like an SP                            | Supported                                 |
| `IF/ELSE`                      | Not supported as procedural logic                             | Supported                                 |
| Loops                          | Not supported as procedural logic                             | Supported                                 |
| Transactions                   | Not used as procedural transaction logic                      | Can contain transaction logic             |
| Error handling                 | Limited                                                       | Can use `TRY...CATCH`                     |
| Result                         | Primarily exposes a result set                                | Can return results and/or perform actions |


### Key Concept

> **View → Expose/query data**

> **Stored Procedure → Execute database operations**



## Q4. What is the difference between a Parameter and a Variable in a Stored Procedure?

### Answer

A parameter and a variable are both used to store values within a Stored Procedure, but they have different purposes.

A parameter is part of the procedure's interface and is used to exchange values between the caller and the procedure. The caller can provide an input parameter, and a procedure can also return values through output parameters.

A variable is an internal storage location used by the procedure while it is executing. Its value is assigned and controlled by the procedure itself, usually from calculations, parameters, or data retrieved from the database.

Both have execution scope and their values do not persist after the procedure execution ends.

For example:

```sql
EXEC GetEmployeeSalary @emp_id = 101;
````

Here, `@emp_id` is an input parameter supplied by the caller.

A **variable** is an internal storage location used by the Stored Procedure while it is executing. Its value is assigned and controlled by the procedure itself. The value can come from a parameter, a calculation, or data retrieved from the database.

For example:

```sql
DECLARE @salary DECIMAL(10,2);

SELECT @salary = salary
FROM Employees
WHERE emp_id = @emp_id;
```

Here, `@salary` is an internal variable whose value is obtained from the database.

### Comparison

| Aspect                       | Parameter                                                  | Variable                                            |
| ---------------------------- | ---------------------------------------------------------- | --------------------------------------------------- |
| Purpose                      | Exchange values between caller and procedure               | Store values for internal processing                |
| Value supplied by            | Usually the caller                                         | Procedure itself                                    |
| Scope                        | Procedure execution                                        | Procedure execution                                 |
| Can receive caller input?    | Yes                                                        | No, not directly                                    |
| Can receive database values? | Can be assigned/used depending on parameter type and logic | Yes                                                 |
| Output capability            | Can be an `OUTPUT` parameter                               | Cannot directly act as a procedure output parameter |
| Lifetime                     | Procedure execution                                        | Procedure execution                                 |

### Example

```sql
CREATE PROCEDURE GetEmployeeSalary
    @emp_id INT
AS
BEGIN
    DECLARE @salary DECIMAL(10,2);

    SELECT @salary = salary
    FROM Employees
    WHERE emp_id = @emp_id;

    IF @salary > 100000
        PRINT 'High Salary';
    ELSE
        PRINT 'Regular Salary';
END;
```

In this example:

* `@emp_id` → **Parameter** supplied by the caller.
* `@salary` → **Variable** used internally by the procedure.

### Mental Model

```text
Caller
   ↓
Parameter
   ↓
Stored Procedure
   ↓
Variable
   ↓
Internal Processing
   ↓
Result / Output Parameter
```

### Key Concept

> **Parameter → Interface between caller and Stored Procedure**

> **Variable → Internal storage used by the Stored Procedure**

### Important Note

The values of parameters and variables exist only within their applicable execution scope. They do not persist after the Stored Procedure execution ends.

### Interview Tip

A simple way to remember the distinction is:

> **"Parameters come into or go out of the procedure; variables are used inside the procedure."**


## Q5. How do you handle errors inside a Stored Procedure in SQL Server?

### Answer

### Error Handling in Stored Procedures

- SQL Server uses **`TRY...CATCH`** for error handling, conceptually similar to Python's `try...except`.
- Statements that may generate an error are placed inside the `TRY` block.
- If an error occurs, control moves to the `CATCH` block.
- `TRY...CATCH` is often combined with **transactions** when multiple operations must succeed or fail together.
- If an error occurs during the transaction:
  - Check whether a transaction is active using `@@TRANCOUNT`.
  - `ROLLBACK TRANSACTION` to undo partial changes.
  - `THROW` to re-raise the error and notify the caller.

### Common Pattern

```sql
BEGIN TRY
    BEGIN TRANSACTION;

    -- SQL operations

    COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH
```

## Q6. Stored Procedure vs Python/Application Code

### Answer

## Stored Procedure vs Python/Application Code

| Stored Procedure | Python/Application Code |
|---|---|
| Stored and executed inside SQL Server | Runs outside the database |
| Primarily suited for database-centric operations | Suited for application-level and general-purpose logic |
| Can encapsulate multiple SQL operations | Can orchestrate database operations and external systems |
| Can manage database transactions | Can also manage database transactions through the database driver |
| May reduce application-database round trips by executing multiple operations in one call | Requires communication with the database to perform database operations |
| Limited to database/programming capabilities supported by SQL Server | Can leverage Python libraries, APIs, files, ML, etc. |

### When to Prefer a Stored Procedure

Use a stored procedure when the logic primarily belongs to the **database**, such as:

- Multiple related SQL operations
- Database-side business rules
- Data validation
- Transactional operations
- Reusable database operations

### When to Prefer Python/Application Code

Use application code when the logic involves:

- External APIs/services
- File processing
- General-purpose computation
- Python libraries
- Application workflows
- ML or other processing outside the database

**Important:** The decision is not simply **simple logic → Stored Procedure** and **complex logic → Python**. The key question is **where the logic belongs: database or application layer?**

**Interview Trigger:** Database-centric logic → Stored Procedure; application/external-system logic → Python/Application layer.

