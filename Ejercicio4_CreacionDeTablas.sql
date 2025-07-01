--ENUNCIADO
/*
Entrega 4- Documento de instalación y configuración
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos. En esta oportunidad utilizarán SQL Server.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos, etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es entregado en una sola ejecución). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”. Algunas operaciones implicarán store procedures que involucran varias tablas, uso de transacciones, etc. Puede que incluso realicen ciertas operaciones mediante varios SPs.
Asegúrense de que los comentarios que acompañen al código lo expliquen.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto en la creación de objetos. NO use el esquema “dbo”.
Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que en los juegos de prueba demuestren la correcta aplicación de las validaciones.
Las pruebas deben realizarse en un script separado, donde con comentarios se indique en cada caso el resultado esperado
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip (observar las pautas para nomenclatura antes expuestas) mediante la sección de prácticas de MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
*/
/*
FECHA DE ENTREGA 27/6
Grupo 9
Materia: Base de datos Aplicada
Alumnos: 
	DNI		|			Nombre				|			Email						|
------------------------------------------------------------------------------------
42956230	|	Ferreyra Santiago Julian	|	santiagojulianferreyra@gmail.com	|
43325353	|	Girardin Gaston Adrian		|	gastongirardin@gmail.com			|
41107584	|	Rodriguez Fenske Axel Joel	|	yo.axel48@gmail.com					|
------------------------------------------------------------------------------------
*/
--FIN DEL ENUNCIADO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SolNorteDB')
BEGIN
    CREATE DATABASE SolNorteDB;
END
GO

USE SolNorteDB;


-- ======================================
-- TABLAS PRINCIPALES: SOCIOS Y TELÉFONOS
-- ======================================
GO
Create Schema Persona
GO

CREATE TABLE Persona.Socio (
  ID_socio INT PRIMARY KEY,
  DNI VARCHAR(8),
  Nombre VARCHAR(50) ,
  Apellido VARCHAR(50),
  Email VARCHAR(50),
  FechaNacimiento DATE,
  domicilio VARCHAR(100),
  obra_social VARCHAR(50),
  numObraSocial VARCHAR(30),
  telObraSocial VARCHAR(30),
  estado VARCHAR(10) CHECK (estado IN ('activo', 'inactivo', 'moroso')),
  usuario VARCHAR(16),
  contrasenia VARCHAR(32),
  caducidad_contrasenia DATE
);
GO

CREATE TABLE Persona.SocioTelefonos (
  ID_socio INT,
  Tel VARCHAR(50),
  PRIMARY KEY (ID_socio, Tel),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio)
);
GO

CREATE TABLE Persona.SocioEmergencia (
  ID_socio INT,
  Tel VARCHAR(50),
  PRIMARY KEY (ID_socio, Tel),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio)
);
GO
CREATE TABLE Persona.Invitado (
  DNI VARCHAR(8),
  fecha DATE,
  ID_socio INT,
  nombre VARCHAR(50),
  apellido VARCHAR(50),
  ID_actividad INT,
  ID_banco INT,
  credenciales VARCHAR(50),
  PRIMARY KEY (DNI, fecha),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio)
);
GO

CREATE TABLE Persona.responsabilidad (
  ID_responsable INT,
  ID_menor INT,
  PRIMARY KEY (ID_responsable, ID_menor),
  FOREIGN KEY (ID_responsable) REFERENCES Persona.Socio(ID_socio),
  FOREIGN KEY (ID_menor) REFERENCES Persona.Socio(ID_socio)
);
GO
CREATE SCHEMA Gestion;
GO

CREATE TABLE Gestion.rol (
  ID_rol INT PRIMARY KEY,
  nombre VARCHAR(20),
  descripcion VARCHAR(280)
);

GO

CREATE TABLE Gestion.Personal (
  ID_personal INT PRIMARY KEY,
  ID_rol INT,
  nombre VARCHAR(50),
  apellido VARCHAR(50),
  DNI VARCHAR(8),
  usuario VARCHAR(16),
  contrasenia VARCHAR(32),
  FOREIGN KEY (ID_rol) REFERENCES Gestion.rol(ID_rol)
);




-- ================================
-- INSCRIPCIONES Y MEMBRESÍAS
-- ================================
GO
CREATE SCHEMA Actividades;

GO
CREATE TABLE Actividades.Membresia (
  ID_tipo INT PRIMARY KEY,
  nombre VARCHAR(20),
  descripcion VARCHAR(140),
  costo DECIMAL(10,2)
);
GO

CREATE TABLE Actividades.Inscripcion_Socio (
  ID_socio INT,
  ID_inscripcion INT,
  ID_membresia INT,
  fecha_inicio DATE,
  fecha_baja DATE,
  PRIMARY KEY (ID_socio, ID_inscripcion),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio),
  FOREIGN KEY (ID_membresia) REFERENCES Actividades.Membresia(ID_tipo)
);
GO

CREATE TABLE Actividades.Actividades_Deportivas (
  ID_actividad INT PRIMARY KEY,
  Nombre VARCHAR(32),
  costo DECIMAL(10,2)
);
GO

CREATE TABLE Actividades.Actividades_Otras (
  ID_actividad INT PRIMARY KEY,
  Nombre VARCHAR(32),
  costo_socio DECIMAL(10,2),
  costo_invitados DECIMAL(10,2)
);
GO

CREATE TABLE Actividades.AcDep_turnos (
  ID_actividad INT,
  ID_turno INT,
  turno VARCHAR(64),
  PRIMARY KEY (ID_actividad, ID_turno),
  FOREIGN KEY (ID_actividad) REFERENCES Actividades.Actividades_Deportivas(ID_actividad)
);
GO

CREATE TABLE Actividades.AcOtra_turnos (
  ID_actividad INT,
  ID_turno INT,
  turno VARCHAR(64),
  PRIMARY KEY (ID_actividad, ID_turno),
  FOREIGN KEY (ID_actividad) REFERENCES Actividades.Actividades_Otras(ID_actividad)
);
GO



CREATE TABLE Actividades.Inscripcion_Deportiva (
  ID_socio INT,
  ID_inscripcion INT,
  ID_actividad INT,
  ID_Turno INT,
  fecha_inicio DATE,
  fecha_baja DATE,
  PRIMARY KEY (ID_socio, ID_inscripcion),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio),
  FOREIGN KEY (ID_actividad) REFERENCES Actividades.Actividades_Deportivas(ID_actividad),
  FOREIGN KEY (ID_actividad, ID_Turno) REFERENCES Actividades.AcDep_turnos(ID_actividad, ID_turno)
);
GO


CREATE TABLE Actividades.Inscripcion_Otra (
  ID_socio INT,
  ID_inscripcion INT,
  ID_actividad INT,
  ID_Turno INT,
  fecha_inicio DATE,
  fecha_baja DATE,
  PRIMARY KEY (ID_socio, ID_inscripcion),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio),
  FOREIGN KEY (ID_actividad) REFERENCES Actividades.Actividades_Otras(ID_actividad),
  FOREIGN KEY (ID_actividad, ID_Turno) REFERENCES Actividades.AcOtra_turnos(ID_actividad, ID_turno)
);
GO

-- =============================
-- CUENTAS Y PAGOS
-- =============================
GO
Create Schema Finansas

GO
CREATE TABLE Finansas.MedioDePago (
  ID_banco INT PRIMARY KEY,
  nombre VARCHAR(32)
);
GO

CREATE TABLE Finansas.Cuenta (
  ID_socio INT,
  ID_cuenta INT,
  ID_banco INT  NULL,
  credenciales VARCHAR(50),
  tipo VARCHAR(20) CHECK (tipo IN ('credito', 'debito')),
  SaldoAFavor DECIMAL(10,2),
  fechaPagoAutomatico DATE,
  PRIMARY KEY (ID_socio, ID_cuenta),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio),
  FOREIGN KEY (ID_banco) REFERENCES Finansas.MedioDePago(ID_banco)
);
GO

CREATE TABLE Finansas.Cuota (
  ID_cuota INT PRIMARY KEY,
  ID_socio INT,
  ID_inscripcion INT,
  ID_detalle INT,
  Tipo VARCHAR(10) CHECK (Tipo IN ('socio', 'deporte', 'otra')),
  fecha DATE,
  Vencimiento1 DATE,
  Vencimiento2 DATE,
  costo DECIMAL(10,2),
  recargo DECIMAL(10,2),
  descuento DECIMAL(10,2),
  Estado VARCHAR(20) CHECK (Estado IN ('impago', 'vencido1', 'vencido2', 'pago')),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio)
);
GO
--DROP TABLE Finansas.factura
CREATE TABLE Finansas.factura (
  ID_factura INT PRIMARY KEY,
  DNI VARCHAR(8),
  CUIT VARCHAR(13),
  FechaYHora DATETIME,
  costo DECIMAL(10,2),
  estado BIT
);
GO

CREATE TABLE Finansas.detalle_factura (
  ID_factura INT,
  ID_cuota INT,
  ID_inscripcion INT,
  Tipo VARCHAR(10),
  costo DECIMAL(10,2),
  recargo DECIMAL(10,2),
  descuento DECIMAL(10,2),
  PRIMARY KEY (ID_factura, ID_cuota),
  FOREIGN KEY (ID_factura) REFERENCES Finansas.factura(ID_factura),
  FOREIGN KEY (ID_cuota) REFERENCES Finansas.Cuota(ID_cuota)
);
GO
--drop table Finansas.cobro
CREATE TABLE Finansas.cobro (
  ID_Cobro BIGINT PRIMARY KEY,
  ID_factura INT,
  ID_socio INT,
  ID_cuenta INT,
  fecha date,
  Medio_Pago Varchar(20),
  Costo DECIMAL(10,2),
  Estado BIT,
  FOREIGN KEY (ID_factura) REFERENCES Finansas.factura(ID_factura),
  FOREIGN KEY (ID_socio, ID_cuenta) REFERENCES Finansas.Cuenta(ID_socio, ID_cuenta)
);
GO


CREATE TABLE Finansas.reembolso (
  ID_factura INT,
  ID_socio INT,
  ID_cuenta INT,
  Costo DECIMAL(10,2),
  Estado BIT,
  PRIMARY KEY (ID_factura, ID_socio, ID_cuenta),
  FOREIGN KEY (ID_factura) REFERENCES Finansas.factura(ID_factura),
  FOREIGN KEY (ID_socio, ID_cuenta) REFERENCES Finansas.Cuenta(ID_socio, ID_cuenta)
);
GO


-- =============================
-- ASISTENCIA
-- =============================
GO
CREATE SCHEMA Asistencia;

GO
CREATE TABLE Asistencia.dias (
  fecha DATE PRIMARY KEY,
  climaMalo BIT
);
GO

CREATE TABLE Asistencia.asistencia (
  ID_socio INT,
  ID_actividad INT,
  ID_turno INT,
  Fecha DATE,
  Presentismo BIT,
  PRIMARY KEY (ID_socio, ID_actividad, ID_turno, Fecha),
  FOREIGN KEY (ID_socio) REFERENCES Persona.Socio(ID_socio),
  FOREIGN KEY (Fecha) REFERENCES Asistencia.dias(fecha)
);

GO



