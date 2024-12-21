ALTER TABLE fact 
ALTER COLUMN Sales_Price DECIMAL(10,2)

----------------------------------------------------------------
----------------------------------------------------------------

ALTER TABLE fact 
ALTER COLUMN Cost_Price DECIMAL(10,2)

----------------------------------------------------------------
----------------------------------------------------------------


SELECT FORMAT(
    SUM(
        (Sales_Price - Cost_Price) * Production_Quantity
        ),'C2'
    ) AS Total_Profit 
FROM Fact

----------------------------------------------------------------
----------------------------------------------------------------

SELECT 
    FORMAT(SUM(Sales_Price),'C2') AS Total_Revenue, 
    FORMAT(SUM(Cost_Price),'C2') AS Total_Cost, 
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity),'C2') AS Total_Profit 
FROM Fact 

----------------------------------------------------------------
----------------------------------------------------------------

SELECT * FROM Fact

----------------------------------------------------------------
----------------------------------------------------------------

SELECT DISTINCT YEAR([Date]) AS Years
FROM Fact
ORDER BY 1

----------------------------------------------------------------
----------------------------------------------------------------

SELECT 
    YEAR([Date]) AS Years,
    CASE 
        WHEN DATEPART(WEEKDAY, [Date]) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    SUM(Production_Quantity) AS Total_Quantity
FROM Fact
GROUP BY YEAR([Date]), 
    CASE 
        WHEN DATEPART(WEEKDAY, [Date]) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END
ORDER BY 1,2

----------------------------------------------------------------
----------------------------------------------------------------



SELECT 
    FORMAT(Profit_CY,'C2') AS TotalProfit_CY,
    FORMAT(Profit_CY,'C2') AS TotalProfit_LY,
    FORMAT(Profit_CY - Profit_LY, 'C2') AS Dif_Profit,
    FORMAT(Profit_CY / Profit_LY - 1, 'P') AS Dif_Profit_P
FROM
(
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS Profit_CY
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact)
)CurrentYear,
(
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS Profit_LY
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact)-1
)LastYear
---------------------------------------------------------------- 2 
WITH CurrentYear AS (
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS Profit_CY
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact)
), LastYear AS (
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS Profit_LY
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact)-1
)
SELECT 
    FORMAT(Profit_CY,'C2') AS TotalProfit_CY,
    FORMAT(Profit_LY,'C2') AS TotalProfit_LY,
    FORMAT(Profit_CY - Profit_LY, 'C2') AS Dif_Profit,
    FORMAT(Profit_CY / Profit_LY - 1, 'P') AS Dif_Profit_P
FROM CurrentYear, LastYear;

----------------------------------------------------------------
----------------------------------------------------------------

WITH Current_Month AS (
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS TotalProfit_CM
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact) 
        AND MONTH([Date]) = (SELECT MAX(MONTH([Date])) FROM Fact)
), Last_Month AS (
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS TotalProfit_LM
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact) 
        AND MONTH([Date]) = (SELECT MAX(MONTH([Date])) FROM Fact) - 1
)
SELECT 
    FORMAT(TotalProfit_CM,'C2') AS TotalProfit_CM,
    FORMAT(TotalProfit_LM,'C2') AS TotalProfit_LM,
    FORMAT(TotalProfit_CM - TotalProfit_LM, 'C2') AS Dif_Profit,
    FORMAT(TotalProfit_CM / TotalProfit_LM - 1, 'P') AS Dif_Profit_P
FROM Current_Month, Last_Month;

---------------------------------------------------------------- 2 
SELECT 
    FORMAT(TotalProfit_CM,'C2') AS TotalProfit_CM,
    FORMAT(TotalProfit_LM,'C2') AS TotalProfit_LM,
    FORMAT(TotalProfit_CM - TotalProfit_LM, 'C2') AS Dif_Profit,
    FORMAT(TotalProfit_CM / TotalProfit_LM - 1, 'P') AS Dif_Profit_P
FROM
(
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS TotalProfit_CM
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact) 
        AND MONTH([Date]) = (SELECT MAX(MONTH([Date])) FROM Fact)
)Current_Month,
(
    SELECT SUM((Sales_Price - Cost_Price) * Production_Quantity) AS TotalProfit_LM
    FROM Fact
    WHERE YEAR([Date]) = (SELECT MAX(YEAR([Date])) FROM Fact) 
        AND MONTH([Date]) = (SELECT MAX(MONTH([Date])) FROM Fact) - 1
)Last_Month


----------------------------------------------------------------
----------------------------------------------------------------

SELECT 
    YEAR([Date]) AS Years, 
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity), 'C2') AS Profit
FROM Fact
GROUP BY YEAR([Date])
ORDER BY 2
----------------------------------------------------------------
----------------------------------------------------------------

SELECT TOP(1)
    DATENAME(MONTH, [Date]) AS MONTH, 
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity), 'C2') AS Profit
FROM Fact
WHERE YEAR([Date]) = 2022
GROUP BY DATENAME(MONTH, [Date])
ORDER BY SUM((Sales_Price - Cost_Price) * Production_Quantity) DESC

----------------------------------------------------------------
----------------------------------------------------------------

WITH best_weekdays as (
    SELECT
        YEAR([Date]) AS Years,
        DATENAME(WEEKDAY, [Date]) AS WeekName,
        FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity), 'C2') AS Profit,
        DENSE_RANK() OVER(
            PARTITION BY YEAR([Date]) 
            ORDER BY SUM((Sales_Price - Cost_Price) * Production_Quantity) DESC
        ) AS Rank
    FROM Fact
    GROUP BY YEAR([Date]), DATENAME(WEEKDAY, [Date])
)
SELECT Years, WeekName, Profit
FROM best_weekdays
WHERE Rank = 1
ORDER BY 1

----------------------------------------------------------------
----------------------------------------------------------------

SELECT DL.Dealership_Location, FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity), 'C2') AS Profit
FROM Fact F
JOIN DimLocation DL 
    ON f.DealershipLocationID = DL.DealershipLocationID
GROUP BY DL.Dealership_Location
ORDER BY 2 DESC;

----------------------------------------------------------------
----------------------------------------------------------------

WITH best_month AS (
    SELECT
        YEAR([Date]) AS Years,
        DATENAME(MONTH, [Date]) AS MonthName, 
        FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity), 'C2') AS Profit,
        DENSE_RANK() OVER(
            PARTITION BY YEAR([Date])
            ORDER BY SUM((Sales_Price - Cost_Price) * Production_Quantity) DESC
        ) AS Rank
    FROM Fact
    GROUP BY YEAR([Date]), DATENAME(MONTH, [Date])
)
SELECT Years, MonthName, Profit
FROM best_month
WHERE Rank = 1
ORDER BY 1;

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
-- DimLocation

SELECT DISTINCT Manufacturing_Location
FROM DimLocation

SELECT * FROM Fact
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DL.Manufacturing_Location, count(F.Color) AS sales_quantity
FROM DimLocation DL
LEFT JOIN Fact F
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY DL.Manufacturing_Location
ORDER BY 2 DESC
----------------------------------------------------------------
----------------------------------------------------------------

SELECT TOP(1)
    DL.Manufacturing_Location, 
    FORMAT(SUM((F.Sales_Price - F.Cost_Price) * F.Production_Quantity), 'C2') AS Profit
FROM DimLocation DL
LEFT JOIN Fact F 
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY DL.Manufacturing_Location
ORDER BY 2
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DISTINCT Country_of_Origin
FROM DimLocation
----------------------------------------------------------------
----------------------------------------------------------------
SELECT dl.Country_of_Origin, count(F.Color) AS sales_quantity
FROM DimLocation DL 
LEFT JOIN Fact F 
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY dl.Country_of_Origin
ORDER BY 2
----------------------------------------------------------------
----------------------------------------------------------------
SELECT 
    DL.Country_of_Origin,
    FORMAT(SUM(Sales_Price),'C2') AS Total_Revenue, 
    FORMAT(SUM(Cost_Price),'C2') AS Total_Cost, 
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity),'C2') AS Total_Profit
FROM DimLocation DL 
LEFT JOIN Fact F 
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY Country_of_Origin
ORDER BY 4 DESC, 2, 3
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DISTINCT Dealership_Location
FROM DimLocation
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DL.Dealership_Location, count(F.Color) AS sales_quantity
FROM DimLocation DL 
LEFT JOIN Fact F 
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY dl.Dealership_Location
ORDER BY 2
----------------------------------------------------------------
----------------------------------------------------------------
SELECT 
    DL.Dealership_Location,
    FORMAT(SUM(Sales_Price),'C2') AS Total_Revenue, 
    FORMAT(SUM(Cost_Price),'C2') AS Total_Cost, 
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity),'C2') AS Total_Profit
FROM DimLocation DL 
LEFT JOIN Fact F 
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY Dealership_Location
ORDER BY 4 DESC, 2, 3
----------------------------------------------------------------
----------------------------------------------------------------
SELECT TOP(1)
    DL.Dealership_Location,
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity),'C2') AS Total_Profit
FROM DimLocation DL 
LEFT JOIN Fact F 
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY Dealership_Location
ORDER BY 2
----------------------------------------------------------------
----------------------------------------------------------------
SELECT TOP(1)
    DL.Country_of_Origin,
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity),'C2') AS Total_Profit
FROM DimLocation DL 
LEFT JOIN Fact F 
    ON DL.DealershipLocationID = F.DealershipLocationID
GROUP BY Country_of_Origin
ORDER BY 2
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
-- DimCar


SELECT DISTINCT Car_Model
FROM DimCar
----------------------------------------------------------------
----------------------------------------------------------------
SELECT TOP(1) DC.Car_Model, COUNT(F.Color) AS sales_quantity
FROM DimCar DC 
LEFT JOIN Fact F 
    ON DC.DealershipLocationID = F.DealershipLocationID
GROUP BY DC.Car_Model
ORDER BY 2 DESC
----------------------------------------------------------------
----------------------------------------------------------------
SELECT Fuel_Type, COUNT(DISTINCT Car_Model) AS Model_Count
FROM DimCar
GROUP BY Fuel_Type
ORDER BY 2 DESC
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DISTINCT DC.Car_Model
FROM DimCar DC
JOIN Fact F
    ON DC.DealershipLocationID = F.DealershipLocationID
WHERE F.Safety_Rating > (SELECT AVG(Safety_Rating) FROM Fact)
ORDER BY 1
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DC.Car_Model, AVG(F.Warranty_Period_months) AS Warranty_Period_months
FROM DimCar DC 
LEFT JOIN Fact F 
    ON DC.DealershipLocationID = F.DealershipLocationID
GROUP BY DC.Car_Model 
ORDER BY 2 DESC
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DC.Car_Model, DC.Fuel_Type, 
    FORMAT(AVG(F.Cost_Price), 'C2') AS Avg_Cost_Price
FROM DimCar DC 
LEFT JOIN Fact F 
    ON DC.DealershipLocationID = F.DealershipLocationID
GROUP BY DC.Car_Model, DC.Fuel_Type
ORDER BY 1, 2, 3 DESC
----------------------------------------------------------------
----------------------------------------------------------------
SELECT 
    DC.Car_Model,
    FORMAT(SUM(Sales_Price),'C2') AS Total_Revenue, 
    FORMAT(SUM(Cost_Price),'C2') AS Total_Cost, 
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity),'C2') AS Total_Profit 
FROM DimCar DC 
LEFT JOIN Fact F 
    ON DC.DealershipLocationID = F.DealershipLocationID
GROUP BY DC.Car_Model
ORDER BY 4 DESC, 2, 3
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DC.Car_Model, COUNT(F.Color) AS sales_quantity
FROM DimCar DC 
LEFT JOIN Fact F 
    ON DC.DealershipLocationID = F.DealershipLocationID
GROUP BY DC.Car_Model
ORDER BY 2 DESC
----------------------------------------------------------------
----------------------------------------------------------------
SELECT TOP(1)
    DC.Car_Model,
    FORMAT(SUM((Sales_Price - Cost_Price) * Production_Quantity),'C2') AS Total_Profit 
FROM DimCar DC 
LEFT JOIN Fact F 
    ON DC.DealershipLocationID = F.DealershipLocationID
GROUP BY DC.Car_Model
ORDER BY 2 DESC
----------------------------------------------------------------
----------------------------------------------------------------
SELECT DC.Color, COUNT(F.Color) AS Sales_quantity
FROM DimCar DC
LEFT JOIN Fact F 
    ON DC.DealershipLocationID = F.DealershipLocationID
GROUP BY DC.Color
ORDER BY 2

----------------------------------------------------------------
----------------------------------------------------------------

SELECT 
    Year([Date]) AS Years,
    Min(Month([Date])) AS StartOfMonth,
    Max(Month([Date])) AS EndOfMonth,
    Count(DISTINCT Month([Date])) AS TotalNumOfMonths,
    Concat_ws('-', Datename(M, Min([Date])), Datename(DAY, Min([Date]))) AS StrMonthAndDay,
    Concat_ws('-', Datename(M, Max([Date])), Datename(DAY, Max([Date]))) AS EndMonthAndDay,
    Count(DISTINCT Datepart(DAYOFYEAR, [Date])) AS DayOfyear
FROM Fact
GROUP BY Year([Date])
ORDER BY 1, 2, 3, 4