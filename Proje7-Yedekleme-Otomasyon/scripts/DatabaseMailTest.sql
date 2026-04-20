EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'BackupAlertsProfile',
    @recipients = 'caglar.tg@gmail.com',
    @subject = 'Manual Email Test',
    @body = 'This is a test message from SQL Server Database Mail.';