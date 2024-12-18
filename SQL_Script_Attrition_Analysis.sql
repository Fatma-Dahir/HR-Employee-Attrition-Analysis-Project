-- DATA CLEANING
-- Check for null values in all columns
SELECT 
    SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) AS Id_Null,
    SUM(CASE WHEN First_name IS NULL THEN 1 ELSE 0 END) AS First_Name_Null,
    SUM(CASE WHEN Last_name IS NULL THEN 1 ELSE 0 END) AS Last_name_Null,
    SUM(CASE WHEN Birthdate IS NULL THEN 1 ELSE 0 END) AS Birthdate_Null,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Gender_Null,
    SUM(CASE WHEN Race IS NULL THEN 1 ELSE 0 END) AS Race_Null,
    SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END) AS Department_Null,
    SUM(CASE WHEN Jobtitle IS NULL THEN 1 ELSE 0 END) AS Jobtitle_Null,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS Location_Null,
    SUM(CASE WHEN Hire_date IS NULL THEN 1 ELSE 0 END) AS Hire_date_Null,
    SUM(CASE WHEN Termdate IS NULL THEN 1 ELSE 0 END) AS Termdate_Null,
    SUM(CASE WHEN Location_city IS NULL THEN 1 ELSE 0 END) AS Location_city_Null,
    SUM(CASE WHEN Location_state IS NULL THEN 1 ELSE 0 END) AS Location_state_Null
FROM data;

-- Check for Duplicates across all columns
SELECT 
    Id, COUNT(*) AS Duplicate_Count
FROM data
GROUP BY 
    Id, First_name, Last_name, Birthdate, Gender, Race, Department, Jobtitle, Location, 
    Hire_date, Termdate, Location_city, Location_state
HAVING COUNT(*) > 1;

-- Create a New Table with Distinct Rows (Deduplicated)
CREATE TABLE new_table AS
SELECT DISTINCT *
FROM data;

-- Drop the old table (data) after creating the new deduplicated table
DROP TABLE data;

-- Rename the new table to the original table name (data)
RENAME TABLE new_table TO data;

-- STANDARDIZE DATA
-- Check if any trim is required or misspelt words and Modify
SELECT DISTINCT Location_city
FROM data
Order by 1;

SELECT DISTINCT Jobtitle
FROM data
Order by 1;

-- Modify Misspelt words
UPDATE data
SET Location_city = 'Jeffersonville'
WHERE Location_city = 'JefFrsonville';

UPDATE data
SET Jobtitle = 'Assistant Professor'
WHERE Jobtitle = 'Assistant ProFssor';

UPDATE data
SET Jobtitle = 'Associate Professor'
WHERE Jobtitle = 'Associate ProFssor';

-- Modify Gender Column
UPDATE data
SET Gender =  CASE
			  WHEN Gender = 'M' THEN 'Male'
              WHEN Gender = 'FM' THEN 'Female'
              ELSE 'Non-Conforming'
              END;
              
-- Merge First and Last Name into a new column - Full Name
ALTER TABLE data
ADD Full_Name VARCHAR (200) AFTER Id;

UPDATE data
SET Full_Name = CONCAT(First_Name, ' ', Last_Name);

ALTER TABLE data
DROP COLUMN First_name,
DROP COLUMN Last_name;

-- Convert data type to date for column Hire_date
SELECT *
FROM data;

UPDATE data
SET Hire_date = STR_TO_DATE(Hire_date,"%d-%m-%Y");

ALTER TABLE data
Modify Hire_date DATE;

-- Convert data type to date for column Birthdate
UPDATE data
SET Birthdate = STR_TO_DATE(Birthdate,"%d-%m-%Y");

ALTER TABLE data
Modify Birthdate DATE;

-- First create a new termdate column, Insert values then Convert data type to date for column Termdate
ALTER TABLE data
ADD Termdate1 TEXT AFTER Termdate ;

-- Insert values into the column
UPDATE data
SET Termdate1 = LEFT(Termdate, 10);

-- Delete column Termdate
ALTER TABLE data
DROP COLUMN Termdate;

-- Rename new column to Termdate
ALTER TABLE data
RENAME COLUMN Termdate1 TO Termdate;

UPDATE data
SET Termdate = NULL WHERE Termdate = 0;

-- Convert the column data type from string to date
UPDATE data
SET Termdate = STR_TO_DATE(Termdate, "%Y-%m-%d")
WHERE Termdate IS NOT NULL;

ALTER TABLE data
MODIFY COLUMN Termdate DATE;

-- ANALYSIS
-- Calculate Total number of Employees
SELECT COUNT(Id) AS Total_Employees
FROM data;

-- Calculate Total number of Departments
SELECT COUNT(DISTINCT Department) AS Total_Department
FROM data;

-- Calculate Total number of Race
SELECT COUNT(DISTINCT Race) AS Total_Race
FROM data;

-- Calculate Total number of Job Titles
SELECT COUNT(DISTINCT Jobtitle) AS Total_Jobtitle
FROM data;

-- Calculate Tenure
ALTER TABLE data
ADD Tenure INT AFTER Termdate;

UPDATE data
SET Tenure = CASE
				WHEN Termdate IS NOT NULL THEN timestampdiff(YEAR, Hire_date, Termdate)
				WHEN Termdate IS NULL OR Termdate >='2024-10-09' THEN timestampdiff(YEAR, Hire_date, '2024-10-09')
			 END;

ALTER TABLE data
ADD TermYear INT AFTER Termdate;

ALTER TABLE data
ADD HiredYear INT AFTER Hire_date;

UPDATE data
SET TermYear = LEFT(Termdate,4)
WHERE Termdate IS NOT NULL;

UPDATE data
SET HiredYear = LEFT(Hire_date,4);

-- Calculate Employee Status
ALTER TABLE data
ADD COLUMN Employee_Status VARCHAR (50) AFTER Tenure;

UPDATE data
SET Employee_Status = CASE
	WHEN Termdate IS NULL OR Termdate > '2024-10-09' THEN 'Active'
	ELSE 'Terminated'
END;

-- Calculate Hired Age
ALTER TABLE data
ADD Hired_Age INT AFTER Termdate;

UPDATE data
SET Hired_Age = timestampdiff(YEAR, Birthdate, Hire_date );

-- check for outliers in hired age column
SELECT *
FROM data
WHERE Hired_Age < 14;

-- Remove Outliers 
DELETE
FROM data
WHERE Hired_Age in (
      SELECT Hired_Age
      FROM (
      SELECT *
      FROM data
      WHERE Hired_Age < 14) as subquery
      );

-- Calculate Working Age
ALTER TABLE data
ADD COLUMN Working_Age TEXT;

UPDATE data
SET Working_Age = CASE
	WHEN Hired_Age < 18 THEN 'Underage'
    WHEN Hired_Age > 65 THEN 'Overage'
    ELSE 'Normal Age'
END;

-- Average Tenure of Terminated Employees
SELECT AVG(Tenure) AS Avg_Tenure
FROM data
WHERE Employee_Status = 'Terminated';

-- Employee Attrition by Department
 SELECT Department,
        COUNT(CASE WHEN Employee_Status = 'Active' THEN 1 END) AS Active,
        COUNT(CASE WHEN Employee_Status = 'Terminated' THEN 1 END) AS Terminateed
FROM data
GROUP BY Department
ORDER BY Department;

-- Employee Attrition Rate by Department
SELECT Department, 
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND((SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)/ COUNT(*)) *100,2) AS Attrition_Rate
FROM data
GROUP BY Department
ORDER BY Attrition_Rate DESC;

-- Employee Attrition Rate by Job title
SELECT Jobtitle, 
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND((SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)/ COUNT(*)) *100,2) AS Attrition_Rate
FROM data
GROUP BY Jobtitle
ORDER BY Attrition_Rate DESC;

-- Employee Attrition Rate by Gender
SELECT Gender, 
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND((SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)/ COUNT(*)) *100,2) AS Attrition_Rate
FROM data
GROUP BY Gender
ORDER BY Attrition_Rate DESC;

-- Employee Attrition Rate by Race
SELECT Race, 
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND((SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)/ COUNT(*)) *100,2) AS Attrition_Rate
FROM data
GROUP BY Race
ORDER BY Attrition_Rate DESC;

-- Employee Attrition Rate by Location
SELECT Location, 
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND((SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)/ COUNT(*)) *100,2) AS Attrition_Rate
FROM data
GROUP BY Location
ORDER BY Attrition_Rate DESC;

-- Employee Attrition Rate by Location State
SELECT Location_state, 
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND((SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)/ COUNT(*)) *100,2) AS Attrition_Rate
FROM data
GROUP BY Location_state
ORDER BY Attrition_Rate DESC;

-- Employee Attrition Rate by Working Age
SELECT Working_Age, 
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND((SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)/ COUNT(*)) *100,2) AS Attrition_Rate
FROM data
GROUP BY Working_Age
ORDER BY Attrition_Rate DESC;

-- Add Employee Attrition RATES into the data table
ALTER TABLE data
ADD COLUMN  Dept_AttritionRate FLOAT,
ADD COLUMN  Gender_AttritionRate FLOAT,
ADD COLUMN  JobTitle_AttritionRate FLOAT,
ADD COLUMN  Location_AttritionRate FLOAT,
ADD COLUMN  Race_AttritionRate FLOAT,
ADD COLUMN  LocationBased_AttritionRate FLOAT,
ADD COLUMN  WorkingAge_AttritionRate FLOAT;

-- Employee Attrition Rate Department
WITH CTE AS
(
SELECT Department,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Attrition_rate
       FROM data
       GROUP BY Department
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Department = CTE.Department 
SET data.Dept_AttritionRate = CTE.Attrition_rate;


-- Employee Attrition Rate by Race
WITH CTE AS
(
SELECT Race,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Attrition_rate
       FROM data
       GROUP BY Race
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Race = CTE.Race
SET data.Race_AttritionRate = CTE.Attrition_rate;

-- Employee Attrition Rate by Working_Age
WITH CTE AS
(
SELECT Working_Age,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Attrition_rate
       FROM data
       GROUP BY Working_Age
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Working_Age = CTE.Working_Age
SET data.WorkingAge_AttritionRate = CTE.Attrition_rate;

-- Employee Attrition rate by Jobtitle 
WITH CTE AS
(
SELECT Jobtitle,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Attrition_rate
       FROM data
       GROUP BY Jobtitle
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Jobtitle = CTE.Jobtitle
SET data.JobTitle_AttritionRate = CTE.Attrition_rate;

-- Employee Attrition by Location
WITH CTE AS
(
SELECT Location,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Attrition_rate
       FROM data
       GROUP BY Location
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Location = CTE.Location
SET data.Location_AttritionRate = CTE.Attrition_rate;

-- Employee Attrition by Gender
WITH CTE AS
(
SELECT Gender,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Attrition_rate
       FROM data
       GROUP BY Gender
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Gender = CTE.Gender
SET data.Gender_AttritionRate = CTE.Attrition_rate;

-- Employee Attrition by Location Based
WITH CTE AS
(
SELECT Location_state,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Terminated' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Attrition_rate
       FROM data
       GROUP BY Location_state
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Location_state = CTE.Location_state
SET data.LocationBased_AttritionRate = CTE.Attrition_rate;

-- Calculate Retention Rate by Job Title
SELECT Jobtitle, COUNT(*) AS Total_Employees,
       (CAST(SUM(CASE WHEN Employee_Status = 'Active' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*)) AS Retention_Rate
       FROM data
       GROUP BY Jobtitle
       ORDER BY Retention_Rate DESC;

-- Calculate Retention Rate by Department
SELECT Department, COUNT(*) AS Total_Employees,
       (CAST(SUM(CASE WHEN Employee_Status = 'Active' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*)) AS Retention_Rate
       FROM data
       GROUP BY Department
       ORDER BY Retention_Rate DESC;
       
-- Add Employee Retention Rate by Department into the data table
ALTER TABLE data
ADD COLUMN Dept_RetentionRate FLOAT;

WITH CTE AS
(
SELECT Department,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Active' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Retention_Rate
       FROM data
       GROUP BY Department
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Department = CTE.Department 
SET data.Dept_RetentionRate = CTE.Retention_rate;

-- Employee Retention Rate by Jobtitle
ALTER TABLE data
ADD COLUMN JobTitle_RetentionRate FLOAT;

WITH CTE AS
(
SELECT Jobtitle,
       ROUND(CAST(SUM(CASE WHEN Employee_Status = 'Active' THEN 1 ELSE 0 END)AS FLOAT) *100 / COUNT(*),2) AS Retention_Rate
       FROM data
       GROUP BY Jobtitle
)

UPDATE tdi_project.data
JOIN CTE 
ON data.Jobtitle = CTE.Jobtitle 
SET data.JobTitle_RetentionRate = CTE.Retention_rate;

-- Departments Working Age Count with gender
SELECT Department, Gender,
       COUNT(CASE WHEN Working_Age = 'Underage' THEN 1 END) AS Total_Underaged,
       COUNT(CASE WHEN Working_Age = 'Normal Age' THEN 1 END) AS Total_NormalAged
FROM data
GROUP BY Department, Gender
ORDER BY Total_Underaged DESC;

-- Jobtitle Working Age Count with gender
SELECT Jobtitle, Gender,
       COUNT(CASE WHEN Working_Age = 'Underage' THEN 1 END) AS Total_Underaged,
       COUNT(CASE WHEN Working_Age = 'Normal Age' THEN 1 END) AS Total_NormalAged
FROM data
GROUP BY Jobtitle, Gender
ORDER BY Total_Underaged DESC;

-- Jobtitle & Departments with Tenure < 1
SELECT Jobtitle, Department,
       COUNT(CASE WHEN Tenure < 1 THEN 1 END) AS Total_Employees
FROM data
GROUP BY Jobtitle, Department
ORDER BY Total_Employees DESC;

 -- Highest Tenure (>=23) by Jobtitles and Department
 SELECT Jobtitle, Department, Tenure,
       COUNT(CASE WHEN Tenure >=23 THEN 1 END) AS Total_Employees
FROM data
GROUP BY Jobtitle, Department, Tenure
ORDER BY Total_Employees DESC;