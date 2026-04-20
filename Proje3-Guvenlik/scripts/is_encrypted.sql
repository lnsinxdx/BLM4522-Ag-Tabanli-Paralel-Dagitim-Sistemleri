SELECT 
    name AS DatabaseName,
    is_encrypted AS EncryptedStatus
FROM sys.databases
WHERE name = 'AdventureWorks2022';
