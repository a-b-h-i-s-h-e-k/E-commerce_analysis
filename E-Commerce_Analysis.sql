use ecommerce_analysis;

-- 1. Select with DISTINCT
SELECT DISTINCT Country
FROM retail_data;

-- Explanation: 
-- This query retrieves a unique list of countries from the retail_data table.

-- 2. Using SELECT with Aggregate Functions
SELECT 
    Country,
    COUNT(*) AS Total_Orders,          -- Count total orders for each country
    SUM(Quantity) AS Total_Quantity,    -- Sum of all quantities sold
    AVG(Price) AS Average_Price         -- Average price of items sold
FROM retail_data
GROUP BY Country;

-- Explanation:
-- This query aggregates data by country, counting the number of orders, summing the quantities, 
-- and calculating the average price for each country.

-- 3. Using WHERE Clause
SELECT *
FROM retail_data
WHERE Price > 20.00;

-- Explanation:
-- This query selects all records from the retail_data table where the price is greater than 20.

-- 4. Using GROUP BY with HAVING
SELECT 
    StockCode,
    SUM(Quantity) AS Total_Sold
FROM retail_data
GROUP BY StockCode
HAVING SUM(Quantity) > 100;

-- Explanation:
-- This query groups records by StockCode and returns only those StockCodes where the total quantity sold 
-- exceeds 100.

-- 5. Using LIKE Operator
SELECT *
FROM retail_data
WHERE Description LIKE '%gift%';

-- Explanation:
-- This query selects all records from retail_data where the description contains the word "gift".

-- 6. Using ORDER BY
SELECT *
FROM retail_data
ORDER BY InvoiceDate DESC;

-- Explanation:
-- This query selects all records from retail_data and orders them by InvoiceDate in descending order.

-- 7. Using IN Operator
SELECT *
FROM retail_data
WHERE Country IN ('France', 'Germany', 'UK');

-- Explanation:
-- This query selects all records from retail_data where the country is either France, Germany, or the UK.

-- 8. Using Window Functions
SELECT 
    Invoice,
    Quantity,
    SUM(Quantity) OVER (PARTITION BY Invoice ORDER BY StockCode) AS Running_Total
FROM retail_data;

-- Explanation:
-- This query calculates a running total of quantities for each invoice, partitioned by the invoice and 
-- ordered by StockCode. It gives a cumulative sum of quantities for items in each invoice.


-- 1. Customer Purchasing Behavior
SELECT 
    CustomerID,
    COUNT(Invoice) AS Purchase_Frequency,
    SUM(Price * Quantity) AS Total_Spend,
    AVG(Price * Quantity) AS Average_Order_Value
FROM retail_data
GROUP BY CustomerID;


-- 2. Calculate Customer Lifetime Value

SELECT 
    CustomerID,
    AVG(Price * Quantity) AS Average_Order_Value,
    COUNT(Invoice) AS Purchase_Frequency,
    (AVG(Price * Quantity) * COUNT(Invoice) * 12) AS CLV  -- Assuming an average customer lifespan of 12 months
FROM retail_data
GROUP BY CustomerID;


-- 3. Predict Potential Churn

SELECT 
    CustomerID,
    MAX(InvoiceDate) AS Last_Purchase_Date,
    DATEDIFF(CURRENT_DATE, MAX(InvoiceDate)) AS Days_Since_Last_Purchase
FROM retail_data
GROUP BY CustomerID
HAVING Days_Since_Last_Purchase > 180;  -- Customers who haven't purchased in the last 6 months




-- 1. Top-Selling Products

SELECT 
    Description,
    SUM(Quantity) AS Total_Sold
FROM retail_data
GROUP BY Description
ORDER BY Total_Sold DESC
LIMIT 10;



-- 2. Customer Spending by Country

SELECT 
    Country,
    SUM(Price * Quantity) AS Total_Spend
FROM retail_data
GROUP BY Country
ORDER BY Total_Spend DESC;


-- 3. Monthly Sales Trend

SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    SUM(Price * Quantity) AS Total_Sales
FROM retail_data
GROUP BY Month
ORDER BY Month;


















use ecommerce_analysis;


Select Country, count(CustomerID) as total_customers
from retail_data
group by Country;

-- Alternate same query when we don't need null values

select Country, count(CustomerID) as total_customers
from retail_data
where CustomerID is not null      -- Exclude rows where CustomerID is empty or NULL
group by Country;



-- SQL DATA CLEANING METHODS

-- 1. IDENTIFYING MISSING DATA
-- before cleaning, we must identify missing or null values. we can use the "ISNULL" condition to find missing data.

-- example
SELECT *
FROM retail_data
WHERE Invoice IS NULL 
   OR StockCode IS NULL 
   OR Description IS NULL 
   OR Quantity IS NULL 
   OR InvoiceDate IS NULL 
   OR Price IS NULL 
   OR CustomerID IS NULL 
   OR Country IS NULL;

-- 2. REMOVING DUPLICATE RECORDS
-- Duplicate records can skew analysis. use "DISTINCT" or "ROW_NUMBER() with PARTITION BY" to identify and remove duplicates.alter

-- Skew analysis means checking if data is unevenly distributed or biased, affecting the accuracy of results. 
-- Duplicate records can make certain values appear more frequently than they should, leading to 
-- misleading insights or results.

-- Example how to identify duplicate records from the table:

-- Selects the 'Invoice' column from the 'retail_data' table
SELECT Invoice, 
-- Selects the 'CustomerID' column, representing the unique identifier of the customer
       CustomerID, 
-- Selects the 'InvoiceDate' column, representing the date when the invoice was issued
       InvoiceDate,
-- Counts the number of records for each combination of 'CustomerID' and 'InvoiceDate'
       Count(*) OVER (PARTITION BY CustomerID, InvoiceDate) 
-- 'OVER (PARTITION BY ...)' ensures the count is calculated for each group of unique 'CustomerID' and 'InvoiceDate'
FROM retail_data; 
-- Specifies the table 'retail_data' from which to pull the data


-- Example How to remove the duplicate records:
-- Creates a Common Table Expression (CTE) named 'CTE'
WITH CTE AS (
    -- Selects 'Invoice', 'CustomerID', and 'InvoiceDate' from 'retail_data'
    SELECT Invoice, 
           CustomerID, 
           InvoiceDate,
           -- Assigns a unique row number to each record within the same 'CustomerID' and 'InvoiceDate' group
           ROW_NUMBER() OVER (PARTITION BY CustomerID, InvoiceDate ORDER BY Invoice) AS ROWNUM
           -- 'ROW_NUMBER()' assigns incremental numbers starting from 1 for each group defined by 'CustomerID' and 'InvoiceDate'
    FROM retail_data
)

-- Deletes rows from 'retail_data'
DELETE FROM retail_data
-- Specifies the condition for deletion: only invoices that have a 'ROWNUM' greater than 1
WHERE Invoice IN (
    -- Selects invoices from the CTE where the row number is greater than 1 (i.e., duplicates)
    SELECT Invoice 
    FROM CTE 
    WHERE ROWNUM > 1
);




-- 3. HANDLING MISSING DATA:
-- There are several strategies for handling missing data, including deletion, imputation, or replacement with default values.

-- example to delete rows with missing data

-- Deletes rows from the 'sales' table
DELETE FROM sales
-- Specifies the condition for deletion: rows where 'productname', 'saleamount', or 'saledate' is NULL
WHERE productname IS NULL 
   OR saleamount IS NULL 
   OR saledate IS NULL;

-- and if we want to replace missing values with default value,

-- Updates the 'sales' table by setting 'productname' to 'UNKNOWN'
UPDATE sales
SET productname = 'UNKNOWN'
-- Specifies that only rows where 'productname' is NULL will be updated
WHERE productname IS NULL;

-- Updates the 'sales' table by setting 'saleamount' to 0
UPDATE sales
SET saleamount = 0
-- Specifies that only rows where 'saleamount' is NULL will be updated
WHERE saleamount IS NULL;

-- Updates the 'sales' table by setting 'saledate' to '2024-02-09'
UPDATE sales
SET saledate = '2024-02-09'
-- Specifies that only rows where 'saledate' is NULL will be updated
WHERE saledate IS NULL;


-- 4. STANDARDIZING DATA
-- Standardizing data involves converting data to a consistent format.
-- for example, converting all text to lowercase or uppercase.

-- example, how to correct the inconsistencies in our data:

-- Updates the 'Customers' table by converting the 'country' column to uppercase
UPDATE Customers
SET country = UPPER(Country);
-- The 'UPPER()' function converts the value in the 'Country' column to uppercase for all rows



-- 5. CORRECTING DATA ENTRY ERRORS
-- DATA ENTRY ERRORS, LIKE MISSPELT words or incorrect values, can be corrected using sql.

-- example

-- Updates the 'products' table by setting 'productname' to 'phone'
UPDATE products
SET productname = 'phone'
-- Specifies that only rows where 'productname' is currently 'phonne' (misspelled) will be updated
WHERE productname = 'phonne';
