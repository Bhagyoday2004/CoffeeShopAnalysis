CREATE DATABASE coffee_shop_db;

USE coffee_shop_db;

SELECT * FROM coffee_shop_db.`coffee shop sales`;

DESCRIBE coffee_shop_db.`coffee shop sales`;
-- afetr describing the datatype for date and time is text so lets change it.

-- updating the datatype of transaction date from STR_TO_DATE 
UPDATE coffee_shop_db.`coffee shop sales`
SET transaction_date = STR_TO_DATE(transaction_date, '%Y-%m-%d');

SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- Modifying Transaction_Date column datatype to Date Format from Text Format
ALTER TABLE coffee_shop_db.`coffee shop sales`
MODIFY COLUMN transaction_date DATE;

-- Checking if the Datatype is modified (It is Modified)
DESCRIBE coffee_shop_db.`coffee shop sales`;

SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- now Transaction_time is in text format we change it to time format
UPDATE coffee_shop_db.`coffee shop sales`
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

-- Modifying Transaction_Time column datatype to Time Format from Text Format
ALTER TABLE coffee_shop_db.`coffee shop sales`
MODIFY COLUMN transaction_time TIME;

-- Checking if the Datatype is modified (It is Modified)
DESCRIBE coffee_shop_db.`coffee shop sales`;

SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- Now we alter the queries according to business requirment and provide insights to the customers

-- calculate total sales for each respective months
-- we know total sales = transaction qty x unit_price
SELECT ROUND(SUM(unit_price * transaction_qty)) as Total_Sales 
FROM coffee_shop_db.`coffee shop sales`
WHERE MONTH(transaction_date) = 5; -- for month of May (because May comes in 5th position in Calender) 

-- Find Month On Month Increase or Decrease in sales
-- Calculate the difference in sales between selected month and previous month
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, -- Total Sales
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- lag function goes to previous month (Month sales Difference)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- Dividing month sales diff by previous month sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- then multiplying it by 100 to get percentage
FROM 
    coffee_shop_db.`coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April(Previous Month) and May(Slected Month)
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
 SELECT * FROM coffee_shop_db.`coffee shop sales`;
    
    -- Total Number of orders for the respective months
    SELECT COUNT(transaction_id) as Total_Orders
FROM  coffee_shop_db.`coffee shop sales`
WHERE MONTH (transaction_date)= 5; -- for month of May (because May comes in 5th position in Calender) 

-- Find Month On Month Increase or Decrease in number of orders
-- Calculate the difference in number of orders between selected month and previous month
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_db.`coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April(Previous Month) and May(Slected Month)
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- Total Quantity Sold For the respective month
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_db.`coffee shop sales`
WHERE MONTH(transaction_date) = 5; -- for month of May (because May comes in 5th position in Calender) 

-- Find Month On Month Increase or Decrease in Total Quantity Sold
-- Calculate the difference in Total Quantity Sold between selected month and previous month
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
   coffee_shop_db.`coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for months of April(Previous Month) and May(Slected Month)
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- now creating a CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_db.`coffee shop sales`
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    
    -- for Round off values use this query
    SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
      coffee_shop_db.`coffee shop sales`
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    
SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- now concentrating on the trend of sales over a period
SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_db.`coffee shop sales`
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;

-- Calculating Per day Sales for the selected month
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
     coffee_shop_db.`coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);
    
SELECT * FROM coffee_shop_db.`coffee shop sales`;

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
      coffee_shop_db.`coffee shop sales`
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
SELECT * FROM coffee_shop_db.`coffee shop sales`;
    
-- Query to calculate sales by weekdays and weekends
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_db.`coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;

SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- Query to calculate sales by Location of the store
SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM coffee_shop_db.`coffee shop sales`
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC;

-- Query to calculate sales by Product Category
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_db.`coffee shop sales`
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- Top 10 Most sales Product in the selected month
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_db.`coffee shop sales`
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- Query for Sales of particular day in particular hour
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
   coffee_shop_db.`coffee shop sales`
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)

-- To get sales from monday to sunday for a specific month
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_db.`coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- To get sales for all hours of a specific month 
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_db.`coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);
