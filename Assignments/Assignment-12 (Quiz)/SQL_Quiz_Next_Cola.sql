--Q1. List top 5 customers by total order amount.
--Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.

SELECT TOP 5
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(so.TotalAmount) AS TotalSpent
FROM customer c
JOIN salesorder so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpent DESC;

--Q2. Find the number of products supplied by each supplier.
--Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(p.ProductID) AS ProductCount
FROM supplier s
JOIN purchaseorder po ON s.SupplierID = po.SupplierID
JOIN purchaseorderdetail pod ON po.OrderID = pod.OrderID
JOIN product p ON pod.ProductID = p.ProductID
GROUP BY s.SupplierID, s.Name
HAVING COUNT(p.ProductID) > 10;

--Q3. Identify products that have been ordered but never returned.
--Show ProductID, ProductName, and total order quantity.

SELECT
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM product p
JOIN salesorderdetail sod ON p.ProductID = sod.ProductID
LEFT JOIN returndetail rd ON p.ProductID = rd.ProductID
WHERE rd.ProductID IS NULL
GROUP BY p.ProductID, p.Name;

--Q4. For each category, find the most expensive product.
--Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.

SELECT
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM product p
JOIN category c ON p.CategoryID = c.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM product p2
    WHERE p2.CategoryID = p.CategoryID
);

--Q5. List all sales orders with customer name, product name, category, and supplier.
--For each sales order, display:
--OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

SELECT
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM salesorder so
JOIN customer c ON so.CustomerID = c.CustomerID
JOIN salesorderdetail sod ON so.OrderID = sod.OrderID
JOIN product p ON sod.ProductID = p.ProductID
JOIN category cat ON p.CategoryID = cat.CategoryID
JOIN purchaseorderdetail pod ON p.ProductID = pod.ProductID
JOIN purchaseorder po ON pod.OrderID = po.OrderID
JOIN supplier s ON po.SupplierID = s.SupplierID;

--Q6. Find all shipments with details of warehouse, manager, and products shipped.
--Display:
--ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.

SELECT
    sh.ShipmentID,
    w.WarehouseID,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    sh.TrackingNumber
FROM shipment sh
JOIN warehouse w ON sh.WarehouseID = w.WarehouseID
JOIN employee e ON w.ManagerID = e.EmployeeID
JOIN shipmentdetail sd ON sh.ShipmentID = sd.ShipmentID
JOIN product p ON sd.ProductID = p.ProductID;

--Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.

SELECT
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM (
    SELECT
        c.CustomerID,
        c.Name AS CustomerName,
        so.OrderID,
        so.TotalAmount,
        RANK() OVER (PARTITION BY c.CustomerID ORDER BY so.TotalAmount DESC) AS rnk
    FROM customer c
    JOIN salesorder so ON c.CustomerID = so.CustomerID
) rankedOrders
WHERE rnk <= 3;


--Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.

SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) AS PrevQuantity,
    LEAD(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) AS NextQuantity
FROM salesorderdetail sod
JOIN salesorder so ON sod.OrderID = so.OrderID
JOIN product p ON sod.ProductID = p.ProductID;


--Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
--CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.

CREATE VIEW vw_CustomerOrderSummary AS
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(so.OrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM customer c
LEFT JOIN salesorder so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name;

--Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.

CREATE PROCEDURE sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SELECT
        s.SupplierID,
        s.Name AS SupplierName,
        SUM(sod.TotalAmount) AS TotalSalesAmount
    FROM supplier s
    JOIN purchaseorder po ON s.SupplierID = po.SupplierID
    JOIN purchaseorderdetail pod ON po.OrderID = pod.OrderID
    JOIN product p ON pod.ProductID = p.ProductID
    JOIN salesorderdetail sod ON p.ProductID = sod.ProductID
    WHERE s.SupplierID = @SupplierID
    GROUP BY s.SupplierID, s.Name;
END;