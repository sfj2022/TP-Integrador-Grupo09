--reporte 1
CREATE TABLE Finansas.Morosidad (
  ID_socio INT,
  ID_cuota INT,
  fecha DATE,
  Estado BIT,
  PRIMARY KEY (ID_socio, ID_cuota)
);
GO


INSERT INTO Finansas.Morosidad (ID_socio, ID_cuota, fecha, Estado)
SELECT
  ID_socio,
  ID_cuota,
  fecha,
  0 -- Indica que está vencido y no pagado
FROM Finansas.Cuota
WHERE Estado IN ('vencido1', 'vencido2');
GO

CREATE PROCEDURE MostrarMorososEnRango
  @FechaInicio DATE,
  @FechaFin DATE
AS
BEGIN
  SET NOCOUNT ON;

  SELECT 
    'Morosos Recurrentes' AS [Nombre del reporte],
    CONCAT(FORMAT(@FechaInicio, 'yyyy-MM-dd'), ' al ', FORMAT(@FechaFin, 'yyyy-MM-dd')) AS [Período],
    s.ID_socio AS [Nro de socio],
    s.nombre + ' ' + s.apellido AS [Nombre y apellido],
    FORMAT(m.fecha, 'MMMM yyyy', 'es-AR') AS [Mes incumplido],
    RANK() OVER (ORDER BY COUNT(*) DESC) AS [Ranking de morosidad]
  FROM Finansas.Morosidad m
  INNER JOIN Persona.Socio s ON m.ID_socio = s.ID_socio
  WHERE m.fecha BETWEEN @FechaInicio AND @FechaFin
    AND m.Estado = 0
  GROUP BY 
    s.ID_socio,
    s.nombre,
    s.apellido,
    FORMAT(m.fecha, 'MMMM yyyy', 'es-AR')
  HAVING COUNT(*) > 2
  ORDER BY [Ranking de morosidad];
END;
GO



--reporte 2
CREATE PROCEDURE IngresoMensualPorActividad
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @anioActual INT = YEAR(GETDATE());

  SELECT 
    Nombre AS [Actividad Deportiva],
    ISNULL([1], 0) AS Enero,
    ISNULL([2], 0) AS Febrero,
    ISNULL([3], 0) AS Marzo,
    ISNULL([4], 0) AS Abril,
    ISNULL([5], 0) AS Mayo,
    ISNULL([6], 0) AS Junio,
    ISNULL([7], 0) AS Julio,
    ISNULL([8], 0) AS Agosto,
    ISNULL([9], 0) AS Septiembre,
    ISNULL([10], 0) AS Octubre,
    ISNULL([11], 0) AS Noviembre,
    ISNULL([12], 0) AS Diciembre
  FROM (
    SELECT 
      ad.Nombre,
      MONTH(c.fecha) AS Mes,
      (c.costo - c.descuento + c.recargo) AS Ingreso
    FROM Finansas.Cuota c
    INNER JOIN Actividades.Inscripcion_Deportiva id
      ON c.ID_inscripcion = id.ID_inscripcion AND c.ID_socio = id.ID_socio
    INNER JOIN Actividades.Actividades_Deportivas ad
      ON id.ID_actividad = ad.ID_actividad
    WHERE 
      c.Tipo = 'deporte'
      AND c.Estado = 'pago'
      AND YEAR(c.fecha) = @anioActual
  ) AS Fuente
  PIVOT (
    SUM(Ingreso) FOR Mes IN (
      [1], [2], [3], [4], [5], [6],
      [7], [8], [9], [10], [11], [12]
    )
  ) AS pvt
  ORDER BY [Actividad Deportiva];
END;
GO



--reporte 3
CREATE PROCEDURE InasistenciasPorMembresia
AS
BEGIN
  SET NOCOUNT ON;

  -- Datos base: inasistencias con categoría y actividad
  WITH Inasistencias AS (
    SELECT 
      a.ID_socio,
      COALESCE(ad.Nombre, ao.Nombre) AS Actividad,
      m.nombre AS Categoria
    FROM Asistencia.asistencia a
    INNER JOIN Actividades.Inscripcion_Socio i 
      ON a.ID_socio = i.ID_socio 
      AND (i.fecha_baja IS NULL OR a.Fecha <= i.fecha_baja)
    INNER JOIN Actividades.Membresia m ON i.ID_membresia = m.ID_tipo
    LEFT JOIN Actividades.Actividades_Deportivas ad ON a.ID_actividad = ad.ID_actividad
    LEFT JOIN Actividades.Actividades_Otras ao ON a.ID_actividad = ao.ID_actividad
    WHERE a.Presentismo = 0
  ),

  -- Conteo de inasistencias y socios únicos por actividad y categoría
  Conteo AS (
    SELECT 
      Actividad,
      Categoria,
      COUNT(*) AS CantInasistencias,
      COUNT(DISTINCT ID_socio) AS CantSocios
    FROM Inasistencias
    GROUP BY Actividad, Categoria
  )

  -- Pivot final
  SELECT 
    c.Actividad,
    
    ISNULL(m.CantSocios, 0) AS [Socios_Mayor],
    ISNULL(m.CantInasistencias, 0) AS [Inasistencias_Mayor],

    ISNULL(ca.CantSocios, 0) AS [Socios_Cadete],
    ISNULL(ca.CantInasistencias, 0) AS [Inasistencias_Cadete],

    ISNULL(me.CantSocios, 0) AS [Socios_Menor],
    ISNULL(me.CantInasistencias, 0) AS [Inasistencias_Menor],

    ISNULL(m.CantSocios, 0) + ISNULL(ca.CantSocios, 0) + ISNULL(me.CantSocios, 0) AS [Socios_Totales],
    ISNULL(m.CantInasistencias, 0) + ISNULL(ca.CantInasistencias, 0) + ISNULL(me.CantInasistencias, 0) AS [Inasistencias_Totales]

  FROM (
    SELECT DISTINCT Actividad FROM Conteo
  ) c
  LEFT JOIN Conteo m ON c.Actividad = m.Actividad AND m.Categoria = 'Mayor'
  LEFT JOIN Conteo ca ON c.Actividad = ca.Actividad AND ca.Categoria = 'Cadete'
  LEFT JOIN Conteo me ON c.Actividad = me.Actividad AND me.Categoria = 'Menor'

  ORDER BY [Inasistencias_Totales] DESC;
END;
GO



--reporte 4
CREATE PROCEDURE SociosConInasistencias
AS
BEGIN
  SET NOCOUNT ON;

  -- Socios con al menos una inasistencia (Presentismo = 0)
  WITH SociosFaltas AS (
    SELECT DISTINCT
      a.ID_socio
    FROM Asistencia.asistencia a
    WHERE a.Presentismo = 0
  )

  SELECT
    s.ID_socio,
    s.nombre,
    s.apellido,
    DATEDIFF(YEAR, s.FechaNacimiento, GETDATE()) -
      CASE 
        WHEN MONTH(s.FechaNacimiento) > MONTH(GETDATE()) OR
             (MONTH(s.FechaNacimiento) = MONTH(GETDATE()) AND DAY(s.FechaNacimiento) > DAY(GETDATE()))
        THEN 1 ELSE 0
      END AS Edad,
    m.nombre AS Categoria
  FROM SociosFaltas sf
  INNER JOIN Persona.Socio s ON sf.ID_socio = s.ID_socio
  INNER JOIN Actividades.Inscripcion_Socio ins ON s.ID_socio = ins.ID_socio
  INNER JOIN Actividades.Membresia m ON ins.ID_membresia = m.ID_tipo
  GROUP BY s.ID_socio, s.nombre, s.apellido, s.FechaNacimiento, m.nombre
  ORDER BY s.apellido, s.nombre;
END;
GO






























