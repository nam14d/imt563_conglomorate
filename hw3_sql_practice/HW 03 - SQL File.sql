/****** IMT 563 Winter 2021  ******/
/****** Homework 03 - Advanced SQL  ******/
/****** Nicholas Marangi  ******/

-- Q1. List the FullName, PreferredName, and number of people with the same preferred name of each person. -- 

SELECT
    peop.FullName, 
    peop.PreferredName,
    COUNT(peop.PreferredName) OVER(PARTITION BY peop.PreferredName) AS NumberOfPeopleWithSharedName
FROM
    [Application].[People] AS peop
ORDER BY 
    peop.PreferredName;

-- Q2. List the CustomerName, CityName, and the number of customers who share the same city, filter for all customers with 2 or more customers in the same city. -- 

SELECT 
    *
FROM
    (SELECT 
        cust.CustomerName,
        city.CityName,
        COUNT(city.CityName) OVER(PARTITION BY city.CityName) AS CustomerCountInCity
    FROM 
        [Sales].[Customers] AS cust
    LEFT JOIN 
        [Application].[Cities] AS city
    ON 
        CityID = DeliveryCityID
    ) AS CustCityCount
WHERE 
    CustCityCount.CustomerCountInCity > 1;

-- Q3. List the CustomerName, CityName, StateProvinceName, CustomersPerState, LatestRecordedPopulation of the city and the ranking of each city’s population within -- 
--     its given StateProvince from highest to lowest city population. -- 

SELECT 
    cust.CustomerName,city.CityName,
    st.StateProvinceName,
    COUNT(cust.CustomerName) OVER(PARTITION BY st.StateProvinceID) AS CustomersPerState,
    city.LatestRecordedPopulation,
    RANK() OVER(PARTITION BY st.StateProvinceName ORDER BY city.LatestRecordedPopulation DESC) AS CityPopulationRank
FROM 
    [Application].[Cities] AS city
JOIN 
    [Application].[StateProvinces] AS st
ON 
    city.StateProvinceID = st.StateProvinceID
JOIN 
    [Sales].[Customers] AS cust
ON 
    city.CityID = cust.DeliveryCityID;

-- Q4. List the StockItemname, UnitPrice, TypicalWeightPerUnit, and the Ranking of highest UnitPrice, returning only the top 10 stock items by rank. -- 

SELECT TOP 10 
    StockItemName, 
    UnitPrice, 
    TypicalWeightPerUnit,
    RANK() OVER(ORDER BY UnitPrice DESC) AS RankByUnitPrice
FROM 
    [Warehouse].[StockItems];

-- Q5. List the SalesPersonFullName, CustomerName, CityName, OrderDate, and the number of Orders that the given Salesperson was a part of for the given year (2014) -- 
--     and month (6).

SELECT
    peop.FullName AS SalesPersonFullName,
    cust.CustomerName,
    city.CityName,
    orders.OrderDate,
    COUNT(orders.OrderID) OVER(PARTITION BY peop.FullName) AS OrderCountBySalesperson
FROM 
    [Application].[People] AS peop
JOIN 
    [Sales].[Orders] AS orders 
ON 
    peop.PersonID = orders.SalespersonPersonID
JOIN 
    [Sales].[Customers] AS cust
ON 
    orders.CustomerID = cust.CustomerID
JOIN 
    [Application].[Cities] AS city
ON 
    cust.DeliveryCityID = city.CityID
WHERE 
    YEAR(orders.OrderDate) = 2014 
AND 
    MONTH(orders.OrderDate) = 6;

-- Q6. List the CustomerName, CustomerCategoryName, CreditLimit, and the rank based on the highest CreditLimit within each CustomerCategory, filtered by a rank of 5 or lower. --- 

SELECT 
    * 
FROM
    (SELECT 
        cust.CustomerName,
        custcat.CustomerCategoryName,
        cust.CreditLimit,
        RANK() OVER(PARTITION BY custcat.CustomerCategoryName ORDER BY cust.CreditLimit DESC) AS CreditLimitRank
    FROM 
        [Sales].[Customers] AS cust
    JOIN 
        [Sales].[CustomerCategories] AS custcat
    ON 
        cust.CustomerCategoryID = custcat.CustomerCategoryID) AS NameCatLimitRank
WHERE 
    NameCatLimitRank.CreditLimitRank <= 5;

-- Q7. List the SupplierName, StockItemName, OrderedOuters, ExpectedUnitPricePerOuter, # of Orders per Supplier and StockItem, -- 
--     the sum of OrderedOuters per Supplier and StockItem, and the total spend per Supplier and StockItem.

WITH NamesOutersPriceCountSum(SupplierName,StockItemName,OrderedOuters,ExpectedUnitPricePerOuter,OrderCountBySupplierAndStockItemName,SumOutersBySupplierAndStockItemName) AS(
    SELECT 
        supp.SupplierName,
        stockit.StockItemName,
        purordline.OrderedOuters,
        purordline.ExpectedUnitPricePerOuter,
        COUNT(purordline.OrderedOuters) OVER(PARTITION BY supp.SupplierName,stockit.StockItemName) AS OrderCountBySupplierAndStockItemName,
        SUM(purordline.OrderedOuters) OVER(PARTITION BY supp.SupplierName, stockit.StockItemName) AS SumOutersBySupplierAndStockItemName
    FROM 
        [Purchasing].[Suppliers] AS supp
    JOIN 
        [Purchasing].[PurchaseOrders] AS purord
    ON 
        supp.SupplierID = purord.SupplierID
    JOIN 
        [Purchasing].[PurchaseOrderLines] AS purordline
    ON 
        purord.PurchaseOrderID = purordline.PurchaseOrderID
    JOIN 
        [Warehouse].[StockItems] AS stockit
    ON 
        purordline.StockItemID = stockit.StockItemID
)
-- END CTE -- 
SELECT 
    NamesOutersPriceCountSum.SupplierName,
    NamesOutersPriceCountSum.StockItemName,
    NamesOutersPriceCountSum.OrderedOuters,
    NamesOutersPriceCountSum.ExpectedUnitPricePerOuter,
    NamesOutersPriceCountSum.OrderCountBySupplierAndStockItemName,
    NamesOutersPriceCountSum.SumOutersBySupplierAndStockItemName,
    SUM(SumOutersBySupplierAndStockItemName * ExpectedUnitPricePerOuter) OVER(PARTITION BY SupplierName,StockItemName,OrderedOuters) AS TotalSpentBySupplierAndStockItemName
FROM 
    NamesOutersPriceCountSum;

-- Q8. List the CountryName, StateProvinceName, CityName, and the # of cities per country and state. -- 

SELECT
    city.CityName,
    st.StateProvinceName,
    country.CountryName,
    COUNT(city.CityID) OVER(PARTITION BY country.CountryID,st.StateProvinceID) AS NumCityPerStateAndCountry
FROM 
    [Application].[Cities] AS city
JOIN 
    [Application].[StateProvinces] AS st
ON 
    city.StateProvinceID = st.StateProvinceID
JOIN 
    [Application].[Countries] AS country
ON 
    country.CountryID = st.CountryID;

-- Q9. List the CustomerName, StockItemName, TotalQuantity by Customer and StockItem, and the Rank of the highest Quantity per Customer and StockItem, --
--     filtered by a rank of 5 or lower.

WITH CustomerStockItem_CDE(CustomerName,StockItemName,TotalQuantity) AS (
SELECT
    cust.CustomerName,
    stockit.StockItemName,
    SUM(ordline.Quantity) AS TotalQuantityByCustomerAndStockItem
FROM 
    [Sales].[Customers] AS cust
JOIN 
    [Sales].[Orders] AS orders
ON 
    cust.CustomerID = orders.CustomerID
JOIN 
    [Sales].[OrderLines] AS ordline
ON 
    ordline.OrderID = orders.OrderID
JOIN 
    [Warehouse].[StockItems] AS stockit
ON 
    stockit.StockItemID = ordline.StockItemID
GROUP BY 
    cust.CustomerName,stockit.StockItemName
)
-- END CDE -- 
SELECT 
    * 
FROM
    (SELECT  
        CustomerStockItem_CDE.CustomerName,
        CustomerStockItem_CDE.StockItemName,
        CustomerStockItem_CDE.TotalQuantity,
        RANK() OVER(PARTITION BY CustomerName ORDER BY TotalQuantity DESC) AS QuantityRank
    FROM 
        CustomerStockItem_CDE) AS CustnameStocknameQuantity
WHERE 
    CustnameStocknameQuantity.QuantityRank <= 5;

-- Q10. List the SupplierName, OrderYear, OrderMonth, TotalSpendBySupplier for a given Year and Month, and the rank by highest spend per month filtered --
--      by the ‘Farbrikam, Inc.’ supplier.

WITH SupplierOrdersYearMonth(SupplierName,OrderYear,OrderMonth,SpendPerMonth) AS(
    SELECT
        supp.SupplierName,
        YEAR(purord.OrderDate) AS OrdYear,
        MONTH(purord.OrderDate) AS OrdMonth,
        SUM(purordline.OrderedOuters * purordline.ExpectedUnitPricePerOuter) AS SpendPerSupplierByMonth
    FROM 
        [Purchasing].[Suppliers] AS supp
    JOIN 
        [Purchasing].[PurchaseOrders] AS purord
    ON 
        supp.SupplierID = purord.SupplierID
    JOIN 
        [Purchasing].[PurchaseOrderLines] AS purordline
    ON 
        purord.PurchaseOrderID = purordline.PurchaseOrderID
    GROUP BY 
        supp.SupplierName, YEAR(purord.OrderDate),MONTH(purord.OrderDate)
)
 -- END CDE --

SELECT 
    *
FROM 
    (SELECT 
        SupplierName,
        OrderYear,
        OrderMonth,
        SpendPerMonth,
        RANK() OVER(ORDER BY SpendPerMonth DESC) AS SpendingRank
    FROM 
        SupplierOrdersYearMonth) AS SupnameYearMonthSpendRank
WHERE
    SupnameYearMonthSpendRank.SupplierName LIKE 'Fab%';

-- EC1. List the OrderID, OrderDate, PickingCompleteWhen, TotalOrdersForYear, TotalOrdersForYearAndMonth, the amount of days difference --
--      between the OrderDate and PickingCompletedWhen date, the amount of days difference between the previous column mentioned and the next slowest order.

WITH IdDatePickingYordersMorders(OrderID,OrderDate,PickingCompletedWhen,OrdersPerYear,OrdersPerMonthAndYear,DaysTillPickup) AS (
    SELECT
        OrderID,
        OrderDate,
        PickingCompletedWhen,
        COUNT(OrderID) OVER(PARTITION BY YEAR(OrderDate)) AS OrdersPerYear,
        COUNT(OrderID) OVER(PARTITION BY YEAR(OrderDate),MONTH(OrderDate)) AS OrdersPerMonthAndYear,
        DATEDIFF(DAY,OrderDate,PickingCompletedWhen) AS DaysTillPickup
    FROM 
        [Sales].[Orders]
)
-- END CTE --

SELECT 
    OrderID,
    OrderDate,
    PickingCompletedWhen,
    OrdersPerYear,
    OrdersPerMonthAndYear,
    DaysTillPickup,
    DaysTillPickup - Lead(DaysTillPickup,1) OVER(ORDER BY DaysTillPickup DESC) AS DaysGreaterThanNextSlowest,
    RANK() OVER(ORDER BY DaysTillPickup DESC) AS LongestWaitForPickupRank
FROM 
    IdDatePickingYordersMorders;

-- EC2. List the CustomerName, the TotalSpend for 2014, the TotalSpend for 2015, the TotalSpend for 2016, the TotalSpend of all years combined, the rank by --
--      TotalSpend, and the difference between the TotalSpend of the previous highest rank and the current TotalSpend.

WITH CustomerPurchasingRecords_CTE(CustomerName,Quantity,UnitPrice,OrderDate) AS(
    SELECT
        cust.CustomerName,
        ordline.Quantity,
        ordline.UnitPrice,
        orders.OrderDate
    FROM 
        [Sales].[Customers] AS cust
    JOIN 
        [Sales].[Orders] AS orders
    ON 
        cust.CustomerID = orders.CustomerID
    JOIN 
        [Sales].[OrderLines] AS ordline
    ON 
        orders.OrderID = ordline.OrderID
),
-- END CTE 1 -- 
AggregatedCustomerPurchasingRecords_CTE(CustomerName,TotalSpend2014,TotalSpend2015,TotalSpend2016,TotalSpend) AS(

SELECT
    CustomerPurchasingRecords_CTE.CustomerName,
    Sales2014.TotalSpend2014,
    Sales2015.TotalSpend2015,
    Sales2016.TotalSpend2016,
    SUM(CustomerPurchasingRecords_CTE.Quantity * CustomerPurchasingRecords_CTE.UnitPrice) AS TotalSpend
FROM 
    CustomerPurchasingRecords_CTE
JOIN
    (SELECT 
        CustomerPurchasingRecords_CTE.CustomerName,
        SUM(CustomerPurchasingRecords_CTE.Quantity * CustomerPurchasingRecords_CTE.UnitPrice) AS TotalSpend2014
    FROM 
        CustomerPurchasingRecords_CTE
    WHERE 
        YEAR(CustomerPurchasingRecords_CTE.OrderDate) = 2014
    GROUP BY 
        CustomerPurchasingRecords_CTE.CustomerName) AS Sales2014
ON 
    Sales2014.CustomerName = CustomerPurchasingRecords_CTE.CustomerName
JOIN 
    (SELECT 
        CustomerPurchasingRecords_CTE.CustomerName,
        SUM(CustomerPurchasingRecords_CTE.Quantity * CustomerPurchasingRecords_CTE.UnitPrice) AS TotalSpend2015
    FROM 
        CustomerPurchasingRecords_CTE
    WHERE 
        YEAR(CustomerPurchasingRecords_CTE.OrderDate) = 2015
    GROUP BY 
        CustomerPurchasingRecords_CTE.CustomerName) AS Sales2015
ON 
    Sales2015.CustomerName = CustomerPurchasingRecords_CTE.CustomerName
JOIN 
    (SELECT 
        CustomerPurchasingRecords_CTE.CustomerName,
        SUM(CustomerPurchasingRecords_CTE.Quantity * CustomerPurchasingRecords_CTE.UnitPrice) AS TotalSpend2016
    FROM 
        CustomerPurchasingRecords_CTE
    WHERE 
        YEAR(CustomerPurchasingRecords_CTE.OrderDate) = 2016
    GROUP BY 
        CustomerPurchasingRecords_CTE.CustomerName) AS Sales2016
ON 
    Sales2016.CustomerName = CustomerPurchasingRecords_CTE.CustomerName
GROUP BY 
    CustomerPurchasingRecords_CTE.CustomerName,Sales2014.TotalSpend2014,Sales2015.TotalSpend2015,Sales2016.TotalSpend2016
)
-- END CTE 2 --
SELECT 
    CustomerName,
    TotalSpend2014,
    TotalSpend2015,
    TotalSpend2016,
    TotalSpend,
    RANK() OVER(ORDER BY TotalSpend DESC) AS WhaleRanking,
    TotalSpend - LAG(TotalSpend,1) OVER(ORDER BY TotalSpend DESC) AS AmountUnderNextRank
FROM 
    AggregatedCustomerPurchasingRecords_CTE;