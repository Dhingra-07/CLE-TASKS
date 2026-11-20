--CREATE DATABASE startersql;
-- Select the database
/*USE startersql;
GO
-- Create the users table
CREATE TABLE users
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    date_of_birth DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
GO*/
--SELECT * FROM users;
--SELECT NAME FROM users;
/*ALTER TABLE users
ADD
    phone_number VARCHAR(15),
    city VARCHAR(100),
    salary DECIMAL(10,2);*/

--ALTER TABLE USERS
--DROP COLUMN PHONE_NUMBER;
--SELECT * FROM USERS;



/*INSERT INTO users
    (name, email, gender, date_of_birth, created_at, city, salary)
VALUES
    ('ABHISHEK', 'DHINGRAJEI@GAMIL.COM', 'MALE', '2005-07-28', DEFAULT, 'YNR', 1000),
    ('DIVYA', 'ABDC@GMAIL.COM', 'FEMALE', '2005-12-28', DEFAULT, 'PUN', 2000),
    ('RAHUL SHARMA', 'rahul.sharma@example.com', 'MALE', '2003-04-15', DEFAULT, 'DELHI', 25000),
    ('PRIYA VERMA', 'priya.verma@example.com', 'FEMALE', '2002-09-21', DEFAULT, 'CHANDIGARH', 32000),
    ('ARJUN SINGH', 'arjun.singh@example.com', 'MALE', '2001-12-10', DEFAULT, 'JAIPUR', 28000),
    ('NEHA GUPTA', 'neha.gupta@example.com', 'FEMALE', '2004-06-05', DEFAULT, 'ROHTAK', 22000),
    ('KARAN MALHOTRA', 'karan.malhotra@example.com', 'MALE', '2000-03-18', DEFAULT, 'PUNE', 45000),
    ('ANJALI MEHTA', 'anjali.mehta@example.com', 'FEMALE', '2003-11-25', DEFAULT, 'MUMBAI', 38000),
    ('VIKAS YADAV', 'vikas.yadav@example.com', 'MALE', '2002-07-14', DEFAULT, 'GURUGRAM', 30000),
    ('SIMRAN KAUR', 'simran.kaur@example.com', 'FEMALE', '2001-02-08', DEFAULT, 'AMRITSAR', 35000),
    ('AMAN KUMAR', 'aman.kumar@example.com', 'MALE', '2004-01-30', DEFAULT, 'YAMUNANAGAR', 20000),
    ('ISHA AGGARWAL', 'isha.aggarwal@example.com', 'FEMALE', '2002-05-19', DEFAULT, 'BENGALURU', 42000);

UPDATE users
SET salary = 30000
WHERE email = 'rahul.sharma@example.com';

DELETE FROM users
WHERE city = 'BENGALURU';

SELECT *
FROM users
WHERE salary > 30000;

SELECT name, salary
FROM users
ORDER BY salary ASC;

SELECT DISTINCT city
FROM users;

SELECT
    name AS full_name,
    salary AS monthly_salary
FROM users;

SELECT TOP 5 *
FROM USERS;

--TO FIND THE HIGHEST PAID TOP 5 USERS
SELECT TOP 5 name, salary
FROM users
ORDER BY salary DESC;

--LIKE SEARCH USING PATTERNS (NAMES STARTS WITH A)
SELECT name
FROM users
WHERE name LIKE 'A%';

--NAMES ENDS WITH A
SELECT name
FROM users
WHERE name LIKE '%A';

--IN THIS RETURN USERS ROM ANY OF THE THREE CITIES.
SELECT name, city
FROM users
WHERE city IN ('DELHI', 'PUNE', 'ROHTAK');

-- BETWEEN FILTER THE RANGE
SELECT name, salary
FROM users
WHERE salary BETWEEN 20000 AND 35000;

-- DATE RANGE 
SELECT name, date_of_birth
FROM users
WHERE date_of_birth BETWEEN '2000-01-01' AND '2005-12-31';

--Returns the current date and time according to the SQL Server system.
SELECT GETDATE() AS current_datetime;

--Display the current date and time alongside every user's name.
SELECT
    name,
    GETDATE() AS query_execution_time
FROM users;

--Calculate the number of specified date boundaries between two dates.
SELECT
    name,
    date_of_birth,
    DATEDIFF(YEAR, date_of_birth, GETDATE()) AS approximate_age
FROM users;

--Extract a particular component, such as the year, month, or day
SELECT
    name,
    date_of_birth,
    DATEPART(YEAR, date_of_birth) AS birth_year,
    DATEPART(MONTH, date_of_birth) AS birth_month,
    DATEPART(DAY, date_of_birth) AS birth_day
FROM users;

--Add five years to each birth date
SELECT
    name,
    date_of_birth,
    DATEADD(YEAR, 5, date_of_birth) AS date_after_five_years
FROM users;

--UPPERCASE
SELECT
    name,
    UPPER(name) AS uppercase_name
FROM users;

--LOWERCASE
SELECT
    email,
    LOWER(email) AS lowercase_email
FROM users;

--SUBSTRING
SELECT
    name,
    SUBSTRING(name, 1, 4) AS first_four_characters
FROM users;

--FINDING THE LENGTH OF STRING
SELECT
    name,
    LEN(name) AS name_length
FROM users;

--Remove Leading and Trailing SpaceS
SELECT
    name,
    TRIM(name) AS cleaned_name
FROM users;

-- REPALCE TEXT
SELECT
    email,
    REPLACE(email, 'gmail.com', 'example.com') AS modified_email
FROM users;

--JOIN STRING TOGETHER(CONCAT() converts its arguments to strings and treats NULL arguments as empty strings.)
SELECT
    CONCAT(name, ' - ', city) AS user_details
FROM users;

-- Find where a substring first occurs in a string.
SELECT EMAIL, CHARINDEX('@',EMAIL) AS at_position
FROM USERS;

--ROUND NUMBER
SELECT
    salary,
    ROUND(salary / 12.0, 2) AS monthly_salary
FROM users;
SELECT ROUND(123.4567, 2) AS rounded_value;

--ROUND UP (CEILING)
SELECT
    salary,
    CEILING(salary / 12.0) AS rounded_monthly_value
FROM users;

--ROUND DOWN(FLOOR)
SELECT
    name,
    salary,
    FLOOR(salary / 12.0) AS monthly_salary
FROM users;

-- CAST() CONVERT A DATA TYPE
SELECT
    name,
    salary,
    CAST(salary AS VARCHAR(20)) AS salary_as_text
FROM users;

-- NULL HANDLING (NULLIS)
SELECT
    name,
    ISNULL(salary, 0) AS salary
FROM users;
-- RETURN THE FIRST NON NULL VALUES(COLLASPE)
SELECT
    name,
    COALESCE(city, 'Unknown City') AS city
FROM users;
-- RETURN NULL WHEN TWO VALUES MATCH(NULLIF())
SELECT NULLIF(10, 20) AS result;

-- APPLY CONDITIONAL LOGIC (CASE WHEN)
SELECT
    name,
    salary,
    CASE
        WHEN salary >= 40000 THEN 'High Salary'
        WHEN salary >= 25000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM users;

SQL evaluates the conditions in order.
1. If salary is at least 40,000, the category is High Salary.
2. Otherwise, if salary is at least 25,000, the category is Medium Salary.
3. If neither condition is true, the category is Low Salary.

--CALSSIFY USERS BY AGE 
SELECT
    name,
    date_of_birth,
    CASE
        WHEN date_of_birth IS NULL THEN 'Unknown Age'
        WHEN DATEADD(
                 YEAR,
                 18,
                 date_of_birth
             ) <= CAST(GETDATE() AS DATE)
        THEN '18 or Older'
        ELSE 'Under 18'
    END AS age_category
FROM users;

--This classifies users based on whether they have reached their eighteenth birthday.*/
 
 