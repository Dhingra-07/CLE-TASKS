/*Real-world practical project: Build a Multi-Step ETL Pipeline
Now let's combine all four concepts into one practical example..
The company wants a report containing:
- Customer ID
- Customer name
- Customer city
- Product name
- Product category
- Total order amount
- Total spending by each customer

We will implement this in multiple steps.
Step 1: Extract and transform using CTEs*/

/*WITH CustomerData AS
(
    SELECT
        id AS user_id,
        name,
        city
    FROM users
),

OrderData AS
(
    SELECT
        order_id,
        user_id,
        product_id,
        amount
    FROM orders
),

ProductData AS
(
    SELECT
        product_id,
        product_name,
        category
    FROM products
)

SELECT
    c.user_id,
    c.name,
    c.city,
    p.product_name,
    p.category,
    o.amount
INTO #ETL_Stage
FROM CustomerData c

INNER JOIN OrderData o
    ON c.user_id = o.user_id

INNER JOIN ProductData p
    ON o.product_id = p.product_id;*/

    --Step 2: Validate the intermediate data
   /* SELECT * FROM #ETL_Stage;
    SELECT COUNT(*) AS total_records
FROM #ETL_Stage;
SELECT *
FROM #ETL_Stage
WHERE PRODUCT_NAME IS  NULL;*/

--TRANSFORM AND AGGREGATE DATA
/*SELECT
    user_id,
    name,
    city,
    SUM(amount) AS total_spending,
    COUNT(*) AS total_orders
FROM #ETL_Stage
GROUP BY
    user_id,
    name,
    city;*/

    --Step 4: Create a reusable View
/*CREATE VIEW vw_customer_spending
AS
SELECT
    u.id AS user_id,
    u.name,
    u.city,
    SUM(o.amount) AS total_spending,
    COUNT(o.order_id) AS total_orders
FROM users u
INNER JOIN orders o
    ON u.id = o.user_id
GROUP BY
    u.id,
    u.name,
    u.city;*/

    SELECT *
FROM vw_customer_spending;
DROP TABLE #ETL_Stage;