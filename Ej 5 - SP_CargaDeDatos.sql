
USE SolNorteDB
--Creacion de Store Procedures para la carga de datos
/*

--CONFIGURACION DEL OPENROWSET - para la lectura del xlsx
--Debe tener instalado el Microsoft Access Database Engine 2016 Redistributable Versión: x64 - Enlace de descarga: https://www.microsoft.com/en-us/download/details.aspx?id=54920

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.12.0', 
    N'AllowInProcess', 1;

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.12.0', 
    N'DynamicParameters', 1;

*/
/*
SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;Database=C:\data\Datos socios.xlsx;Extended Properties="Excel 12.0;HDR=YES;IMEX=1"',
    'SELECT * FROM [Responsables de Pago$]'
);
*/

GO
CREATE OR ALTER PROCEDURE ImportarExcel ( @RutaArchivo NVARCHAR(255),@NombreHoja NVARCHAR(128))
AS
BEGIN

PRINT 'Importando desde archivo: ' + @RutaArchivo;

SET NOCOUNT ON;
    DECLARE @Temp_Lectura_XLSX NVARCHAR(MAX);
    SET @Temp_Lectura_XLSX = '
	IF OBJECT_ID(''tempdb..##Excel_Hoja'') IS NOT NULL DROP TABLE ##Excel_Hoja;
        SELECT *
        INTO ##Excel_Hoja
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.16.0'',
            ''Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES;IMEX=1'',
            ''SELECT * FROM [' + @NombreHoja + '$]''
        );
    ';
    EXEC sp_executesql @Temp_Lectura_XLSX;
END

GO 

CREATE OR ALTER FUNCTION dbo.ConvertirNumeroATextoPlano
(
    @ValorInput SQL_VARIANT
)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @Resultado VARCHAR(100);
    DECLARE @Texto NVARCHAR(100) = CAST(@ValorInput AS NVARCHAR(100));

    -- Si contiene notación científica, lo tratamos
    IF @Texto LIKE '%E+%' OR @Texto LIKE '%e+%'
    BEGIN
        DECLARE @BigNum DECIMAL(38,0);
        SET @BigNum = TRY_CAST(@ValorInput AS DECIMAL(38,0));
        SET @Resultado = CAST(@BigNum AS VARCHAR(100));
    END
    ELSE
    BEGIN
        SET @Resultado = @Texto;
    END

    RETURN @Resultado;
END;

-- ESTE SP separa la tabla temporal en 3 tablas de la hoja Tarifas, que sirve para procesar los datos de las tarifas
-- Pide como parametro el nombre de la tabla temporal(de la hoja de Tarifas) , el rago de la fila 1, 2 y 3, el rango debe contener el titulo de la columna
GO
CREATE OR ALTER PROCEDURE SepararTablaTemporalEnTres (
    @NombreTabla NVARCHAR(128), @FilaIni1 INT, @FilaFin1 INT,@FilaIni2 INT, @FilaFin2 INT, @FilaIni3 INT, @FilaFin3 INT)
AS
BEGIN
    SET NOCOUNT ON;
    -- Borrar las tablas si ya existen
    IF OBJECT_ID('tempdb..##Tabla_Subtabla_1') IS NOT NULL DROP TABLE ##Tabla_Subtabla_1;
    IF OBJECT_ID('tempdb..##Tabla_Subtabla_2') IS NOT NULL DROP TABLE ##Tabla_Subtabla_2;
    IF OBJECT_ID('tempdb..##Tabla_Subtabla_3') IS NOT NULL DROP TABLE ##Tabla_Subtabla_3;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
        SELECT * INTO ##Tabla_Subtabla_1 FROM (
            SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Fila
            FROM ' + QUOTENAME(@NombreTabla) + '
        ) AS T
        WHERE Fila BETWEEN ' + CAST(@FilaIni1 AS NVARCHAR) + ' AND ' + CAST(@FilaFin1 AS NVARCHAR) + ';

        SELECT * INTO ##Tabla_Subtabla_2 FROM (
            SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Fila
            FROM ' + QUOTENAME(@NombreTabla) + '
        ) AS T
        WHERE Fila BETWEEN ' + CAST(@FilaIni2 AS NVARCHAR) + ' AND ' + CAST(@FilaFin2 AS NVARCHAR) + ';

        SELECT * INTO ##Tabla_Subtabla_3 FROM (
            SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Fila
            FROM ' + QUOTENAME(@NombreTabla) + '
        ) AS T
        WHERE Fila BETWEEN ' + CAST(@FilaIni3 AS NVARCHAR) + ' AND ' + CAST(@FilaFin3 AS NVARCHAR) + ';
    ';

    EXEC sp_executesql @SQL;
END;


GO
--SP que importa los datos de la primer hoja "Responsables de Pago" 
CREATE OR ALTER PROCEDURE ProcesarHoja1 (@RutaArchivo VARCHAR(255))
AS
BEGIN
    SET NOCOUNT ON;
	SET DATEFORMAT DMY; -- para que no de error el formato de la fecha

DECLARE @NombreHoja VARCHAR(20)='Responsables de Pago';
EXEC ImportarExcel @RutaArchivo, @NombreHoja;

DECLARE
@ID_socio INT,
@nombre VARCHAR(30),
@apellido VARCHAR(30),
@DNI VARCHAR(10),
@Email VARCHAR(50),
@FNac DATE,
@domicilio VARCHAR(100),
@NombObraSocial VARCHAR(50),
@NroSocioObraSocial VARCHAR(30),
@TelCont VARCHAR(15),
@TelEmerg1 VARCHAR(30),
@TelEmerg2 VARCHAR(30),
@estado VARCHAR(10),
@usuario VARCHAR(16),
@contrasenia VARCHAR(32),
@caducidad_contrasenia DATE,
@fila INT = 1,
@total INT;

SELECT @total = COUNT(*) FROM ##Excel_Hoja;

-- Crear tabla temporal con numeración
SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila
INTO #ExcelNumerado
FROM ##Excel_Hoja;

 WHILE @fila <= @total
 BEGIN
	BEGIN TRY
		SELECT
            @ID_socio = TRY_CAST(REPLACE([Nro de socio], 'SN-', '') AS INT),
            @nombre = [Nombre],
			@apellido = [ apellido],
			@DNI = [ DNI],
            @Email = [ email personal],
            @FNac = TRY_CAST([ fecha de nacimiento] AS DATE),
            @domicilio = 'Sin domicilio', 
            @NombObraSocial = [ Nombre de la obra social o prepaga],
            @NroSocioObraSocial = [nro# de socio obra social/prepaga ],
			@TelCont = dbo.ConvertirNumeroATextoPlano([ teléfono de contacto]),
            @TelEmerg1 = dbo.ConvertirNumeroATextoPlano([ teléfono de contacto emergencia]),
			@TelEmerg2 = dbo.ConvertirNumeroATextoPlano([teléfono de contacto de emergencia ]),
			@estado = 'activo',
            @usuario = LEFT(LOWER(LEFT(@Email, CHARINDEX('@', @Email) - 1)), 16),
            @contrasenia = '12345678', 
            @caducidad_contrasenia = '31-12-2099'
			FROM #ExcelNumerado
			WHERE nro_fila = @fila;

	EXEC InsertarSocio @ID_socio = @ID_socio, @DNI = @DNI, @Nombre = @nombre, @Apellido = @apellido, @Email = @Email, @FechaNacimiento = @FNac, @domicilio = @domicilio, @obra_social = @NombObraSocial, @numObraSocial = @NroSocioObraSocial, @telObraSocial = '-', @estado = @estado, @usuario = @usuario, @contrasenia = @contrasenia, @caducidad_contrasenia = @caducidad_contrasenia;
	
	IF @TelCont IS NOT NULL
		EXEC InsertarSocioTelefono @ID_socio = @ID_socio, @Tel = @TelCont;

    
	IF @TelEmerg1 IS NOT NULL
		EXEC InsertarSocioEmergencia @ID_socio = @ID_socio, @Tel = @TelEmerg1;

	IF @TelEmerg2 IS NOT NULL
		EXEC InsertarSocioEmergencia @ID_socio = @ID_socio, @Tel = @TelEmerg2;

	 END TRY
        BEGIN CATCH
           PRINT 'Error al procesar el usuario ' + CAST(@fila AS VARCHAR) + ' (ID: ' + ISNULL(CAST(@ID_socio AS VARCHAR), 'NULL') + ', Nombre: ' + ISNULL(@nombre, 'NULL') + '): ' + ERROR_MESSAGE();

        END CATCH;

	SET @fila += 1;
	END

END

GO
--SP que importa los datos de la segunda hoja "Grupo Familiar" 
CREATE OR ALTER PROCEDURE ProcesarHoja2 (
    @RutaArchivo VARCHAR(255))
AS
BEGIN
	SET NOCOUNT ON;
	SET DATEFORMAT DMY;

	DECLARE @NombreHoja VARCHAR(20)='Grupo Familiar';
	EXEC ImportarExcel @RutaArchivo, @NombreHoja;
	
	DECLARE
	@ID_socio INT,
	@ID_socio_responsable INT,
	@nombre VARCHAR(30),
	@apellido VARCHAR(30),
	@DNI VARCHAR(10),
	@Email VARCHAR(50),
	@FNac DATE,
	@NombObraSocial VARCHAR(50),
	@NroSocioObraSocial VARCHAR(30),
	@domicilio VARCHAR(15),
	@TelCont VARCHAR(15),
	@TelEmerg1 VARCHAR(50),
	@TelEmerg2 VARCHAR(50),
	@estado VARCHAR(10),
	@usuario VARCHAR(16),
	@contrasenia VARCHAR(32),
	@caducidad_contrasenia DATE,
	@fila INT = 1,
	@total INT;

	SELECT @total = COUNT(*) FROM ##Excel_Hoja;
	SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila
INTO #ExcelNumerado
FROM ##Excel_Hoja;


WHILE @fila <= @total
 BEGIN
	BEGIN TRY

			
		SELECT
    @ID_socio = TRY_CAST(REPLACE([Nro de Socio], 'SN-', '') AS INT),
    @ID_socio_responsable = TRY_CAST(REPLACE([Nro de socio RP], 'SN-', '') AS INT),
    @nombre = [Nombre],
    @apellido = [ apellido],
    @DNI = dbo.ConvertirNumeroATextoPlano([ DNI]),
    @FNac = TRY_CAST([ fecha de nacimiento] AS DATE),
    @NombObraSocial = ISNULL(NULLIF([ Nombre de la obra social o prepaga], ''), 'hospital público más cercano'),
    @NroSocioObraSocial = ISNULL(NULLIF([nro# de socio obra social/prepaga ], ''), 'no tiene'),
    @TelCont = dbo.ConvertirNumeroATextoPlano(NULLIF([ teléfono de contacto], '')),
    @TelEmerg1 = dbo.ConvertirNumeroATextoPlano(NULLIF([ teléfono de contacto emergencia], '')),
    @TelEmerg2 = dbo.ConvertirNumeroATextoPlano([teléfono de contacto de emergencia ])
FROM #ExcelNumerado
WHERE nro_fila = @fila;

SELECT 
    @Email = ISNULL(dbo.ConvertirNumeroATextoPlano(NULLIF([ email personal], '')), 
                    (SELECT TOP 1 Email FROM Persona.Socio WHERE ID_socio = @ID_socio_responsable)),
    @domicilio = (SELECT domicilio FROM Persona.Socio WHERE ID_socio = @ID_socio_responsable),
    @usuario = LEFT(LOWER(LEFT(
                ISNULL(dbo.ConvertirNumeroATextoPlano(NULLIF([ email personal], '')), 
                (SELECT TOP 1 Email FROM Persona.Socio WHERE ID_socio = @ID_socio_responsable))
            , CHARINDEX('@', 
                ISNULL(dbo.ConvertirNumeroATextoPlano(NULLIF([ email personal], '')), 
                (SELECT TOP 1 Email FROM Persona.Socio WHERE ID_socio = @ID_socio_responsable))
            ) - 1)), 11) + 'menor'
FROM #ExcelNumerado
WHERE nro_fila = @fila;

		IF @ID_socio IS NOT NULL AND @ID_socio_responsable IS NOT NULL
		

		EXEC InsertarSocio @ID_socio = @ID_socio, @DNI = @DNI, @Nombre = @nombre, @Apellido = @apellido, @Email = @Email, @FechaNacimiento = @FNac, @domicilio = @domicilio, @obra_social = @NombObraSocial, @numObraSocial = @NroSocioObraSocial, @telObraSocial = '-', @estado = @estado, @usuario = @usuario, @contrasenia = @contrasenia, @caducidad_contrasenia = @caducidad_contrasenia;

		INSERT INTO Persona.responsabilidad (ID_responsable, ID_menor)
		VALUES (@ID_socio_responsable, @ID_socio);
			
			IF NOT EXISTS (
				SELECT 1
				FROM Persona.Socio
				WHERE ID_socio = @ID_socio_responsable
			)
			BEGIN
				THROW 50001, 'Error: El número de socio responsable no existe en Persona.Socio.', 1;
			END

		IF @TelCont IS NOT NULL
		EXEC InsertarSocioTelefono @ID_socio = @ID_socio, @Tel = @TelCont;
		
		IF @TelEmerg1 IS NOT NULL
		EXEC InsertarSocioEmergencia @ID_socio = @ID_socio, @Tel = @TelEmerg1;

		IF @TelEmerg2 IS NOT NULL
		EXEC InsertarSocioEmergencia @ID_socio = @ID_socio, @Tel = @TelEmerg2;



		 END TRY
        BEGIN CATCH
           PRINT 'Error al procesar el usuario ' + CAST(@fila AS VARCHAR) + ' (ID: ' + ISNULL(CAST(@ID_socio AS VARCHAR), 'NULL') + ', Nombre: ' + ISNULL(@nombre, 'NULL') + '): ' + ERROR_MESSAGE();

        END CATCH;

			SET @fila += 1;
	END

END

GO
--SP que importa los datos de la tercer hoja "pago cuotas" 
CREATE OR ALTER PROCEDURE ProcesarHoja3 (
    @RutaArchivo VARCHAR(255))
AS
BEGIN
	SET NOCOUNT ON;
	SET DATEFORMAT DMY; -- para que no de error el formato de la fecha

	DECLARE @NombreHoja VARCHAR(20)='pago cuotas';
	EXEC ImportarExcel @RutaArchivo, @NombreHoja;

	DECLARE
@ID_Pago BIGINT,
@ID_Socio VARCHAR(30),
@ID_Factura INT,
@valor int,
@Medio_Pago VARCHAR(15),
@Fecha DATE,
@fila INT = 1,
@total INT;

DECLARE --para generar la factura y cuenta
@DNI INT,
@CUIT CHAR(13),
@ID_cuenta INT;

SELECT @total = COUNT(*) FROM ##Excel_Hoja;
SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila
INTO #ExcelNumerado
FROM ##Excel_Hoja;

WHILE @fila <= @total
 BEGIN
	BEGIN TRY
		SELECT
		@ID_Pago = TRY_CAST(dbo.ConvertirNumeroATextoPlano([Id de pago]) AS BIGINT),
		@ID_Socio = TRY_CAST(REPLACE([Responsable de pago], 'SN-', '') AS INT),
		@valor =TRY_CAST([Valor] AS INT),
		@Medio_Pago = [Medio de pago],
		@Fecha =TRY_CAST([fecha] AS DATE)
		FROM #ExcelNumerado
		WHERE nro_fila = @fila;

		SET @DNI = (SELECT DNI FROM Persona.Socio WHERE ID_Socio = @ID_Socio);
		SET @CUIT = '20-' + CAST(@DNI AS VARCHAR) + '-3';
				
		exec InsertarFactura @ID_factura=NULL, @DNI=@DNI, @CUIT = @CUIT, @FechaYHora = @Fecha,@costo = @valor, @estado = true;

		IF NOT EXISTS ( SELECT 1 FROM Finansas.Cuenta WHERE ID_Socio = @ID_Socio)
		BEGIN
		    EXEC InsertarCuenta @ID_Socio = @ID_Socio, @ID_cuenta = NULL;
		END

		SELECT @ID_Cuenta = ID_Cuenta FROM Finansas.Cuenta WHERE ID_Socio = @ID_Socio;
		
		SELECT @ID_Factura = MAX(ID_factura) FROM Finansas.factura WHERE DNI = @DNI AND CUIT = @CUIT AND FechaYHora = @Fecha;

		Exec InsertarCobro @ID_factura=@ID_Factura ,@ID_Cobro=@ID_Pago, @ID_socio=@ID_Socio, @Costo=@valor, @Medio_Pago=@Medio_Pago, @fecha=@Fecha, @Estado = true, @ID_cuenta= @ID_Cuenta;

		END TRY 
        BEGIN CATCH
           PRINT 'Error al procesar el pago ' + CAST(@fila AS VARCHAR) + ' (ID_Pago: ' + ISNULL(CAST(@ID_Pago AS VARCHAR), 'NULL') + ', ID_Usuario: ' + ISNULL(@ID_Socio, 'NULL') + '): ' + ERROR_MESSAGE();

        END CATCH;

	SET @fila += 1;
	END

END

GO
--SP que importa los datos de la cuarta hoja "Tarifas" 
CREATE OR ALTER PROCEDURE ProcesarHoja4 (
    @RutaArchivo VARCHAR(255))
AS
BEGIN
DECLARE @NombreHoja VARCHAR(20)='Tarifas';
EXEC ImportarExcel @RutaArchivo, @NombreHoja;

EXEC SepararTablaTemporalEnTres '##Excel_Hoja' , 1, 6, /*Rango 1*/ 9, 11,/*Rango 2*/ 15, 25;/*Rango 3*/
Exec ProcesarSubTabla1;
Exec ProcesarSubTabla2;
Exec ProcesarSubTabla3;
END

GO

CREATE OR ALTER PROCEDURE ProcesarSubTabla1 --[Actividad], [Valor por mes], [Vigente hasta]
AS
BEGIN
SET NOCOUNT ON;
SET DATEFORMAT DMY;

DECLARE 
@actividad Varchar(30),
@valor decimal(10,2),
@fech_vigencia date,
@fila INT = 1,
@total INT;

SELECT @total = COUNT(*) FROM ##Tabla_Subtabla_1;
SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila
INTO #SubtablaNumerado
FROM ##Tabla_Subtabla_1;

WHILE @fila <= @total
 BEGIN
		BEGIN TRY
		SELECT
		@actividad=[Actividad],
		@valor = TRY_CAST([Valor por mes] AS DECIMAL(10,2)),
		@fech_vigencia = TRY_CAST([Vigente hasta] AS DATE)
		FROM #SubtablaNumerado
		WHERE nro_fila = @fila;

		exec InsertarActividadDeportiva @ID_actividad=NULL,@Nombre=@actividad,@costo=@valor;

		 END TRY
        BEGIN CATCH
           PRINT 'Error al procesar el la actividad ' + CAST(@fila AS VARCHAR) + ' (actividad: ' + ISNULL(CAST(@actividad AS VARCHAR), 'NULL') + ERROR_MESSAGE();

        END CATCH;

	SET @fila += 1;
	END

END


GO

CREATE OR ALTER PROCEDURE ProcesarSubTabla2 --[Categoria socio], [Valor cuota], [Vigente hasta]
AS
BEGIN

SET NOCOUNT ON;
SET DATEFORMAT DMY;

DECLARE 
@CatSocio Varchar(30),
@valorCuota decimal(10,2),
@fech_vigencia date,
@fila INT = 1,
@total INT;

SELECT @total = COUNT(*) FROM ##Tabla_Subtabla_2;
SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila
INTO #SubtablaNumerado
FROM ##Tabla_Subtabla_2;

WHILE @fila <= @total
 BEGIN
		BEGIN TRY
		SELECT
		@CatSocio=[Actividad],
		@valorCuota = TRY_CAST([Valor por mes] AS DECIMAL(10,2)),
		@fech_vigencia = TRY_CAST([Vigente hasta] AS DATE)
		FROM #SubtablaNumerado
		WHERE nro_fila = @fila;

		exec InsertarMembresia @ID_tipo=NULL,@Nombre=@CatSocio,@costo=@valorCuota, @descripcion=' ';

		 END TRY
        BEGIN CATCH
           PRINT 'Error al procesar el la membresia ' + CAST(@fila AS VARCHAR) + ' (categoria: ' + ISNULL(CAST(@CatSocio AS VARCHAR), 'NULL ') + ERROR_MESSAGE();

        END CATCH;

	SET @fila += 1;
	END

END
GO

CREATE OR ALTER PROCEDURE ProcesarSubTabla3 
AS
BEGIN
SET NOCOUNT ON;
SET DATEFORMAT DMY;

DECLARE
@id_actividad INT,
@nombre Varchar(30),
@tipoDuracion Varchar(30),
@tipoPersona Varchar(30),
@tipoCondicion Varchar(30),
@costo Decimal(10,2), 
@costoTXT varchar(15),
@fila INT = 1,
@total INT;

SELECT @total = COUNT(*) FROM ##Tabla_Subtabla_3;
SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila
INTO #SubtablaNumerado
FROM ##Tabla_Subtabla_3;

WHILE @fila <= @total
 BEGIN
		BEGIN TRY
		SET @tipoPersona = CASE 
            WHEN @fila % 2 = 1 THEN 'Adulto'
            ELSE 'Menor'
        END;

        -- Determinar tipo de duración
        SET @tipoDuracion = CASE 
            WHEN @fila IN (1,2) THEN 'Día'
            WHEN @fila IN (3,4) THEN 'Temporada'
            WHEN @fila IN (5,6) THEN 'Mes'
            ELSE 'Otro'
        END;

        -- SOCIO: el valor está en [Vigente hasta]
        SELECT @costoTXT = [Vigente hasta]
		FROM #SubtablaNumerado
		WHERE nro_fila = @fila;
SET @costo = TRY_CAST(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@costoTXT)), '$', ''), '.', ''), ',', '.') AS DECIMAL(10,2));

		 SET @tipoCondicion = 'Socio';


		exec InsertarActividadOtra @ID_actividad=NULL ,@Nombre='pileta' ,@TipoDuracion=@tipoDuracion ,@TipoPersona=@tipoPersona ,@Condicion=@tipoCondicion ,@Costo=@costo; 
		-- VISITANTE: el valor está en [F4]
        SELECT @costoTXT = [F4]
		FROM #SubtablaNumerado
		WHERE nro_fila = @fila;
		SET @costo = TRY_CAST(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@costoTXT)), '$', ''), '.', ''), ',', '.') AS DECIMAL(10,2));

            SET @tipoCondicion = 'Invitado';
			
			exec InsertarActividadOtra @ID_actividad=NULL ,@Nombre='pileta' ,@TipoDuracion=@tipoDuracion ,@TipoPersona=@tipoPersona ,@Condicion=@tipoCondicion ,@Costo=@costo; 
            END TRY
        BEGIN CATCH
           PRINT 'Error al procesar el valor de la otra actividad ' + CAST(@fila AS VARCHAR) + ' (id: ' + ISNULL(CAST(@Costo AS VARCHAR), 'NULL ') + ERROR_MESSAGE();

        END CATCH;

	SET @fila += 1;
	END

END

GO
--SP que importa los datos de la quinta hoja "presentismo_actividades" 
CREATE OR ALTER PROCEDURE ProcesarHoja5 ( --[Nro de Socio], [Actividad], [fecha de asistencia], [Asistencia], [Profesor]
    @RutaArchivo VARCHAR(255))
AS
BEGIN
DECLARE @NombreHoja VARCHAR(25)='presentismo_actividades';
SET NOCOUNT ON;
	SET DATEFORMAT DMY;
	EXEC ImportarExcel @RutaArchivo, @NombreHoja;

	DECLARE
@ID_socio INT,
@actividad VARCHAR(30),
@FechaAsist DATE,
@Asistencia VARCHAR(2),
@Profesor VARCHAR(30),
@id_actividad INT,
@id_turno INT,
@presentismo BIT,
@fila INT = 1,
@total INT;
SELECT @total = COUNT(*) FROM ##Excel_Hoja;
-- Crear tabla temporal con numeración
SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila
INTO #ExcelNumerado
FROM ##Excel_Hoja;
WHILE @fila <= @total
 BEGIN
	BEGIN TRY
		SELECT
			@ID_socio = TRY_CAST(REPLACE([Nro de Socio], 'SN-', '') AS INT),
            @actividad = [Actividad],
			@Asistencia = [Asistencia],
            @Profesor = [Profesor],
            @FechaAsist = TRY_CAST([fecha de asistencia] AS DATE)
			FROM #ExcelNumerado
			WHERE nro_fila = @fila;

			IF @Asistencia = 'P' OR @Asistencia = 'J'
			SET @presentismo=1;
			else 
			SET @presentismo=0;

			--ACTIVIDAD YA INCERTADA EN HOJA 4
			select TOP 1 @id_actividad = ID_actividad from Actividades.Actividades_Deportivas where Nombre=@actividad
			


			Exec InsertarAcDepTurno @ID_actividad=@id_actividad, @id_turno = null, @turno='M';

			Select TOP 1 @id_turno = ID_turno from Actividades.AcDep_turnos where ID_actividad=@id_actividad and turno='M';

			EXEC InsertarInscripcionDeportiva @ID_socio=@ID_socio, @ID_inscripcion=NULL, @ID_actividad=@id_actividad,@ID_Turno=@id_turno, @fecha_inicio = '1/1/2025';

			Exec InsertarAsistencia @ID_socio=@ID_socio,@ID_actividad=@id_actividad,@ID_turno=@id_turno,@Fecha=@FechaAsist,@Presentismo=@presentismo;



		END TRY
        BEGIN CATCH
           PRINT 'Error al procesar la asistencia ' + CAST(@fila AS VARCHAR) + ' (ID socio: ' + ISNULL(CAST(@ID_socio AS VARCHAR), 'NULL') + ', fecha: ' + ISNULL(CONVERT(VARCHAR, @FechaAsist, 103), 'NULL') + '): ' + ERROR_MESSAGE();

        END CATCH;

	SET @fila += 1;
	END

END

GO
CREATE OR ALTER PROCEDURE VerColumnasTablaTemporal
    @NombreTabla NVARCHAR(128)
AS
BEGIN
    DECLARE @ColumnList NVARCHAR(MAX) = '';

    SELECT @ColumnList = STRING_AGG('[' + c.name + ']', ', ')
    FROM tempdb.sys.columns c
    INNER JOIN tempdb.sys.objects o ON c.object_id = o.object_id
    WHERE o.name LIKE '%' + REPLACE(@NombreTabla, '#', '') + '%';

    PRINT @ColumnList;
END

GO


CREATE OR ALTER PROCEDURE CargarDiasDesdeCSV
    @rutaArchivo VARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #TempMeteo (
        [time] VARCHAR(50),
        [temperature_2m] VARCHAR(40),
        [rain] VARCHAR(40),
        [relative_humidity_2m] VARCHAR(40),
        [wind_speed_10m] VARCHAR(40)
    );

    DECLARE @sql VARCHAR(MAX);

    SET @sql = '
    BULK INSERT #TempMeteo
    FROM ''' + @rutaArchivo + '''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''0x0A'',
        CODEPAGE = ''ACP'',
        TABLOCK
    );';

    EXEC(@sql);

    -- Tabla temporal con datos resumidos por día
    WITH DiasClima AS (
        SELECT 
            CONVERT(DATE, REPLACE([time], 'T', ' ')) AS fecha,
            CASE 
                WHEN MAX(TRY_CAST([rain] AS FLOAT)) > 0.5 THEN 1 
                ELSE 0 
            END AS climaMalo
        FROM #TempMeteo
        WHERE ISDATE(REPLACE([time], 'T', ' ')) = 1
        GROUP BY CONVERT(DATE, REPLACE([time], 'T', ' '))
    )
    MERGE Asistencia.dias AS destino
    USING DiasClima AS fuente
        ON destino.fecha = fuente.fecha
    WHEN MATCHED AND destino.climaMalo <> fuente.climaMalo THEN
        -- Actualizar si cambió el clima
        UPDATE SET destino.climaMalo = fuente.climaMalo
    WHEN NOT MATCHED THEN
        -- Insertar si no existe
        INSERT (fecha, climaMalo) VALUES (fuente.fecha, fuente.climaMalo);

    DROP TABLE #TempMeteo;
END;
GO