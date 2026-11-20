
-- UNDERSTANDING THE OVER CLAUSE()
/*use startersql;
SELECT NAME, GENDER, SALARY,
AVG(SALARY) OVER() AS AVG
FROM USERS;
*/

-- NOW LET US UNDERSTAND THE PARTITION BY:
/*
SELECT NAME, SALARY,CITY,
AVG(SALARY) OVER (PARTITION BY CITY )
AS CITY_AVG
FROM USERS;
*/
-- NOW LETS US LEARN ORDER BY INSIDE OVER()
/*
USE startersql;
SELECT NAME, SALARY , ROW_NUMBER() 
OVER(ORDER BY SALARY DESC)
AS ROW_NUM
FROM USERS;

ORDER BY salary DESC means highest salary first.
ROW_NUMBER() assigns sequential numbers.
Highest salary receives row number 1.
*/

--ROW_NUMBER()
/*
SELECT
    id,
    name,
    salary,
    ROW_NUMBER() OVER(
        ORDER BY salary DESC
    ) AS row_num
FROM users;
*/
-- NOW LET US UNDERSTAND THE RANK() RANKING WITH GAPS 
/*
SELECT
    name,
    salary,
    RANK() OVER(
        ORDER BY salary DESC
    ) AS salary_rank
FROM users;
*/
-- DENSE() RANKING WITHOUT GAPS
/*SELECT NAME, SALARY, DENSE_RANK() OVER
(ORDER BY SALARY DESC)
AS DENSE_RANK
FROM USERS;*/

-- NTILE() DIVIDE INTO GROUPS
/*
SELECT
    name,
    gender,
    salary,
    NTILE(2) OVER(
        PARTITION BY gender
        ORDER BY salary DESC
    ) AS salary_quartile
FROM users;
*/
 -- aggregate window  functions 
 /*
 These functions calculate aggregates while keeping individual rows visible.

Common aggregate window functions:
- SUM()
- AVG()
- COUNT()
- MIN()
- MAX()
*/
-- TOTAL SALARY 
/*
USE startersql;
SELECT NAME, SALARY, 
SUM(SALARY) OVER() AS TOTAL_SALARY FROM USERS;*/
  
  -- NOW LET US UNDERSTAND MOST IMP TOPIC 

--TOP-N PER GROUP
-- EX:1 HIGHEST PAID USER
/*
WITH SALARYRANKING AS 
( SELECT ID, NAME, SALARY, ROW_NUMBER() OVER( ORDER BY SALARY DESC)
AS RN
FROM USERS)
SELECT * FROM SALARYRANKING WHERE RN = 1;
*/
-- EX:2 TOP 3 SALARY
/*
WITH SalaryRanking AS
(
    SELECT
        id,
        name,
        salary,
        ROW_NUMBER() OVER(
            ORDER BY salary DESC
        ) AS RN
    FROM users
)
SELECT *
FROM SalaryRanking
WHERE rn <= 3;
*/
-- EX: 3 TOP 2 USERS IN EACH GENDER
/*
WITH GenderRanking AS
(
    SELECT
        id,
        name,
        gender,
        salary,
        ROW_NUMBER() OVER(
            PARTITION BY gender
            ORDER BY salary DESC
        ) AS rn
    FROM users
)
SELECT *
FROM GenderRanking
WHERE rn <= 2;

This is the standard SQL pattern:
1. Create ranking using ROW_NUMBER().
2. Partition by the required group.
3. Sort by the required metric.
4. Filter rank in an outer query.
*/
