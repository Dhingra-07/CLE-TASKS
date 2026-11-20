/*USE startersql;
SELECT * FROM USERS;
SELECT * FROM ORDERS;
SELECT * FROM products;*/

-- NOW PERFORMING UNION (ITS REMOVE THE DULPICATE ROWS FROM THE COMBINED RESULTS )
--SELECT CITY FROM USERS;
/*SELECT CITY 
FROM USERS
WHERE CITY IS NOT NULL
UNION 
SELECT CITY FROM USERS
WHERE CITY IS NOT NULL;*/

--UNION ALL (ITS KEEPS THE DUPLICATES)

/*SELECT city
FROM users
WHERE city IS NOT NULL

UNION ALL

SELECT city
FROM users
WHERE city IS NOT NULL;*/
/*SELECT name
FROM users

UNION ALL

SELECT product_name
FROM products;*/

--PART - 2 (INTERSECT AND EXCEPT)
/*SELECT id
FROM users

INTERSECT

SELECT user_id
FROM orders;*/

/*When should you use INTERSECT?
Use it to find common records between two result sets.
- Customers present in two databases.
- Products appearing in two inventories.
- IDs appearing in two datasets.*/
/*
SELECT id
FROM users

EXCEPT

SELECT user_id
FROM orders;*/

/*| Operator | What it returns |
| `INTERSECT` | Records appearing in both results |
| `EXCEPT` | Records appearing in the first result but not the second |*/

--This query can help identify orphaned order references.
/*SELECT user_id
FROM orders

EXCEPT

SELECT id
FROM users;
*/

--PART-3
-- SUB QUERIES ( A QUERY INSIDE ANOTHER QUERY)
-- SCALAR SUBQUERY ( A SCALAR SUBQUERY RETURN ONE VALUE : ONE ROW AND ONE COLUMN)

--Find users earning above the average salary
/*SELECT
    id,
    name,
    salary
FROM users
WHERE salary > (
    SELECT AVG(salary)
    FROM users
);*/

--Find the highest-paid user or users
/*SELECT
    id,
    name,
    salary
FROM users
WHERE salary = (
    SELECT MAX(salary)
    FROM users
);*/

/*When should you use scalar subqueries?
Use them when you need a single calculated value for comparison, such as:
- Salary greater than the average.
- Price equal to the maximum price.
- Orders greater than the average order amount.
- Salary equal to the minimum salary.*/

-- PART - 4 (IN OPERATOR)
-- FINDING THE USERS WITH ID 1, 2, 6--- 
/*SELECT
    id,
    name,
    city
FROM users
WHERE id IN (1, 2, 6);*/

-- FINDING THE USERS  WHO HAVE PLACED ORDERS 
/*SELECT
    id,
    name
FROM users
WHERE id IN (
    SELECT user_id
    FROM orders
);*/
/*When should you use IN?
Use it when you want to find records whose values belong to a set of values.

Examples:
- Users with orders.
- Products belonging to selected categories.
- Employees belonging to specified departments.*/
  
  -- USING NOT IN 
 /* SELECT id, name
FROM users
WHERE id NOT IN (
    SELECT user_id
    FROM orders
);*/
--Be careful when using NOT IN if the subquery can return NULL.

-- PART 5 EXISTS AND NOT EXISTS--
/*SELECT
    u.id,
    u.name
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.user_id = u.id
);*/

-- NOT EXISTS
/*SELECT
    u.id,
    u.name
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.user_id = u.id
);*/

-- PART 6 CORRELATED SUB QUERY
/*correlated subquery refers to a column from the outer query.

Unlike a simple scalar subquery that calculates one independent value, 
a correlated subquery is logically evaluated in relation to each candidate outer row.*/

/*SELECT
    u.id,
    u.name
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.user_id = u.id
      AND o.amount > 10000
);*/

/*When should you use correlated subqueries?
Common uses include:
- Finding users with orders.
- Finding users without orders.
- Comparing a user's salary against their department or city average.
- Finding records that meet a condition relative to other records.
- Finding the second-highest or Nth-highest value.*/

-- NOW IMAGINE YOU WANT ONLY USERS WHOSE TOTAL SPENDING EXCEEDS RS 10000
/*SELECT
    u.id,
    u.name,
    o.total_spending
FROM users AS u
INNER JOIN (
    SELECT
        user_id,
        SUM(amount) AS total_spending
    FROM orders
    GROUP BY user_id
) AS o
    ON u.id = o.user_id
WHERE o.total_spending > 10000;*/

-- PART 8 NTH - HIGHEST VALUE PATTERNS 
-- FINDING THE HIGHEST SALARY 

/*SELECT ID, NAME, SALARY 
FROM USERS WHERE SALARY = ( SELECT MAX(salary) FROM USERS);*/

-- FINDING THE SECOND HIGHEST SALARY USING SUBQUERY
/*SELECT
MAX(SALARY) AS SECOND_HIGH FROM USERS
WHERE salary < ( SELECT MAX(salary)  FROM USERS);*/

-- NOW FOR THE THISRD HIGEHEST SALARY 
/*SELECT MAX(salary) AS third_highest_salary
FROM users
WHERE salary < (
    SELECT MAX(salary)
    FROM users
    WHERE salary < (
        SELECT MAX(salary)
        FROM users
    )
);*/

-- PART 9 NTH HIGHEST SALARY USING A CORRELATED SUBQUERY 
 -- FORMULA 
 --Nth-highest salary = the salary with exactly N − 1 distinct salary values above it.
 -- FIND THE SECOND HIGHEST DISTINCT SALARY 
 /*SELECT DISTINCT
    u1.salary AS second_highest_salary
FROM users AS u1
WHERE u1.salary IS NOT NULL
  AND (
      SELECT COUNT(DISTINCT u2.salary)
      FROM users AS u2
      WHERE u2.salary > u1.salary
  ) = 1;*/

  -- THIRD HIGHEST
  /*SELECT DISTINCT
    u1.salary AS third_highest_salary
FROM users AS u1
WHERE u1.salary IS NOT NULL
  AND (
      SELECT COUNT(DISTINCT u2.salary)
      FROM users AS u2
      WHERE u2.salary > u1.salary
  ) = 2;*/

  -- PART 10: Nth-Highest Salary Using DENSE_RANK()
  /*SELECT
    id,
    name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM users
WHERE salary IS NOT NULL;*/
-- THIS GIVES THE RANKINFG ACCORDING TO THE SALARY RANK--
--USE startersql;
/*SELECT
    id,
    name,
    salary
FROM users
WHERE salary > (
    SELECT AVG(salary)
    FROM users
);

SELECT
    u.id,
    u.name
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.user_id = u.id
);

SELECT
    u.id,
    u.name
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.user_id = u.id
);

SELECT
    u.id,
    u.name
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    INNER JOIN products AS p
        ON o.product_id = p.product_id
    WHERE o.user_id = u.id
      AND p.price > 10000
);

SELECT MAX(price) AS second_highest_price
FROM products
WHERE price < (
    SELECT MAX(price)
    FROM products
);*/

