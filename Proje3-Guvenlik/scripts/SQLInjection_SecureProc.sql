USE AdventureWorks2022
GO

-- Guvenli saklanan prosedur: parametreli sorgu kullanarak SQL Injection'a karsi koruma saglar
CREATE OR ALTER PROCEDURE dbo.SearchProduct_Secure
    @SearchTerm NVARCHAR(500)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @params NVARCHAR(MAX)
    
    -- GUVENLI YONTEM: sp_executesql ile parametreli sorgu
    -- Kullanici girdisi SQL kodu olarak degil, deger olarak islenir
    SET @sql = N'SELECT ProductID, Name, ProductNumber, ListPrice 
                 FROM Production.Product 
                 WHERE Name = @term'
    
    SET @params = N'@term NVARCHAR(500)'
    
    PRINT N'Çalıştırılan sorgu: ' + @sql
    PRINT N'Parametre degeri: ' + @SearchTerm
    
    -- sp_executesql sorguyu ve parametreyi ayrı tutar
    -- Saldirganin girdisi asla SQL kodu olarak calistirilmaz
    EXEC sp_executesql @sql, @params, @term = @SearchTerm
END
GO

-- Normal kullanim - ayni sonucu vermeli (1 satir)
EXEC dbo.SearchProduct_Secure @SearchTerm = N'Blade'

-- Saldiri 1 tekrar - bu sefer 0 satir donmeli (saldiri basarisiz)
EXEC dbo.SearchProduct_Secure @SearchTerm = N''' OR 1=1 --'

-- Saldiri 2 tekrar - 0 satir donmeli (saldiri basarisiz)
EXEC dbo.SearchProduct_Secure @SearchTerm = N''' UNION SELECT BusinessEntityID, FirstName, LastName, CAST(EmailPromotion AS MONEY) FROM Person.Person --'

-- Saldiri 3 tekrar - hicbir tablo silinmemeli, sadece 0 satir donmeli
CREATE TABLE dbo.TestTable2 (ID INT, Data NVARCHAR(50))
INSERT INTO dbo.TestTable2 VALUES (1, 'Test Verisi')
GO

EXEC dbo.SearchProduct_Secure @SearchTerm = N'''; DROP TABLE dbo.TestTable2; --'

-- Tablo hala duruyor mu? Evet - saldiri basarisiz
SELECT * FROM dbo.TestTable2
