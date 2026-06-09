-- Proje 1: Sorgu optimizasyonu - önce/sonra karşılaştırma
USE AdventureWorks2022;
GO

-- SORGU 1: Tarih filtresi optimizasyonu
-- Sorun: YEAR()/MONTH() fonksiyonları indeks kullanımını engelliyor

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Öncesi: fonksiyon kullanımı (yavaş)
SELECT SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013 AND MONTH(OrderDate) = 7;
GO

-- Sonrası: tarih aralığı kullanımı (hızlı)
SELECT SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2013-07-01' AND OrderDate < '2013-08-01';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


-- SORGU 3: LIKE optimizasyonu
-- Sorun: '%son' baştan joker karakter, indeks kullanılamıyor


DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Öncesi: baştan joker karakter (yavaş)
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE LastName LIKE '%son';
GO

-- Sonrası: sondan joker karakter (hızlı, indeks kullanabilir)
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE LastName LIKE 'Son%';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


-- SORGU 4: SELECT * ve büyük join optimizasyonu
-- Sorun: SELECT * gereksiz sütun çekiyor, indeks kullanımını zorlaştırıyor


DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Öncesi: SELECT * ile tüm sütunlar (yavaş)
SELECT *
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE soh.OrderDate >= '2014-01-01';
GO

-- Sonrası: sadece gerekli sütunlar (hızlı)
SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    p.Name AS UrunAdi,
    sod.OrderQty,
    sod.LineTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE soh.OrderDate >= '2014-01-01';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
