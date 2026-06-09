USE AdventureWorks2022;
GO

-- PITR senaryosu: korunması gereken kayıt
INSERT INTO dbo.YedekTest (Aciklama) VALUES ('PITR - iyi kayit (korunmali)');

-- Zaman damgalarını ayırmak için kısa bekleme
WAITFOR DELAY '00:00:10';

-- Hatalı işlem (bu kaydı geri almak istiyoruz)
INSERT INTO dbo.YedekTest (Aciklama) VALUES ('PITR - HATALI kayit (istenmeyen)');

-- Kayıtların zaman damgalarını gör — STOPAT zamanını buradan seç
SELECT Id, Aciklama, KayitZamani FROM dbo.YedekTest ORDER BY Id;

-- Bu değişiklikleri yakalayan log yedeği al
BACKUP LOG AdventureWorks2022
TO DISK = 'C:\Backup\Proje2\AW2022_Log2.trn'
WITH FORMAT, INIT,
     NAME = 'AdventureWorks2022 Log Yedek 2',
     STATS = 10;

     ---PART B
-- Yedek içindeki mantıksal dosya adlarını doğrula
RESTORE FILELISTONLY FROM DISK = 'C:\Backup\Proje2\AW2022_Full.bak';

-- Tam yedek (yeni isimle, MOVE ile, NORECOVERY)
RESTORE DATABASE AdventureWorks2022_PITR
FROM DISK = 'C:\Backup\Proje2\AW2022_Full.bak'
WITH MOVE 'AdventureWorks2022'     TO 'C:\Backup\Proje2\AW2022_PITR.mdf',
     MOVE 'AdventureWorks2022_log' TO 'C:\Backup\Proje2\AW2022_PITR_log.ldf',
     NORECOVERY, REPLACE;

-- Fark yedek (NORECOVERY)
RESTORE DATABASE AdventureWorks2022_PITR
FROM DISK = 'C:\Backup\Proje2\AW2022_Diff.bak'
WITH NORECOVERY;

-- İlk log yedeği (NORECOVERY)
RESTORE LOG AdventureWorks2022_PITR
FROM DISK = 'C:\Backup\Proje2\AW2022_Log1.trn'
WITH NORECOVERY;

-- İkinci log: STOPAT ile hatalı işlemden ÖNCEYE geri dön
-- Aşağıdaki zamanı Part A çıktısındaki iyi/hatalı kayit arasından seç
RESTORE LOG AdventureWorks2022_PITR
FROM DISK = 'C:\Backup\Proje2\AW2022_Log2.trn'
WITH STOPAT = '2026-06-09 22:50:59', RECOVERY;   -- <-- BU ZAMANI DÜZENLE

-- Sonucu doğrula: iyi kayit VAR, HATALI kayit YOK olmalı
SELECT Id, Aciklama, KayitZamani
FROM AdventureWorks2022_PITR.dbo.YedekTest
ORDER BY Id;
SELECT 'master' AS db, COUNT(*) AS tablo_var FROM master.sys.tables WHERE name = 'YedekTest'
UNION ALL
SELECT 'AdventureWorks2022', COUNT(*) FROM AdventureWorks2022.sys.tables WHERE name = 'YedekTest';

