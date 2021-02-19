
----------------------------------------------------------------------------------------------------------
--Autor          : Hidequel Puga
--Fecha          : 2021-02-19
--Descripción    : Muestra información de las base de datos
----------------------------------------------------------------------------------------------------------

		  SELECT a.database_id
			   , a.[name]
			   , CASE a.[compatibility_level]
					WHEN 80 THEN 'SQL Server 2000 (80)'
					WHEN 90 THEN 'SQL Server 2005 (90)'
					WHEN 100 THEN 'SQL Server 2008 (100)'
					WHEN 110 THEN 'SQL Server 2012 (110)'
					WHEN 120 THEN 'SQL Server 2014 (120)'
					WHEN 130 THEN 'SQL Server 2016 (130)'
					WHEN 140 THEN 'SQL Server 2017 (140)'
					WHEN 150 THEN 'SQL Server 2019 (150)'
				  END AS compatibility_level_desc
			   , a.recovery_model_desc
			   , c.files AS datafiles
			   , FORMAT(c.size, '###,###,##0.00') as datafiles_size
			   , d.files AS logfiles
			   , FORMAT(d.size, '###,###,##0.00') as logfiles_size
			   , FORMAT((c.size + d.size), '###,###,##0.00') AS database_size
			FROM sys.databases AS a 
	  INNER JOIN (
				   SELECT database_id, type, type_desc, count(1) AS files, sum((size*8)/1024.00) AS size
					 FROM sys.master_files AS DbFiles
					WHERE type = 0
				 GROUP BY database_id, type, type_desc
					) AS c 
			  ON a.database_id = c.database_id
	  INNER JOIN (
				   SELECT database_id, type, type_desc, count(1) AS files, sum((size*8)/1024.00) AS size
					 FROM sys.master_files AS DbFiles
					WHERE type = 1
				 GROUP BY database_id, type, type_desc
					) AS d 
			  ON a.database_id = d.database_id
		GROUP BY a.database_id
			   , a.[name]
			   , a.compatibility_level
			   , a.recovery_model_desc
			   , c.files
			   , c.size
			   , d.files
			   , d.size;