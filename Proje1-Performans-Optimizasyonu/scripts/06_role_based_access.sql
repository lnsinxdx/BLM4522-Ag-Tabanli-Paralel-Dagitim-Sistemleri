-- Proje 1: Rol tabanli erisim kontrolu (performans yonetimi baglaminda)
-- Bu script rolleri olusturur. Yetki testleri 06_role_test.sql dosyasinda
-- ayri kullanici baglantilariyla yapilir.

-- 1. LOGIN OLUSTURMA (sunucu seviyesi)

USE master;
GO

-- Varsa eski login'leri temizle
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'perf_monitor_user')
    DROP LOGIN perf_monitor_user;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'perf_admin_user')
    DROP LOGIN perf_admin_user;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'app_user')
    DROP LOGIN app_user;
GO

CREATE LOGIN perf_monitor_user WITH PASSWORD = 'Monitor123!';
CREATE LOGIN perf_admin_user WITH PASSWORD = 'Admin123!';
CREATE LOGIN app_user WITH PASSWORD = 'App123!';
GO

-- Izleme rollerine sunucu seviyesi DMV erisimi (VIEW SERVER STATE)
GRANT VIEW SERVER STATE TO perf_monitor_user;
GRANT VIEW SERVER STATE TO perf_admin_user;
GO

-- =============================================
-- 2. VERITABANI KULLANICILARI OLUSTURMA
-- =============================================
USE AdventureWorks2022;
GO

CREATE USER perf_monitor_user FOR LOGIN perf_monitor_user;
CREATE USER perf_admin_user FOR LOGIN perf_admin_user;
CREATE USER app_user FOR LOGIN app_user;
GO


-- 3. ROL OLUSTURMA VE IZIN ATAMA


-- Rol 1: Performans Izleyici (DMV okur, veri okur, DEGISTIREMEZ)
CREATE ROLE db_performance_monitor;
GRANT VIEW DATABASE STATE TO db_performance_monitor;
ALTER ROLE db_datareader ADD MEMBER db_performance_monitor;
GO

-- Rol 2: Performans Yoneticisi (izleme + indeks olusturma/silme)
CREATE ROLE db_performance_admin;
GRANT VIEW DATABASE STATE TO db_performance_admin;
ALTER ROLE db_datareader ADD MEMBER db_performance_admin;
ALTER ROLE db_ddladmin ADD MEMBER db_performance_admin;
GO

-- Rol 3: Uygulama Kullanicisi (SADECE veri okuma)
CREATE ROLE db_application_user;
ALTER ROLE db_datareader ADD MEMBER db_application_user;
GO


-- 4. KULLANICILARI ROLLERE ATAMA

ALTER ROLE db_performance_monitor ADD MEMBER perf_monitor_user;
ALTER ROLE db_performance_admin ADD MEMBER perf_admin_user;
ALTER ROLE db_application_user ADD MEMBER app_user;
GO


-- 5. ROL VE IZINLERI DOGRULAMA

SELECT
    dp.name AS rol_adi,
    mp.name AS uye_adi,
    dp.type_desc AS rol_tipi
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.role_principal_id = dp.principal_id
JOIN sys.database_principals mp ON drm.member_principal_id = mp.principal_id
WHERE dp.name IN ('db_performance_monitor', 'db_performance_admin', 'db_application_user')
ORDER BY dp.name, mp.name;
GO
