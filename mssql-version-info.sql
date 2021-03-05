
----------------------------------------------------------------------------------------------------------
--Autor          : Hidequel Puga
--Fecha          : 2021-02-19
--Descripción    : Muestra información de la versión de MSSQL Server
----------------------------------------------------------------------------------------------------------

SELECT CONVERT(VARCHAR(50), SERVERPROPERTY('ServerName')) AS ServerName
	 , CONVERT(VARCHAR(500), @@VERSION) AS Version
	 , CONVERT(VARCHAR(50), SERVERPROPERTY('edition')) AS Edition
	 , CONVERT(VARCHAR(50), SERVERPROPERTY('productlevel')) AS ProductLevel
	 , CONVERT(VARCHAR(50), SERVERPROPERTY('collation')) AS Collation
	 , CASE SERVERPROPERTY('IsClustered')
			WHEN 1 THEN 'Clustered Instance'
			WHEN 0 THEN 'Non Clustered Instance'
			ELSE ''
		END AS IsClusteredInstance  
	 , CASE SERVERPROPERTY('IsSingleUser')
			WHEN 1 THEN 'Single User'
			WHEN 0 THEN 'Multi User'
		    ELSE ''
		END AS IsInstanceInSingleUserMode;

