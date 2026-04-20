EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'BackupAlertsProfile',
    @recipients = 'caglar.tg@gmail.com',
    @subject = 'AdventureWorks2022 Backup Report',
    @body_format = 'HTML',
    @body = 'Latest backup status for AdventureWorks2022:',
    @query = N'
        SELECT 
            b.database_name AS DatabaseName,
            MAX(b.backup_finish_date) AS LastBackupTime,
            CASE MAX(b.type)
                WHEN ''D'' THEN ''Full''
                WHEN ''I'' THEN ''Differential''
                WHEN ''L'' THEN ''Transaction Log''
                ELSE ''Other''
            END AS BackupType,
            MAX(b.backup_size) / 1024 / 1024 AS BackupSizeMB
        FROM 
            msdb.dbo.backupset b
        WHERE 
            b.database_name = ''AdventureWorks2022''
        GROUP BY 
            b.database_name
    ';