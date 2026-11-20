/*
Let's combine the concepts into a small SQL task using your users table.
Requirement
1. Increase salary of Delhi users by ₹1,000.
2. Start a transaction.
3. Count affected rows.
4. Commit if successful.
5. Roll back if an error occurs.
6. Print a meaningful error message.
*/

/*
USE startersql;
 GO
 
CREATE OR ALTER PROCEDURE dbo.IncreaseDelhiSalary
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        UPDATE dbo.users
        SET salary = salary + 1000
        WHERE city = 'DELHI';

        DECLARE @RowsUpdated INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        SELECT
            @RowsUpdated AS RowsUpdated,
            'SUCCESS' AS Status;

    END TRY

    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;

        THROW;

    END CATCH;
END;
-- EXECUTING THE QUERY 

EXEC DBO.INCREASEDELHISALARY;
*/

-- CHECKING THE QUERY 
SELECT * FROM DBO.USERS WHERE CITY ='DELHI'; 