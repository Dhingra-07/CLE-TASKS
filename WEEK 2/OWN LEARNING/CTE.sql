--USE startersql;

-- NOW PERFORMING THE CTE(COMMON TABLE EXPRESSION)
--A CTE is a temporary named result set that you 
--create inside a SQL query using the WITH keyword.

/*WITH HighSalaryUsers AS
(
    SELECT
        id,
        name,
        city,
        salary
    FROM users
    WHERE salary > 30000
)

SELECT *
FROM HighSalaryUsers;*/

-- GENERATE A CUSTOMER ORDER REPORT CONTAINING USER DETAILS, PRODUCT DETAOLS AND ORDER AMOUNTS.
/*USE startersql;
WITH UserData AS
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
        category,
        price
    FROM products
)

SELECT
    u.user_id,
    u.name,
    u.city,
    o.order_id,
    p.product_name,
    p.category,
    o.amount
FROM UserData u
INNER JOIN OrderData o
    ON u.user_id = o.user_id
INNER JOIN ProductData p
    ON o.product_id = p.product_id;*/

    -- NOW PERFORMING THE R CTE(RECURSIVE COMMON TABLE EXPRESSION)
/* A recursive CTE is a CTE that refers to itself repeatedly to generate or process data.
It is useful when data has a hierarchy or a sequence.
Common applications:
- Employee-manager hierarchies
- Organizational structures
- Category-subcategory hierarchies
- Generating dates
- Generating number sequences*/

-- EXAMPLE: A SEQUENCE OF USER IDS FROM THE MINIMUM TO MAXIMUM USER ID FROM USER TABLE

/*USE startersql;
;WITH DateBounds AS
(
    -- Step 1: Find minimum and maximum registration dates
    SELECT
        CAST(MIN(created_at) AS DATE) AS start_date,
        CAST(MAX(created_at) AS DATE) AS end_date
    FROM users
    WHERE created_at IS NOT NULL
),

DateCalendar AS
(
    -- Step 2: Anchor member (starting date)
    SELECT
        start_date AS registration_date,
        end_date
    FROM DateBounds
    WHERE start_date IS NOT NULL

    UNION ALL

    -- Step 3: Recursive member
    SELECT
        DATEADD(DAY, 1, registration_date),
        end_date
    FROM DateCalendar
    WHERE registration_date < end_date
)

-- Step 4: Display generated dates
SELECT
    registration_date
FROM DateCalendar
ORDER BY registration_date
OPTION (MAXRECURSION 0);*/

-- SQL VIEWS (A VIEW IS A VIRTUAL TABLE CRREATED USING A SQL QUERY)....

/*CREATE VIEW vw_high_salary_users
AS
SELECT
    id,
    name,
    city,
    salary
FROM users
WHERE salary > 30000;*/
-- NOW TO ACCESS IT 
SELECT * FROM VW_HIGH_SALARY_USERS;
