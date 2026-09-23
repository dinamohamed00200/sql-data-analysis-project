# Cars Data Analysis using SQL Server

## Project Overview

This project focuses on analyzing a cars dataset using SQL Server.

The project covers the complete data analysis process, starting from data
quality assessment and cleaning, followed by database normalization,
dimensional modeling, data analysis, reporting, views, and stored procedures.

## Dataset

The dataset contains information about cars, including:

- Car Name
- MPG
- Cylinders
- Displacement
- Horsepower
- Weight
- Acceleration
- Model Year
- Origin

## Tools & Technologies

- SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL

## Project Steps

### 1. Data Exploration

- Counted total records
- Identified unique cars
- Identified unique origins
- Analyzed origin distribution
- Analyzed model year range
- Calculated MPG, Horsepower, and Weight statistics

### 2. Data Quality Assessment

Checked the dataset for:

- NULL values
- Zero values
- Duplicate records
- Invalid values
- Text formatting issues

### 3. Data Cleaning

Created a cleaned table called `clean_cars`.

The cleaning process included:

- Trimming text fields
- Converting zero values to NULL where appropriate
- Checking missing values
- Validating numeric fields

### 4. Database Normalization

Created a normalized database structure containing:

- `normalized.Origin`
- `normalized.ModelYear`
- `normalized.Car`
- `normalized.VehiclePerformance`

Primary keys and foreign key relationships were also created and validated.

### 5. Star Schema

Designed a Star Schema for analytical reporting.

#### Dimension Tables

- `star.Dim_Car`
- `star.Dim_Origin`
- `star.Dim_ModelYear`

#### Fact Table

- `star.Fact_CarPerformance`

The fact table stores vehicle performance measurements and connects them
to the dimension tables using foreign keys.

### 6. Data Analysis

Performed different analyses, including:

- Average MPG by Origin
- Average Horsepower by Origin
- MPG trends by Model Year
- Average Weight and MPG by Origin
- Top 10 cars by MPG
- Top 10 cars by Horsepower
- Analysis by number of Cylinders
- Cars above average MPG
- Cars above average Horsepower
- Cars above average Weight

### 7. Advanced SQL

The project also includes:

- INNER JOIN
- GROUP BY
- Aggregate Functions
- Subqueries
- CTEs
- CASE Statements
- Views
- Stored Procedures

### 8. Reports

Created SQL reports for:

- Origin Performance
- Model Year Performance
- Cylinder Analysis
- Efficiency Analysis
- Top 10 Overall Cars

### 9. Views

Created reusable views for:

- Car Performance Details
- Origin Performance
- Model Year Performance

### 10. Stored Procedures

Created stored procedures for:

- Getting cars by Origin
- Getting cars by Model Year
- Getting Origin Summary

## Project Structure

```text
sql-data-analysis-project/
│
├── README.md
│
└── Cars_Analysis.sql
