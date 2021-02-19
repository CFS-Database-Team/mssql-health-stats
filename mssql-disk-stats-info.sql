
----------------------------------------------------------------------------------------------------------
--Autor          : Hidequel Puga
--Fecha          : 2021-02-19
--Descripción    : Muestra información del uso y espacio de los discos
----------------------------------------------------------------------------------------------------------

	DECLARE @result  AS INT
		  , @objfso  AS INT
		  , @drv     AS INT 
		  , @cdrive  AS VARCHAR(13) 
		  , @size    AS VARCHAR(50) 
		  , @free    AS VARCHAR(50)
		  , @label   AS varchar(10);


	IF OBJECT_ID(N'tempdb..#DriveSpace_temp') IS NOT NULL
		DROP TABLE #DriveSpace_temp;

	IF OBJECT_ID(N'tempdb..#DriveInfo_temp') IS NOT NULL
		DROP TABLE #DriveInfo_temp;

	CREATE TABLE #DriveSpace_temp (
		  DriveLetter CHAR(1) NOT NULL
		, FreeSpace   VARCHAR(10) NOT NULL
	);

	CREATE TABLE #DriveInfo_temp (
		  DriveLetter CHAR(1)
		, TotalSpace  BIGINT
		, FreeSpace   BIGINT
		, [Label]     VARCHAR(10)
	);

	INSERT INTO #DriveSpace_temp 
		   EXEC [master].[dbo].xp_fixeddrives;

	-- Iterate through drive letters.
	DECLARE curDriveLetters CURSOR FOR SELECT DriveLetter FROM #DriveSpace_temp;
	DECLARE @DriveLetter CHAR(1) OPEN curDriveLetters

	FETCH NEXT FROM curDriveLetters 
	INTO @DriveLetter
	WHILE (@@fetch_status <> -1)
		BEGIN

			IF (@@fetch_status <> -2)
				BEGIN

					SET @cDrive = 'GetDrive("' + @DriveLetter + '")'; 

					EXEC @Result = sp_OACreate 'Scripting.FileSystemObject', @objfso OUTPUT; 

					IF @Result = 0 
						EXEC @Result = sp_OAMethod @objfso, @cdrive, @drv OUTPUT; 

					IF @Result = 0 
						EXEC @Result = sp_OAGetProperty @drv,'TotalSize', @size OUTPUT;

					IF @Result = 0 
						EXEC @Result = sp_OAGetProperty @drv,'FreeSpace', @free OUTPUT;

					IF @Result = 0 
						EXEC @Result = sp_OAGetProperty @drv,'VolumeName', @label OUTPUT;

					IF @Result <> 0 
						EXEC sp_OADestroy @Drv; 
						EXEC sp_OADestroy @objfso; 

						SET @Size = (CONVERT(BIGINT, @Size) / 1048576);
						SET @Free = (CONVERT(BIGINT, @Free) / 1048576);

						INSERT INTO #DriveInfo_temp
							 VALUES (@driveletter, @size, @free, @label);

				END
			FETCH NEXT FROM curDriveLetters 
			INTO @DriveLetter

		END

	CLOSE curDriveLetters
	DEALLOCATE curDriveLetters

	SELECT t.DriveLetter AS [DriveLetters]
		 , CASE WHEN (t.DriveLetter = 'C') THEN 'OS'
		  	ELSE t.[Label]
		  END AS [Label]
		 , FORMAT(t.TotalSpace, '###,###,##0.00') AS [TotalSpace(MB)]
		 , FORMAT((t.TotalSpace - t.FreeSpace), '###,###,##0.00') AS [UsedSpace(MB)]
		 , FORMAT(t.FreeSpace, '###,###,##0.00') AS [FreeSpace(MB)]
		 , FORMAT(((CONVERT(NUMERIC(9,2), t.FreeSpace) / CONVERT(NUMERIC(9,2), t.TotalSpace)) * 100), '###,###,##0.00') AS [PercentageFree(%)]
	  FROM #DriveInfo_temp AS t
  ORDER BY t.[DriveLetter] ASC;

	DROP TABLE #DriveSpace_temp;
	DROP TABLE #DriveInfo_temp;