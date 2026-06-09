-- Her kullanici baglantisinda ayri calistirilir
USE AdventureWorks2022;
GO

-- Test 1: Veri okuma
BEGIN TRY
    SELECT TOP 1 SalesOrderID FROM Sales.SalesOrderHeader;
    PRINT '[BASARILI] Veri okuma yapildi';
END TRY
BEGIN CATCH
    PRINT '[BASARISIZ] Veri okuma: ' + ERROR_MESSAGE();
END CATCH

-- Test 2: DMV erisimi
BEGIN TRY
    SELECT COUNT(*) FROM sys.dm_db_index_usage_stats WHERE database_id = DB_ID();
    PRINT '[BASARILI] DMV erisimi yapildi';
END TRY
BEGIN CATCH
    PRINT '[BASARISIZ] DMV erisimi: ' + ERROR_MESSAGE();
END CATCH

-- Test 3: Indeks olusturma
BEGIN TRY
    CREATE INDEX IX_Test_Status ON Sales.SalesOrderHeader(Status);
    PRINT '[BASARILI] Indeks olusturuldu';
    DROP INDEX IX_Test_Status ON Sales.SalesOrderHeader;
END TRY
BEGIN CATCH
    PRINT '[BASARISIZ] Indeks olusturma: ' + ERROR_MESSAGE();
END CATCH
GO
