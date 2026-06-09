-- Tam yedek ile fark yedeği arasında değişiklik
INSERT INTO dbo.YedekTest (Aciklama) VALUES ('Fark yedeginden once eklendi');

-- Fark yedeği al (son tam yedekten bu yana değişenler)
BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Backup\Proje2\AW2022_Diff.bak'
WITH DIFFERENTIAL, FORMAT, INIT,
     NAME = 'AdventureWorks2022 Fark Yedek',
     STATS = 10;
