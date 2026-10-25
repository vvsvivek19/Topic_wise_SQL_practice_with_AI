-- CREATE TABLE Employees (
--     EmployeeID INT PRIMARY KEY,
--     EmployeeName VARCHAR(100) NOT NULL,
--     Department VARCHAR(50) NOT NULL,
--     Salary DECIMAL(10, 2),
--     HireDate DATE
-- );

-- INSERT INTO Employees
--     (EmployeeID, EmployeeName, Department, Salary, HireDate)
-- VALUES
--     (1, 'Aarav',  'Engineering', 75000, '2022-03-15'),
--     (2, 'Priya',  'Engineering', 85000, '2021-07-10'),
--     (3, 'Rahul',  'Engineering', 65000, '2023-01-20'),
--     (4, 'Sneha',  'HR',          50000, '2020-06-12'),
--     (5, 'Karan',  'HR',          55000, '2022-11-05'),
--     (6, 'Meera',  'Sales',       60000, '2021-04-18'),
--     (7, 'Vikram', 'Sales',       70000, '2023-08-01'),
--     (8, 'Ananya', 'Sales',       80000, '2020-02-25'),
--     (9, 'Ishaan', 'Marketing',   45000, '2022-09-14'),
--     (10,'Neha',   'Marketing',   52000, '2021-12-03'),
--     (11,'Rohan',  'Engineering', 90000, '2020-10-30'),
--     (12,'Pooja',  'HR',          48000, '2023-05-22');

/*
==========================================================
Warm-up Question 1: Department Salary Analysis
==========================================================

Task:
Find departments whose average employee salary is greater
than 60,000, considering only employees earning at least
50,000.

Requirements:
1. Exclude employees earning less than 50,000 before
   calculating department averages.
2. Return the following columns:
   - Department
   - EmployeeCount: Number of employees included in the
     calculation.
   - AverageSalary: Average salary of those employees.
3. Include only departments whose resulting average salary
   is strictly greater than 60,000.
4. Sort the results by AverageSalary in descending order.

Tables:
Employees(EmployeeID, EmployeeName, Department, Salary,
          HireDate)

==========================================================
*/
SELECT
    Department,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AverageSalary
FROM Employees
WHERE Salary >= 50000
GROUP BY Department
HAVING AverageSalary > 60000
ORDER BY AverageSalary DESC;


/*
==========================================================
Warm-up Question 2: Employees Above Department Average
==========================================================

Task:
Find employees whose salary is greater than the average
salary of their own department.

Requirements:
1. Return:
   - EmployeeID
   - EmployeeName
   - Department
   - Salary
2. Compare each employee's salary against the average
   salary of their department.
3. Include only employees earning strictly more than
   their department's average salary.
4. Sort the results by Department in ascending order,
   then Salary in descending order.

Table:
Employees(EmployeeID, EmployeeName, Department, Salary,
          HireDate)

==========================================================
*/
WITH CTE_avg_salary AS
(
SELECT department, AVG(Salary) as avg_salary
FROM Employees
GROUP BY department
),
CTE_joined AS
(
SELECT E.EmployeeID, E.EmployeeName, E.Department, E.Salary, cas.avg_salary
FROM Employees E 
JOIN CTE_avg_salary as cas
ON E.Department = cas.Department
)
SELECT EmployeeID, EmployeeName, Department, Salary FROM CTE_joined
WHERE Salary > avg_salary;

SELECT EmployeeID, EmployeeName, Department, Salary
FROM (
SELECT *,
	AVG(Salary) OVER(PARTITION BY Department) as avg_dept_salary
FROM Employees)t
WHERE Salary > avg_dept_salary;

/*
==========================================================
Warm-up Question 3: Customers Who Never Ordered
==========================================================

Task:
Find all customers who have never placed an order.

Requirements:
1. Return:
   - CustomerID
   - CustomerName
   - City
2. Include customers who have no matching records in Orders.
3. Sort the results by CustomerID in ascending order.

Tables:
Customers(CustomerID, CustomerName, City)

Orders(OrderID, CustomerID, OrderDate, OrderAmount)

==========================================================
*/

-- CREATE TABLE Customers (
--     CustomerID INT PRIMARY KEY,
--     CustomerName VARCHAR(100) NOT NULL,
--     City VARCHAR(50) NOT NULL
-- );

-- CREATE TABLE Orders (
--     OrderID INT PRIMARY KEY,
--     CustomerID INT,
--     OrderDate DATE NOT NULL,
--     OrderAmount DECIMAL(10, 2) NOT NULL,
--     FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
-- );

-- INSERT INTO Customers (CustomerID, CustomerName, City)
-- VALUES
--     (1, 'Aarav', 'Delhi'),
--     (2, 'Priya', 'Mumbai'),
--     (3, 'Rahul', 'Delhi'),
--     (4, 'Sneha', 'Pune'),
--     (5, 'Karan', 'Mumbai'),
--     (6, 'Meera', 'Chennai'),
--     (7, 'Vikram', 'Pune');

-- INSERT INTO Orders (OrderID, CustomerID, OrderDate, OrderAmount)
-- VALUES
--     (101, 1, '2026-01-10', 1500.00),
--     (102, 2, '2026-01-15', 2200.00),
--     (103, 1, '2026-02-05',  800.00),
--     (104, 4, '2026-02-12', 3100.00),
--     (105, 6, '2026-03-01', 1200.00),
--     (106, 2, '2026-03-08',  950.00);

SELECT 
	c.CustomerID,
    c.CustomerName,
    c.City
FROM Customers c
LEFT JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL
ORDER BY c.CustomerID;

/*
==========================================================
Warm-up Question 4: Rank Employees by Department
==========================================================

Task:
Rank employees within each department based on their salary.

Requirements:
1. Return:
   - EmployeeID
   - EmployeeName
   - Department
   - Salary
   - SalaryRank
2. The highest-paid employee in each department should receive
   rank 1.
3. Employees with equal salaries should receive the same rank.
4. Sort the final output by Department ASC, SalaryRank ASC,
   and EmployeeID ASC.

Table:
Employees(EmployeeID, EmployeeName, Department, Salary, HireDate)

==========================================================
*/

SELECT  EmployeeID,
   EmployeeName,
   Department,
   Salary,
DENSE_RANK() OVER(PARTITION BY Department ORDER BY Salary DESC) as SalaryRank
FROM Employees
ORDER BY Department ASC, SalaryRank ASC, EmployeeID ASC;

/*
==========================================================
Mixed Practice — Question 1: Customer Purchase Analysis
==========================================================

Task:
Identify customers who have placed at least 2 orders
and whose total spending exceeds 2000.

Required output:
- CustomerID
- CustomerName
- City
- TotalOrders
- TotalSpending
- AverageOrderValue (rounded to 2 decimal places)

Requirements:
1. At least 2 orders per customer.
2. Total spending must be greater than 2000.
3. Sort by TotalSpending DESC, CustomerID ASC.
4. Exclude customers without orders.

Tables:
Customers(CustomerID, CustomerName, City)
Orders(OrderID, CustomerID, OrderDate, OrderAmount)

==========================================================
*/

-- Write your solution here
WITH CTE_aggregate_data AS
(
SELECT o.CustomerID,
COUNT(*) TotalOrders,
SUM(o.OrderAmount) TotalSpending,
round(AVG(o.OrderAmount),2) AverageOrderValue
FROM orders o
LEFT JOIN  customers c
ON c.CustomerID = o.CustomerID
GROUP BY o.CustomerID
HAVING TotalOrders >= 2 AND  TotalSpending > 2000
)
SELECT cad.CustomerID, c.CustomerName, c.City, cad.TotalOrders, cad.TotalSpending, cad.AverageOrderValue
FROM CTE_aggregate_data as cad
JOIN Customers c 
ON cad.CustomerID = c.CustomerID;





























