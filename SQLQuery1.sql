--Create Database 
CREATE DATABASE Cars_Analysis;
GO

USE Cars_Analysis;
GO

--Show the Number of Rows
SELECT COUNT(*) AS Total_Rows
FROM raw_cars;

--Preview the data
SELECT *
FROM raw_cars;


--Number of unique cars
SELECT COUNT(DISTINCT Car) AS Total_Cars
FROM raw_cars;


--Number of origins
SELECT
    COUNT(DISTINCT Origin) AS Unique_Origins
FROM raw_cars;

--Origin distribution
SELECT Origin , COUNT(*) AS Car_Count
FROM raw_cars
GROUP BY Origin 
ORDER BY Car_Count DESC;

-------Origin_Model------
SELECT
    Origin_Model,
    COUNT(*) AS Car_Count
FROM dbo.raw_cars
GROUP BY Origin_Model
ORDER BY Car_Count DESC;



--Time_range
SELECT MIN(Model) AS First_Model_Year,
       MAX(Model) AS Last_Model_Year
FROM raw_cars;

--MPG stats
SELECT ROUND(MIN(MPG),2) AS Min_MPG,
       ROUND(MAX(MPG),2) AS Max_MPG,
	   ROUND(AVG(MPG),2) AS Avg_MPG
FROM raw_cars;

--Horsepower stats
SELECT ROUND(MIN(Horsepower),2) AS Min_Horsepower,
       ROUND(MAX(Horsepower),2) AS Max_Horsepower,
	   ROUND(AVG(Horsepower),2) AS Avg_Horsepower
FROM raw_cars;

--Weight stats
SELECT
    ROUND(MIN(Weight),2) AS Min_Weight,
    ROUND(MAX(Weight),2) AS Max_Weight,
    ROUND(AVG(Weight),2) AS Avg_Weight
FROM raw_cars;

------Data Quality Assessment (null_values,zero_values ,duplicate_records) ---------------
---Null_values
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Car IS NULL THEN 1 ELSE 0 END) AS Null_Car,
    SUM(CASE WHEN MPG IS NULL THEN 1 ELSE 0 END) AS Null_MPG,
    SUM(CASE WHEN Cylinders IS NULL THEN 1 ELSE 0 END) AS Null_Cylinders,
    SUM(CASE WHEN Displacement IS NULL THEN 1 ELSE 0 END) AS Null_Displacement,
    SUM(CASE WHEN Horsepower IS NULL THEN 1 ELSE 0 END) AS Null_Horsepower,
    SUM(CASE WHEN Weight IS NULL THEN 1 ELSE 0 END) AS Null_Weight,
    SUM(CASE WHEN Acceleration IS NULL THEN 1 ELSE 0 END) AS Null_Acceleration,
    SUM(CASE WHEN Model IS NULL THEN 1 ELSE 0 END) AS Null_Model,
    SUM(CASE WHEN Origin IS NULL THEN 1 ELSE 0 END) AS Null_Origin,
    SUM(CASE WHEN Origin_Model IS NULL THEN 1 ELSE 0 END) AS Null_Origin_Model
FROM raw_cars;

---Zero_values----
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN MPG = 0 THEN 1 ELSE 0 END) AS Zero_MPG,
    SUM(CASE WHEN Cylinders = 0 THEN 1 ELSE 0 END) AS Zero_Cylinders,
    SUM(CASE WHEN Displacement = 0 THEN 1 ELSE 0 END) AS Zero_Displacement,
    SUM(CASE WHEN Horsepower = 0 THEN 1 ELSE 0 END) AS Zero_Horsepower,
    SUM(CASE WHEN Weight = 0 THEN 1 ELSE 0 END) AS Zero_Weight,
    SUM(CASE WHEN Acceleration = 0 THEN 1 ELSE 0 END) AS Zero_Acceleration,
    SUM(CASE WHEN Model = 0 THEN 1 ELSE 0 END) AS Zero_Model
FROM raw_cars;

SELECT
    Car,
    MPG,
    Horsepower,
    Cylinders,
    Displacement,
    Weight,
    Acceleration,
    Model,
    Origin
FROM dbo.raw_cars
WHERE MPG = 0
   OR Horsepower = 0;

------duplicated_values-------
SELECT * ,COUNT(*) AS Duplicate_Count
FROM raw_cars
GROUP BY Car,MPG,Cylinders,Displacement,Horsepower,Weight,Acceleration,Model,Origin,Origin_Model
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;

---check text fields(Text Formatting)----
SELECT *
FROM raw_cars
WHERE
    Car IS NULL
    OR LTRIM(RTRIM(Car)) = ''
    OR Car <> LTRIM(RTRIM(Car));


-------Create clean_table---------
SELECT
    LTRIM(RTRIM(Car)) AS Car,
    NULLIF(MPG, 0) AS MPG,
    Cylinders,
    Displacement,
    NULLIF(Horsepower, 0) AS Horsepower,
    Weight,
    Acceleration,
    Model,
    LTRIM(RTRIM(Origin)) AS Origin,
    LTRIM(RTRIM(Origin_Model)) AS Origin_Model
INTO clean_cars
FROM raw_cars;

SELECT
    (SELECT COUNT(*) FROM raw_cars) AS Raw_Rows,
    (SELECT COUNT(*) FROM clean_cars) AS Clean_Rows;
-------------clean_cars table---------------
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN MPG IS NULL THEN 1 ELSE 0 END) AS Missing_MPG,
    SUM(CASE WHEN Horsepower IS NULL THEN 1 ELSE 0 END) AS Missing_Horsepower
FROM clean_cars;

SELECT
    SUM(CASE WHEN MPG = 0 THEN 1 ELSE 0 END) AS Zero_MPG,
    SUM(CASE WHEN Horsepower = 0 THEN 1 ELSE 0 END) AS Zero_Horsepower
FROM clean_cars;

---------Data Quality Summary---------
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN MPG IS NULL THEN 1 ELSE 0 END) AS Missing_MPG,
    SUM(CASE WHEN Horsepower IS NULL THEN 1 ELSE 0 END)  AS Missing_Horsepower,
    SUM(CASE WHEN MPG < 0 THEN 1 ELSE 0 END)  AS Negative_MPG,
    SUM(CASE WHEN Horsepower < 0 THEN 1 ELSE 0 END)  AS Negative_Horsepower,
    SUM(CASE WHEN Cylinders <= 0 THEN 1 ELSE 0 END)  AS Invalid_Cylinders,
    SUM(CASE WHEN Displacement <= 0 THEN 1 ELSE 0 END) AS Invalid_Displacement,
    SUM(CASE WHEN Weight <= 0 THEN 1 ELSE 0 END)  AS Invalid_Weight,
    SUM(CASE WHEN Acceleration <= 0 THEN 1 ELSE 0 END)  AS Invalid_Acceleration
FROM clean_cars;

---------------------------Database Normalization--------------------------
---Create Schema
USE Cars_Analysis;
CREATE SCHEMA normalized;



----Create table (normalized.Origin)
CREATE TABLE normalized.Origin(
       Origin_ID INT IDENTITY(1,1) PRIMARY KEY,
	   Origin_Name VARCHAR(100) NOT NULL UNIQUE);

-----Insert into ----
INSERT INTO normalized.Origin (Origin_Name)
SELECT DISTINCT(Origin)
FROM clean_cars
WHERE Origin IS NOT NULL;


SELECT *
FROM normalized.Origin
ORDER BY Origin_ID;



----Create table (normalized.ModelYear)
CREATE TABLE normalized.ModelYear(
       ModelYear_ID INT IDENTITY(1,1) PRIMARY KEY,
	   Model_Year INT NOT NULL UNIQUE);

-----Insert into -----
INSERT INTO normalized.ModelYear (Model_Year)
SELECT DISTINCT(Model)
FROM clean_cars
WHERE Model IS NOT NULL;


SELECT *
FROM normalized.ModelYear
ORDER BY Model_Year;

SELECT COUNT(*) AS ModelYear_Count
FROM normalized.ModelYear; 





----Create table (normalized.Car)
CREATE TABLE normalized.Car(
    CarID INT IDENTITY(1,1) PRIMARY KEY,
    CarName VARCHAR(150) NOT NULL UNIQUE,
    Origin_ID INT NOT NULL,

CONSTRAINT FK_Car_Origin FOREIGN KEY (Origin_ID) REFERENCES normalized.Origin(Origin_ID));


-----Insert into -----
INSERT INTO normalized.Car(CarName,Origin_ID)
SELECT DISTINCT c.Car,o.Origin_ID
FROM clean_cars AS c
INNER JOIN normalized.Origin AS o ON c.Origin = o.Origin_Name;

SELECT COUNT(*) AS Car_Count
FROM normalized.Car;

SELECT TOP 10
    c.CarID,
    c.CarName,
    c.Origin_ID,
    o.Origin_Name
FROM normalized.Car AS c
INNER JOIN normalized.Origin AS o
    ON c.Origin_ID = o.Origin_ID
ORDER BY c.CarID;


--------Create table (normalized.VehiclePerformance)
CREATE TABLE normalized.VehiclePerformance
(
    PerformanceID INT IDENTITY(1,1) PRIMARY KEY,

    CarID INT NOT NULL,
    ModelYear_ID INT NOT NULL,

    MPG FLOAT NULL,
    Cylinders INT NOT NULL,
    Displacement FLOAT NOT NULL,
    Horsepower INT NULL,
    Weight INT NOT NULL,
    Acceleration FLOAT NOT NULL,

    CONSTRAINT FK_Performance_Car
        FOREIGN KEY (CarID)
        REFERENCES normalized.Car(CarID),

    CONSTRAINT FK_Performance_ModelYear
        FOREIGN KEY (ModelYear_ID)
        REFERENCES normalized.ModelYear(ModelYear_ID)
);


--------------Insert into --------
INSERT INTO normalized.VehiclePerformance
(CarID,ModelYear_ID,MPG,Cylinders,Displacement,Horsepower,Weight,Acceleration)
SELECT
    c.CarID,
    y.ModelYear_ID,
    d.MPG,
    d.Cylinders,
    d.Displacement,
    d.Horsepower,
    d.Weight,
    d.Acceleration
FROM clean_cars AS d
INNER JOIN normalized.Car AS c
    ON d.Car = c.CarName
INNER JOIN normalized.ModelYear AS y
    ON d.Model = y.Model_Year;


SELECT TOP 10 *
FROM normalized.VehiclePerformance
ORDER BY PerformanceID;


------Check  Number of row in (clean_Rows & Normalized_Rows)
SELECT
    (SELECT COUNT(*) FROM dbo.clean_cars)
        AS Clean_Rows,

    (SELECT COUNT(*) FROM normalized.VehiclePerformance)
        AS Normalized_Rows;


-------------Keys & Relationships Validation----------
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'normalized'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

--------------KPI Dashboard---------
SELECT
    COUNT(*) AS Total_Performance_Records,
    ROUND(AVG(MPG), 2) AS Average_MPG,
    ROUND(AVG(Horsepower), 2) AS Average_Horsepower,
    ROUND(AVG(CAST(Weight AS FLOAT)), 2) AS Average_Weight,
    ROUND(AVG(Acceleration), 2) AS Average_Acceleration
FROM normalized.VehiclePerformance;

------- KPIs depend on Origin------
SELECT
    o.Origin_Name,
    COUNT(*) AS Vehicle_Count,
    ROUND(AVG(vp.MPG), 2) AS Average_MPG,
    ROUND(AVG(vp.Horsepower), 2) AS Average_Horsepower,
    ROUND(AVG(CAST(vp.Weight AS FLOAT)), 2) AS Average_Weight,
    ROUND(AVG(vp.Acceleration), 2) AS Average_Acceleration
FROM normalized.VehiclePerformance vp
INNER JOIN normalized.Car c ON vp.CarID = c.CarID
INNER JOIN normalized.Origin o ON c.Origin_ID = o.Origin_ID
GROUP BY o.Origin_Name
ORDER BY Average_MPG DESC;


-------------KPI by Model Year----------
SELECT
    my.Model_Year,
    COUNT(*) AS Vehicle_Count,
    ROUND(AVG(vp.MPG), 2) AS Average_MPG,
    ROUND(AVG(vp.Horsepower), 2) AS Average_Horsepower
FROM normalized.VehiclePerformance vp
INNER JOIN normalized.ModelYear my ON vp.ModelYear_ID = my.ModelYear_ID
GROUP BY my.Model_Year
ORDER BY my.Model_Year;

-- عملنا كرييت ل 3 ديمنشن و انسيرت و سيليكت

CREATE SCHEMA star;

CREATE TABLE star.Dim_Car

(
    CarKey INT IDENTITY(1,1) PRIMARY KEY,

    CarID INT NOT NULL,

    CarName VARCHAR(150) NOT NULL
);

INSERT INTO star.Dim_Car
(CarID, CarName)
SELECT
    CarID,
    CarName
FROM normalized. Car;


 SELECT * FROM star.Dim_Car;

 CREATE TABLE star.Dim_Origin
(
    OriginKey INT IDENTITY(1,1) PRIMARY KEY,
    Origin_ID INT NOT NULL,
    Origin_Name VARCHAR(100) NOT NULL
);

INSERT INTO star.Dim_Origin
(Origin_ID, Origin_Name)
SELECT
    Origin_ID,
    Origin_Name
FROM normalized. Origin;


SELECT * FROM star.Dim_Origin;
 

CREATE TABLE star.Dim_ModelYear
(
    ModelYearKey INT IDENTITY(1,1) PRIMARY KEY,
    ModelYear_ID INT NOT NULL,
    Model_Year INT NOT NULL
);
INSERT INTO star.Dim_ModelYear
(ModelYear_ID, Model_Year)
SELECT
    ModelYear_ID,
    Model_Year
FROM normalized.ModelYear;

SELECT *
FROM star.Dim_ModelYear
ORDER BY Model_Year;

CREATE TABLE star.Fact_CarPerformance
(
FactKey INT IDENTITY(1,1) PRIMARY KEY,
CarKey INT NOT NULL,
OriginKey INT NOT NULL,
ModelYearKey INT NOT NULL,
MPG FLOAT NULL,
Cylinders INT NOT NULL,

    Displacement FLOAT NOT NULL,

    Horsepower INT NULL,

    Weight INT NOT NULL,

    Acceleration FLOAT NOT NULL,
 
    CONSTRAINT FK_Fact_Car

        FOREIGN KEY (CarKey)

        REFERENCES star.Dim_Car(CarKey),
 
    CONSTRAINT FK_Fact_Origin

        FOREIGN KEY (OriginKey)

REFERENCES star.Dim_Origin(OriginKey),
CONSTRAINT FK_Fact_ModelYear
FOREIGN KEY (ModelYearKey)
REFERENCES star.Dim_ModelYear(ModelYearKey)
);

INSERT INTO star.Fact_CarPerformance

(

    CarKey,

    OriginKey,

    ModelYearKey,

    MPG,

    Cylinders,

    Displacement,

    Horsepower,

    Weight,

    Acceleration

)

SELECT

    dc.CarKey,

    do.OriginKey,

    dy.ModelYearKey,

    vp.MPG,

    vp.Cylinders,

    vp.Displacement,

    vp.Horsepower,

    vp.Weight,

    vp.Acceleration

FROM normalized.VehiclePerformance vp
 
INNER JOIN normalized.Car c

    ON vp.CarID = c.CarID
 
INNER JOIN normalized.Origin o

    ON c.Origin_ID = o.Origin_ID
 
INNER JOIN normalized.ModelYear my

    ON vp.ModelYear_ID = my.ModelYear_ID
 
INNER JOIN star.Dim_Car dc

    ON c.CarID = dc.CarID
 
INNER JOIN star.Dim_Origin do

    ON o.Origin_ID = do.Origin_ID
 
INNER JOIN star.Dim_ModelYear dy

    ON my.ModelYear_ID = dy.ModelYear_ID;


 SELECT TOP 10 * FROM star.Fact_CarPerformance;
 
 SELECT COUNT(*) AS Fact_Rows
FROM star.Fact_CarPerformance;

-------------- عملنا 3 جوين بين الفاكت و الديمينشن-----------------------------

SELECT
    dc.CarName,
    do.Origin_Name,
    dy.Model_Year,
    f.MPG,
    f.Horsepower,
    f.Weight,
    f.Acceleration
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc
    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
INNER JOIN star.Dim_ModelYear dy
    ON f.ModelYearKey = dy.ModelYearKey;

-----------------------------------------------------

SELECT
    do.Origin_Name,
    dc.CarName,
    f.MPG,
    f.Horsepower
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc
    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
ORDER BY do.Origin_Name, dc.CarName;

----------------------------------------------

SELECT
    dy.Model_Year,
    dc.CarName,
    do.Origin_Name,
    f.MPG,
    f.Horsepower
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc
    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
INNER JOIN star.Dim_ModelYear dy
    ON f.ModelYearKey = dy.ModelYearKey
 
ORDER BY dy.Model_Year, dc.CarName;

--------------------هنعمل 7 اناليسيز -----------------------------

-- إيه الـ Origin اللي عنده أعلى متوسط MPG؟
  SELECT
    do.Origin_Name,
    COUNT(*) AS Vehicle_Count,
    ROUND(AVG(f.MPG), 2) AS Average_MPG
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
GROUP BY do.Origin_Name
 
ORDER BY Average_MPG DESC;

-- متوسط الـ Horsepower لكل Origin كام؟
SELECT
    do.Origin_Name,
    ROUND(AVG(CAST(f.Horsepower AS FLOAT)), 2) AS Average_Horsepower
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
GROUP BY do.Origin_Name
 
ORDER BY Average_Horsepower DESC;

-- هل كفاءة السيارات في استهلاك الوقود اتحسنت مع السنين؟

SELECT

    dy.Model_Year,

    COUNT(*) AS Vehicle_Count,

    ROUND(AVG(f.MPG), 2) AS Average_MPG

FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_ModelYear dy

    ON f.ModelYearKey = dy.ModelYearKey
 
GROUP BY dy.Model_Year
 
ORDER BY dy.Model_Year;

-- إيه متوسط الوزن والـ MPG حسب الـ Origin؟
SELECT

    do.Origin_Name,

    ROUND(AVG(CAST(f.Weight AS FLOAT)), 2) AS Average_Weight,

    ROUND(AVG(f.MPG), 2) AS Average_MPG

FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Origin do

    ON f.OriginKey = do.OriginKey
 
GROUP BY do.Origin_Name
 
ORDER BY Average_Weight DESC;
 
 -- إيه أفضل 10 سيارات من حيث MPG؟
 SELECT TOP 10

    dc.CarName,

    do.Origin_Name,

    dy.Model_Year,

    f.MPG

FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc

    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do

    ON f.OriginKey = do.OriginKey
 
INNER JOIN star.Dim_ModelYear dy

    ON f.ModelYearKey = dy.ModelYearKey
 
WHERE f.MPG IS NOT NULL
 
ORDER BY f.MPG DESC;
 
 --Top 10 Cars by Horsepower 
 
 SELECT TOP 10
    dc.CarName,
    do.Origin_Name,
    dy.Model_Year,
    f.Horsepower
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc
    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
INNER JOIN star.Dim_ModelYear dy
    ON f.ModelYearKey = dy.ModelYearKey
 
WHERE f.Horsepower IS NOT NULL
 
ORDER BY f.Horsepower DESC;

-- كل عدد Cylinders موجود في كام سيارة، ومتوسط الـ MPG بتاعه كام؟
SELECT
    f.Cylinders,
    COUNT(*) AS Vehicle_Count,
    ROUND(AVG(f.MPG), 2) AS Average_MPG,
    ROUND(AVG(CAST(f.Horsepower AS FLOAT)), 2) AS Average_Horsepower
FROM star.Fact_CarPerformance f
 
GROUP BY f.Cylinders
 
ORDER BY f.Cylinders;

-- SELECT COUNT(*) FROM star.Fact_CarPerformance;

-- SELECT COUNT(*) FROM normalized.VehiclePerformance;


-- هنعمل الساب كويري 

--يه السيارات اللي الـ MPG بتاعها أعلى من متوسط كل السيارات؟

SELECT
    dc.CarName,
    do.Origin_Name,
    f.MPG
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc
    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
WHERE f.MPG >
(
    SELECT AVG(MPG)
    FROM star.Fact_CarPerformance
)
 
ORDER BY f.MPG DESC;


-- السيارات التي Horsepower بتاعها أعلى من المتوسط
SELECT

    dc.CarName,

    do.Origin_Name,

    f.Horsepower

FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc

    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do

    ON f.OriginKey = do.OriginKey
 
WHERE f.Horsepower >

(

    SELECT AVG(Horsepower)

    FROM star.Fact_CarPerformance

    WHERE Horsepower IS NOT NULL

)
ORDER BY f.Horsepower DESC;

-- السيارات الأثقل من متوسط الوزن
SELECT

    dc.CarName,

    do.Origin_Name,

    f.Weight

FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc

    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do

    ON f.OriginKey = do.OriginKey
 
WHERE f.Weight >

(

    SELECT AVG(CAST(Weight AS FLOAT))

    FROM star.Fact_CarPerformance

)
 
ORDER BY f.Weight DESC;
 
 -- هنبدا CTE  

 -- CTE 1 — متوسط MPG لكل Origin
 WITH Origin_MPG AS
(
    SELECT
        OriginKey,
        ROUND(AVG(MPG), 2) AS Average_MPG
    FROM star.Fact_CarPerformance
    GROUP BY OriginKey
)
 
SELECT
    do.Origin_Name,
    om.Average_MPG
FROM Origin_MPG om
 
INNER JOIN star.Dim_Origin do
    ON om.OriginKey = do.OriginKey
 
ORDER BY om.Average_MPG DESC;

-- CTE 2 — مقارنة كل سيارة بمتوسط الـ MPG
WITH Average_MPG AS
(
    SELECT
        AVG(MPG) AS Overall_Average_MPG
    FROM star.Fact_CarPerformance
)
 
SELECT
    dc.CarName,
    do.Origin_Name,
    f.MPG,
    ROUND(a.Overall_Average_MPG, 2) AS Overall_Average_MPG
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc
    ON f.CarKey = dc.CarKey
 
INNER JOIN star.Dim_Origin do
    ON f.OriginKey = do.OriginKey
 
CROSS JOIN Average_MPG a
 
WHERE f.MPG IS NOT NULL
 
ORDER BY f.MPG DESC;

-- CTE 3 — تحليل Model Year
WITH Year_Analysis AS

(

    SELECT

        ModelYearKey,

        COUNT(*) AS Vehicle_Count,

        ROUND(AVG(MPG), 2) AS Average_MPG,

        ROUND(AVG(CAST(Horsepower AS FLOAT)), 2) AS Average_Horsepower

    FROM star.Fact_CarPerformance

    GROUP BY ModelYearKey

)
 
SELECT

    dy.Model_Year,

    ya.Vehicle_Count,

    ya.Average_MPG,

    ya.Average_Horsepower

FROM Year_Analysis ya
 
INNER JOIN star.Dim_ModelYear dy

    ON ya.ModelYearKey = dy.ModelYearKey
 
ORDER BY dy.Model_Year;
 

 -- هنعمل الكيس ستيتمنت 

 --CASE 1 — تصنيف السيارات حسب MPG هنقسمهم الي :  High Efficiency /  Medium Efficiency / Low Efficiency
 SELECT

    dc.CarName,

    f.MPG,
 
    CASE

        WHEN f.MPG >= 30 THEN 'High Efficiency'

        WHEN f.MPG >= 20 THEN 'Medium Efficiency'

        ELSE 'Low Efficiency'

    END AS MPG_Category
 
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc

    ON f.CarKey = dc.CarKey WHERE f.MPG IS NOT NULL ORDER BY f.MPG DESC;
 

 -- CASE 2 — تصنيف Horsepower
-- هنقسم الـ Horsepower إلى: High Power - Medium Power - Low Power

SELECT dc.CarName, f.Horsepower,
 
    CASE

        WHEN f.Horsepower >= 200 THEN 'High Power'

        WHEN f.Horsepower >= 100 THEN 'Medium Power'

        ELSE 'Low Power'

    END AS Power_Category
 
FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc ON f.CarKey = dc.CarKey WHERE f.Horsepower IS NOT NULL  ORDER BY f.Horsepower DESC;
 

 -- CASE 3 — تصنيف السيارات حسب Weight
 SELECT dc.CarName, f.Weight,
 
    CASE
        WHEN f.Weight >= 3500 THEN 'Heavy'
        WHEN f.Weight >= 2500 THEN 'Medium'
        ELSE 'Light'
    END AS Weight_Category
 FROM star.Fact_CarPerformance f
 
INNER JOIN star.Dim_Car dc ON f.CarKey = dc.CarKey ORDER BY f.Weight DESC;

-- CASE 4 — تصنيف السيارات حسب الأداءهنا  نعمل Classification بسيط يجمع بين MPG وHorsepower.

SELECT

    dc.CarName,

    f.MPG,

    f.Horsepower,
 
    CASE

        WHEN f.MPG >= 30 AND f.Horsepower >= 150

            THEN 'Efficient & Powerful'
 
        WHEN f.MPG >= 30

            THEN 'Efficient'
 
        WHEN f.Horsepower >= 150

            THEN 'Powerful'
 
        ELSE 'Standard' 
		END AS Performance_Category
 FROM star.Fact_CarPerformance f
INNER JOIN star.Dim_Car dc ON f.CarKey = dc.CarKey
WHERE f.MPG IS NOT NULL AND f.Horsepower IS NOT NULL ORDER BY f.MPG DESC;
-- Data Analysis & Reports دلوقتي  نعمل Queries شكلها أقرب لتقارير حقيقية.


-- Report 1 — Origin Performance Report ده تقرير شامل لكل Origin. 
SELECT do.Origin_Name,
COUNT(*) AS Vehicle_Count,
ROUND(AVG(f.MPG), 2) AS Average_MPG,
ROUND(AVG(CAST(f.Horsepower AS FLOAT)), 2) AS Average_Horsepower,
ROUND(AVG(CAST(f.Weight AS FLOAT)), 2) AS Average_Weight, ROUND(AVG(f.Acceleration), 2) AS Average_Acceleration
FROM star.Fact_CarPerformance f
INNER JOIN star.Dim_Origin do ON f.OriginKey = do.OriginKey GROUP BY do.Origin_Name ORDER BY Average_MPG DESC;
 
 -- Report 2 — Model Year Performance Report

 SELECT dy.Model_Year,
COUNT(*) AS Vehicle_Count,
ROUND(AVG(f.MPG), 2) AS Average_MPG,
ROUND(AVG(CAST(f.Horsepower AS FLOAT)), 2) AS Average_Horsepower,
ROUND(AVG(CAST(f.Weight AS FLOAT)), 2) AS Average_Weight
FROM star.Fact_CarPerformance f INNER JOIN star.Dim_ModelYear dy
ON f.ModelYearKey = dy.ModelYearKey GROUP BY dy.Model_Year ORDER BY dy.Model_Year;
 
-- Report 3 — Cylinder Analysis
SELECT Cylinders,COUNT(*) AS Vehicle_Count,
ROUND(AVG(MPG), 2) AS Average_MPG, ROUND(AVG(CAST(Horsepower AS FLOAT)), 2) AS Average_Horsepower,
ROUND(AVG(CAST(Weight AS FLOAT)), 2) AS Average_Weight
FROM star.Fact_CarPerformance  GROUP BY Cylinders ORDER BY Cylinders;

-- Report 4 — Efficiency Report نستخدم ال CASE اللي عملناه عشان نعرف عدد السيارات في كل Category.
SELECT
    CASE
        WHEN MPG >= 30 THEN 'High Efficiency'
        WHEN MPG >= 20 THEN 'Medium Efficiency'
        ELSE 'Low Efficiency'
    END AS MPG_Category,
COUNT(*) AS Vehicle_Count, ROUND(AVG(MPG), 2) AS Average_MPG
FROM star.Fact_CarPerformance WHERE MPG IS NOT NULL
GROUP BY
    CASE
        WHEN MPG >= 30 THEN 'High Efficiency'
        WHEN MPG >= 20 THEN 'Medium Efficiency'
        ELSE 'Low Efficiency'
    END
 ORDER BY Average_MPG DESC;

-- Report 5 — Top 10 Overall Cars

SELECT TOP 10
    dc.CarName,
    do.Origin_Name,
    dy.Model_Year,
    f.MPG,
    f.Horsepower,
    f.Weight,
    f.Acceleration
FROM star.Fact_CarPerformance f
INNER JOIN star.Dim_Car dc ON f.CarKey = dc.CarKey 
INNER JOIN star.Dim_Origin do ON f.OriginKey = do.OriginKey 
INNER JOIN star.Dim_ModelYear dy ON f.ModelYearKey = dy.ModelYearKey
WHERE f.MPG IS NOT NULL AND f.Horsepower IS NOT NULL ORDER BY f.MPG DESC, f.Horsepower DESC;

 -- View — Car Performance Details

 USE Cars_Analysis;
 
CREATE VIEW star.vw_CarPerformance AS
SELECT
    dc.CarName,
    do.Origin_Name,
    dy.Model_Year,
    f.MPG,
    f.Cylinders,
    f.Displacement,
    f.Horsepower,
    f.Weight,
    f.Acceleration
FROM star.Fact_CarPerformance f
INNER JOIN star.Dim_Car dc ON f.CarKey = dc.CarKey
INNER JOIN star.Dim_Origin do ON f.OriginKey = do.OriginKey
INNER JOIN star.Dim_ModelYear dy ON f.ModelYearKey = dy.ModelYearKey;


SELECT * FROM star.vw_CarPerformance;

-- View — Origin Performance Report 

CREATE VIEW star.vw_OriginPerformance AS
SELECT do.Origin_Name,
COUNT(*) AS Vehicle_Count,
ROUND(AVG(f.MPG), 2) AS Average_MPG,
ROUND(AVG(CAST(f.Horsepower AS FLOAT)), 2) AS Average_Horsepower,
ROUND(AVG(CAST(f.Weight AS FLOAT)), 2) AS Average_Weight,
ROUND(AVG(f.Acceleration), 2) AS Average_Acceleration FROM star.Fact_CarPerformance f 
INNER JOIN star.Dim_Origin do ON f.OriginKey = do.OriginKey GROUP BY do.Origin_Name;

SELECT * FROM star.vw_OriginPerformance ORDER BY Average_MPG DESC;

-- View — Model Year Performance
CREATE VIEW star.vw_ModelYearPerformance AS
SELECT dy.Model_Year,
COUNT(*) AS Vehicle_Count, ROUND(AVG(f.MPG), 2) AS Average_MPG, ROUND(AVG(CAST(f.Horsepower AS FLOAT)), 2)
AS Average_Horsepower, ROUND(AVG(CAST(f.Weight AS FLOAT)), 2) AS Average_Weight
FROM star.Fact_CarPerformance f INNER JOIN star.Dim_ModelYear dy
ON f.ModelYearKey = dy.ModelYearKey GROUP BY dy.Model_Year;

SELECT * FROM star.vw_ModelYearPerformance ORDER BY Model_Year;
 
 -- stored procdure 
 -- Stored Procedure — Get Cars by Origin

 CREATE PROCEDURE star.GetCarsByOrigin
@OriginName VARCHAR(100) AS BEGIN
    SELECT
        dc.CarName,
        do.Origin_Name,
        dy.Model_Year,
        f.MPG,
        f.Horsepower,
        f.Weight,
        f.Acceleration
FROM star.Fact_CarPerformance f INNER JOIN star.Dim_Car dc
ON f.CarKey = dc.CarKey INNER JOIN star.Dim_Origin do
ON f.OriginKey = do.OriginKey INNER JOIN star.Dim_ModelYear dy
ON f.ModelYearKey = dy.ModelYearKey WHERE do.Origin_Name = @OriginName ORDER BY f.MPG DESC;
 
END;

 EXEC star.GetCarsByOrigin @OriginName = 'US';
 EXEC star.GetCarsByOrigin @OriginName = 'Europe';
 EXEC star.GetCarsByOrigin @OriginName = 'Japan';

 -- Stored Procedure — Get Cars by Model Year

 CREATE PROCEDURE star.GetCarsByModelYear
 @ModelYear INT AS BEGIN
    SELECT
        dc.CarName,
        do.Origin_Name,
        dy.Model_Year,
        f.MPG,
        f.Horsepower,
        f.Weight,
        f.Acceleration
FROM star.Fact_CarPerformance f INNER JOIN star.Dim_Car dc
ON f.CarKey = dc.CarKey INNER JOIN star.Dim_Origin do
ON f.OriginKey = do.OriginKey INNER JOIN star.Dim_ModelYear dy
ON f.ModelYearKey = dy.ModelYearKey WHERE dy.Model_Year = @ModelYear ORDER BY f.MPG DESC;
 
END;

 EXEC star.GetCarsByModelYear @ModelYear = 80 ;

-- Stored Procedure — Origin Summary

CREATE PROCEDURE star.GetOriginSummary
@OriginName VARCHAR(100) AS BEGIN 
SELECT do.Origin_Name, COUNT(*) AS Vehicle_Count, ROUND(AVG(f.MPG), 2) AS Average_MPG,
ROUND(AVG(CAST(f.Horsepower AS FLOAT)), 2) AS Average_Horsepower, ROUND(AVG(CAST(f.Weight AS FLOAT)), 2)
AS Average_Weight, ROUND(AVG(f.Acceleration), 2) AS Average_Acceleration FROM star.Fact_CarPerformance f
INNER JOIN star.Dim_Origin do ON f.OriginKey = do.OriginKey WHERE do.Origin_Name = @OriginName 
GROUP BY do.Origin_Name;

END;

EXEC star.GetOriginSummary @OriginName = 'US';

SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'star';

SELECT SCHEMA_NAME(schema_id) AS Schema_Name, name AS Procedure_Name FROM sys.procedures
WHERE schema_id = SCHEMA_ID('star');
 

