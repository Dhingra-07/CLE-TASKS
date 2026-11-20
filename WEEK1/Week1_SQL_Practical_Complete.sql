/*
Week 1 SQL Practical Questions - SQL Server / SSMS
Database: Week1_SQL_Practice

*/
/*
IF DB_ID('Week1_SQL_Practice') IS NULL
    CREATE DATABASE Week1_SQL_Practice;
GO
USE Week1_SQL_Practice;
GO

/* Q1.1 Course batches: constraints, insert, update, transaction, rollback */
CREATE TABLE course_batches
(
    batch_id INT PRIMARY KEY,
    subject_id VARCHAR(5) NOT NULL,
    batch_name VARCHAR(40) NOT NULL,
    start_date DATE NOT NULL,
    capacity INT CHECK (capacity > 0),
    trainer VARCHAR(40) NULL,
    status VARCHAR(10) DEFAULT 'Planned'
);
GO
INSERT INTO course_batches(batch_id, subject_id, batch_name, start_date, capacity, trainer)
VALUES
(1,'S01','SQL Morning Batch','2026-04-01',30,NULL),
(2,'S02','Python Weekend Batch','2026-04-05',25,'Ritu Sharma'),
(3,'S03','Visualization Evening','2026-05-10',20,NULL),
(4,'S01','SQL Evening Batch','2026-03-20',30,'Amit Bansal');
GO
-- Intentionally fails CHECK constraint; execute separately if you want to see the error:
-- INSERT INTO course_batches(batch_id,subject_id,batch_name,start_date,capacity,trainer)
-- VALUES (5,'S04','Stats Crash Course','2026-04-15',0,NULL);
UPDATE course_batches SET trainer='Neha Joshi' WHERE batch_id=1;
UPDATE course_batches SET trainer='Ritu Sharma' WHERE batch_id=3;
BEGIN TRANSACTION;
DELETE FROM course_batches WHERE status='Planned';
SELECT * FROM course_batches; -- temporary view after delete
ROLLBACK TRANSACTION;
UPDATE course_batches SET status='Open' WHERE start_date <= '2026-04-01';
SELECT * FROM course_batches ORDER BY batch_id;
GO

/* Q1.2 Admissions students list and distinct cities */
CREATE TABLE students
(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    gender CHAR(1),
    city VARCHAR(30),
    email VARCHAR(100),
    phone VARCHAR(10),
    dob DATE,
    join_date DATE
);
GO
INSERT INTO students VALUES
(101,'aarav sharma','M','Jaipur','aarav.sharma@gmail.com','9876543210','2004-05-12','2026-01-05'),
(102,'Diya Patel','F','Ahmedabad','diya.patel@yahoo.com',NULL,'2003-11-23','2026-01-10'),
(103,'Kabir Singh','M','Delhi',NULL,'9812345678','2004-02-02','2026-01-18'),
(104,'Meera Iyer','F','Chennai','meera.iyer@outlook.com','9900112233',NULL,'2026-02-03'),
(105,'rohan VERMA','M','Jaipur','rohan.verma@gmail.com','9811122233','2005-07-30','2026-02-14'),
(106,'Sana Khan','F','Delhi',NULL,NULL,NULL,'2026-02-20'),
(107,'Ishaan Gupta','M','Pune','ishaan.gupta@gmail.com','9822001100','2004-09-09','2026-03-01'),
(108,'Ananya Rao','F',NULL,NULL,NULL,'2003-12-19','2026-03-05'),
(109,'Vikram Joshi','M','Jaipur','vikram.joshi@yahoo.com','9876501234','2004-01-25','2026-03-11'),
(110,'Neha Kapoor','F','Mumbai','neha.kapoor@gmail.com','9800098000','2005-03-14','2026-03-20');
GO
-- Admissions call list
SELECT student_id, student_name, city, join_date
FROM students
WHERE city IN ('Jaipur','Delhi')
  AND join_date BETWEEN '2026-02-01' AND '2026-03-31'
ORDER BY join_date DESC;
-- Unique campaign cities, excluding NULL
SELECT DISTINCT city
FROM students
WHERE city IS NOT NULL
ORDER BY city;
GO

/* Q1.3 Student contact data cleaning */
SELECT student_id,
       UPPER(TRIM(student_name)) AS clean_name,
       CASE WHEN email IS NULL THEN 'Not Provided'
            ELSE LEFT(email, CHARINDEX('@',email)-1) END AS email_user,
       CASE WHEN email IS NULL THEN 'Not Provided'
            ELSE SUBSTRING(email, CHARINDEX('@',email)+1, LEN(email)) END AS email_domain,
       CASE WHEN phone IS NULL THEN 'Not Provided'
            ELSE CONCAT('XXXXXX', RIGHT(phone,4)) END AS masked_phone,
       DATENAME(MONTH, join_date) AS join_month,
       DATEDIFF(DAY, join_date, '2026-10-01') AS days_with_us
FROM students
ORDER BY student_id;
GO

/* Q1.4 Profile completeness and fee-payment classification/averages */
-- Part A: student profile completeness
SELECT student_id, student_name,
       (CASE WHEN email IS NULL THEN 1 ELSE 0 END
        + CASE WHEN phone IS NULL THEN 1 ELSE 0 END
        + CASE WHEN city IS NULL THEN 1 ELSE 0 END
        + CASE WHEN dob IS NULL THEN 1 ELSE 0 END) AS missing_fields,
       CASE
          WHEN email IS NOT NULL AND phone IS NOT NULL AND city IS NOT NULL AND dob IS NOT NULL
               THEN 'Complete'
          WHEN email IS NULL AND phone IS NULL THEN 'Contact Missing'
          ELSE 'Partially Complete'
       END AS profile_status
FROM students
ORDER BY student_id;
GO
CREATE TABLE fee_payments
(
    payment_id VARCHAR(3) PRIMARY KEY,
    student_id INT,
    subject_id VARCHAR(5),
    payment_date DATE,
    amount DECIMAL(10,2) NULL,
    status VARCHAR(15)
);
GO
INSERT INTO fee_payments VALUES
('P01',101,'S01','2026-01-06',4000,'Success'),
('P02',101,'S02','2026-01-20',5000,'Success'),
('P03',102,'S01','2026-01-11',4000,'Failed'),
('P04',102,'S01','2026-01-12',4000,'Success'),
('P05',103,'S02','2026-01-19',2500,'Success'),
('P06',103,'S03','2026-02-01',3500,'Success'),
('P07',104,'S01','2026-02-04',4000,'Success'),
('P08',105,'S02','2026-02-15',5000,'Success'),
('P09',105,'S04','2026-02-16',NULL,'Pending'),
('P10',103,'S02','2026-02-19',2500,'Success'),
('P11',107,'S01','2026-03-02',4000,'Success'),
('P12',107,'S02','2026-03-03',5000,'Refunded'),
('P13',108,'S03','2026-03-06',3500,'Success'),
('P14',109,'S01','2026-03-12',4000,'Success'),
('P15',110,'S05','2026-03-21',4500,'Success');
GO
-- Part B: payment classification. Check NULL amount first.
SELECT payment_id, student_id, amount, status,
       CASE WHEN amount IS NULL THEN 'Amount Missing'
            WHEN status <> 'Success' THEN 'Not Collected'
            ELSE 'Collected' END AS payment_class
FROM fee_payments
ORDER BY payment_id;
-- Part C: correct average ignores NULL; incorrect average treats NULL as zero
SELECT CAST(ROUND(AVG(amount),2) AS DECIMAL(10,2)) AS avg_amount_correct,
       CAST(ROUND(AVG(COALESCE(amount,0)),2) AS DECIMAL(10,2)) AS avg_amount_wrong
FROM fee_payments;
GO

/* Q1.5 Subject demand (valid student IDs only; preserve subjects with zero) */
CREATE TABLE subjects
(
    subject_id VARCHAR(5) PRIMARY KEY,
    subject_name VARCHAR(50),
    fee DECIMAL(10,2),
    max_seats INT
);
GO
INSERT INTO subjects VALUES
('S01','SQL Fundamentals',4000,30),
('S02','Python Programming',5000,30),
('S03','Data Visualization',3500,20),
('S04','Statistics',3000,25),
('S05','Cloud Basics',4500,20),
('S06','Machine Learning',6000,15);
CREATE TABLE enrollments
(
    enrollment_id VARCHAR(3) PRIMARY KEY,
    student_id INT,
    subject_id VARCHAR(5),
    enroll_date DATE
);
GO
INSERT INTO enrollments VALUES
('E01',101,'S01','2026-01-06'),
('E02',101,'S02','2026-01-06'),
('E03',102,'S01','2026-01-11'),
('E04',103,'S02','2026-01-19'),
('E05',103,'S03','2026-02-01'),
('E06',104,'S01','2026-02-04'),
('E07',105,'S02','2026-02-15'),
('E08',105,'S04','2026-02-15'),
('E09',107,'S01','2026-03-02'),
('E10',107,'S02','2026-03-02'),
('E11',108,'S03','2026-03-06'),
('E12',109,'S01','2026-03-12'),
('E13',110,'S05','2026-03-21'),
('E14',112,'S02','2026-03-25');
GO
SELECT s.subject_id, s.subject_name,
       COUNT(e.enrollment_id) AS enrolled_students,
       s.max_seats - COUNT(e.enrollment_id) AS seats_left,
       CASE WHEN COUNT(e.enrollment_id) >= 4 THEN 'High'
            WHEN COUNT(e.enrollment_id) BETWEEN 2 AND 3 THEN 'Medium'
            WHEN COUNT(e.enrollment_id) = 1 THEN 'Low'
            ELSE 'No Demand' END AS demand_level
FROM subjects s
LEFT JOIN enrollments e ON e.subject_id=s.subject_id
LEFT JOIN students st ON st.student_id=e.student_id
WHERE e.enrollment_id IS NULL OR st.student_id IS NOT NULL
GROUP BY s.subject_id, s.subject_name, s.max_seats
ORDER BY enrolled_students DESC, s.subject_id;
GO

/* Q1.6 Monthly revenue and subject revenue */
SELECT CONVERT(CHAR(7), payment_date, 120) AS pay_month,
       SUM(CASE WHEN status='Success' THEN 1 ELSE 0 END) AS successful_payments,
       SUM(CASE WHEN status='Success' THEN amount ELSE 0 END) AS total_revenue,
       AVG(CASE WHEN status='Success' THEN amount END) AS avg_payment,
       SUM(CASE WHEN status<>'Success' THEN 1 ELSE 0 END) AS other_payments
FROM fee_payments
GROUP BY CONVERT(CHAR(7), payment_date, 120)
HAVING SUM(CASE WHEN status='Success' THEN amount ELSE 0 END) >= 15000
ORDER BY pay_month;
-- Revenue by subject, only above 8000
SELECT s.subject_name, SUM(fp.amount) AS total_revenue
FROM fee_payments fp
JOIN subjects s ON s.subject_id=fp.subject_id
WHERE fp.status='Success'
GROUP BY s.subject_name
HAVING SUM(fp.amount)>8000
ORDER BY total_revenue DESC;
GO

/* Q1.7 Unmatched students, customers and orders */
-- Students with no enrollment
SELECT st.student_id, st.student_name, st.city
FROM students st
WHERE NOT EXISTS
(
    SELECT 1 FROM enrollments e WHERE e.student_id=st.student_id
);
CREATE TABLE store_customers
(
    customer_id VARCHAR(3) PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(30)
);
CREATE TABLE store_orders
(
    order_id VARCHAR(5) PRIMARY KEY,
    customer_id VARCHAR(3) NULL,
    order_date DATE,
    amount DECIMAL(10,2)
);
GO
INSERT INTO store_customers VALUES
('C01','Rahul Mehta','Jaipur'),
('C02','Priya Nair','Kochi'),
('C03','Arjun Das','Kolkata'),
('C04','Fatima Sheikh','Mumbai'),
('C05','Karan Malhotra','Delhi');
INSERT INTO store_orders VALUES
('O1001','C01','2026-03-01',1200),
('O1002','C02','2026-03-02',850),
('O1003','C01','2026-03-05',430),
('O1004','C07','2026-03-06',999),
('O1005','C04','2026-03-08',2100),
('O1006',NULL,'2026-03-09',300);
GO
-- Customers who never placed an order
SELECT c.customer_id, c.customer_name, c.city
FROM store_customers c
WHERE NOT EXISTS
(
    SELECT 1 FROM store_orders o WHERE o.customer_id=c.customer_id
);
-- Orders whose customer is missing or invalid
SELECT o.order_id, o.customer_id, o.amount,
       CASE WHEN o.customer_id IS NULL THEN 'Guest order - no customer'
            ELSE 'Customer not found' END AS issue
FROM store_orders o
LEFT JOIN store_customers c ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL;
GO

/* Q1.8 ShopEasy order summary - pre-aggregate to avoid fan-out */
CREATE TABLE customers
(
    customer_id VARCHAR(3) PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(30),
    signup_date DATE
);
CREATE TABLE products
(
    product_id VARCHAR(2) PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    unit_price DECIMAL(10,2)
);
CREATE TABLE orders
(
    order_id INT PRIMARY KEY,
    customer_id VARCHAR(3),
    order_date DATE,
    status VARCHAR(20)
);
CREATE TABLE order_items
(
    order_id INT,
    product_id VARCHAR(2),
    qty INT,
    unit_price DECIMAL(10,2)
);
CREATE TABLE payments
(
    payment_id VARCHAR(4) PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    method VARCHAR(20)
);
GO
INSERT INTO customers VALUES
('C01','Rahul Mehta','Jaipur','2025-11-02'),
('C02','Priya Nair','Kochi','2025-12-15'),
('C03','Arjun Das','Kolkata','2026-01-08'),
('C04','Fatima Sheikh','Mumbai','2026-01-20'),
('C05','Karan Malhotra','Delhi','2026-02-11'),
('C06','Sneha Kulkarni','Pune','2026-02-25');
INSERT INTO products VALUES
('P1','Wireless Mouse','Electronics',799),
('P2','USB-C Hub','Electronics',1999),
('P3','Notebook A5','Stationery',120),
('P4','Gel Pen Pack','Stationery',250),
('P5','Desk Lamp','Home',1499),
('P6','Water Bottle','Home',499);
INSERT INTO orders VALUES
(1001,'C01','2026-03-02','Delivered'),
(1002,'C02','2026-03-03','Delivered'),
(1003,'C01','2026-03-10','Delivered'),
(1004,'C03','2026-03-12','Cancelled'),
(1005,'C04','2026-03-15','Shipped'),
(1006,'C05','2026-03-18','Delivered'),
(1007,'C01','2026-04-01','Shipped'),
(1008,'C06','2026-04-03','Pending');
INSERT INTO order_items VALUES
(1001,'P1',2,799),(1001,'P3',5,120),
(1002,'P2',1,1999),
(1003,'P4',2,250),(1003,'P6',1,499),
(1004,'P5',1,1499),
(1005,'P1',1,799),(1005,'P2',1,1999),(1005,'P3',10,120),
(1006,'P6',3,499),
(1007,'P5',1,1499),
(1008,'P4',4,250);
INSERT INTO payments VALUES
('PM01',1001,'2026-03-02',2198,'UPI'),
('PM02',1002,'2026-03-03',1000,'Card'),
('PM03',1002,'2026-03-05',999,'Card'),
('PM04',1003,'2026-03-10',500,'UPI'),
('PM05',1005,'2026-03-15',3998,'NetBanking'),
('PM06',1006,'2026-03-18',1497,'UPI'),
('PM07',1009,'2026-04-02',750,'UPI'),
('PM08',1004,'2026-03-12',1499,'Card');
GO
WITH item_summary AS
(
    SELECT order_id,
           SUM(qty) AS item_count,
           SUM(qty*unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
),
payment_summary AS
(
    SELECT order_id, SUM(amount) AS paid_amount
    FROM payments
    GROUP BY order_id
)
SELECT o.order_id, c.customer_name, o.order_date, o.status,
       COALESCE(i.item_count,0) AS item_count,
       COALESCE(i.order_value,0) AS order_value,
       COALESCE(p.paid_amount,0) AS paid_amount,
       COALESCE(i.order_value,0)-COALESCE(p.paid_amount,0) AS balance,
       CASE WHEN COALESCE(p.paid_amount,0)>=COALESCE(i.order_value,0) THEN 'Paid'
            WHEN COALESCE(p.paid_amount,0)>0 THEN 'Partially Paid'
            ELSE 'Unpaid' END AS payment_status
FROM orders o
JOIN customers c ON c.customer_id=o.customer_id
LEFT JOIN item_summary i ON i.order_id=o.order_id
LEFT JOIN payment_summary p ON p.order_id=o.order_id
ORDER BY o.order_id;
GO

/* Q1.9 Reconcile orders and payments - FULL OUTER JOIN */
WITH item_summary AS
(
    SELECT order_id, SUM(qty*unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
),
payment_summary AS
(
    SELECT order_id, SUM(amount) AS paid_amount
    FROM payments
    GROUP BY order_id
)
SELECT COALESCE(o.order_id,p.order_id) AS order_id,
       o.status AS order_status,
       i.order_value,
       COALESCE(p.paid_amount,0) AS paid_amount,
       CASE
          WHEN o.order_id IS NULL THEN 'Unknown Order'
          WHEN o.status='Cancelled' AND p.order_id IS NOT NULL THEN 'Refund Required'
          WHEN o.status<>'Cancelled' AND p.order_id IS NULL THEN 'Payment Missing'
          WHEN COALESCE(p.paid_amount,0)<COALESCE(i.order_value,0) THEN 'Short Paid'
       END AS recon_status
FROM orders o
FULL OUTER JOIN payment_summary p ON p.order_id=o.order_id
LEFT JOIN item_summary i ON i.order_id=o.order_id
WHERE o.order_id IS NULL
   OR (o.status='Cancelled' AND p.order_id IS NOT NULL)
   OR (o.status<>'Cancelled' AND p.order_id IS NULL)
   OR (COALESCE(p.paid_amount,0)<COALESCE(i.order_value,0))
ORDER BY COALESCE(o.order_id,p.order_id);
GO

/* Q1.10 Employee directory: SELF JOIN, LEFT JOIN and RIGHT JOIN */
CREATE TABLE departments
(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30),
    location VARCHAR(30)
);
CREATE TABLE employees
(
    emp_id VARCHAR(3) PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT NULL,
    manager_id VARCHAR(3) NULL,
    salary INT,
    hire_date DATE
);
GO
INSERT INTO employees VALUES
('E01','Asha Verma',10,NULL,150000,'2018-04-01'),
('E02','Ravi Kumar',20,'E01',95000,'2019-06-15'),
('E03','Meena Pillai',20,'E02',72000,'2021-01-10'),
('E04','John Mathew',20,'E02',72000,'2022-03-01'),
('E05','Sara Ali',30,'E01',98000,'2019-09-20'),
('E06','Vivek Rao',30,'E05',64000,'2023-02-14'),
('E07','Pooja Shah',30,'E05',58000,'2024-07-01'),
('E08','Nikhil Jain',20,'E03',55000,'2025-01-06'),
('E09','Tara Menon',40,'E01',88000,'2020-11-11'),
('E10','Imran Qureshi',NULL,'E01',61000,'2025-08-18');
INSERT INTO departments VALUES
(10,'Leadership','Jaipur'),
(20,'Engineering','Bengaluru'),
(30,'Analytics','Pune'),
(40,'Finance','Mumbai'),
(50,'Legal','Delhi');
GO
-- Part A: employee manager self-join; left join department to keep unassigned employees
SELECT e.emp_id, e.emp_name,
       COALESCE(m.emp_name,'No Manager') AS manager_name,
       COALESCE(d.dept_name,'Not Assigned') AS dept_name,
       COALESCE(d.location,'Not Assigned') AS location
FROM employees e
LEFT JOIN employees m ON m.emp_id=e.manager_id
LEFT JOIN departments d ON d.dept_id=e.dept_id
ORDER BY e.emp_id;
-- Part B: RIGHT JOIN to retain departments with zero employees
SELECT d.dept_id, d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON d.dept_id=e.dept_id
WHERE e.emp_id IS NULL;
GO

/* Q1.11 Salary benchmarks with subqueries */
-- Part A: 4th highest distinct salary
SELECT MAX(salary) AS fourth_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees
                WHERE salary < (SELECT MAX(salary) FROM employees
                               WHERE salary < (SELECT MAX(salary) FROM employees)));
-- Part B: earn above own department average; exclude NULL department
SELECT e.emp_name, e.dept_id, e.salary,
       CAST(ROUND(x.dept_avg_salary,2) AS DECIMAL(10,2)) AS dept_avg_salary
FROM employees e
JOIN
(
    SELECT dept_id, AVG(CAST(salary AS DECIMAL(10,2))) AS dept_avg_salary
    FROM employees
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
) x ON x.dept_id=e.dept_id
WHERE e.salary>x.dept_avg_salary
ORDER BY e.dept_id, e.salary DESC;
-- Part C: managers with at least one report; EXISTS + scalar subquery count
SELECT e.emp_id, e.emp_name,
       (SELECT COUNT(*) FROM employees r WHERE r.manager_id=e.emp_id) AS direct_reports
FROM employees e
WHERE EXISTS (SELECT 1 FROM employees r WHERE r.manager_id=e.emp_id)
ORDER BY e.emp_id;
GO

/* Q1.12 CRM and billing lists: set operations */
CREATE TABLE crm_customers
(
    customer_id VARCHAR(3),
    email VARCHAR(100)
);
CREATE TABLE billing_customers
(
    customer_id VARCHAR(3),
    email VARCHAR(100)
);
GO
INSERT INTO crm_customers VALUES
('C01','rahul.mehta@mail.com'),
('C02','priya.nair@mail.com'),
('C02','priya.nair@mail.com'),
('C03','arjun.das@mail.com'),
('C04','fatima.s@mail.com');
INSERT INTO billing_customers VALUES
('C02','priya.nair@mail.com'),
('C04','fatima.s@mail.com'),
('C05','karan.m@mail.com'),
('C06','sneha.k@mail.com');
GO
-- A: in both lists
SELECT customer_id,email FROM crm_customers
INTERSECT
SELECT customer_id,email FROM billing_customers;
-- B: CRM only
SELECT customer_id,email FROM crm_customers
EXCEPT
SELECT customer_id,email FROM billing_customers;
-- C: Billing only
SELECT customer_id,email FROM billing_customers
EXCEPT
SELECT customer_id,email FROM crm_customers;
-- D: row counts returned by UNION and UNION ALL
SELECT
    (SELECT COUNT(*) FROM
       (SELECT customer_id,email FROM crm_customers
        UNION
        SELECT customer_id,email FROM billing_customers) u) AS union_rows,
    (SELECT COUNT(*) FROM
       (SELECT customer_id,email FROM crm_customers
        UNION ALL
        SELECT customer_id,email FROM billing_customers) ua) AS union_all_rows;
GO
*/