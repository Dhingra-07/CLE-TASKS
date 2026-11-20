-- CREATING THE ANOTHER TABLE FOR PERFORMING THE JOINS BETWEEN USERS AND ORDER TABLE

/*USE startersql;

CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    product_name VARCHAR(100),
    amount DECIMAL(10,2)
);

-- INSERTING THE VALUES INTO ORDERS TABLE

INSERT INTO orders (user_id, product_name, amount)
VALUES
(1, 'Laptop', 55000),
(1, 'Mouse', 800),
(2, 'Keyboard', 1500),
(3, 'Monitor', 12000),
(3, 'Headphones', 2500);
  
  -- CHECKING THE CONTENT IN THE ORDER TABLE
  SELECT * FROM ORDERS;

  -- NOW PERFORMING THE JOINS

--INNER JOIN (users.id = 1 matches orders where orders.user_id = 1.
ABHISHEK appears twice because he has two orders.
Users without matching orders are not included)

SELECT 
USERS.ID,USERS.NAME,ORDERS.PRODUCT_NAME,ORDERS.AMOUNT
FROM USERS 
INNER JOIN ORDERS 
ON USERS.ID = ORDERS.USER_ID;

-- LEFT JOIN
--A LEFT JOIN returns all records from the left table, along with matching records from the right table.
--If a left-table record has no match, the right-table columns contain NULL.

SELECT
    u.id,
    u.name,
    u.city,
    o.product_name,
    o.amount
FROM users AS u
LEFT JOIN orders AS o
    ON u.id = o.user_id;

    -- NOW CONDITION ( COMBINE JOIN WITH GROUP BY AND SUM )
    -- SUPPOSE A COMPANY WANTS TO KNOW THE TOTAL AMOUNT SPENT BY EACH USER

    SELECT
    u.id,
    u.name,
    SUM(o.amount) AS total_spent
FROM users AS u
INNER JOIN orders AS o
    ON u.id = o.user_id
GROUP BY
    u.id,
    u.name
ORDER BY total_spent DESC;

What does this query do?
1. INNER JOIN connects users with their orders.
2. GROUP BY creates a group for each user.
3. SUM(o.amount) calculates each user's total spending.
4. ORDER BY total_spent DESC displays the highest spenders first.

-- NOW FIND USERS WHOSE TOTAL SPENDING EXCEEDS RS 10000
SELECT 
U.ID, U.NAME, SUM(O.AMOUNT) AS TOTAL_SPENT
FROM USERS AS U
INNER JOIN ORDERS AS O
ON U.ID = O.USER_ID
GROUP BY 
U.ID, U.NAME 
HAVING SUM(O.AMOUNT) > 10000
ORDER BY TOTAL_SPENT DESC;

---IF WE WANT TO JOIN THE TABLE USING LEFT JOIN WITH COUNT AND SUM
SELECT U.ID, U.NAME,
COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
COALESCE(SUM(O.AMOUNT),0) AS TOTAL_SPENT
FROM USERS AS U
LEFT JOIN ORDERS AS O
 ON U.ID = O.USER_ID 
 GROUP BY 
 U.ID,U.NAME
 ORDER BY TOTAL_SPENT DESC;
 

 -- NOW WE USING THE FULL OUTER JOIN 
 SELECT 
 U.ID,U.NAME,O.ORDER_ID,O.USER_ID,O.PRODUCT_NAME
 FROM USERS AS U
 FULL OUTER JOIN ORDERS AS O
 ON U.ID = O.ORDER_ID;
 */

 -- FINDING THE ONLY UNMATCHED RECORDS FROM EITHER TABLE
 /*SELECT
    u.id,
    u.name,
    o.order_id,
    o.user_id
FROM users AS u
FULL OUTER JOIN orders AS o
    ON u.id = o.user_id
WHERE u.id IS NULL
   OR o.order_id IS NULL;
   */

   -- SELF JOIN 
  --HAVING THE SAME DOB
 /* SELECT
    u1.name AS User1,
    u2.name AS User2,
    u1.date_of_birth
FROM users AS u1
INNER JOIN users AS u2
    ON u1.date_of_birth = u2.date_of_birth
    AND u1.id < u2.id;*/

    --FIND THE USERS EARNING MORE THAN ANOTHER USER
   /* SELECT
    u1.name AS HigherPaidUser,
    u1.salary AS HigherSalary,
    u2.name AS LowerPaidUser,
    u2.salary AS LowerSalary
FROM users AS u1
INNER JOIN users AS u2
    ON u1.salary > u2.salary;*/

-- HOW TO AVOID ACCIDENTAL DUPLICATES AGGREGATE BEFORE JOINING 
 /*  WITH Orders AS (
    SELECT 1 AS user_id, 101 AS order_id, CAST(1000 AS DECIMAL(10,2)) AS amount
    UNION ALL
    SELECT 1, 102, CAST(2000 AS DECIMAL(10,2))
),
SupportTickets AS (
    SELECT 1 AS user_id, 201 AS ticket_id
    UNION ALL
    SELECT 1, 202
    UNION ALL
    SELECT 1, 203
),
OrderSummary AS (
    SELECT
        user_id,
        COUNT(*) AS total_orders,
        SUM(amount) AS total_spending
    FROM Orders
    GROUP BY user_id
),
TicketSummary AS (
    SELECT
        user_id,
        COUNT(*) AS total_tickets
    FROM SupportTickets
    GROUP BY user_id
)
SELECT
    u.id AS user_id,
    u.name,
    COALESCE(o.total_orders, 0) AS total_orders,
    COALESCE(o.total_spending, 0) AS total_spending,
    COALESCE(t.total_tickets, 0) AS total_tickets
FROM users AS u
LEFT JOIN OrderSummary AS o
    ON u.id = o.user_id
LEFT JOIN TicketSummary AS t
    ON u.id = t.user_id
WHERE u.id = 1; */
 
 -- MULTI TABEL JOINS WITHOUT DUPLICATING TOTALS 

/* WITH OrderSummary AS (
    SELECT
        user_id,
        COUNT(*) AS total_orders,
        SUM(amount) AS total_spending,
        AVG(amount) AS average_order_amount
    FROM orders
    GROUP BY user_id
)
SELECT
    u.id,
    u.name,
    COALESCE(o.total_orders, 0) AS total_orders,
    COALESCE(o.total_spending, 0) AS total_spending,
    o.average_order_amount
FROM users AS u
LEFT JOIN OrderSummary AS o
    ON u.id = o.user_id
ORDER BY u.id;*/

-- CHECKING HOW MANY JOIN DONE AFTER DOING JOINING 
/*SELECT COUNT(*) AS total_users
FROM users;
SELECT COUNT(*) AS joined_rows
FROM users AS u
LEFT JOIN orders AS o
    ON u.id = o.user_id;*/