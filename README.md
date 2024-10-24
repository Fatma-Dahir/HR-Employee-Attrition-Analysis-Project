# 📊 HR Employee Attrition Analysis Project

## Table of Contents
- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results & Findings](#results--findings)
- [Recommendations](#Recommendations)
- [Limitations](#limitations)

## Project Overview
This is a HR Attrition Analysis Project for Panama Limited, a Financial Technology Company. It includes data cleaning, exploratory analysis and visualizations to identify the key factors contributing to high employee attrition and provide actionable recommendations to reduce turnover. Advanced SQL techniques were employed for data cleaning and analysis, while Excel was used for visualizations.

## Data Sources
The primary dataset used for this analysis is the "HR_Data.csv" file, which contains detailed information about each employee in the company.

## Tools
- MySQL Workbench - Data Cleaning and Analysis [Download Here](https://dev.mysql.com/downloads/installer/)
- Excel - Data Visualization [Download Here](https://www.microsoft.com/)

## Data Cleaning
In this phase, I performed the following tasks:
1. Imported the HR Data into MySQL Workbench using the Import Table Wizard
2. Handled duplicate values
3. Standardized the data

## Exploratory Data Analysis
EDA involved exploring the data to answer key questions such as:
- Which departments, Job titles, Gender, Race, Age and Locations are affected by attrition and what are their attrition rates?
- At what ages were the employees hired? Could there be any under-aged employees?
- Which departments and job titles have underage employees(below 18years) and how many are they?
- What is the attrition rate comparison between underaged employees and normal aged employees?
- What are the departments and job titles with highest retention rates?
- What is the average tenure of terminated employees?
- How many employees in each job title have a tenure of less than 1 year? What are the issues causing that?
- Which current employees have stayed the longest in the company and what departments and job titles are they in? What can we learn from them?
- What measures to take to reduce employee attrition?

## Data Analysis
### Key SQL Queries
In this project, I performed various SQL queries to analyze employee attrition data. Below are some key queries: 
- This query adds the calculated attrition rate by department into the table containing the Employee data
 ```sql
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
```
- This query results to the job titles with the highest count of underaged employees (between 14-18 years) appear at the top along side with the gender. It also retrieves total count of normal aged employees (between 18-65 years) within those departments
```sql
SELECT Jobtitle, Gender,
       COUNT(CASE WHEN Working_Age = 'Underage' THEN 1 END) AS Total_Underaged,
       COUNT(CASE WHEN Working_Age = 'Normal Age' THEN 1 END) AS Total_NormalAged
FROM data
GROUP BY Jobtitle, Gender
ORDER BY Total_Underaged DESC;
```

## Results & Findings
I conducted the analysis using SQL and got the following results:
- Total Number of Employees (22214),  Departments(13),  Job titles(184),  Race(7)
- Auditing Department has the highest attrition rate of 17.07%
- Employees who work at the Headquarters have the highest attrition rate of 11.02% as compared to those who work remotely
- 88% of Employees were above 18 years when hired and 12% were underaged
- Employees who joined Panama limited as under-aged (below 18 years) have the highest attrition rate of 13.25% as compared to the normal aged-10.57% .This is a high indicator to the company to not hire under-aged employees as it contributes to attrition among other factors
- Employees who come from Michigan have the highest attrition rate of 11.72%
- Job Titles Statistician IV, Sales Associate and Executive Secretary have the highest attrition rate of 50%
- Female gender has the highest attrition rate of 11.35%.
- Native Hawaiian or Other Pacific Islander have the highest attrition rate of 14.41%
- Marketing department has the highest retention rate of 91.24%
- Marketing Manager among other Job titles have 100% retention rate 
- Average Tenure of Terminated Employees is 7.1 years
- Job titles such as Business Analyst have tenure < 1 and Research Assistant II among others have tenure > 23

## Recommendations
Based on the analysis, I recommend the following:
- Panama Limited should avoid employing underage employees(below 18 years). This is an issue that could be contributing to the high attrition as the employees are too young to work effectively and also not qualified to meet the job requirements.
- The company should look into departments and job titles with high attrition rates and tenure of <1 year and find out what could be causing employees to leave
- It should also analyze departments and job titles with high retention rates and tenure of 23 years get insights as to why they stay. This will help them apply the same strategies to the other departments and job titles especially those with high retention rates
- Panama limited should also consider having more remote roles as the analysis showed higher attrition rates among the employees who work at the headquarters
- The company should also find out why employees who come from Michigan have the  highest attrition rate of 11.72%. Is there an issue from that region that causes that?
- The company should also be open to getting job review, satisfaction and rating from the employees. This will help them understand if there are any issues facing the employees and solve them.
- Above all, Panama Limited should create a conducive working environment, salary review, recognize employees for their performances, offer training and career development opportunities 

## Limitations
- Some employee records had negative ages and very young ages below 14 years. These records were treated as outliers and removed from the data



