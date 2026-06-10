USE AdventureWorks2022;
GO
-- Son log yedeğinden (Log2) SONRA gelen kritik veri — henüz hiçbir yedekte yok
INSERT INTO dbo.YedekTest (Aciklama) VALUES ('Felaket oncesi kritik kayit');

-- Bu kayıt şu an sadece transaction log icinde yasiyor
SELECT Id, Aciklama, KayitZamani FROM dbo.YedekTest ORDER BY Id;

--PART B

-- Kuyruk (tail) log yedeği: son yedekten bu yana her seyi yakalar.
-- NORECOVERY veritabanini "restoring" durumuna alir (felaket anini simule eder).
BACKUP LOG AdventureWorks2022
TO DISK = 'C:\Backup\Proje2\AW2022_TailLog.trn'
WITH NORECOVERY,
     NAME = 'AdventureWorks2022 Tail-Log Yedek',
     STATS = 10;

--PART C
USE master;
GO
-- Tam zincir + kuyruk log ile tam kurtarma (RPO ~ 0)
RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Backup\Proje2\AW2022_Full.bak' WITH NORECOVERY, REPLACE;

RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Backup\Proje2\AW2022_Diff.bak' WITH NORECOVERY;

RESTORE LOG AdventureWorks2022
FROM DISK = 'C:\Backup\Proje2\AW2022_Log1.trn' WITH NORECOVERY;

RESTORE LOG AdventureWorks2022
FROM DISK = 'C:\Backup\Proje2\AW2022_Log2.trn' WITH NORECOVERY;

-- Kuyruk log: felaketten hemen onceki son islemleri de geri getirir
RESTORE LOG AdventureWorks2022
FROM DISK = 'C:\Backup\Proje2\AW2022_TailLog.trn' WITH RECOVERY;

-- Dogrula: 'kritik kayit' dahil her sey geri geldi mi?
SELECT Id, Aciklama, KayitZamani FROM AdventureWorks2022.dbo.YedekTest ORDER BY Id;
