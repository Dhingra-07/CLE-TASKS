/*USE startersql;
We'll cover:
1. CREATE PROCEDURE, ALTER PROCEDURE, DROP PROCEDURE
2. Input parameters (@parameter)
3. Output parameters (OUTPUT)
4. EXEC to execute stored procedures
5. Scalar user-defined functions
6. Table-valued functions
7. Stored Procedure vs Function
8. Real business logic examples using your tables
9. Practice exercises

CREATING A PROCEDURE : INPUT PARAMETER 
*/
/*USE startersql;
GO 
CREATE PROCEDURE GETUSERSBYCITY
@CITY VARCHAR(50)
AS 
BEGIN
 SELECT * FROM DBO.USERS
 WHERE CITY = @CITY;
 END;
 GO*/
-- EXECUTING THE USERS ACCORDING TO THE CITY
--EXEC GETUSERSBYCITY @City = 'PUNE';
-- NOW PERFORMING THE ALTERING THE PROCEDURE 
-- THIS ONLT RETURNS THE ONLY SALARY AND NAME
/*ALTER PROCEDURE GetUsersByCity
    @City VARCHAR(50)
AS
BEGIN
    SELECT name, city, salary
    FROM dbo.users
    WHERE city = @City;
END;
GO*/
-- EXECUTING THE QUERY
--EXEC GETUSERSBYCITY @CITY = 'DELHI';
-- NOW PERFORMING THE DROP PROCEDURE 
--DROP PROCEDURE GETUSERSBYCITY;

--  INPUT OUTPUT PARAMETER IN STORED PROCEDURE 
/*CREATE OR ALTER PROCEDURE CountUsersByCity
    @City VARCHAR(50),
    @TotalUsers INT OUTPUT
AS
BEGIN
    SELECT @TotalUsers = COUNT(*)
    FROM dbo.users
    WHERE city = @City;
END;
GO*/
-- EXECUTING THE OUTPUT
/*DECLARE @Result INT;

EXEC CountUsersByCity
    @City = 'Delhi',
    @TotalUsers = @Result OUTPUT;

SELECT @Result AS TotalUsers;
How it works
Step-by-step:
1. DECLARE @Result INT creates a variable.
2. 'Delhi' goes into the procedure.
3. COUNT(*) calculates the number of Delhi users.
4. @TotalUsers stores the count inside the procedure.
5. OUTPUT sends the value back.
6. SELECT @Result displays the result.*/


-- NOW UNDERSATNDING THE USER DEFINED FUNCTIONS 
--> SCALAR FUNCTION : FOR CALCULATING THE ANNUAL SALARY 
/*CREATE OR ALTER FUNCTION dbo.CalculateAnnualSalary
(
    @MonthlySalary DECIMAL(10,2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN @MonthlySalary * 12;
END;
GO*/
-- EXECUTING THE QUERY
  /* SELECT name,
    salary AS MonthlySalary,
    dbo.CalculateAnnualSalary(salary) AS AnnualSalary
FROM dbo.users;*/
--> NOW FOR CALCULATING THE EMPLOYEE BONUS
/*CREATE OR ALTER FUNCTION dbo.CalculateBonus
(
    @Salary DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Salary * 0.10;
END;
GO*/
-- EXECUTING THE QUERY
/*SELECT
    name,
    salary,
    dbo.CalculateBonus(salary) AS Bonus
FROM dbo.users;*/

--. TABLE VALUED FUNCTION TVF
/*A table-valued function returns an entire table instead of a single value.

There are two types:
- Inline Table-Valued Function (iTVF)
- Multi-Statement Table-Valued Function (mTVF)*/
-- EXAMPLE : INCLINE TABLE VALUED FUNCTION
/*
CREATE OR ALTER FUNCTION dbo.GetHighSalaryUsers
(
    @MinSalary DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT id, name, city, salary
    FROM dbo.users
    WHERE salary >= @MinSalary
);
GO*/
 -- EXECUTING THE QUERY
 /*
 SELECT * FROM 
 DBO.GETHIGHSALARYUSERS(7000)
 WHERE CITY = 'DELHI';*/

 -->> NOW PERFORMING THE MULTI TABLE VALUED FUNCTION
 /*
 CREATE OR ALTER FUNCTION DBO.GETSALARYCATEGORY
 (
 @MINSALARY DECIMAL(10,2)
 )
 RETURNS @RESULT TABLE
 (
 ID INT , NAME VARCHAR(100), SALARY DECIMAL(10,2),
 SALARY_CATEGORY VARCHAR(30)
 )
 AS 
 BEGIN
  INSERT INTO @RESULT 
  SELECT 
  ID, NAME, SALARY,
  CASE
  WHEN SALARY >= 3000 THEN 'HIGH'
  WHEN SALARY >= 5000 THEN 'MEDIUM'
  ELSE 'LOW'
  END
  FROM DBO.USERS 
  WHERE SALARY  >= @MINSALARY;
  RETURN;
  END;
  GO
  */
  -- EXECUTING THE QUERY
  --SELECT * FROM DBO.GETSALARYCATEGORY(2000);