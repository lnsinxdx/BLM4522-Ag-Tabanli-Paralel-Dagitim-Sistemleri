USE master;
GO

BACKUP CERTIFICATE MyServerCert 
TO FILE = 'C:\Backup\MyServerCert.cer' -- Sertifika dosyası
WITH PRIVATE KEY (
    FILE = 'C:\Backup\MyServerCertKey.pvk', -- ozel anahtar dosyası
    ENCRYPTION BY PASSWORD = '1234!' -- Yedekleme sırasında kullanılacak sifre
);
GO
