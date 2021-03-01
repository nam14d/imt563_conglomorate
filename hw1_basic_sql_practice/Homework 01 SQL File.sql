/* IMT 563 Winter 2021
   Homework 01 - SQL Practice
   Nicholas Marangi
*/

USE WorldWideImporters

-- 1. What are the FullNames, Emails and Phone Numbers of all the people considered employees?

SELECT 
   FullName,
   EmailAddress,
   PhoneNumber
FROM 
   [Application].[People]
WHERE 
   IsEmployee = 1;

-- 2. What are the Names, PostalCode, WebsiteURL for all Customers within the 'Supermarket' category?

SELECT 
    cust.CustomerName,
    cust.PostalPostalCode,
    cust.WebsiteURL,
    custcat.CustomerCategoryName
FROM 
  [Sales].[Customers] AS cust
JOIN 
  [Sales].[CustomerCategories] AS custcat
ON 
  cust.CustomerCategoryID = custcat.CustomerCategoryID
WHERE 
  custcat.CustomerCategoryName = 'Supermarket';

-- 3. What are the Names, UnitPrice, TypicalWeightPerUnit of all the Stock Items which have a UnitPrice > 30
-- ordered by the highest UnitPrice / TypicalWeightPerUnit?

SELECT
    StockItemName,
    UnitPrice,
    TypicalWeightPerUnit,
    FLOOR(UnitPrice/TypicalWeightPerUnit) AS PriceByUnitWeight
FROM
    [Warehouse].[StockItems]
WHERE
    UnitPrice > 30
ORDER BY
    (UnitPrice/TypicalWeightPerUnit) DESC

-- 4. For all Sales Orders made in the year 2014, what is the FullName of the SalesPerson and their Total number of orders, 
-- in order of greatest TotalOrders?

SELECT
    people.FullName,
    COUNT(orders.OrderID) AS OrderCount
FROM
    [Sales].[Orders] AS orders
JOIN 
    [Application].[People] AS people
ON 
    orders.SalespersonPersonID = people.PersonID
WHERE 
    YEAR(orders.OrderDate) = '2014'
GROUP BY 
    people.FullName
ORDER BY
    OrderCount DESC

-- 5.How many Customers have the word 'Toy' anywhere in their name as well as a Phone Number starting with a
-- (240) Area Code?

SELECT 
    COUNT(CustomerID) AS Toy240CustomersCount
FROM 
    [Sales].[Customers] AS cust
WHERE 
    cust.CustomerName LIKE '%Toy%' 
AND 
    cust.PhoneNumber LIKE '(240)%'

-- 6. What are the OrderDates, PickingCompletedDates, the difference in DAYS between the two dates, and the name of the
-- person in charge of Picking the Sales Orders with a difference in days greater than 100, in order of greatest day difference?

SELECT 
    people.FullName, 
    orders.OrderDate, 
    CONVERT(DATE, orders.PickingCompletedWhen) AS PickingCompletedDate, 
    DATEDIFF(day, orders.OrderDate, orders.PickingCompletedWhen) AS DeliveryTimeInDays
FROM
    [Application].[People] AS people
JOIN 
    [Sales].[Orders] AS orders
ON 
    people.PersonID = orders.PickedByPersonID
WHERE
    DATEDIFF(day, orders.OrderDate, orders.PickingCompletedWhen) > 100 
ORDER BY
    DeliveryTimeInDays DESC

-- 7. On what dates did the Average Vehicle Temperature between the two chiller sensors exceed the threshold of 4.9, 
-- and what was the Average Temperature in order of most recent?

SELECT 
    RecordedWhen, 
    AVG(Temperature) AS AverageTemp
FROM 
    [Warehouse].[VehicleTemperatures]
GROUP BY 
    RecordedWhen
HAVING 
    AVG(Temperature) > 4.9
ORDER BY 
    RecordedWhen DESC

-- 8. What are the Names of the top 5 suppliers by total FINALIZED purchase orders created by WWI?

SELECT TOP(5)
   supplier.SupplierName,
   supplier.SupplierID,
   COUNT(porder.PurchaseOrderID) AS TotalFinalizedOrders
FROM
   [Purchasing].[Suppliers] AS supplier
JOIN 
   [Purchasing].[PurchaseOrders] AS porder
ON 
   supplier.SupplierID = porder.SupplierID
WHERE
   porder.IsOrderFinalized = 1
GROUP BY
   supplier.SupplierName, supplier.SupplierID
ORDER BY
   TotalFinalizedOrders DESC

-- 9. What is the Customer, City, StateProvince Names, DeliveryPostalCode and LatestRecordedPopulation of 
-- all Customers with a delivery City within Washington which have a LatestRecordedPopulation > 2000?

SELECT 
    cust.CustomerName, 
    cust.CustomerID, 
    city.CityName, 
    st.StateProvinceName, 
    cust.DeliveryPostalCode, 
    city.LatestRecordedPopulation
FROM 
    [Application].[Cities] AS city
JOIN 
    [Application].[StateProvinces] as st
ON 
    city.StateProvinceID = st.StateProvinceID
JOIN 
    [Sales].[Customers] as cust
ON 
    city.CityID = cust.DeliveryCityID
WHERE 
    city.LatestRecordedPopulation > 2000
AND
    st.StateProvinceCode = 'WA'

-- 10. What is the name of the StockItem with the most discrete units shipped by WWI through sales orders
-- and how many units have they sold of that StockItem in total?

SELECT TOP 1
    sitem.StockItemName,
    sitem.StockItemID,
    SUM(oline.Quantity) AS UnitsShippedThroughSalesOrders
FROM
    [Warehouse].[StockItems] as sitem
JOIN
    [Sales].[OrderLines] as oline
ON
    sitem.StockItemID = oline.StockItemID
GROUP BY
    sitem.StockItemName,
    sitem.StockItemID
ORDER BY
    UnitsShippedThroughSalesOrders DESC

-- Extra Credit (Optional)

-- 1. What is the FullName of the Customer who spent the most in total (UnitPrice * Quantity) when combining all Orders from the years 2015 and 2016
-- and what was their total spend in both of those years individually as well as combined?


-- 2. What is the name of the most purchased StockItem by quantity for each customer and how many times did that customer buy it in total?