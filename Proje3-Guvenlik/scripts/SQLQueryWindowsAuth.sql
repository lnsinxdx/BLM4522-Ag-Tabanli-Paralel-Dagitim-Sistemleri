USE [master]
GO
CREATE LOGIN [DESKTOP-69U1T5J\cagla] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
use [master];
GO
USE [AdventureWorks2022]
GO
CREATE USER [desktop-69u1t5j\cagla] FOR LOGIN [DESKTOP-69U1T5J\cagla]
GO
USE [AdventureWorks2022]
GO
ALTER USER [desktop-69u1t5j\cagla] WITH DEFAULT_SCHEMA=[desktop-69u1t5j\cagla]
GO
USE [AdventureWorks2022]
GO
CREATE SCHEMA [desktop-69u1t5j\cagla] AUTHORIZATION [desktop-69u1t5j\cagla]
GO
USE [AdventureWorks2022]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [desktop-69u1t5j\cagla]
GO
