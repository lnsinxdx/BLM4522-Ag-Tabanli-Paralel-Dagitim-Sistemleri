-- Indeks yönetimi
USE AdventureWorks2022;
GO

-- Indeks oluşturmadan önceki performans

-- Önbelleği temizle
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Sorgu 2 (öncesi): TotalDue filtresi - indeks yok
SELECT SalesOrderID, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > 100000;
GO

-- Sorgu 4 (öncesi): Büyük join - OrderDate filtresi
SELECT SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2014-01-01';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- INDEKS OLUŞTURMA

-- Indeks 1: DMV önerisi - TotalDue üzerinde (tahmini %94.72 iyileşme)
CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_TotalDue
ON Sales.SalesOrderHeader (TotalDue)
INCLUDE (CustomerID);
GO

-- Indeks 2: OrderDate üzerinde (Sorgu 1 ve 4 için)
CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_OrderDate
ON Sales.SalesOrderHeader (OrderDate)
INCLUDE (SalesOrderID, TotalDue);
GO

-- Oluşturulan indeksleri doğrula
SELECT
    i.name AS indeks_adi,
    i.type_desc AS indeks_tipi,
    COL_NAME(ic.object_id, ic.column_id) AS sutun_adi,
    ic.is_included_column AS dahil_mi
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('Sales.SalesOrderHeader')
    AND i.name IN ('IX_SalesOrderHeader_TotalDue', 'IX_SalesOrderHeader_OrderDate')
ORDER BY i.name, ic.key_ordinal;
GO

-- Indeks oluşturduktan sonraki performans

-- Önbelleği tekrar temizle
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Sorgu 2 (sonrası): TotalDue filtresi - artık indeks var
SELECT SalesOrderID, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > 100000;
GO

-- Sorgu 4 (sonrası): OrderDate filtresi - artık indeks var
SELECT SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2014-01-01';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
