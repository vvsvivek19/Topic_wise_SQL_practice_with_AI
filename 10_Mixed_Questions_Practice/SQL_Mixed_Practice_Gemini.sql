/*
  =============================================================================
  Warm-up Challenge #1: The Delivery Rating Audit
  -----------------------------------------------------------------------------
  Task: 
  Query the `delivery_orders` table to find the following metrics for each customer:
    1. `customer_id`
    2. `total_orders`: The total count of all orders placed by the customer.
    3. `rated_orders`: The count of orders that actually received a delivery rating 
       (i.e., where `delivery_rating` is NOT NULL).
    4. `avg_order_amount`: The average amount spent per customer.

  Filter Constraint:
    - Only display customers who have placed **more than 1 order** total.
    - Order the final output by `total_orders` descending.
  =============================================================================
*/

-- DROP TABLE IF EXISTS delivery_orders;

-- CREATE TABLE delivery_orders (
--     order_id INT PRIMARY KEY,
--     customer_id INT,
--     delivery_rating INT, -- Can be NULL if the customer didn't rate
--     order_amount DECIMAL(10,2),
--     order_date DATE
-- );

-- INSERT INTO delivery_orders VALUES 
-- (1, 101, 5, 450.00, '2026-01-01'),
-- (2, 101, NULL, 300.00, '2026-01-03'), -- Unrated order for customer 101
-- (3, 102, 4, 1200.00, '2026-01-02'),
-- (4, 103, 3, 250.00, '2026-01-02'),
-- (5, 101, 5, 600.00, '2026-01-05'),
-- (6, 102, NULL, 400.00, '2026-01-06'); -- Unrated order for customer 102

SELECT 
	customer_id,
    count(*) as total_orders,
    count(delivery_rating) as rated_orders,
    AVG(order_amount) as avg_order_amount
FROM delivery_orders
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;

/*
  =============================================================================
  Challenge #2: The Time-Lapse Offset (Retention Analytics)
  -----------------------------------------------------------------------------
  Task: 
  The growth team wants to know how many days elapse between consecutive 
  orders for returning users. 
  
  Write a query that projects the following for each customer:
    1. `customer_id`
    2. `order_id`
    3. `order_date`
    4. `previous_order_date`: The exact date of the customer's chronologically 
       preceding order.
    5. `days_since_last_order`: The difference in days between the current 
       order_date and the previous_order_date.

  Filter Constraint:
    - Exclude the very first order for every customer from the final output 
      (i.e., we only want to see rows where a previous order actually exists).
  =============================================================================
*/

-- TRUNCATE TABLE delivery_orders;

-- INSERT INTO delivery_orders VALUES 
-- (1, 101, 5, 450.00, '2026-01-01'), -- Cust 101: 1st Order (Exclude from final)
-- (2, 101, NULL, 300.00, '2026-01-05'), -- Cust 101: 2nd Order (Gap: 4 days)
-- (3, 101, 4, 600.00, '2026-01-12'), -- Cust 101: 3rd Order (Gap: 7 days)
-- (4, 102, 4, 1200.00, '2026-01-02'), -- Cust 102: 1st Order (Exclude)
-- (5, 102, NULL, 400.00, '2026-01-06'), -- Cust 102: 2nd Order (Gap: 4 days)
-- (6, 103, 5, 250.00, '2026-01-10'); -- Cust 103: 1st Order (Exclude)

SELECT * FROM delivery_orders;

SELECT 
    customer_id, 
    order_id, 
    order_date,
    previous_order_date,
    DATEDIFF(order_date, previous_order_date) AS days_since_last_order
FROM (
    SELECT 
        customer_id, 
        order_id, 
        order_date,
        LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) as previous_order_date
    FROM delivery_orders
) t
WHERE previous_order_date IS NOT NULL;

/*
  =============================================================================
  Warm-up Challenge #3: The Execution Order Crash
  -----------------------------------------------------------------------------
  Task: 
  A junior analyst at Blinkit wrote the following query to find high-value 
  customers who have spent more than 500 in total. 

  THE BROKEN QUERY:
  SELECT 
      user_id, 
      SUM(order_value) AS total_spent 
  FROM blinkit_orders 
  WHERE total_spent > 500 
  GROUP BY user_id;

  The SQL engine instantly throws an error and crashes. 
  
  Your Job:
  1. Fix the query so it runs successfully and returns the correct data.
  2. Explain *why* the original query failed based on the SQL Order of Execution.
  =============================================================================
*/

-- DROP TABLE IF EXISTS blinkit_orders;

-- CREATE TABLE blinkit_orders (
--     order_id INT PRIMARY KEY,
--     user_id INT,
--     order_value DECIMAL(10,2)
-- );

-- INSERT INTO blinkit_orders VALUES 
-- (1, 201, 300.00),
-- (2, 201, 250.00), -- User 201 Total: 550 (Should appear in results)
-- (3, 202, 100.00),
-- (4, 202, 150.00), -- User 202 Total: 250 (Should NOT appear)
-- (5, 203, 800.00); -- User 203 Total: 800 (Should appear in results)

SELECT 
      user_id, 
      SUM(order_value) AS total_spent 
  FROM blinkit_orders 
  GROUP BY user_id
  HAVING total_spent > 100;

SELECT * FROM blinkit_orders;



















