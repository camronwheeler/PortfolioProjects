-- Create tables from information based on characters from "The Office"

-- This table includes each employee's employee ID, first name, last name, age, and gender
CREATE TABLE EmployeeDemographic
(
EmployeeID int, 
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
);

-- This table includes each employee's employee ID, job title, and salary
CREATE TABLE EmployeeSalary
(
EmployeeID int,
JobTitle varchar(50),
Salary varchar(50)
);

-- This table includes the employee ID, first name, last name, age, and gender of employees in the warehouse
CREATE TABLE WarehouseEmployeeDemographic
(
EmployeeID int,
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
)

-- Insert data into previously created tables

INSERT INTO EmployeeDemographic VALUES
(1001, 'Jim', 'Halpert', 30, 'Male'),
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male');

INSERT INTO EmployeeSalary VALUES
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 48000),
(1009, 'Accountant', 42000);

INSERT INTO WarehouseEmployeeDemographic VALUES
(1013, 'Darryl', 'Philbin', NULL, 'Male'),
(1050, 'Roy', 'Anderson', 31, 'Male'),
(1051, 'Hidetoshi', 'Hasagawa', 40, 'Male'),
(1052, 'Val', 'Johnson', 31, 'Female');

DROP TABLE EmployeeDemographic;
DROP TABLE EmployeeSalary;

-- Beginner Queries - SELECT, FROM, WHERE, GROUP BY, ORDER BY

SELECT *
FROM EmployeeDemographic;

SELECT *
FROM EmployeeSalary;

SELECT *
FROM WarehouseEmployeeDemographic;

SELECT LastName
FROM EmployeeDemographic
LIMIT 5;

SELECT *
FROM EmployeeDemographic
WHERE LastName LIKE 'S%o%';

SELECT Gender, COUNT(Gender) as GenderCount
FROM EmployeeDemographic
WHERE Age > 30
GROUP BY Gender
ORDER BY GenderCount;

-- Joins, Unions, Case Statements, Updating/Deleting Data, Partition By, Data Types, Aliasing, Creating Views, HAVING vs GROUP BY, GETDATE(),Primary Key vs Foreign Key
SELECT demo.EmployeeID, demo.FirstName, demo.LastName, sal.JobTitle, sal.Salary
FROM EmployeeDemographic as demo INNER JOIN EmployeeSalary as sal
ON demo.EmployeeID = sal.EmployeeID
WHERE FirstName <> 'Michael'
ORDER BY Salary DESC;

SELECT sal.JobTitle, AVG(Salary)
FROM EmployeeDemographic as demo INNER JOIN EmployeeSalary as sal
ON demo.EmployeeID = sal.EmployeeID
WHERE JobTitle = 'Salesman'
GROUP BY JobTitle;

SELECT *
FROM EmployeeDemographic
UNION
SELECT *
FROM WarehouseEmployeeDemographic;

SELECT EmployeeID, FirstName, Age
FROM EmployeeDemographic
UNION
SELECT EmployeeID, JobTitle, Salary
FROM EmployeeSalary
ORDER BY EmployeeID;

SELECT FirstName, LastName, Age,
CASE
	WHEN AGE > 30 THEN 'Old'
    WHEN Age BETWEEN 27 AND 30 THEN 'Young'
    ELSE 'Baby'
END as YoungOld
FROM EmployeeDemographic
WHERE Age IS NOT NULL
ORDER BY Age;

SELECT FirstName, LastName, JobTitle, Salary,
CASE
	WHEN JobTitle = 'Salesman' THEN Salary + (Salary * .10)
    WHEN JobTitle = 'Accounant' THEN Salary + (Salary * .05)
    WHEN JobTitle = 'HR' THEN Salary + (Salary * .01)
    ELSE Salary + (Salary * .03)
END as SalaryAfterRaise
FROM EmployeeDemographic as demo JOIN EmployeeSalary as sal
ON demo.EmployeeID= sal.EmployeeID;

SELECT JobTitle, COUNT(JobTitle) as JobTitleCount
FROM EmployeeDemographic as demo JOIN EmployeeSalary as sal
ON demo.EmployeeID = sal.EmployeeID
GROUP BY JobTitle
HAVING COUNT(JobTitle) > 1;

SELECT JobTitle, AVG(Salary) as AvgSalary
FROM EmployeeDemographic as demo JOIN EmployeeSalary as sal
ON demo.EmployeeID = sal.EmployeeID
GROUP BY JobTitle
HAVING AVG(Salary) > 45000
ORDER BY AVG(Salary);

UPDATE EmployeeDemographic
SET Age = 31, Gender = 'Female'
WHERE FirstName = 'Holly' AND LastName = 'Flax';

DELETE FROM EmployeeDemographic
WHERE EmployeeID = 1111;

SELECT CONCAT(FirstName,' ', LastName) as FullName
FROM EmployeeDemographic;

SELECT FirstName, LastName, Gender, Salary, COUNT(Gender) OVER (PARTITION BY Gender) as TotalGender
FROM EmployeeDemographic as demo JOIN EmployeeSalary as sal
ON demo.EmployeeID = sal.EmployeeID;

-- CTEs, SYS Tables, Subqueries, Temp Tables, String Functions, Regular Expression, Stored Procedures, Importing/Exporting Data

WITH CTE_Employee as 
(SELECT FirstName, LastName, Gender, Salary, 
COUNT(Gender) OVER (PARTITION BY Gender) as TotalGender,
AVG(Salary) OVER (PARTITION BY Gender) as AvgSalary
FROM EmployeeDemographic demo JOIN EmployeeSalary sal
	ON demo.EmployeeID = sal.EmployeeID
WHERE Salary > 45000)
SELECT FirstName, AvgSalary
FROM CTE_Employee;

CREATE TEMPORARY TABLE temp_Employee (
EmployeeID int,
JobTitle varchar(100),
Salary int
);

INSERT INTO temp_Employee
SELECT *
FROM EmployeeSalary;

CREATE TEMPORARY TABLE temp_Employee2 (
JobTitle varchar(50), 
EmployeesPerJob int,
AvgAge int,
AvgSalary int);

DROP TABLE IF EXISTS temp_Employee2;
INSERT INTO temp_Employee2 
SELECT JobTitle, COUNT(JobTitle), Avg(Age), AVG(salary)
FROM EmployeeDemographic demo JOIN EmployeeSalary sal
	ON demo.EmployeeID = sal.EmployeeID
GROUP BY JobTitle;

SELECT *
FROM temp_Employee2;

-- This table is used to show string functions on records to display them differently
DROP TABLE IF EXISTS EmployeeErrors;
CREATE TABLE EmployeeErrors (
EmployeeID int,
FirstName varchar(50),
LastName varchar(50)
);

ALTER TABLE EmployeeErrors
MODIFY COLUMN EmployeeID varchar(50);

INSERT INTO EmployeeErrors VALUES
('1001 ', 'Jimbo', 'Halbert'),
(' 1002', 'Pamela', 'Beasely'),
('1005', 'T0by', 'Flenderson - Fired');

SELECT *
FROM EmployeeErrors;

SELECT EmployeeID, TRIM(EmployeeID) as IDTRIM
FROM EmployeeErrors;

SELECT EmployeeID, LTRIM(EmployeeID) as IDTRIM
FROM EmployeeErrors;

SELECT EmployeeID, RTRIM(EmployeeID) as IDTRIM
FROM EmployeeErrors;

SELECT LastName, REPLACE(LastName, '- Fired', '') as LastNameFixed
FROM EmployeeErrors;

SELECT SUBSTRING(FirstName, 3, 3)
FROM EmployeeErrors;

SELECT SUBSTRING(err.FirstName, 1, 3), SUBSTRING(demo.FirstName, 1, 3)
FROM EmployeeErrors err JOIN EmployeeDemographic demo
	ON SUBSTRING(err.FirstName, 1, 3) = SUBSTRING(demo.FirstName, 1, 3);

SELECT FirstName, LOWER(FirstName)
FROM EmployeeErrors;

SELECT FirstName, UPPER(FirstName)
FROM EmployeeErrors;

DELIMITER //

CREATE PROCEDURE TEST()
BEGIN
	SELECT *
	FROM EmployeeDemographic;
END //

DELIMITER ;
CALL TEST();

DELIMITER //

CREATE PROCEDURE Temp_Employee()
BEGIN
	DROP TABLE IF EXISTS temp_Employee;
	CREATE TEMPORARY TABLE temp_Employee (
		JobTitle varchar(100),
		EmployeesPerJob int,
		AvgAge int,
		AvgSalary int
	);
    
	INSERT INTO temp_Employee
	SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(salary)
	FROM EmployeeDemographic demo JOIN EmployeeSalary sal
	ON demo.EmployeeID = sal.EmployeeID
	GROUP BY JobTitle;
END //

DELIMITER ;
CALL Temp_Employee();
SELECT *
FROM temp_Employee;

SELECT *
FROM EmployeeSalary;

-- Subquery in SELECT
SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM EmployeeSalary) as AllAvgSalary
FROM EmployeeSalary;

SELECT EmployeeID, Salary, AVG(Salary) OVER () as AllAvgSalary
FROM EmployeeSalary;

-- Subquery in FROM
SELECT *
FROM (SELECT EmployeeID, Salary, AVG(Salary) OVER () as AllAvgSalary
	FROM EmployeeSalary) as dt_employee;
    
-- Subquery in WHERE
SELECT EmployeeID, JobTitle, Salary
FROM EmployeeSalary
WHERE EmployeeID IN (SELECT EmployeeID
	FROM EmployeeDemographic
    WHERE Age > 30);