USE master;
GO
-- Üretim veritabanina dokunmadan yan tarafa tam kurtarma kopyasi
RESTORE DATABASE AdventureWorks2022_Kurtarma
FROM DISK = 'C:\Backup\Proje2\AW2022_Full.bak'
WITH MOVE 'AdventureWorks2022'     TO 'C:\Backup\Proje2\AW2022_Kurtarma.mdf',
     MOVE 'AdventureWorks2022_log' TO 'C:\Backup\Proje2\AW2022_Kurtarma_log.ldf',
     NORECOVERY, REPLACE;

RESTORE DATABASE AdventureWorks2022_Kurtarma
FROM DISK = 'C:\Backup\Proje2\AW2022_Diff.bak' WITH NORECOVERY;

RESTORE LOG AdventureWorks2022_Kurtarma
FROM DISK = 'C:\Backup\Proje2\AW2022_Log1.trn' WITH NORECOVERY;

RESTORE LOG AdventureWorks2022_Kurtarma
FROM DISK = 'C:\Backup\Proje2\AW2022_Log2.trn' WITH NORECOVERY;

RESTORE LOG AdventureWorks2022_Kurtarma
FROM DISK = 'C:\Backup\Proje2\AW2022_TailLog.trn' WITH RECOVERY;

-- Üretim ile kurtarma kopyasini yan yana karsilastir
SELECT 'Uretim'   AS kaynak, COUNT(*) AS satir_sayisi FROM AdventureWorks2022.dbo.YedekTest
UNION ALL
SELECT 'Kurtarma', COUNT(*)                           FROM AdventureWorks2022_Kurtarma.dbo.YedekTest;
