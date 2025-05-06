USE AdventureWorks 
GO 
set statistics time ON; 
set statistics IO ON; 

-- =============================================
-- aliasy
-- =============================================

	SELECT 
		DB_NAME(database_id) AS [Database Name], 
		CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 1)) AS io_in_mb,
		CAST(SUM(num_of_bytes_read)/1048576 AS DECIMAL(12, 1)) AS io_reads_in_mb,
		CAST(SUM(num_of_bytes_written)/1048576 AS DECIMAL(12, 1)) AS io_writes_in_mb 
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS dm_io_stats
	GROUP BY database_id

-- drugi sposób aliasowania
	SELECT 
		[Database Name] = DB_NAME(database_id), 
		io_in_mb = CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 1))  ,
		io_reads_in_mb = CAST(SUM(num_of_bytes_read)/1048576 AS DECIMAL(12, 1)),
		io_writes_in_mb = CAST(SUM(num_of_bytes_written)/1048576 AS DECIMAL(12, 1)) 
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS dm_io_stats
	GROUP BY database_id






-- Co jest niepoprawnego w tym zapytaniu? 

select
	SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
	SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID TerritoryID, 
	BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, 
	CurrencyRateID, SubTotal, TaxAmt, Freight TotalDue, Comment, rowguid, ModifiedDate
from Sales.SalesOrderHeader





-- to samo zapytanie z aliasami

select
	h.SalesOrderID, h.RevisionNumber, h.OrderDate, h.DueDate, h.ShipDate, h.Status, 
	h.OnlineOrderFlag, h.SalesOrderNumber, h.PurchaseOrderNumber, h.AccountNumber, 
	h.CustomerID, h.SalesPersonID, h.TerritoryID, h.BillToAddressID, h.ShipToAddressID, 
	h.ShipMethodID, h.CreditCardID, h.CreditCardApprovalCode, h.CurrencyRateID, h.SubTotal, 
	h.TaxAmt, h.Freight h.TotalDue, h.Comment, h.rowguid, h.ModifiedDate
from Sales.SalesOrderHeader h



-- dodajmy jeszcze formatowanie
select
h.SalesOrderID, 
	h.RevisionNumber, 
	h.OrderDate, 
	h.DueDate,
	h.ShipDate, 
	h.Status, 
	h.OnlineOrderFlag, 
	h.SalesOrderNumber, 
	h.PurchaseOrderNumber, 
	h.AccountNumber, 
	h.CustomerID, 
	h.SalesPersonID, 
	h.TerritoryID, 
	h.BillToAddressID, 
	h.ShipToAddressID, 
	h.ShipMethodID, 
	h.CreditCardID, 
	h.CreditCardApprovalCode, 
	h.CurrencyRateID,
	h.SubTotal, 
	h.TaxAmt, 
	h.Freight h.TotalDue, 
	h.Comment, 
	h.rowguid, 
	h.ModifiedDate
from Sales.SalesOrderHeader h



-- =============================================
-- SELECT * 
-- =============================================
use tempdb;

drop table if exists dbo.t1;

-- utwórzmy prosta tabelke
create table dbo.t1 (
	col1 int,
	col2 nvarchar(100)
);



-- wstaw jakies dane
insert into dbo.t1 values (1, 'val1');




select * from dbo.t1;
go






-- utwórz widok wyswietlajacy dane z tabeli 
drop view if exists dbo.v1;
go

create view dbo.v1
as
select * from dbo.t1;
GO





-- odpytajmy widok
select * from dbo.v1;





-- dodajmy kolumne
alter table dbo.t1 add col3 nvarchar(100) not null constraint DF_Added default 'ADDED!';

select * from dbo.t1;








-- odpytajmy widok
select * from dbo.v1;







-- Jak wyglada definicja naszego widoku?
exec sp_helptext 'dbo.v1';





-- Rozwiazanie #1
exec sp_refreshview 'dbo.v1';

select * from dbo.v1;








-- rozwiazanie #2 - 
alter table dbo.t1 drop constraint DF_Added;
alter table dbo.t1 drop column col3;

select * from dbo.v1;  -- immediate error

exec sp_refreshview 'dbo.v1';







-- problem rozwiazany
select * from dbo.v1;


-- =============================================
-- Podzapytania w kolumnach
-- =============================================

SELECT 
    SalesOrderID,
    (SELECT Name FROM Production.Product WHERE ProductID = sod.ProductID) AS ProductName,
    OrderQty
FROM Sales.SalesOrderDetail sod
WHERE sod.ProductID BETWEEN 700 AND 710;





SELECT 
    sod.SalesOrderID,
    p.Name AS ProductName,
    sod.OrderQty
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE sod.ProductID BETWEEN 700 AND 710;



SELECT 
    sod.SalesOrderID,
    p.Name AS ProductName,
    sod.OrderQty
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE 
	sod.ProductID >=  700 
	AND sod.ProductID <= 710;



-- =============================================
-- funkcja na kolumnie w WHERE
-- =============================================

SELECT 
SalesOrderID, 
OrderDate
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013;
GO 


SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01';






-- =============================================
-- prosty plan wykonania
-- =============================================
	
	
	
	SELECT DISTINCT(City) FROM Person.Address
	GO





-- =============================================
--Ostrzerzenia w planach wykonania
-- =============================================




	--ColumnsWithNoStatistics

	DROP STATISTICS HumanResources.Employee.[_WA_Sys_00000011_5DCAEF64]
	GO

	ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS OFF
	GO


	SELECT * FROM HumanResources.Employee
	WHERE VacationHours = 48

	ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS ON










	--SpillToTempDb 

		SELECT
			h.OrderDate,
			calculatedValue = SUM(d.UnitPrice * d.OrderQty)
		FROM [Sales].[SalesOrderHeaderBig] AS h
		INNER JOIN [Sales].[SalesOrderDetailBig] AS d
			ON h.SalesOrderID = d.SalesOrderID
		GROUP BY
			h.OrderDate
		ORDER BY
			h.OrderDate;










-- =============================================
-- Variables – SET vs SELECT
-- =============================================

DECLARE @bonus MONEY;

SELECT @bonus = Bonus
FROM Sales.SalesPerson; -- No ORDER BY, so value is unpredictable



SELECT @bonus;

-- Safer with TOP 1 and ORDER BY:
SELECT TOP 1 @bonus = Bonus
FROM Sales.SalesPerson
ORDER BY ModifiedDate DESC;



SELECT @bonus;









-- =============================================
-- Implicit Conversion – VARCHAR vs INT
-- =============================================
-- Problem: implicit conversion can cause index scan instead of seek
-- Let's say NationalIDNumber is VARCHAR, and we compare it to INT






SELECT *
FROM HumanResources.Employee
WHERE NationalIDNumber = 123456; -- Implicit conversion from INT to VARCHAR









-- Better: use matching data type
SELECT *
FROM HumanResources.Employee
WHERE NationalIDNumber = '123456'; -- No conversion, better performance
GO 





--========================================
--CTE 
--========================================

WITH CTE_Product AS 
	(
		SELECT 
			[ProductID], 
			[Name]
		FROM [Production].[Product]
		WHERE [Color] IN ('white', 'black')
	)
	SELECT
	* 
	FROM [Sales].[SalesOrderDetail] AS sod
	INNER JOIN CTE_Product AS p
		ON p.ProductID = sod.ProductID



-- CTE & cache data

; WITH CTE AS (
	SELECT NEWID() AS id
	) 

SELECT id FROM CTE 
UNION ALL
SELECT id FROM CTE 


SET STATISTICS IO ON; 
SET STATISTICS TIME ON; 
GO 

--CTE vs Temp Table vs Table variable

-- CTE
WITH t (customerid, lastorderdate) AS 
 (SELECT customerid, max(orderdate) 
  FROM sales.SalesOrderHeader
  GROUP BY customerid)
SELECT * 
FROM sales.salesorderheader soh
INNER JOIN t ON soh.customerid=t.customerid AND soh.orderdate=t.lastorderdate
GO





-- Temporary table
CREATE TABLE #temptable (customerid [int] NOT NULL PRIMARY KEY, lastorderdate [datetime] NULL);

INSERT INTO #temptable
SELECT customerid, max(orderdate) as lastorderdate 
FROM sales.SalesOrderHeader
GROUP BY customerid;

SELECT * 
FROM sales.SalesOrderHeader soh
INNER JOIN #temptable t ON soh.customerid=t.customerid AND soh.orderdate=t.lastorderdate

DROP TABLE #temptable
GO



-- Table variable
DECLARE @tablevariable TABLE (customerid [int] NOT NULL PRIMARY KEY, lastorderdate [datetime] NULL);

INSERT INTO @tablevariable
SELECT customerid, max(orderdate) as lastorderdate 
FROM sales.SalesOrderHeader
GROUP BY customerid;

SELECT * 
FROM sales.salesorderheader soh
INNER JOIN @tablevariable t ON soh.customerid=t.customerid AND soh.orderdate=t.lastorderdate
GO


--========================================

--przyk?ad z?ego wykorzystania CTE

with _AggregateGlobal AS
(
	SELECT SUM(SOD.OrderQty) as SumProductQuantity,
			AVG(SOD.OrderQty) as AvgProductQuantity
	FROM Sales.SalesOrderDetail SOD
), _AggregateCustomer AS
(
	SELECT SH.CustomerID,
			SUM(SOD.OrderQty) as SumProductQuantity,
			AVG(SOD.OrderQty) as AvgProductQuantity
	FROM Sales.SalesOrderDetail SOD 
	JOIN Sales.SalesOrderHeader SH
	ON SH.SalesOrderID = SOD.SalesOrderID
	GROUP BY SH.CustomerID
)
SELECT SOD.SalesOrderID, 
	   SOD.ProductID,
	   SOD.OrderQty,  
	   SH.CustomerID,
	   CAST(100. * SOD.OrderQty / AC.SumProductQuantity AS numeric(10,2)) as SumPercentByCustomer,
	   SOD.OrderQty - AC.AvgProductQuantity AS DifferenceByCustomer,
	   CAST(100. * SOD.OrderQty / AG.SumProductQuantity AS numeric(10,2)) as SumPercentAll,
	   SOD.OrderQty - AG.AvgProductQuantity AS DifferencePercentAll
FROM Sales.SalesOrderDetail SOD
JOIN Sales.SalesOrderHeader SH
ON SOD.SalesOrderID = SH.SalesOrderID
JOIN _AggregateCustomer AC 
ON AC.CustomerID = SH.CustomerID
CROSS JOIN _AggregateGlobal AG
--WHERE SH.CustomerID = 29611








--Jak to npisa? poprawnie 
SELECT SOD.SalesOrderID, 
	   SOD.ProductID,
	   SOD.OrderQty,  
	   SH.CustomerID, 
	   CAST(100. * SOD.OrderQty / SUM(SOD.OrderQty) OVER (PARTITION BY SH.CustomerId) AS numeric(10,2)) as SumPercentByCustomer,
	   SOD.OrderQty - AVG(SOD.OrderQty) OVER (PARTITION BY SH.CustomerId) AS DifferenceByCustomer,
	   CAST(100. * SOD.OrderQty / SUM(SOD.OrderQty) OVER () AS numeric(10,2)) as SumPercentAll,
	   SOD.OrderQty - AVG(SOD.OrderQty) OVER () AS DifferencePercentAll
FROM Sales.SalesOrderDetail SOD
JOIN Sales.SalesOrderHeader SH
ON SOD.SalesOrderID = SH.SalesOrderID
--WHERE SH.CustomerID = 29611
GO 





--========================================
--CROSS APPLY
--========================================



--Utworzenie funkcji

CREATE OR ALTER FUNCTION [dbo].[CustomerLastTransactionDate]
(
   @CustomerID int
   ,@topn int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT TOP (@topn) 
		  sc.CustomerID,
		  fis.OrderDate 
	FROM 
		  [Sales].[Customer] AS sc
	JOIN 
		  [Sales].[SalesOrderHeader] AS fis
	ON 
		  fis.CustomerID=sc.CustomerID
	WHERE 
		  sc.CustomerID=@CustomerID
GO


SELECT 
    * 
FROM 
    dbo.[CustomerLastTransactionDate] (11001,2)
GO 


--CROSS APPLY

SELECT 
      dc.CustomerID,
      t.OrderDate
FROM 
      [Sales].[Customer] AS dc
CROSS APPLY 
      [dbo].[CustomerLastTransactionDate](dc.CustomerID,2) AS t
ORDER BY 
      dc.CustomerID ASC,
      t.OrderDate DESC
GO 



--optymalizacja dzi?ki cross apply

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO 
SELECT 
    COUNT_BIG(soh.[OrderDate]) AS ca_count
FROM 
    Sales.SalesOrderHeaderBig AS soh
INNER JOIN  
    Sales.SalesOrderDetailBig AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
GO 
----------------------

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO 
SELECT 
    COUNT_BIG(soh.[OrderDate]) AS ca_count
FROM 
    Sales.SalesOrderDetailBig AS sod
CROSS APPLY (SELECT [OrderDate] FROM Sales.SalesOrderHeaderBig AS sh
			WHERE sh.SalesOrderID = sod.SalesOrderID )AS soh
    


--U?ycie CROSS APPLY W WARUNKACH

GO 
PRINT 'use not in';

SELECT CustomerID 
FROM Sales.Customer 
WHERE CustomerID NOT IN 
(
  SELECT CustomerID 
  FROM Sales.SalesOrderHeaderBig
);
GO 



PRINT 'Use OUTER APPLY';

SELECT c.CustomerID 
FROM Sales.Customer AS c
OUTER APPLY 
(
 SELECT CustomerID 
   FROM Sales.SalesOrderHeaderBig
   WHERE CustomerID = c.CustomerID
) AS h
WHERE h.CustomerID IS NULL;

GO 


PRINT 'USE LEFT JOIN';
SELECT c.CustomerID 
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeaderBig AS h
   ON h.CustomerID = c.CustomerID
WHERE h.CustomerID IS NULL; 


PRINT 'EXCEPT';
SELECT CustomerID 
FROM Sales.Customer AS c 
EXCEPT
SELECT CustomerID
FROM Sales.SalesOrderHeaderBig;
GO 


PRINT 'NOT EXISTS'; 
GO 
SELECT CustomerID 
FROM Sales.Customer AS c 
WHERE NOT EXISTS 
(
  SELECT 1 
    FROM Sales.SalesOrderHeaderBig
    WHERE CustomerID = c.CustomerID
);




