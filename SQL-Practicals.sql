--Lab Setup for Basic/Advanced SQL Exercises:
--Sample database: Employee Management System
=============================================

---------------------------------------
--All rights reserved. GPL-GNU licenc
--No responsibility will be taken by the author for any issues that may be caused by any code in this fil
-------------------------------------
--TO BE EXECUTED IN SSMS (NOT ONLINE LAB-WEBSITES):

--Check SQL Server details (name/version):
print @@servername  --OR select SERVERPROPERTY('ServerName')		-- host-server & named-instance nam
print @@version
print system_user

-------------------------------------
--Do NOT run following database creation without updating the File-Paths first.
--(Alterntively, in SSMS create database using GUI (Right click "Databases" -> "New Database")
CREATE DATABASE [EmpDb]
 ON  PRIMARY ( NAME = N'EmpDb', FILENAME = N'C:\temp\EmpDb.mdf')
 LOG ON ( NAME = N'EmpDb_log', FILENAME = N'C:\temp\EmpDb_log.ldf' )
-------------------------------------

--DB state:
SELECT database_id, name, state_desc [DB_State], recovery_model_desc, user_access_desc, collation_name, compatibility_level FROM sys.databases WHERE name = 'Employee'
--Change Recovery Model:
ALTER DATABASE [EmpDb] SET RECOVERY SIMPLE 
GO

USE EmpDb
GO

print db_name()  --View database-name in us
--------------------------------


--SAMPLE TABLES CREATION WITH DATA:
-----------------------------------

--Create emp table:
create table emp (
	eid	int 	 NOT NULL ,
	ename	varchar(100)	,
	jobtitle	varchar(100)	,
	managerid	int	,
	hiredate	date	,
	salary	money	,
	commission	decimal(9,2)	,
	did	int ,
	rid int
)			

EXEC sp_tables @table_owner='dbo'
EXEC sp_help 'emp'

insert into emp (eid,ename,jobtitle,managerid,hiredate,salary,commission,did,rid)
	Values
	(	68319, 'Kylie', 'President', 68319, '2009-11-18', 60000.00, NULL , 10	, NULL ),
	(	66928, 'Bob', 'General Manager', 68319, '2013-05-01', 27500.00, 0.33 , 10	, NULL ),
	(	67832, 'Clare', 'Technical Manager', 66928, '2011-06-09', 25500.00, NULL , 10	, NULL ),
	(	65646, 'John', 'Sales Manager', 66928, '2014-04-02', 29570.00, NULL , 10	, NULL ),
	(	67858, 'Scarlet', 'Analyst', 67832, '2017-04-19', 3100.00, NULL , 20	, NULL ),
	(	69324, 'Mark', 'DBA', 67832, '2012-01-23', 1900.00, NULL , 20	, NULL ),
	(	69062, 'Frank', 'Analyst', 67832, '2011-12-03', 3100.00, NULL , 20	, NULL ),
	(	63679, 'Sandra', 'Developer', 67832, '2010-12-18', 2900.00, NULL , 20	, NULL ),
	(	64989, 'Irene', 'Sales Representative', 65646, '2018-02-20', 1700.00, 0.1, 30	, 1 ),
	(	65271, 'Dwayne', 'Sales Representative', 65646, '2011-02-22', 1350.00, 0.05, 30	, 2 ),
	(	66564, 'Gerogia', 'Sales Representative', 65646, '2011-09-28', 1400.00, 0.02, 30	, 1 ),
	(	66569, 'Matt', 'Sales Representative', 65646, '2019-01-28', 1325.00, 0.02, 30	, 2 ),
	(	66571, 'Raj', 'Sales Representative', 65646, '2013-02-15', 1190.00, 0.02, 30	, 5 ),
	(	68454, 'Tucker', 'Sales Representative', 65646, '2011-09-08', 1600.00, 0.01, 30	, 3 ),
	(	68455, 'Sam', 'Sales Representative', 65646, '2020-09-18', 1400.00, 0.01, 30	, 4 ),
	(	68736, 'Andy', 'Technical Support', 67832, '2017-05-23', 1200.00, NULL , 20	, NULL ),
	(	69000, 'Julie', 'Sales Apprentice', 65646, '2011-12-03', 950.00, NULL , 30 , 4	)


--Create dept table:
CREATE TABLE [dbo].[dept](
	[did] [int] NOT NULL,
	[DeptName] [nchar](30) NULL
)

INSERT INTO dept ([did],[DeptName])
VALUES
	(10,	'Mgmt'),
	(20,	'Tech'),
	(30,	'Sales'),
	(40,	'Procurement')
    
--Create region table:
CREATE TABLE [dbo].[region](
	[rid] [int] NOT NULL,
	[RegionName] [nchar](30) NULL
)

INSERT INTO region ([rid],[RegionName])
VALUES
	(1,	'Americas'),
	(2,	'Europe'),
	(3,	'Australias'),
	(4,	'Africa'),
	(5,	'Asia'),
	(6,	'Antarctica')


--Creating PK on DEPT:
ALTER TABLE dept
ADD CONSTRAINT pk_did
PRIMARY KEY (did)

--Creating PK on REGION table:
ALTER TABLE region
ADD CONSTRAINT pk_rid
PRIMARY KEY (rid)

--FK for DEPT:
ALTER TABLE emp
ADD CONSTRAINT fk_did
FOREIGN KEY (did) REFERENCES dept(did)

--FK for REGION:
ALTER TABLE emp
ADD CONSTRAINT fk_rid
FOREIGN KEY (rid) REFERENCES region(rid)
-------------------------------------------------------
EXEC sp_tables @table_owner='dbo'
SELECT * FROM emp
SELECT * FROM dept
SELECT * FROM region
-------------------------------------------------------

EXEC sp_help 'emp'
EXEC sp_help 'dept'
EXEC sp_help 'region'

-------------------------------------------------------

--Print highest salary from the 'emp' table:
SELECT top_salary = MAX(salary) FROM emp;
SELECT  MAX(salary) AS 'top_salary' FROM emp;
SELECT  MAX(salary) AS [top_salary] FROM emp;


--Print highest salary from the 'emp' table along with the 
--employee-names, job_titles and their department-names:
select ename, jobtitle, d.deptname, salary
from emp e
	join dept d on e.did = d.did
--where salary = (select MAX(salary) from emp)
where eid = (select eid from emp where salary = (select MAX(salary) from emp))

--68319
--Print employees' details drawing top 3 salaries:
select TOP 3 * from emp
ORDER BY salary DESC

--Print 2nd hightest salary from the 'emp' table along with the employee-names, job_titles and their department-names:
--Solve this in 5 different methods:
--Method-1: using sub-query:
SELECT TOP 1 ename, jobtitle, salary
FROM emp
WHERE salary < (select MAX(salary) from emp)
ORDER BY salary DESC

--Method-2: using Offset/Fetch:
SELECT ename, jobtitle, salary FROM emp
ORDER BY salary DESC
OFFSET 1 ROW 
FETCH NEXT 1 ROW ONLY

--List all employee-names (ename), job_titles and their department-names (dept_name):
select ename, jobtitle, e.did, d.deptname 
from emp e
	join dept d on e.did = d.did

--Method-3: using Derived-table or order by (table created "on-the-fly"):
SELECT TOP 1 * FROM
	(SELECT TOP 2 e.ename, e.jobtitle, e.salary FROM emp AS e
	ORDER BY e.salary DESC) AS emp1
ORDER BY emp1.salary ASC

--Method-4: using CTE (table created "on-the-fly"):
--Step-1: CTE (Common Table Expression):
WITH emp1 AS
	(SELECT TOP 2 ename, jobtitle, salary FROM emp
	ORDER BY salary DESC)
--Step-2:
SELECT TOP 1 * FROM emp1
ORDER BY salary ASC

--Method-5: using "Derived Table and Row_Number() function":
SELECT * FROM
(SELECT  ROW_NUMBER() OVER(ORDER BY salary DESC) AS row, ename,salary FROM emp) AS emp1
WHERE row = 2

--Derived table: --following is same as: (select ename, jobtitle, did from emp)
select ename, jobtitle, did
from 
	(select * from emp) AS emp_output --must have a name/aliase.


--Create a store procedure that returns all employees details of those who work in 'Sales':
GO
CREATE PROCEDURE emp_sales
AS
BEGIN
	--select * from emp where did = 30  --using did / number
	select ename, jobtitle, d.deptname, salary
	from emp e
		join dept d on e.did = d.did
	where d.deptname = 'Sales'  --using dept-name
END
--Calling:
EXEC emp_sales
GO


--Create a store procedure that returns employees based on given (dynamic) department number (did):
GO
CREATE PROCEDURE emp_in_dept @did int
AS
select * from emp where did = @did
--Calling:
EXEC emp_in_dept @did = 30
EXEC emp_in_dept 10
EXEC emp_in_dept 20
GO


select * from dept
sp_help dept

--List all employees work with the 'Sales' department (including Sales Manager):
--select * from emp where did = 30
select ename, jobtitle, e.did, d.deptname 
from emp e
	join dept d on e.did = d.did
where jobtitle LIKE 'Sale%'  --"ILike" allows the RegExp patters, (e.g.: '.\\S[ale]{3}')


--Create a stored proc (called "AgeCalculatorInYears") that accepts your year of birth (YYYY i.e. 4 digit int), 
--year(getdate())
GO
DROP PROC AgeCalculatorInYears
CREATE PROC AgeCalculatorInYears @y INT
AS
SELECT 'You are ' + CAST((YEAR(GETDATE())-@y) AS VARCHAR(4)) + ' year(s) old.'
--SELECT year(getdate()) - @y
--Call:
EXEC AgeCalculatorInYears 1979
--EXEC AgeCalculatorInYears 1971-07-25


--Write a stored proc (called "AgeCalculator") that accepts your date of birth, then returns your age with break-down 
--(e.g.: "Today you are x year(s), x month(s) and x days old.")
--Optionally, add validation to ensure that the date of birth is passed in (as parameter), e.g., if DOB not supplied it asks for it.
--Tip: ISO date format: 'yyyy-mm-dd'
--Using: DATEADD, DATEDIFF, DATEPART and DATEFROMPARTS functions.

DROP PROC AgeCalculator
--DROP PROC IF EXISTS AgeCalculator --SS version 2016 onwards.

CREATE PROC AgeCalculator(@dob DATE = NULL)
AS
BEGIN
	IF @dob IS NULL
	BEGIN
		PRINT 'Please provide your Date of birth (preferably in ISO format: YYYY-MM-DD)'
		RETURN
	END
	IF @dob > getdate()  --checks if @dob is in future
	BEGIN
		PRINT 'You have entered a date in future,  please enter a valid date of birth (in ISO format: YYYY-MM-DD)'
		RETURN
	END
	DECLARE @y INT,@m INT,@d INT --to store date-of-birth year/month/day.
	DECLARE @cy INT,@cm INT,@cd INT --to store current or today's year/month/day.
	DECLARE @t DATE, @dt DATE    --to store temporary dates.
	SET @t = DATEFROMPARTS(DATEPART(YEAR, getdate()), DATEPART(MONTH, @dob), DATEPART(DAY, @dob))
	SET @y = DATEDIFF(YEAR, @dob, getdate())
	IF @t > getdate()  --checks if month & day are higher value
		SET @y = @y - 1
	SET @t = DATEADD(YEAR, @y, @dob)
	SET @m = DATEDIFF(MONTH, @t, getdate())
	IF DATEPART(DAY, @t) > DATEPART(DAY, getdate())
	BEGIN
		SET @m = @m - 1
	END
	SET @t = DATEADD(MONTH, @m, @t)
	SET @d = DATEDIFF(DAY, @t, getdate())
	print 'Date of birth: ' + cast(@dob as varchar(10))
	print 'Date today is: ' + cast(cast(getdate() as date) as varchar(10))
	PRINT 'Today you are ' + cast(@y AS varchar(4)) + ' years, ' + cast(@m AS varchar(2)) + ' months and ' + cast(@d AS varchar(2)) + ' days old.'
END
--Usage:
EXEC AgeCalculator
EXEC AgeCalculator '2023-03-07'

----------------------

--if the current season/month is a summer month (Apr-Aug), list Sales employees who work with European region
--otherwise list employees from the Australian region:
If MONTH(GETDATE()) >= 4 AND MONTH(GETDATE()) <= 8
BEGIN
	SELECT ename, jobtitle, e.did, d.deptname 
	FROM emp e
		JOIN dept d ON e.did = d.did
		JOIN region r ON e.rid = r.rid
	WHERE RegionName = 'Europe'
		AND jobtitle LIKE '%Sale%'
END
ELSE
BEGIN
	SELECT ename, jobtitle, e.did, d.deptname 
	FROM emp e
		JOIN dept d ON e.did = d.did
		JOIN region r ON e.rid = r.rid
	WHERE RegionName = 'Australias'
		AND jobtitle LIKE '%Sale%'
END

--Using If..Else:
DECLARE @x INT
SET @x = 0
IF (@x > 0)
	PRINT 'True'
ELSE
	PRINT 'False'

--Table type variable example:
DECLARE @y TABLE
(
	id		int,
	name    varchar(256)
)
INSERT INTO @y (id,name)
VALUES (1, 'John')
SELECT * FROM @y
----------------------


--Using simple While loop print numbers from 1 to 10, skipping the number 5:
DECLARE @i INT = 0
WHILE @i < 10
BEGIN 
	SET @i = @i + 1
	IF @i = 5
		CONTINUE;

	PRINT @i
END


--Write a stored proc that uses While loop to check whether or not the given number/int (passed in as a parameter) is a prime number.
-- % is a modulus operator, returns remainder. 12%10 = 2   9%3=0
CREATE PROC PrimeNumberCheck (@n INT)
AS
BEGIN
	DECLARE @i INT = @n / 2
	DECLARE @isPrime BIT = 1
	WHILE @i >= 2
	BEGIN
		IF @n % @i = 0
		BEGIN 
			SET @isPrime = 0
			BREAK;
		END
		SET @i = @i - 1
	END

	IF @isPrime = 1
		PRINT 'Yes, ' + cast(@n as varchar(40))  + ' is a Prime number.';
	ELSE
		PRINT 'No, ' + cast(@n as varchar(40))  + ' is NOT a Prime number.';

END
--Usage:
EXEC PrimeNumberCheck @n = 12
EXEC PrimeNumberCheck 5

----------------------

--List all employees along with their line-manager names:
--Using Self-Join:
select e.eid, e.ename, e.jobtitle, e.managerid, m.ename
from emp e
	join emp m ON e.managerid=m.eid;

--Using Inner-Query:
select e.eid, e.ename, e.jobtitle, e.managerid, mgr_name = (select m.ename from emp m where e.managerid=m.eid)
from emp e


/*Note: SQL provides 3 set operators:
1) UNION: Combine all results from two query blocks into a single result, omitting any duplicates.
2) INTERSECT: Combine only those rows which the results of two query blocks have in common, omitting any duplicates.
3) EXCEPT: For two query blocks A and B, return all results from A which are not also present in B, omitting any duplicates.
*/

--Using CTE and SET operator (UNION/EXCEPT), list all emp names NOT managed by "Kylie" & "Bob":
SELECT * FROM emp WHERE managerid NOT IN (68319, 66928)

--Using CTE and SET operator:
;WITH cte AS ( SELECT * FROM emp WHERE managerid IN (68319, 66928) )
SELECT * FROM emp
EXCEPT
SELECT * FROM cte


--Create a Simple Cursor to print all employees who work with Sales (not limited to the Sales department),
-- display only 2 columns: Employee-Names and Department-Names.
DECLARE @n VARCHAR(99)
DECLARE @d VARCHAR(99)
DECLARE cur_Emps_in_Sales CURSOR
FOR
	SELECT e.ename, d.DeptName FROM emp e
	JOIN dept d ON e.did=d.did
	WHERE e.jobtitle LIKE 'Sale%'

OPEN cur_Emps_in_Sales
FETCH NEXT FROM cur_Emps_in_Sales INTO @n, @d
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @n + ', ' + @d
	FETCH NEXT FROM cur_Emps_in_Sales INTO @n, @d
END
CLOSE cur_Emps_in_Sales
DEALLOCATE cur_Emps_in_Sales
----------------

--Write a simple Cursor to list all employees from the Sales department and 
--list their: names, jobtile, salary and commission.
DECLARE @name VARCHAR(99)
DECLARE @team VARCHAR(99)
DECLARE @salary VARCHAR(99)
DECLARE @commission VARCHAR(99)

DECLARE EmpTeam CURSOR
FOR 
	SELECT ename, jobtitle, salary, commission FROM emp WHERE did=30  --30 is Sales dept.
BEGIN
	OPEN  EmpTeam
	FETCH EmpTeam INTO @name, @team, @salary, @commission
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Employee: ' + @name
		PRINT 'Job Title: ' + @team
		PRINT 'Salary: ' + @salary
		PRINT 'Commissions: ' + @commission
		PRINT '--------------'
		PRINT ''
		FETCH EmpTeam INTO @name, @team, @salary, @commission
	END
	CLOSE EmpTeam
END
DEALLOCATE EmpTeam

------------------------


--Create a copy of 'emp' table as a temporary table ("##Emp2") with an 
--additinal column called "Commision_Amount" that should be populated with 
--the same value as in "Commission" column.


--SELECT..INTO: quickest way to create a copy of a table:
SELECT *, commission AS [Commision_Amount] INTO ##Emp2 FROM emp
select * from ##Emp2
--Check if table created as expected:
use tempdb
exec sp_help '##Emp2'

use Employee
/* Create a Cursor that inserts values into the new column [Commision_Amount] as created above in the "##Emp2" table: 
	1) For employees with non-zero/not-null values in the "Commission%" column, insert: [Salary]*[Commission%].
	2) For employees who work in "Tech" department, insert: £10 (flat/fixed value).
	3) For other employees (who are neither in "Tech" department nor have any "Commission%"), insert: 0.
*/
DECLARE @eid INT
DECLARE @ename VARCHAR(99)
DECLARE @dname VARCHAR(99)
DECLARE @sal MONEY
DECLARE @comm MONEY
DECLARE cur_Emps_Salary_Comm CURSOR
FOR
	SELECT e.eid, e.ename, d.DeptName, e.salary, e.Commision_Amount
	FROM ##Emp2 e JOIN dept d ON e.did = d.did
OPEN cur_Emps_Salary_Comm
FETCH NEXT FROM cur_Emps_Salary_Comm INTO @eid, @ename, @dname, @sal, @comm
WHILE @@FETCH_STATUS = 0
BEGIN
	IF ltrim(@dname) LIKE 'Tech%'
		UPDATE ##Emp2 SET Commision_Amount = 10.0 WHERE eid = @eid
	ELSE
		IF ISNULL(@comm,0) = 0
			UPDATE ##Emp2 SET Commision_Amount = 0 WHERE eid = @eid
		ELSE
			UPDATE ##Emp2 SET Commision_Amount = CAST(@sal AS decimal(9,2)) * ISNULL(@comm,0)  WHERE eid = @eid
	PRINT cast(@eid as varchar(99)) + ', ' +  @ename + ', ' +  ltrim(@dname) + ', ' +  cast(@sal as varchar(99)) + ', ' +  cast(ISNULL(@comm,0) as varchar(99))
	FETCH NEXT FROM cur_Emps_Salary_Comm INTO @eid, @ename, @dname, @sal, @comm
END
CLOSE cur_Emps_Salary_Comm  
DEALLOCATE cur_Emps_Salary_Comm

----------------------------


--Write a simple Try..Catch block to handle error gracefully:
BEGIN TRY
    PRINT 1/0;  -- Generating divide-by-zero error.
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber  		--=> 8134
        ,ERROR_SEVERITY() AS ErrorSeverity		--=> 16
        ,ERROR_STATE() AS ErrorState		--=> 1
        ,ERROR_PROCEDURE() AS ErrorProcedure	--=> NULL
        ,ERROR_LINE() AS ErrorLine			--=> 3
        ,ERROR_MESSAGE() AS ErrorMessage;		--=> Divide by zero error encountered.
END CATCH;


-- Create another temporary table called "##Emp3" by copying of "Emp" table with an 
-- additinal column called "Bonus" that should be populated with NULLs, and
-- add another column called "Commision_Amount" populated with "salary * commission", and/or zero if "commission" is NULL.

select *, (salary * isnull(commission,0)) [Commision_Amount], NULL AS [Bonus]  INTO ##Emp3 from emp  --Create copy of table with additional column.
select * from ##Emp3   --Check if table created as expected.

/* Create a stored proc that inserts values into the newly created column "Bonus" (within the "##Emp3" table) as below:
	1) in the "Bonus" column store [Salary]/[Commision_Amount]
	2) Use Try..Catch block to trap any errors (divide by zero) and deal with errors gracefully (to show appropriate error message).
When called, the stored proc should list all employees along with a newly populated "Bonus" column.
*/
--DROP PROC CalcBonus
CREATE PROC CalcBonus
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @eid INT
	DECLARE @sal MONEY
	DECLARE @comm MONEY
	DECLARE @bonus MONEY

	DECLARE cur_Emps_Bonus CURSOR 
	FOR
		SELECT e.eid, e.salary, e.Commision_Amount, e.Bonus
		FROM ##Emp3 e
	OPEN cur_Emps_Bonus
	FETCH NEXT FROM cur_Emps_Bonus INTO @eid, @sal, @comm, @bonus
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			IF ISNULL(@bonus,0) = 0
				UPDATE ##Emp3 SET Bonus = CAST(@sal AS decimal(9,2)) / ISNULL(@comm,0) WHERE eid = @eid
			PRINT cast(@eid as varchar(99)) + ', ' + cast(@sal as varchar(99)) + ', ' +  cast(ISNULL(@comm,0) as varchar(99))+ ', ' +  cast(ISNULL(@bonus,0) as varchar(99))
			FETCH NEXT FROM cur_Emps_Bonus INTO @eid, @sal, @comm, @bonus
		END TRY
		BEGIN CATCH
			PRINT CAST(@eid AS VARCHAR(9)) + ' eid: ' + CAST(ERROR_NUMBER() AS VARCHAR(9)) + ': ' + ERROR_MESSAGE()
			FETCH NEXT FROM cur_Emps_Bonus INTO @eid, @sal, @comm, @bonus
		END CATCH
	END
	CLOSE cur_Emps_Bonus  
	DEALLOCATE cur_Emps_Bonus

	Select * from ##Emp3
	SET NOCOUNT OFF
END
--Call:
EXEC CalcBonus


---------------------------

--Date handling examples:
PRINT getdate()  -- today's date.

--Manipulating date by creating new date object:
DECLARE @t DATE, @dt DATE = getdate()
SET @t = DATEFROMPARTS(2000, 12, 29)
--SET @t = DATEFROMPARTS(DATEPART(YEAR, getdate()), 12, 29)

--Formatting of date:
print format(@t, 'dd-MM-yyyy')
print format(@t, 'dd-MMM-yyyy')
print format(@t, 'dd-MMMM-yyyy')
print datediff(YEAR, @t, @dt)

print (DATEPART(Month, getdate()))

PRINT MONTH(getdate())


