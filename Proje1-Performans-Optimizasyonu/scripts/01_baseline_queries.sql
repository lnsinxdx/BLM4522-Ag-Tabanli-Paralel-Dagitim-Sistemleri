-- Proje 1: Performans baseline sorguları
-- Bu sorgular daha sonra optimize edilecek

USE AdventureWorks2022;
GO

-- Önbelleği temizle (her test öncesi temiz ölçüm için)
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

-- Metrik toplama açık
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Sorgu 1: SARGable olmayan tarih filtresi (YEAR/MONTH fonksiyonu indeksi kullandırmıyor)
SELECT SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013 AND MONTH(OrderDate) = 7;
GO

-- Sorgu 2: Indekslenmemiş sütun üzerinde filtre (TotalDue)
SELECT SalesOrderID, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > 100000;
GO

-- Sorgu 3: Baştan joker karakterli LIKE (indeks kullanılamıyor)
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE LastName LIKE '%son';
GO

-- Sorgu 4: SELECT * ile büyük join (gereksiz veri çekiyor)
SELECT *
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE soh.OrderDate >= '2014-01-01';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
