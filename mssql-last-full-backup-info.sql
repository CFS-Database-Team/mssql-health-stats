
----------------------------------------------------------------------------------------------------------
--Autor          : Hidequel Puga
--Fecha          : 2021-02-19
--Descripción    : Muestra información del ultimo backup completo de las base de datos
----------------------------------------------------------------------------------------------------------

		  SELECT db.database_id AS database_id
		       , db.[name]      AS [database_name]
			   ,  CASE bs.[type]
					WHEN 'D' THEN 'Full backup'
					WHEN 'I' THEN 'Differential backup'
					WHEN 'L' THEN 'Log backup'
					ELSE '-'
				  END AS backup_type
			   , ISNULL(FORMAT(bs.backup_finish_date, N'yyyy-MM-dd hh:mm tt'), 'Never') AS backup_finish_date
			   , ISNULL(FORMAT(CONVERT(NUMERIC(10,2), bs.compressed_backup_size / 1024 / 1024), '###,###,##0.00'), '-') AS backup_size
			   , CASE 
					WHEN (ABS(DATEDIFF(DAY, GETDATE(), bs.backup_finish_date)) = 0) THEN LTRIM(ISNULL(STR(ABS(DATEDIFF(HOUR, GETDATE(), bs.backup_finish_date))) + ' hours ago', '-'))
					ELSE LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(), bs.backup_finish_date))) + ' days ago', '-'))
				  END AS elapsed_time_last_backup
			   , LTRIM(ISNULL(STR(ABS(DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date))) + ' seconds', '-')) AS duration
			   , ROW_NUMBER() OVER (PARTITION BY db.[name] ORDER BY MAX(bs.backup_finish_date) DESC) AS rownum
	        FROM [master].[sys].[databases] AS db
 LEFT OUTER JOIN [msdb].[dbo].[backupset] AS bs
			  ON DB_ID(bs.[database_name]) = db.database_id
			  AND bs.type = 'D'
			 AND bs.server_name = SERVERPROPERTY('ServerName')
		   WHERE db.[name] <> 'tempdb'
		GROUP BY db.database_id
		       , db.[name]
			   ,  bs.[type]
			   , bs.compressed_backup_size
			   , bs.backup_start_date, bs.backup_finish_date
		  --HAVING MAX(bs.backup_finish_date) <= DATEADD(dd, -7, GETDATE()) 
		  --    OR MAX(bs.backup_finish_date) IS NULL