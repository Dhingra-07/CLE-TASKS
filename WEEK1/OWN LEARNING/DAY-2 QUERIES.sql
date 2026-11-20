-- DAY-2
 --USE startersql SELECT * FROM USERS;
  
  /* USING GROUP BY 
  SELECT CITY FROM USERS
  GROUP BY CITY;
   
   -- COUNT FUNCTIONS
   SELECT CITY, 
   COUNT(*) AS TOTAL_USERS
   FROM USERS
   GROUP BY CITY;

   SELECT NAME,
   COUNT(SALARY) AS TOTAL_SALARY
   FROM USERS
   GROUP BY NAME;
   
   -- PERFORMING THE COUNT(), SUM(), AVG()
   SELECT
    city,
    COUNT(*) AS total_users,
    SUM(salary) AS total_salary,
    AVG(salary) AS average_salary
FROM users
GROUP BY city;

-- HAVING CLAUSE
SELECT
    city,
    COUNT(*) AS total_users
FROM users
GROUP BY city
HAVING COUNT(*) > 1;

-- CITIES WHERE AVG SALARY ABOVE 40000
SELECT
    city,
    AVG(salary) AS average_salary
FROM users
GROUP BY city
HAVING AVG(salary) > 40000;

-- TOATL SALARY ABOVE 7000
SELECT
    city,
    SUM(salary) AS total_salary
FROM users
GROUP BY city
HAVING SUM(salary) > 7000;


-- now performing the where and having BOTH 
SELECT
    city,
    AVG(salary) AS average_salary
FROM users
WHERE salary > 20000
GROUP BY city
HAVING AVG(salary) > 35000;
*/

