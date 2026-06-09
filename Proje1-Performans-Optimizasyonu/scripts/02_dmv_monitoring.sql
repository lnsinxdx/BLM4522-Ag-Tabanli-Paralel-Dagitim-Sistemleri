--  DMV ile performans izleme
USE AdventureWorks2022;
GO

-- 1. En pahalı 10 sorgu (CPU süresine göre)
SELECT TOP 10
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    qs.execution_count,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
    SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS sorgu_metni
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY avg_cpu_time DESC;
GO

-- 2. En pahalı 10 sorgu (mantıksal okuma sayısına göre)
SELECT TOP 10
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    qs.execution_count,
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS sorgu_metni
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY avg_logical_reads DESC;
GO

-- 3. SQL Server'ın önerdiği eksik indeksler
SELECT
    mid.statement AS tablo,
    mid.equality_columns AS esitlik_sutunlari,
    mid.inequality_columns AS esitsizlik_sutunlari,
    mid.included_columns AS dahil_edilen_sutunlar,
    migs.avg_user_impact AS tahmini_iyilesme_yuzdesi,
    migs.user_seeks AS arama_sayisi
FROM sys.dm_db_missing_index_details mid
JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
WHERE mid.database_id = DB_ID('AdventureWorks2022')
ORDER BY tahmini_iyilesme_yuzdesi DESC;
GO

-- 4. Kullanılmayan indeksler (okunmuyor ama yazma maliyeti var)
SELECT
    o.name AS tablo_adi,
    i.name AS indeks_adi,
    i.type_desc AS indeks_tipi,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
JOIN sys.objects o ON i.object_id = o.object_id
WHERE ius.database_id = DB_ID('AdventureWorks2022')
    AND o.type = 'U'
    AND i.name IS NOT NULL
    AND ius.user_seeks = 0
    AND ius.user_scans = 0
    AND ius.user_lookups = 0
    AND ius.user_updates > 0
ORDER BY ius.user_updates DESC;
GO

-- 5. Bekleme istatistikleri (sunucu neleri bekliyor)
SELECT TOP 10
    wait_type,
    wait_time_ms,
    signal_wait_time_ms,
    wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms,
    waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE',
    'SLEEP_TASK','SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH',
    'WAITFOR','BROKER_TASK_STOP','BROKER_RECEIVE_WAITFOR',
    'CLR_AUTO_EVENT','CLR_MANUAL_EVENT','DIRTY_PAGE_POLL',
    'DISPATCHER_QUEUE_SEMAPHORE','XE_TIMER_EVENT','XE_DISPATCHER_WAIT',
    'CHECKPOINT_QUEUE','FT_IFTS_SCHEDULER_IDLE_WAIT','HADR_WORK_QUEUE'
)
ORDER BY wait_time_ms DESC;
GO
