DECLARE @fileName NVARCHAR(500)
DECLARE @backupDate NVARCHAR(20)

-- backup tarihi
SET @backupDate = CONVERT(NVARCHAR(20), GETDATE(), 112)

-- dosya isminin olusuturulmasi
SET @fileName = 'C:\Backup\AdventureWorks_Caglar_' + @backupDate + '.bak'

-- backup islemi INIT yeni dosyaya overwrite etmesini saglar. stats 10 ise her yuzde 10 ilerlemede mesaj gosterir
BACKUP DATABASE AdventureWorks2022
TO DISK = @fileName
WITH INIT, STATS = 10;
