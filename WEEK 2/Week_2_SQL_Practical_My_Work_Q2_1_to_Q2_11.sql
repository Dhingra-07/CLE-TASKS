/* Week 2 SQL Practical
   Topics: Functions, Stored Procedures, CTEs and Window Functions
   Database: Week2_SQL_Practice
*/
/*
IF DB_ID(N'Week2_SQL_Practice') IS NULL CREATE DATABASE Week2_SQL_Practice;
GO
USE Week2_SQL_Practice;
GO
SET NOCOUNT ON;
GO

-- Q2.1 Books that were rated lower than their adaptation
DROP TABLE IF EXISTS dbo.book_review;
DROP TABLE IF EXISTS dbo.adaptation;
DROP TABLE IF EXISTS dbo.book;
DROP TABLE IF EXISTS dbo.author;
GO
CREATE TABLE dbo.author(author_id INT PRIMARY KEY, author_name VARCHAR(100) NOT NULL);
CREATE TABLE dbo.book(book_id INT PRIMARY KEY, author_id INT NOT NULL REFERENCES dbo.author(author_id), title VARCHAR(150), publish_year INT);
CREATE TABLE dbo.adaptation(book_id INT PRIMARY KEY REFERENCES dbo.book(book_id), type VARCHAR(20), title VARCHAR(150), release_year INT, rating DECIMAL(4,2));
CREATE TABLE dbo.book_review(review_id INT PRIMARY KEY, book_id INT NOT NULL REFERENCES dbo.book(book_id), rating DECIMAL(4,2));
INSERT dbo.author VALUES (1,'Anita Rao'),(2,'Dev Malhotra'),(3,'Kiran Sethi'),(4,'Leela Thomas');
INSERT dbo.book VALUES
(101,1,'The Monsoon Letters',2015),(102,1,'City of Lanterns',2018),(103,2,'Code of the Hills',2012),
(104,3,'The Last Tea Garden',2019),(105,4,'Silent Harbour',2016),(106,2,'Paper Kites',2020);
INSERT dbo.adaptation VALUES
(101,'Movie','Monsoon Letters',2017,8.10),(102,'Series','Lanterns',2024,7.90),(103,'Movie','Hill Code',2014,7.00),
(104,'Series','Tea Garden',2022,8.60),(105,'Movie','Harbour',2018,6.50),(106,'Movie','Kites',2021,7.40);
INSERT dbo.book_review VALUES
(1,101,7),(2,101,8),(3,102,6),(4,102,7),(5,103,8),(6,103,7),(7,103,9),
(8,104,8),(9,104,8),(10,105,6),(11,105,7),(12,106,7),(13,106,7),(14,106,7);
;WITH BookRatings AS
(
 SELECT book_id, CAST(AVG(CAST(rating AS DECIMAL(10,2))) AS DECIMAL(4,2)) AS book_rating
 FROM dbo.book_review GROUP BY book_id
)
SELECT b.title AS book_title, a.title AS adaptation_title, a.release_year AS adaptation_year,
       b.publish_year AS publication_year, au.author_name, br.book_rating, a.rating AS adaptation_rating
FROM dbo.book b
JOIN dbo.author au ON au.author_id=b.author_id
JOIN dbo.adaptation a ON a.book_id=b.book_id
JOIN BookRatings br ON br.book_id=b.book_id
WHERE br.book_rating<a.rating AND ABS(a.release_year-b.publish_year)<=4
ORDER BY b.title;
GO

-- Q2.2 Customer order lookup using a function and procedure
DROP PROCEDURE IF EXISTS dbo.sp_customer_orders;
DROP FUNCTION IF EXISTS dbo.fn_format_us_date;
DROP TABLE IF EXISTS dbo.order_items;
DROP TABLE IF EXISTS dbo.orders;
DROP TABLE IF EXISTS dbo.customers;
GO
CREATE TABLE dbo.customers(customer_id VARCHAR(3) PRIMARY KEY, customer_name VARCHAR(100), city VARCHAR(50), signup_date DATE);
CREATE TABLE dbo.orders(order_id INT PRIMARY KEY, customer_id VARCHAR(3) NOT NULL REFERENCES dbo.customers(customer_id), order_date DATE, status VARCHAR(20));
CREATE TABLE dbo.order_items(order_id INT NOT NULL REFERENCES dbo.orders(order_id), product_id VARCHAR(10), qty INT, unit_price DECIMAL(10,2));
INSERT dbo.customers VALUES
('C01','Rahul Mehta','Jaipur','2025-11-02'),('C02','Priya Nair','Kochi','2025-12-15'),('C03','Arjun Das','Kolkata','2026-01-08'),
('C04','Fatima Sheikh','Mumbai','2026-01-20'),('C05','Karan Malhotra','Delhi','2026-02-11'),('C06','Sneha Kulkarni','Pune','2026-02-25');
INSERT dbo.orders VALUES
(1001,'C01','2026-03-02','Delivered'),(1002,'C02','2026-03-03','Delivered'),(1003,'C01','2026-03-10','Delivered'),(1004,'C03','2026-03-12','Cancelled'),
(1005,'C04','2026-03-15','Shipped'),(1006,'C05','2026-03-18','Delivered'),(1007,'C01','2026-04-01','Shipped'),(1008,'C06','2026-04-03','Pending');
INSERT dbo.order_items VALUES
(1001,'P1',2,799),(1001,'P3',5,120),(1002,'P2',1,1999),(1003,'P4',2,250),(1003,'P6',1,499),
(1004,'P5',1,1499),(1005,'P1',1,799),(1005,'P2',1,1999),(1005,'P3',10,120),(1006,'P6',3,499),(1007,'P5',1,1499),(1008,'P4',4,250);
GO
CREATE FUNCTION dbo.fn_format_us_date(@input_date DATE)
RETURNS VARCHAR(10)
AS
BEGIN
 RETURN CONVERT(VARCHAR(10),@input_date,101);
END;
GO
CREATE PROCEDURE dbo.sp_customer_orders
 @customer_id VARCHAR(3), @order_count INT OUTPUT, @total_value DECIMAL(10,2) OUTPUT
AS
BEGIN
 SET NOCOUNT ON;
 SET @order_count=0; SET @total_value=0;
 IF NOT EXISTS(SELECT 1 FROM dbo.customers WHERE customer_id=@customer_id) RETURN;
 ;WITH OrderTotals AS
 (
  SELECT o.order_id,o.order_date,o.status,SUM(oi.qty*oi.unit_price) AS order_value
  FROM dbo.orders o JOIN dbo.order_items oi ON oi.order_id=o.order_id
  WHERE o.customer_id=@customer_id AND o.status<>'Cancelled'
  GROUP BY o.order_id,o.order_date,o.status
 )
 SELECT order_id,dbo.fn_format_us_date(order_date) AS order_date_us,status,order_value
 FROM OrderTotals ORDER BY order_id;
 SELECT @order_count=COUNT(*),@total_value=COALESCE(SUM(x.order_value),0)
 FROM (SELECT o.order_id,SUM(oi.qty*oi.unit_price) AS order_value
       FROM dbo.orders o JOIN dbo.order_items oi ON oi.order_id=o.order_id
       WHERE o.customer_id=@customer_id AND o.status<>'Cancelled'
       GROUP BY o.order_id) x;
END;
GO
DECLARE @cnt INT,@val DECIMAL(10,2);
EXEC dbo.sp_customer_orders @customer_id='C01',@order_count=@cnt OUTPUT,@total_value=@val OUTPUT;
SELECT @cnt AS order_count,@val AS total_value;
EXEC dbo.sp_customer_orders @customer_id='C99',@order_count=@cnt OUTPUT,@total_value=@val OUTPUT;
SELECT @cnt AS order_count,@val AS total_value;
GO

-- Q2.3 Generate the remaining dates of a month
DROP PROCEDURE IF EXISTS dbo.sp_dateproc;
DROP TABLE IF EXISTS dbo.datepro_data;
DROP TABLE IF EXISTS dbo.datepro;
GO
CREATE TABLE dbo.datepro(id INT PRIMARY KEY,Dateint INT,Datentime VARCHAR(50));
INSERT dbo.datepro VALUES
(101,20220510,'2022-05-10T09:30:00+05:30'),(102,20220227,'2022-02-27T18:45:00+05:30'),
(103,20220925,'2022-09-25T12:16:00+05:30'),(104,20221229,'2022-12-29T07:05:00+05:30'),(105,20221228,'2022-12-28T11:29:00+05:30');
CREATE TABLE dbo.datepro_data(Id INT,Dateint INT,Datentime DATETIME,Dates DATE);
GO
CREATE PROCEDURE dbo.sp_dateproc @ids VARCHAR(100)
AS
BEGIN
 SET NOCOUNT ON;
 DELETE FROM dbo.datepro_data WHERE Id IN (SELECT TRY_CONVERT(INT,value) FROM STRING_SPLIT(@ids,',') WHERE TRY_CONVERT(INT,value) IS NOT NULL);
 ;WITH Selected AS
 (
  SELECT d.id,d.Dateint,TRY_CONVERT(DATE,CONVERT(CHAR(8),d.Dateint),112) AS start_date,
         TRY_CONVERT(DATETIME,LEFT(REPLACE(d.Datentime,'T',' '),16),120) AS normal_datetime
  FROM dbo.datepro d JOIN STRING_SPLIT(@ids,',') s ON d.id=TRY_CONVERT(INT,LTRIM(RTRIM(s.value)))
 ), Calendar AS
 (
  SELECT id,Dateint,normal_datetime,start_date AS Dates,EOMONTH(start_date) AS month_end FROM Selected WHERE start_date IS NOT NULL
  UNION ALL
  SELECT id,Dateint,normal_datetime,DATEADD(DAY,1,Dates),month_end FROM Calendar WHERE Dates<month_end
 )
 INSERT dbo.datepro_data(Id,Dateint,Datentime,Dates)
 SELECT id,Dateint,normal_datetime,Dates FROM Calendar OPTION(MAXRECURSION 1000);
 SELECT Id,Dateint,CONVERT(VARCHAR(16),Datentime,120) AS Datentime,Dates
 FROM dbo.datepro_data WHERE Id IN (SELECT TRY_CONVERT(INT,value) FROM STRING_SPLIT(@ids,',')) ORDER BY Id,Dates;
END;
GO
EXEC dbo.sp_dateproc '101,102,104';
SELECT COUNT(*) AS total_rows FROM dbo.datepro_data;
GO

-- Q2.4 Open elective subject allotment
DROP PROCEDURE IF EXISTS dbo.sp_allot_subjects;
DROP TABLE IF EXISTS dbo.UnallotedStudents;
DROP TABLE IF EXISTS dbo.Allotments;
DROP TABLE IF EXISTS dbo.StudentPreference;
DROP TABLE IF EXISTS dbo.SubjectDetails;
DROP TABLE IF EXISTS dbo.StudentDetails;
GO
CREATE TABLE dbo.StudentDetails(StudentId BIGINT PRIMARY KEY,StudentName VARCHAR(100),GPA DECIMAL(3,2),Branch VARCHAR(10),Section CHAR(1));
CREATE TABLE dbo.SubjectDetails(SubjectId VARCHAR(10) PRIMARY KEY,SubjectName VARCHAR(100),MaxSeats INT,RemainingSeats INT);
CREATE TABLE dbo.StudentPreference(StudentId BIGINT REFERENCES dbo.StudentDetails(StudentId),SubjectId VARCHAR(10) REFERENCES dbo.SubjectDetails(SubjectId),Preference INT CHECK(Preference BETWEEN 1 AND 5),PRIMARY KEY(StudentId,Preference),UNIQUE(StudentId,SubjectId));
CREATE TABLE dbo.Allotments(SubjectId VARCHAR(10),StudentId BIGINT);
CREATE TABLE dbo.UnallotedStudents(StudentId BIGINT PRIMARY KEY);
INSERT dbo.StudentDetails VALUES
(159103036,'Mohit Agarwal',8.90,'CCE','A'),(159103037,'Rohit Agarwal',5.20,'CCE','A'),(159103038,'Shohit Garg',7.10,'CCE','B'),
(159103039,'Mrinal Malhotra',7.90,'CCE','A'),(159103040,'Mehreet Singh',5.60,'CCE','A'),(159103041,'Arjun Tehlan',9.20,'CCE','B');
INSERT dbo.SubjectDetails VALUES
('PO1491','Basics of Political Science',60,2),('PO1492','Basics of Accounting',120,1),('PO1493','Basics of Financial Markets',90,1),('PO1494','Eco philosophy',60,1),('PO1495','Automotive Trends',60,0);
INSERT dbo.StudentPreference VALUES
(159103036,'PO1491',1),(159103036,'PO1492',2),(159103036,'PO1493',3),(159103036,'PO1494',4),(159103036,'PO1495',5),
(159103037,'PO1494',1),(159103037,'PO1495',2),(159103037,'PO1492',3),(159103037,'PO1491',4),(159103037,'PO1493',5),
(159103038,'PO1492',1),(159103038,'PO1491',2),(159103038,'PO1494',3),(159103038,'PO1495',4),(159103038,'PO1493',5),
(159103039,'PO1491',1),(159103039,'PO1492',2),(159103039,'PO1495',3),(159103039,'PO1493',4),(159103039,'PO1494',5),
(159103040,'PO1492',1),(159103040,'PO1494',2),(159103040,'PO1491',3),(159103040,'PO1493',4),(159103040,'PO1495',5),
(159103041,'PO1491',1),(159103041,'PO1493',2),(159103041,'PO1492',3),(159103041,'PO1494',4),(159103041,'PO1495',5);
GO
CREATE PROCEDURE dbo.sp_allot_subjects
AS
BEGIN
 SET NOCOUNT ON;
 -- Set the seats back to the starting values before allotment.
 UPDATE dbo.SubjectDetails SET RemainingSeats=CASE SubjectId WHEN 'PO1491' THEN 2 WHEN 'PO1492' THEN 1 WHEN 'PO1493' THEN 1 WHEN 'PO1494' THEN 1 WHEN 'PO1495' THEN 0 END;
 TRUNCATE TABLE dbo.Allotments; DELETE FROM dbo.UnallotedStudents;
 DECLARE @sid BIGINT,@sub VARCHAR(10),@pref INT,@seats INT;
 DECLARE student_cur CURSOR LOCAL FAST_FORWARD FOR SELECT StudentId FROM dbo.StudentDetails ORDER BY GPA DESC,StudentId;
 OPEN student_cur; FETCH NEXT FROM student_cur INTO @sid;
 WHILE @@FETCH_STATUS=0
 BEGIN
  DECLARE pref_cur CURSOR LOCAL FAST_FORWARD FOR SELECT SubjectId FROM dbo.StudentPreference WHERE StudentId=@sid ORDER BY Preference;
  OPEN pref_cur; FETCH NEXT FROM pref_cur INTO @sub;
  DECLARE @got BIT=0;
  WHILE @@FETCH_STATUS=0 AND @got=0
  BEGIN
   SELECT @seats=RemainingSeats FROM dbo.SubjectDetails WHERE SubjectId=@sub;
   IF @seats>0
   BEGIN
    INSERT dbo.Allotments(SubjectId,StudentId) VALUES(@sub,@sid);
    UPDATE dbo.SubjectDetails SET RemainingSeats=RemainingSeats-1 WHERE SubjectId=@sub;
    SET @got=1;
   END;
   FETCH NEXT FROM pref_cur INTO @sub;
  END;
  CLOSE pref_cur; DEALLOCATE pref_cur;
  IF @got=0 INSERT dbo.UnallotedStudents VALUES(@sid);
  FETCH NEXT FROM student_cur INTO @sid;
 END;
 CLOSE student_cur; DEALLOCATE student_cur;
END;
GO
EXEC dbo.sp_allot_subjects;
SELECT * FROM dbo.Allotments ORDER BY CASE SubjectId WHEN 'PO1491' THEN 1 WHEN 'PO1492' THEN 2 WHEN 'PO1494' THEN 3 WHEN 'PO1493' THEN 4 ELSE 5 END,StudentId;
SELECT * FROM dbo.UnallotedStudents;
SELECT * FROM dbo.SubjectDetails;
GO

-- Q2.5 Safe payment posting with error handling
DROP PROCEDURE IF EXISTS dbo.sp_record_payment;
DROP TABLE IF EXISTS dbo.error_log;
DROP TABLE IF EXISTS dbo.payments;
GO
CREATE TABLE dbo.payments(payment_id VARCHAR(10) PRIMARY KEY,order_id INT NOT NULL,payment_date DATE NOT NULL DEFAULT GETDATE(),amount DECIMAL(10,2) NOT NULL,method VARCHAR(30));
INSERT dbo.payments(payment_id,order_id,payment_date,amount,method) VALUES
('PM01',1001,'2026-03-02',2198,'UPI'),('PM02',1002,'2026-03-03',1000,'Card'),('PM03',1002,'2026-03-05',999,'Card'),
('PM04',1003,'2026-03-10',500,'UPI'),('PM05',1005,'2026-03-15',3998,'NetBanking'),('PM06',1006,'2026-03-18',1497,'UPI'),
('PM07',1009,'2026-04-02',750,'UPI'),('PM08',1004,'2026-03-12',1499,'Card');
CREATE TABLE dbo.error_log(log_id INT IDENTITY(1,1) PRIMARY KEY,error_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),proc_name SYSNAME,error_number INT,error_message NVARCHAR(4000),input_values VARCHAR(500));
GO
CREATE PROCEDURE dbo.sp_record_payment @payment_id VARCHAR(10),@order_id INT,@amount DECIMAL(10,2),@method VARCHAR(30)
AS
BEGIN
 SET NOCOUNT ON;
 BEGIN TRY
  BEGIN TRANSACTION;
  IF NOT EXISTS(SELECT 1 FROM dbo.orders WHERE order_id=@order_id) THROW 50001,'Order not found',1;
  IF EXISTS(SELECT 1 FROM dbo.orders WHERE order_id=@order_id AND status='Cancelled') THROW 50002,'Order is cancelled',1;
  IF @amount<=0 THROW 50003,'Amount must be greater than zero',1;
  DECLARE @order_value DECIMAL(12,2),@already_paid DECIMAL(12,2);
  SELECT @order_value=SUM(oi.qty*oi.unit_price) FROM dbo.order_items oi WHERE oi.order_id=@order_id;
  SELECT @already_paid=COALESCE(SUM(p.amount),0) FROM dbo.payments p WHERE p.order_id=@order_id;
  IF COALESCE(@already_paid,0)+@amount>@order_value THROW 50004,'Payment exceeds order value',1;
  INSERT dbo.payments(payment_id,order_id,payment_date,amount,method) VALUES(@payment_id,@order_id,CONVERT(DATE,GETDATE()),@amount,@method);
  COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
  INSERT dbo.error_log(proc_name,error_number,error_message,input_values)
  VALUES('sp_record_payment',ERROR_NUMBER(),ERROR_MESSAGE(),CONCAT(@payment_id,',',@order_id,',',@amount,',',@method));
 END CATCH
END;
GO
EXEC dbo.sp_record_payment 'PM09',1007,1499,'Card';
EXEC dbo.sp_record_payment 'PM10',1010,500,'UPI';
EXEC dbo.sp_record_payment 'PM11',1004,100,'UPI';
EXEC dbo.sp_record_payment 'PM12',1003,0,'UPI';
EXEC dbo.sp_record_payment 'PM13',1003,600,'UPI';
EXEC dbo.sp_record_payment 'PM14',1003,499,'UPI';
SELECT * FROM dbo.payments ORDER BY payment_id;
SELECT log_id,proc_name,error_number,error_message,input_values FROM dbo.error_log ORDER BY log_id;
GO

-- Q2.6 Rank employees by salary department-wise
DROP TABLE IF EXISTS dbo.emp_salary;
GO
CREATE TABLE dbo.emp_salary(emp_id INT PRIMARY KEY,emp_name VARCHAR(50),department VARCHAR(50),salary INT);
INSERT dbo.emp_salary VALUES
(1,'Aditi','Engineering',100000),(2,'Bharat','Engineering',100000),(3,'Chetan','Engineering',90000),(4,'Divya','Engineering',80000),(5,'Eshan','Engineering',80000),(6,'Farhan','Engineering',70000),
(7,'Gauri','Sales',75000),(8,'Harsh','Sales',72000),(9,'Ira','Sales',72000),(10,'Jatin','Support',50000),(11,'Kavya','HR',60000),(12,'Lokesh','HR',60000);
SELECT emp_id,emp_name,department,salary,
 ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC,emp_id) AS row_num,
 RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS rnk,
 DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS dense_rnk
FROM dbo.emp_salary ORDER BY department,salary DESC,emp_id;
;WITH SalaryRanks AS
(
 SELECT department,emp_name,salary,DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS salary_level
 FROM dbo.emp_salary
)
SELECT department,emp_name,salary,salary_level FROM SalaryRanks WHERE salary_level<=3 ORDER BY department,salary DESC,emp_name;
GO

-- Q2.7 Book and author view
DROP VIEW IF EXISTS dbo.vw_book_author;
DROP TABLE IF EXISTS dbo.BookAuthors;
DROP TABLE IF EXISTS dbo.Books;
DROP TABLE IF EXISTS dbo.Authors;
GO
CREATE TABLE dbo.Books(BookID INT PRIMARY KEY,Title VARCHAR(100));
CREATE TABLE dbo.Authors(AuthorID INT PRIMARY KEY,AuthorName VARCHAR(100));
CREATE TABLE dbo.BookAuthors(BookID INT REFERENCES dbo.Books(BookID),AuthorID INT REFERENCES dbo.Authors(AuthorID),PRIMARY KEY(BookID,AuthorID));
INSERT dbo.Books VALUES(1,'Desert Winds'),(2,'River Songs'),(3,'The Glass Fort'),(4,'Night Train'),(5,'Salt and Stone'),(6,'Paper Moons');
INSERT dbo.Authors VALUES(1,'Meera Kaul'),(2,'Rohan Sen'),(3,'Tanvi Bose'),(4,'Ishita Roy');
INSERT dbo.BookAuthors VALUES(1,1),(2,2),(3,1),(3,3),(4,4),(5,2),(6,2),(6,1);
GO
CREATE VIEW dbo.vw_book_author
AS
WITH AuthorBookCounts AS
(
 SELECT a.AuthorID,a.AuthorName,COUNT(DISTINCT ba.BookID) AS BookCount
 FROM dbo.Authors a JOIN dbo.BookAuthors ba ON ba.AuthorID=a.AuthorID GROUP BY a.AuthorID,a.AuthorName
)
SELECT b.Title AS Booktitle,
 STRING_AGG(CAST(x.AuthorName AS VARCHAR(MAX)),',') WITHIN GROUP(ORDER BY x.AuthorName) AS Authorname,
 STRING_AGG(CAST(x.BookCount AS VARCHAR(10)),',') WITHIN GROUP(ORDER BY x.AuthorName) AS Book_count
FROM dbo.Books b JOIN dbo.BookAuthors ba ON ba.BookID=b.BookID JOIN AuthorBookCounts x ON x.AuthorID=ba.AuthorID
GROUP BY b.BookID,b.Title;
GO
SELECT * FROM dbo.vw_book_author ORDER BY Booktitle;
GO

-- Q2.8 Revised salary and comparison with previous employee
DROP VIEW IF EXISTS dbo.VW_EMP_DEPT;
DROP TABLE IF EXISTS dbo.Employee;
DROP TABLE IF EXISTS dbo.Dept_loc;
GO
CREATE TABLE dbo.Employee(Empid INT PRIMARY KEY,Full_name VARCHAR(100),Salary DECIMAL(10,2),Hiredate DATE,deptid INT NULL);
CREATE TABLE dbo.Dept_loc(deptid INT PRIMARY KEY,deptname VARCHAR(100),loc VARCHAR(50));
INSERT dbo.Employee VALUES
(1012,'Raji K Nair',35500,'2018-04-09',1),(1009,'Jeena',12000,'2018-11-17',2),(1005,'Nidhi R Shetty',10000,'2019-01-16',3),
(1011,'Jiya Shetty',45500,'2019-03-27',4),(1003,'Arun Kumar Menon',45500,'2019-08-02',5),(1007,'Farah Ali',30000,'2020-02-10',NULL),(1001,'Manoj P Iyer',52000,'2020-07-15',2);
INSERT dbo.Dept_loc VALUES(1,'HR','Dallas'),(2,'Sales','Chicago'),(3,'Customer service','Chicago'),(4,'IT','Boston'),(5,'Research','Seattle'),(6,'Legal','New York');
GO
CREATE VIEW dbo.VW_EMP_DEPT
AS
WITH Cleaned AS
(
 SELECT e.Empid,
        CASE WHEN CHARINDEX(' ',LTRIM(RTRIM(e.Full_name)))=0 THEN LTRIM(RTRIM(e.Full_name))
             ELSE LEFT(LTRIM(RTRIM(e.Full_name)),CHARINDEX(' ',LTRIM(RTRIM(e.Full_name)))-1)+' '+
                  RIGHT(LTRIM(RTRIM(e.Full_name)),CHARINDEX(' ',REVERSE(LTRIM(RTRIM(e.Full_name)))+' ')-1) END AS Full_name,
        e.Salary,e.Hiredate,COALESCE(d.deptname,'NA') AS deptname,COALESCE(d.loc,'NA') AS loc,
        LAG(e.Salary) OVER(ORDER BY e.Hiredate,e.Empid) AS Previous_emp_sal
 FROM dbo.Employee e LEFT JOIN dbo.Dept_loc d ON d.deptid=e.deptid
)
SELECT Empid,Full_name,Salary,
 CAST(Salary*(1+CASE loc WHEN 'Chicago' THEN .05 WHEN 'Boston' THEN .03 WHEN 'Dallas' THEN .10 WHEN 'New York' THEN .10 ELSE 0 END) AS DECIMAL(10,2)) AS Inc_Sal,
 Previous_emp_sal,Hiredate,deptname,loc,
 CASE WHEN Previous_emp_sal IS NULL THEN 'No previous employee'
      WHEN Salary>Previous_emp_sal THEN 'Salary is greater than previously hired employee'
      WHEN Salary<Previous_emp_sal THEN 'Salary is less than previously hired employee'
      ELSE 'Salary is same as previously hired employee' END AS message
FROM Cleaned;
GO
SELECT * FROM dbo.VW_EMP_DEPT ORDER BY Hiredate,Empid;
GO

-- Q2.9 Running total and 3-month moving average
DROP TABLE IF EXISTS dbo.monthly_sales;
GO
CREATE TABLE dbo.monthly_sales(month_start DATE,region VARCHAR(20),revenue DECIMAL(12,2),PRIMARY KEY(region,month_start));
INSERT dbo.monthly_sales VALUES
('2026-01-01','North',120000),('2026-02-01','North',135000),('2026-03-01','North',128000),('2026-04-01','North',150000),('2026-05-01','North',160000),('2026-06-01','North',145000),
('2026-01-01','South',90000),('2026-02-01','South',85000),('2026-03-01','South',110000),('2026-04-01','South',105000),('2026-05-01','South',130000),('2026-06-01','South',140000);
SELECT region,month_start,revenue,
 SUM(revenue) OVER(PARTITION BY region ORDER BY month_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
 CAST(AVG(revenue) OVER(PARTITION BY region ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS DECIMAL(12,2)) AS moving_avg_3m,
 CAST(100.0*revenue/SUM(revenue) OVER(PARTITION BY region) AS DECIMAL(6,2)) AS pct_of_total
FROM dbo.monthly_sales ORDER BY region,month_start;
GO

-- Q2.10 Keep the latest record for each customer
DROP TABLE IF EXISTS dbo.customer_updates;
GO
CREATE TABLE dbo.customer_updates(load_id INT PRIMARY KEY,customer_id VARCHAR(10),email VARCHAR(100),city VARCHAR(50),updated_at DATETIME2);
INSERT dbo.customer_updates VALUES
(1,'C01','rahul@mail.com','Jaipur','2026-05-01 10:00:00'),(2,'C02','priya@mail.com','Kochi','2026-05-01 10:05:00'),
(3,'C01','rahul.m@mail.com','Jaipur','2026-05-03 09:00:00'),(4,'C03','arjun@mail.com','Kolkata','2026-05-02 12:00:00'),
(5,'C02','priya@mail.com','Kochi','2026-05-01 10:05:00'),(6,'C01','rahul.m@mail.com','Delhi','2026-05-03 09:00:00'),
(7,'C04','fatima@mail.com','Mumbai','2026-05-04 08:30:00'),(8,'C03','arjun.d@mail.com','Kolkata','2026-05-05 18:45:00');
;WITH Ranked AS
(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY updated_at DESC,load_id DESC) AS rn
 FROM dbo.customer_updates
)
SELECT customer_id,email,city,updated_at,load_id FROM Ranked WHERE rn=1 ORDER BY customer_id;
;WITH Ranked AS
(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY updated_at DESC,load_id DESC) AS rn
 FROM dbo.customer_updates
)
SELECT COUNT(*) AS rows_loaded,SUM(CASE WHEN rn=1 THEN 1 ELSE 0 END) AS rows_kept,
       SUM(CASE WHEN rn>1 THEN 1 ELSE 0 END) AS rows_removed
FROM Ranked;
GO

-- Q2.11 Find the longest login streak for each user
DROP TABLE IF EXISTS dbo.logins;
GO
CREATE TABLE dbo.logins(user_id VARCHAR(10),login_date DATE,PRIMARY KEY(user_id,login_date));
INSERT dbo.logins VALUES
('U1','2026-03-01'),('U1','2026-03-02'),('U1','2026-03-03'),('U1','2026-03-05'),('U1','2026-03-06'),('U1','2026-03-07'),
('U2','2026-03-01'),('U2','2026-03-03'),('U2','2026-03-04'),('U2','2026-03-05'),('U2','2026-03-06'),('U2','2026-03-10'),
('U3','2026-03-02'),('U4','2026-03-01'),('U4','2026-03-02'),('U4','2026-03-04'),('U4','2026-03-05'),('U4','2026-03-08'),('U4','2026-03-09');
;WITH Numbered AS
(
 SELECT user_id,login_date,DATEADD(DAY,-CONVERT(INT,ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date)),login_date) AS grp
 FROM dbo.logins
), Streaks AS
(
 SELECT user_id,MIN(login_date) AS streak_start,MAX(login_date) AS streak_end,COUNT(*) AS streak_days
 FROM Numbered GROUP BY user_id,grp
), Ranked AS
(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY streak_days DESC,streak_end DESC) AS rn
 FROM Streaks
)
SELECT user_id,streak_start,streak_end,streak_days FROM Ranked WHERE rn=1 ORDER BY user_id;
GO

-- End of Week 2 SQL practical
*/