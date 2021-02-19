
----------------------------------------------------------------------------------------------------------
--Autor          : Hidequel Puga
--Fecha          : 2021-02-19
--Descripci�n    : Muestra informaci�n de la instancia de MSSQL Server
----------------------------------------------------------------------------------------------------------

SELECT sqlserver_start_time AS StartTime
	 , CONVERT(VARCHAR(20), DATEDIFF(DD, sqlserver_start_time, GETDATE())) AS Uptime
  FROM sys.dm_os_sys_info; 