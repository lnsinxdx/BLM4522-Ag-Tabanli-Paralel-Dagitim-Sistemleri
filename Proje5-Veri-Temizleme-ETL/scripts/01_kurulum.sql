-- Proje 5 icin calisma veritabani ve sema yapisi

USE master;
GO

IF DB_ID('Proje5_ETL') IS NOT NULL
BEGIN
    ALTER DATABASE Proje5_ETL SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Proje5_ETL;
END
GO

CREATE DATABASE Proje5_ETL;
GO

USE Proje5_ETL;
GO

-- kaynak: ham/staging veri | temiz: temizlenmis veri | hedef: yuklenecek tablolar
CREATE SCHEMA kaynak;
GO
CREATE SCHEMA temiz;
GO
CREATE SCHEMA hedef;
GO
