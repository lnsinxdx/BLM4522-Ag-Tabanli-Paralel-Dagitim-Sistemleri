-- Proje 1: Extended Events ile yavaş sorgu izleme

-- Varsa önceki oturumu sil
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'SorguIzleme')
BEGIN
    ALTER EVENT SESSION SorguIzleme ON SERVER STATE = STOP;
    DROP EVENT SESSION SorguIzleme ON SERVER;
END
GO

-- 500ms üzeri sorguları yakalayan oturum
CREATE EVENT SESSION SorguIzleme ON SERVER
ADD EVENT sqlserver.sql_statement_completed (
    ACTION (
        sqlserver.sql_text,
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.client_app_name
    )
    WHERE duration > 500000  -- 500ms (mikrosaniye cinsinden)
)
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY = 5 SECONDS);
GO

-- Oturumu başlat
ALTER EVENT SESSION SorguIzleme ON SERVER STATE = START;
GO

-- Not: Session başladıktan sonra baseline sorgularını tekrar çalıştır.
-- Sonra aşağıdaki sorgu ile yakalanan olayları görüntüle.

-- Yakalanan yavaş sorguları oku
SELECT
    event_data.value('(@timestamp)', 'DATETIME2') AS olay_zamani,
    event_data.value('(data[@name="duration"]/value)[1]', 'BIGINT') / 1000 AS sure_ms,
    event_data.value('(data[@name="cpu_time"]/value)[1]', 'BIGINT') / 1000 AS cpu_ms,
    event_data.value('(data[@name="logical_reads"]/value)[1]', 'BIGINT') AS mantiksal_okuma,
    event_data.value('(action[@name="sql_text"]/value)[1]', 'NVARCHAR(MAX)') AS sorgu
FROM (
    SELECT CAST(target_data AS XML) AS target_xml
    FROM sys.dm_xe_session_targets st
    JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
    WHERE s.name = 'SorguIzleme'
) AS tab
CROSS APPLY target_xml.nodes('RingBufferTarget/event') AS x(event_data);
GO
