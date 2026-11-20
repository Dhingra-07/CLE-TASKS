/*
USE startersql;
GO
LAG() — Get Previous Row's Value
What is LAG?
LAG() helps you access the value from a previous row without joining the table to itself.

For example:
- Current employee salary
- Previous employee salary
- Difference between current and previous salary
*/
-- COMPARE CURRENT SALARY WITH PREVIOUS SALARY 
/*SELECT NAME, ID, SALARY, LAG(SALARY) OVER (ORDER BY ID) AS PREVIOUS_SALARY
FROM USERS;*/
/*
--What is LEAD?
LEAD() is the opposite of LAG().
- LAG() → Previous row
- LEAD() → Next row
*/
/*
SELECT NAME, ID, SALARY, LEAD(SALARY) OVER (ORDER BY ID ) AS NS
FROM USERS;*/

-- NOW UNDERSTNAD THE RUNNING TOTAL
/*
ROWS	Work with physical rows
UNBOUNDED PRECEDING	Start from the first row
CURRENT ROW	End at the current row

SELECT NAME, ID , SALARY,
SUM(SALARY) OVER (ORDER BY ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AS RN_TOTAL FROM USERS;
*/

-- RUNNING  TOTAL BY GENDER 
/*SELECT
    id,
    name,
    gender,
    salary,
    SUM(salary) OVER (
        PARTITION BY gender
        ORDER BY id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS gender_running_total
FROM users;*/

/*
Moving Average — Average of Previous Rows
What is a moving average?
A moving average calculates the average of a fixed number of rows as we move through the data.

Suppose we want the 3-row moving average of salaries.

For the first three employees:
\[
\frac{1000+2000+30000}{3}=11000
\]

For the next three rows:
\[
\frac{2000+30000+25000}{3}=19000
\]

SELECT
    id,
    name,
    salary,
    AVG(salary) OVER (
        ORDER BY id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average
FROM users;
Real-world use
- 7-day average sales
- 30-day average revenue
- Moving average of stock prices
- Average daily customer calls
- Average employee performance over recent period
*/

-- WINDOW FRAMES ROWS VS RANGE
-- ROWS COUNT PHYSICAL ROWS
/*use startersql;
SELECT
    name,
    salary,
    SUM(salary) OVER (
        ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rows_total
FROM users;
*/
/*
-- RANGE : INCLUDES PEER ROWS WITH THE SAME ORDERING VALUE
SELECT
    name,
    salary,
    SUM(salary) OVER (
        ORDER BY salary
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS range_total
FROM users;
*/
-- NOW PERFORMING THE  DEDUPLICATION
/*
SELECT
    name,
    city,
    salary,
    COUNT(*) AS duplicate_count
FROM users
GROUP BY name, city, salary
HAVING COUNT(*) > 1;*/

-- LATEST RECORD PER KEY***IMPORTANT
/*
What does latest record per key mean?
If you want to keep only the latest inserted record for each 
name, we can use name as the key and highest id as latest.
*/
/*
WITH LatestCTE AS
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY name
            ORDER BY id DESC
        ) AS rn
    FROM users
)
SELECT *
FROM LatestCTE
WHERE rn = 1
-- BECUASE I HAD SELCTED THE TIMESTAMP AS DEFAULT NAD DONT MAKE ANY 
-- ENTRY OF AN EMPLOYEE THATS WHY THEY SHOWING ALL USERS
*/
/*
Gaps & Islands
This is a slightly advanced but very useful SQL concept.
What are gaps and islands?
- Islands = consecutive or continuous records.
- Gaps = missing records between continuous records.
Example: Employee attendance.
employee_id	attendance_date
1	2026-01-01
1	2026-01-02
1	2026-01-03
1	2026-01-06
1	2026-01-07
1	2026-01-10

Here:
- Jan 1–3 → First island
- Jan 6–7 → Second island
- Jan 10 → Third island
Missing dates:
- Jan 4
- Jan 5
- Jan 8
- Jan 9
A. Find consecutive date islands
Query
WITH DateCTE AS
(
    SELECT
        employee_id,
        attendance_date,
        DATEADD(
            DAY,
            -ROW_NUMBER() OVER (
                PARTITION BY employee_id
                ORDER BY attendance_date
            ),
            attendance_date
        ) AS island_group
    FROM Attendance
)
SELECT
    employee_id,
    MIN(attendance_date) AS start_date,
    MAX(attendance_date) AS end_date,
    COUNT(*) AS consecutive_days
FROM DateCTE
GROUP BY employee_id, island_group
ORDER BY employee_id, start_date;


Result
employee_id	start_date	end_date	consecutive_days
1	Jan 1	Jan 3	3
1	Jan 6	Jan 7	2
1	Jan 10	Jan 10	1

Why does this work?
This expression is the key:
DATEADD(
    DAY,
    -ROW_NUMBER() OVER (
        PARTITION BY employee_id
        ORDER BY attendance_date
    ),
    attendance_date
)


For consecutive dates, subtracting the increasing row number gives the same date value.

Example:
Date	ROW_NUMBER	Date minus row number
Jan 1	1	Dec 31
Jan 2	2	Dec 31
Jan 3	3	Dec 31
Jan 6	4	Jan 2
Jan 7	5	Jan 2

Same calculated value = same island.
B. Find gaps between dates
SELECT
    employee_id,
    attendance_date,
    LEAD(attendance_date) OVER (
        PARTITION BY employee_id
        ORDER BY attendance_date
    ) AS next_attendance,
    DATEDIFF(
        DAY,
        attendance_date,
        LEAD(attendance_date) OVER (
            PARTITION BY employee_id
            ORDER BY attendance_date
        )
    ) - 1 AS missing_days
FROM Attendance;


For Jan 3 → Jan 6:
- Difference = 3 days
- Missing days = 2
This helps identify missing attendance, missing dates, missing sequence numbers, and gaps in transaction activity.

Note: This example assumes one attendance record per employee per date.
*/
-- LETS UNDERSTAND STRING AGG()-- COMBINE MULTIPLE ROWS INTO ONE STRING
/*
What is STRING_AGG?
STRING_AGG() combines values from multiple rows into one string.
SELECT
    city,
    STRING_AGG(name, ', ') AS employee_names
FROM users
GROUP BY city;*/
--name → Values to combine
--(', ') → Separator between values*/
/*
SELECT
    gender,
    STRING_AGG(name, ', ') AS employees
FROM users
GROUP BY gender;
*/
--This creates one row for MALE and one row for FEMALE, 
--with names combined into a string.
--SOME REAL WORLD USES OF  THIS::::::
/*
Real-world Data Engineer use
- Combine all products into one order summary.
- Combine employee names by department.
- Create comma-separated customer lists.
- Build reporting outputs.
- Aggregate multiple categories into one field.
*/
