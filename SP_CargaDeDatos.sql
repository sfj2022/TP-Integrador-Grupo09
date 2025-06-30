--Creacion de Store Procedures para la carga de datos
USE SolNorteDB



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

/*
EXEC ImportarExcel 'C:\data\Datos socios.xlsx', 'Tarifas';
SELECT * FROM ##Excel_Hoja;
*/

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

/*
GO
EXEC SepararTablaTemporalEnTres
    '##Excel_Hoja', -- nombre de la tabla temporal existente
    1, 6,          -- Rango 1
    9, 11,         -- Rango 2
    15, 25;         -- Rango 3

GO
-- Consultás las nuevas tablas:
SELECT * FROM ##Tabla_Subtabla_1;
SELECT * FROM ##Tabla_Subtabla_2;
SELECT * FROM ##Tabla_Subtabla_3;
*/

GO
DELETE FROM Persona.Socio;
GO
--SP que importa los datos de la primer hoja "Responsables de Pago" 
CREATE OR ALTER PROCEDURE ProcesarHoja1 (
    @RutaArchivo VARCHAR(255))
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

SELECT COLUMN_NAME
FROM tempdb.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE '#ExcelNumerado%';
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
			@TelCont = [ teléfono de contacto],
            @TelEmerg1 = CONVERT(VARCHAR(50),[ teléfono de contacto emergencia]),
			@TelEmerg2 = CONVERT(VARCHAR(50),[ teléfono de contacto emergencia]),
            @estado = 'activo',
            @usuario = LEFT(LOWER(LEFT(@Email, CHARINDEX('@', @Email) - 1)), 16),
            @contrasenia = '12345678', 
            @caducidad_contrasenia = '31-12-2099'
			FROM #ExcelNumerado
			WHERE nro_fila = @fila;

	EXEC InsertarSocio @ID_socio = @ID_socio, @DNI = @DNI, @Nombre = @nombre, @Apellido = @apellido, @Email = @Email, @FechaNacimiento = @FNac, @domicilio = @domicilio, @obra_social = @NombObraSocial, @numObraSocial = @NroSocioObraSocial, @telObraSocial = @TelCont, @estado = @estado, @usuario = @usuario, @contrasenia = @contrasenia, @caducidad_contrasenia = @caducidad_contrasenia;

	 END TRY
        BEGIN CATCH
           PRINT 'Error al procesar el usuario ' + CAST(@fila AS VARCHAR) + ' (ID: ' + ISNULL(CAST(@ID_socio AS VARCHAR), 'NULL') + ', Nombre: ' + ISNULL(@nombre, 'NULL') + '): ' + ERROR_MESSAGE();

        END CATCH;

	SET @fila += 1;
	END

END

GO
--EXEC ProcesarHoja1 'C:\data\Datos socios.xlsx';

--Select * from Persona.Socio
GO
--SP que importa los datos de la segunda hoja "Grupo Familiar" 
CREATE OR ALTER PROCEDURE ProcesarHoja2 (
    @RutaArchivo VARCHAR(255))
AS
BEGIN
DECLARE @NombreHoja CHAR(20)='Grupo Familiar';


END

GO
--SP que importa los datos de la tercer hoja "pago cuotas" 
CREATE OR ALTER PROCEDURE ProcesarHoja3 (
    @RutaArchivo VARCHAR(255))
AS
BEGIN
DECLARE @NombreHoja CHAR(20)='pago cuotas';


END

GO
--SP que importa los datos de la cuarta hoja "Tarifas" 
CREATE OR ALTER PROCEDURE ProcesarHoja4 (
    @RutaArchivo VARCHAR(255))
AS
BEGIN
DECLARE @NombreHoja CHAR(20)='Tarifas';


END

GO
--SP que importa los datos de la quinta hoja "presentismo_actividades" 
CREATE OR ALTER PROCEDURE ProcesarHoja5 (
    @RutaArchivo VARCHAR(255))
AS
BEGIN
DECLARE @NombreHoja CHAR(20)='presentismo_actividades';


END



/*
GO
CREATE OR ALTER PROCEDURE CargarDataset (@archivo VARCHAR(100))
AS
BEGIN
	
	-- para que no de error de formato cuando agarra la fecha
	SET DATEFORMAT DMY;

	-- tabla como la de kaggle
	CREATE TABLE tabla_temporal (
		Id_propiedad INT,
		Nombre_propiedad NVARCHAR(1000),
		Id_usuario INT,
		Nombre_usuario NVARCHAR(100),
		Localidad NVARCHAR(100),
		Latitud FLOAT,
		Longitud FLOAT,
		Tipo_de_propiedad NVARCHAR(100),
		Precio_por_noche FLOAT,
		Noches_minimas INT,
		Numero_de_reviews INT,
		Ultima_review DATE,
		Reviews_mensuales FLOAT,
		Cantidad_de_publicaciones INT,
		Disponibilidad_365 INT
	);


	-- esto esta hecho de esta forma porque BULK INSERT no admite variables en el FROM, asi que hay que hacer esto raro
	DECLARE @bulk NVARCHAR(MAX);
	-- declaro una variable con el query que no hay que tocar mucho porque se rompe facil
	SET @bulk = 'BULK INSERT tabla_temporal
	FROM ''' +  @archivo + '''
	 WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		FORMAT = ''CSV'',
		FIELDQUOTE = ''"''
	);';

	-- y la ejecuto como si fuera in stored procedure
	EXEC (@bulk);

	-- Lleno localidad con los nombres y los "CP" distintos encontrados en el dataset
	INSERT INTO Localidad (Nombre)
	SELECT DISTINCT tabla_temporal.Localidad FROM tabla_temporal;

	-- Lleno los tipos con los tipos de propiedad distintos encontrados en el dataset
	INSERT INTO Tipo_de_propiedad (Descripcion)
	SELECT DISTINCT tabla_temporal.Tipo_de_propiedad
	FROM tabla_temporal;

	INSERT INTO Categoria (Id_categoria, Nombre)
	VALUES (1, 'Anfitrion');
	INSERT INTO Categoria (Id_categoria, Nombre)
	VALUES (2, 'SuperAnfitrion');

	-- Creo una tabla temporal con id, nombre y cantidad de reviews
	CREATE TABLE #Usuario_reviews (
		Id_usuario INT,
		Nombre_usuario NVARCHAR(100),
		Reviews_totales INT
	);

	-- La lleno con el total de reviews hechas a propiedades cada usuario
	INSERT INTO #Usuario_reviews
	SELECT Id_usuario, Nombre_usuario, SUM(Numero_de_reviews) AS reviews
	FROM tabla_temporal
	GROUP BY Id_usuario, Nombre_usuario;

	-- Obtengo el promedio de reviews
	DECLARE @promedio_reviews TINYINT;
	SET @promedio_reviews = (SELECT AVG(Reviews_totales) FROM #Usuario_reviews);

	-- Si el total de reviews es mayor al promedio de reviews la categoria es 2, si no 1
	INSERT INTO Usuario (Id_usuario, Nombre, Contrasenia, Id_categoria)
	SELECT 
		Id_usuario,
		Nombre_usuario,
		'P4ssW@rd',
		CASE
			WHEN Reviews_totales > @promedio_reviews THEN 2
			ELSE 1
		END
	FROM #Usuario_reviews
	WHERE Nombre_usuario IS NOT NULL;

	DROP TABLE #Usuario_reviews;

	-- anterior, sin categoria
	--INSERT INTO Usuario (Id_usuario, Nombre)
	--SELECT DISTINCT
	--	tabla_temporal.Id_usuario,
	--	tabla_temporal.Nombre_usuario
	--FROM tabla_temporal
	--WHERE tabla_temporal.Nombre_usuario IS NOT NULL;

	-- Lleno propiedad con las del dataset y los foreign keys de usuario, localidad y tipo_de_propiedad ya cargados
	INSERT INTO Propiedad (
		Id_propiedad,
		Nombre,
		Noches_minimas,
		Precio_por_noche,
		Latitud,
		Longitud,
		Id_usuario,
		Id_tipo_de_propiedad,
		CP
	)
	SELECT
		tabla_temporal.Id_propiedad,
		tabla_temporal.Nombre_propiedad,
		tabla_temporal.Noches_minimas,
		tabla_temporal.Precio_por_noche,
		tabla_temporal.Latitud,
		tabla_temporal.Longitud,
		tabla_temporal.Id_usuario,
		Tipo_de_propiedad.Id_tipo_de_propiedad,
		Localidad.CP
	FROM tabla_temporal
	INNER JOIN Localidad
	ON Localidad.Nombre = tabla_temporal.Localidad
	INNER JOIN Tipo_de_propiedad
	ON Tipo_de_propiedad.Descripcion = tabla_temporal.Tipo_de_propiedad
	WHERE tabla_temporal.Nombre_propiedad IS NOT NULL AND tabla_temporal.Nombre_usuario IS NOT NULL;

drop table tabla_temporal;
END;
*/