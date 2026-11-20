-- TRY AND CATCH : ERROR HANDLING
--TRY: EXECUTE SQL STATEMENTS THAT MIGHT GENERATE ERRORS.
--CATCH: HANDLE THE ERROR IF A CATCHABLE ERROR OCCURS.
--EXAMPLE TO GENERATE THE ERROR
/*

BEGIN TRY

    SELECT 10 / 0 AS Result;

END TRY

BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;*/

-->> NOW THROW VS RAISERROR
/*
A. THROW

Practical validation using your USERS table
Suppose we want to prevent inserting a negative salary*/
/*
DECLARE @Salary INT = -5000;

BEGIN TRY

    IF @Salary < 0
    BEGIN
        THROW 50001,
              'Salary cannot be negative.',
              1;
    END;

    SELECT 'Valid Salary' AS Result;

END TRY

BEGIN CATCH

    SELECT ERROR_MESSAGE() AS ErrorMessage;

END CATCH;*/
/*
/*use startersql;
RAISERROR(
    'Salary cannot be negative.',
    16,
    1
);
*/
-- SQL TRANSACTIONS
-- COMMIT EXAMPLE*/
/*

BEGIN TRANSACTION
UPDATE DBO.USERS
SET SALARY = 15000
WHERE NAME = 'ABHISHEK'
;
COMMIT TRANSACTION*/

-- ROLL BACK(ROLL BACK UNDOES UNCOMMITED CHNAGES)
/*BEGIN TRANSACTION;

UPDATE dbo.users
SET salary = 50000
WHERE name = 'ABHISHEK';

ROLLBACK TRANSACTION;

SELECT *
FROM dbo.users
WHERE name = 'ABHISHEK';*/
 -- TRY AND CATCH WITH TRANSACTIONS 
 /*
 BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE dbo.users
    SET salary = 15000
    WHERE name = 'ABHISHEK';

    UPDATE dbo.users
    SET salary = 25000
    WHERE name = 'DIVYA';

    COMMIT TRANSACTION;

    PRINT 'Transaction completed successfully.';

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;*/

/*Execution flow
1. TRY starts.
2. Transaction starts.
3. Both updates execute.
4. If everything succeeds → COMMIT.
5. If an error occurs → CATCH.
6. CATCH checks whether a transaction exists.
7. If it exists → ROLLBACK.
8. Error details are returned.

Why use this?
Imagine a banking or payroll pipeline:
- Update employee salaries.
- Update salary payment records.
- Update financial summary.
If one step fails, you do not want only some of the changes saved.

Transactions protect data consistency.*/

-- NOW PERFORMING THE TRANCOUNT - TRANSACTION COUNTER
--
--SELECT @@TRANCOUNT AS TRANSACTIONCOUNT;
-- NOW NESTED TRANSACTIONS 
/*
BEGIN TRANSACTION;

SELECT @@TRANCOUNT;  -- 1

BEGIN TRANSACTION;

SELECT @@TRANCOUNT;  -- 2

COMMIT TRANSACTION;

SELECT @@TRANCOUNT;  -- 1

COMMIT TRANSACTION;

SELECT @@TRANCOUNT;  -- 0
An inner COMMIT only reduces @@TRANCOUNT; 
the outer transaction must commit before the changes are truly committed.
*/
-- @@ROWCOUNT - ROW AFFFECTED 
/*
UPDATE dbo.users
SET salary = 30000
WHERE city = 'DELHI';

SELECT @@ROWCOUNT AS RowsUpdated;*/


-- NOW TELL US UNDERSTAND THE TRANSACTION IN STORED PROCEDURE
/*Transactions Inside Stored Procedures
You previously learned stored procedures, input parameters and OUTPUT parameters.

Now we combine those concepts.
Example: Safe salary update procedure
This procedure:
- Accepts user ID.
- Accepts new salary.
- Validates salary.
- Updates the user.
- Uses a transaction.
- Rolls back if something fails.
- Throws an error if the user doesn't exist.
*/
/*
CREATE OR ALTER PROCEDURE dbo.UpdateSalarySafe
    @UserID INT,
    @NewSalary DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        IF @NewSalary < 0
        BEGIN
            THROW 50001,
                  'Salary cannot be negative.',
                  1;
        END;

        BEGIN TRANSACTION;

        UPDATE dbo.users
        SET salary = @NewSalary
        WHERE id = @UserID;

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50002,
                  'User ID does not exist.',
                  1;
        END;

        COMMIT TRANSACTION;

        PRINT 'Salary updated successfully.';

    END TRY

    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;
END;*/

-- Negative salary
/*EXEC dbo.UpdateSalarySafe 1, -5000;

-- Invalid user ID
EXEC dbo.UpdateSalarySafe 9999, 50000;
Why SET XACT_ABORT ON?
It instructs SQL Server to terminate and roll back the current transaction for most run-time errors.

This improves transaction safety, especially in data processing operations.
What is XACT_STATE()?
Value	Meaning
1	Active transaction that can be committed
0	No active transaction
-1	Active transaction that cannot be committed; rollback required

This is why XACT_STATE() is often safer than checking only @@TRANCOUNT inside a CATCH block.

Data Engineer tip: For production procedures, use TRY...CATCH, SET XACT_ABORT ON, transactions, 
rollback logic and THROW together.
*/
  
  -- USING WHILE LOOP IN SQL SERVER
  --PRINTING THE NUMBERS FROM 1 TO 10
 /*
 DECLARE @I INT = 1;
  WHILE @I <= 10
  BEGIN
  PRINT @I
  SET @I = @I+1;
  END;
  */

  -- NOW UPDATING THE SALARIES USING WHILE LOOP 
  /*
  DECLARE @I INT = 1;
  WHILE @I <= 4
  BEGIN 
  UPDATE DBO.USERS 
  SET  SALARY = SALARY + 1000
  WHERE ID = @I;
  SET @I = @I +1;
  END;*/
  --SELECT SALARY FROM USERS;

  -- CURSOR ROW BY ROW PROCESSING
/*What is a cursor?
A cursor allows you to retrieve rows from a query result one at a time and perform operations on each row.
Normal SQL works with multiple rows together.
A cursor allows you to work with individual records.
*/
/*
DECLARE @Name VARCHAR(100);
DECLARE @Salary DECIMAL(10,2);

DECLARE UserCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT name, salary
FROM dbo.users;

OPEN UserCursor;

FETCH NEXT FROM UserCursor
INTO @Name, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN

    PRINT 'User: ' + @Name;

    PRINT 'Salary: ' + CAST(@Salary AS VARCHAR(20));

    FETCH NEXT FROM UserCursor
    INTO @Name, @Salary;

END;

CLOSE UserCursor;

DEALLOCATE UserCursor;
*/

-- CURSOR WITH CONDITIONAL PROCESSING 
/*
DECLARE @Name VARCHAR(100);
DECLARE @Salary DECIMAL(10,2);

DECLARE UserCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT name, salary
FROM dbo.users;

OPEN UserCursor;

FETCH NEXT FROM UserCursor
INTO @Name, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN

    IF @Salary >= 30000
    BEGIN
        PRINT @Name + ' - High Salary';
    END
    ELSE
    BEGIN
        PRINT @Name + ' - Normal Salary';
    END;

    FETCH NEXT FROM UserCursor
    INTO @Name, @Salary;

END;

CLOSE UserCursor;

DEALLOCATE UserCursor;

This demonstrates how SQL can process each user separately.

But this method has a performance disadvantage 
when thousands or millions of records are involved.
*/
-- NOW LET US PERFORM THE (ROW BY ROW VS SET BASED PROCESSING)
/*
Row-by-row means processing one record at a time.

Examples:
- Cursor
- WHILE loop with individual updates
- Iterative processing of IDs
Set-based processing
Set-based means applying one SQL operation to multiple rows simultaneously.

Examples:
- UPDATE with WHERE
- INSERT SELECT
- DELETE with WHERE
- GROUP BY
- JOIN
- MERGE, when appropriate
*/

-- NOW LET US DO (TRY..CATCH WITH CURSOR) 
/*
DECLARE @Name VARCHAR(100);
DECLARE @Salary DECIMAL(10,2);

BEGIN TRY

    DECLARE UserCursor CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT name, salary
    FROM dbo.users;

    OPEN UserCursor;

    FETCH NEXT FROM UserCursor
    INTO @Name, @Salary;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        PRINT @Name;

        FETCH NEXT FROM UserCursor
        INTO @Name, @Salary;

    END;

    CLOSE UserCursor;
    DEALLOCATE UserCursor;

END TRY

BEGIN CATCH

    IF CURSOR_STATUS('local', 'UserCursor') >= 0
        CLOSE UserCursor;

    IF CURSOR_STATUS('local', 'UserCursor') > -3
        DEALLOCATE UserCursor;
        */
    SELECT ERROR_MESSAGE() AS ErrorMessage;

END CATCH;