-- Yedekleme zincirini göstermek için test tablosu oluştur
IF OBJECT_ID('dbo.YedekTest', 'U') IS NOT NULL
    DROP TABLE dbo.YedekTest;

CREATE TABLE dbo.YedekTest (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Aciklama NVARCHAR(100),
    KayitZamani DATETIME2 DEFAULT SYSDATETIME()
);

-- Tam yedekten önceki ilk kayıt
INSERT INTO dbo.YedekTest (Aciklama) VALUES ('Tam yedekten once eklendi');

-- Tam yedek al
BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Backup\Proje2\AW2022_Full.bak'
WITH FORMAT, INIT,
     NAME = 'AdventureWorks2022 Tam Yedek',
     STATS = 10;
