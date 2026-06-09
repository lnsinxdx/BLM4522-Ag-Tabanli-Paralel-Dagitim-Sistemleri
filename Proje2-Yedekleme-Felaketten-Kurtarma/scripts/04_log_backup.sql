-- Fark yedeği ile log yedeği arasında değişiklik
INSERT INTO dbo.YedekTest (Aciklama) VALUES ('Log yedeginden once eklendi');

-- İşlem günlüğü (log) yedeği al
BACKUP LOG AdventureWorks2022
TO DISK = 'C:\Backup\Proje2\AW2022_Log1.trn'
WITH FORMAT, INIT,
     NAME = 'AdventureWorks2022 Log Yedek 1',
     STATS = 10;

-- Üç yedeği de doğrula (geçerlilik kontrolü)
RESTORE VERIFYONLY FROM DISK = 'C:\Backup\Proje2\AW2022_Full.bak';
RESTORE VERIFYONLY FROM DISK = 'C:\Backup\Proje2\AW2022_Diff.bak';
RESTORE VERIFYONLY FROM DISK = 'C:\Backup\Proje2\AW2022_Log1.trn';

-- Yedekleme geçmişini msdb üzerinden incele
SELECT
    bs.database_name,
    bs.backup_start_date,
    CASE bs.type
        WHEN 'D' THEN 'Tam'
        WHEN 'I' THEN 'Fark'
        WHEN 'L' THEN 'Log'
    END AS yedek_turu,
    CAST(bs.backup_size / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS boyut_mb,
    bmf.physical_device_name
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'AdventureWorks2022'
ORDER BY bs.backup_start_date DESC;
