USE SolNorteDB

GO
-- Execs en orden para la prueba
EXEC ProcesarHoja1 'C:\data\Datos socios.xlsx';
GO
EXEC ProcesarHoja2 'C:\data\Datos socios.xlsx';
GO
EXEC ProcesarHoja3 'C:\data\Datos socios.xlsx';
GO
EXEC ProcesarHoja4 'C:\data\Datos socios.xlsx';
GO
EXEC ProcesarHoja5 'C:\data\Datos socios.xlsx';
GO
EXEC CargarDiasDesdeCSV
    @rutaArchivo = 'C:\data\open-meteo-buenosaires_2025.csv';
	
EXEC CargarDiasDesdeCSV
    @rutaArchivo = 'C:\data\open-meteo-buenosaires_2024.csv';


/*
select * from Asistencia.dias


Exec ProcesarSubTabla1;
Exec ProcesarSubTabla2;
Exec ProcesarSubTabla3;
select * from Actividades.Actividades_Otras


*/
/*
EXEC ImportarExcel 'C:\data\Datos socios.xlsx', 'Tarifas';
SELECT * FROM ##Excel_Hoja;
*/
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
--select * from ##Excel_Hoja 
--select * from Persona.Socio where ID_socio = 4144
--select * from Actividades.Actividades_Deportivas
--delete Actividades.Actividades_Deportivas
--SELECT * FROM ##Tabla_Subtabla_1;
--SELECT * FROM ##Tabla_Subtabla_2;
--select * from Actividades.Membresia
--delete Actividades.Membresia
--select * from Asistencia.asistencia

--exec VerColumnasTablaTemporal ##Tabla_Subtabla_3
/* --para ver el nombre de las columnas
EXEC ImportarExcel 'C:\data\Datos socios.xlsx', 'Tarifas';
DECLARE @ColumnList NVARCHAR(MAX) = '';

SELECT @ColumnList = STRING_AGG('[' + name + ']', ', ')
FROM tempdb.sys.columns
WHERE object_id = OBJECT_ID('tempdb..##Excel_Hoja');

PRINT @ColumnList;
*/


/*
EXEC VerColumnasTablaTemporal '##Tabla_Subtabla_2';

EXEC ImportarExcel 'C:\data\Datos socios.xlsx', 'presentismo_actividades';
Select * from ##Excel_Hoja
EXEC VerColumnasTablaTemporal '##Excel_Hoja';

*/