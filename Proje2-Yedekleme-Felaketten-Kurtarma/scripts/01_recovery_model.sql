-- Mevcut kurtarma modelini kontrol et
SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'AdventureWorks2022';

-- FULL recovery model'e geç (log yedekleri ve PITR için gerekli)
ALTER DATABASE AdventureWorks2022 SET RECOVERY FULL;

-- Değişikliği doğrula
SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'AdventureWorks2022';
