CREATE DATABASE SolNorteDB;
USE SolNorteDB;

/* Creación de ESQUEMAS */
CREATE SCHEMA Datos;
GO

CREATE SCHEMA Operaciones;
GO

CREATE SCHEMA Facturacion;
GO

CREATE TABLE Datos.Socio (
    DNI INT NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    FechaNacimiento DATE NOT NULL,
    Telefono VARCHAR(20),
    Domicilio NVARCHAR(200),
    TelefonoEmergencia VARCHAR(20),
    ObraSocial NVARCHAR(100),
    NumObraSocial NVARCHAR(50),
    TelObraSocial VARCHAR(20),
    Activo BIT DEFAULT 1
);

CREATE TABLE Datos.Menor (
    DNI INT PRIMARY KEY,
    DNIResponsable INT NOT NULL,
    FOREIGN KEY (DNI) REFERENCES Datos.Socio(DNI),
    FOREIGN KEY (DNIResponsable) REFERENCES Datos.Socio(DNI)
);
GO

CREATE TABLE Datos.ActividadDeportiva (
    ID_Actividad INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Costo DECIMAL(10,2) NOT NULL,
    Dias NVARCHAR(100),
    Activo BIT DEFAULT 1
);
GO

CREATE TABLE Datos.Membresia (
    ID_Tipo INT PRIMARY KEY,
    Nombre NVARCHAR(100),
    Costo DECIMAL(10,2),
    Activo BIT DEFAULT 1
);
GO

CREATE TABLE Facturacion.Factura (
    ID_Factura INT IDENTITY(1,1) PRIMARY KEY,
    CUIT CHAR(11) NOT NULL,
    FechaHora DATETIME DEFAULT GETDATE(),
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    Domicilio NVARCHAR(200),
    CostoTotal DECIMAL(10,2) NOT NULL,
    Vencimiento1 DATE,
    Vencimiento2 DATE,
    Estado NVARCHAR(20) DEFAULT 'Activa'
);
GO

CREATE TABLE Datos.MedioDePago (
    IdTipoPago INT NOT NULL,
    IdFuentePago INT NOT NULL,
    Fuente NVARCHAR(50) NOT NULL,
    Activo BIT DEFAULT 1,
    CONSTRAINT PK_MedioDePago PRIMARY KEY (IdTipoPago, IdFuentePago)
);

CREATE TABLE Facturacion.FacturaDetalleActividad (
    FacturaID INT NOT NULL,
    DNI INT NOT NULL,
    SocioID INT NOT NULL,
    ActividadID INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_FacturaDetalleActividad PRIMARY KEY (FacturaID, SocioID, ActividadID),
    FOREIGN KEY (FacturaID) REFERENCES Facturacion.Factura(ID_Factura),
    FOREIGN KEY (DNI) REFERENCES Datos.Socio(DNI),
    FOREIGN KEY (ActividadID) REFERENCES Datos.ActividadDeportiva(ID_Actividad)
);

-- Procedimientos para SOCIO
CREATE PROCEDURE Operaciones.InsertarSocio 
    @DNI INT,
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Email NVARCHAR(100),
    @FechaNacimiento DATE,
    @Telefono VARCHAR(20),
    @Domicilio NVARCHAR(200),
    @TelefonoEmergencia VARCHAR(20),
    @ObraSocial NVARCHAR(100) = NULL,
    @NumObraSocial NVARCHAR(50) = NULL,
    @TelObraSocial VARCHAR(20) = NULL
AS
BEGIN
    INSERT INTO Datos.Socio (
        DNI, Nombre, Apellido, Email, FechaNacimiento, Telefono, Domicilio,
        TelefonoEmergencia, ObraSocial, NumObraSocial, TelObraSocial
    )
    VALUES (
        @DNI, @Nombre, @Apellido, @Email, @FechaNacimiento, @Telefono, @Domicilio,
        @TelefonoEmergencia, @ObraSocial, @NumObraSocial, @TelObraSocial
    );
END;
GO

CREATE PROCEDURE Operaciones.ActualizarSocio
    @DNI INT,
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Email NVARCHAR(100),
    @Telefono VARCHAR(20),
    @Domicilio NVARCHAR(200),
    @TelefonoEmergencia VARCHAR(20),
    @ObraSocial NVARCHAR(100) = NULL,
    @NumObraSocial NVARCHAR(50) = NULL,
    @TelObraSocial VARCHAR(20) = NULL
AS
BEGIN
    UPDATE Datos.Socio
    SET 
        Nombre = @Nombre,
        Apellido = @Apellido,
        Email = @Email,
        Telefono = @Telefono,
        Domicilio = @Domicilio,
        TelefonoEmergencia = @TelefonoEmergencia,
        ObraSocial = @ObraSocial,
        NumObraSocial = @NumObraSocial,
        TelObraSocial = @TelObraSocial
    WHERE DNI = @DNI;
END;
GO

CREATE PROCEDURE Operaciones.EliminarSocio
    @DNI INT
AS
BEGIN
    UPDATE Datos.Socio
    SET Activo = 0
    WHERE DNI = @DNI;
END;
GO

CREATE PROCEDURE Operaciones.InsertarActividadDeportiva
    @ID_Actividad INT,
    @Nombre NVARCHAR(100),
    @Costo DECIMAL(10,2),
    @Dias NVARCHAR(100)
AS
BEGIN
    INSERT INTO Datos.ActividadDeportiva (ID_Actividad, Nombre, Costo, Dias)
    VALUES (@ID_Actividad, @Nombre, @Costo, @Dias);
END;
GO

CREATE PROCEDURE Operaciones.ActualizarActividadDeportiva
    @ID_Actividad INT,
    @Nombre NVARCHAR(100),
    @Costo DECIMAL(10,2),
    @Dias NVARCHAR(100)
AS
BEGIN
    UPDATE Datos.ActividadDeportiva
    SET 
        Nombre = @Nombre,
        Costo = @Costo,
        Dias = @Dias
    WHERE ID_Actividad = @ID_Actividad;
END;
GO

CREATE PROCEDURE Operaciones.EliminarActividadDeportiva
    @ID_Actividad INT
AS
BEGIN
    UPDATE Datos.ActividadDeportiva
    SET Activo = 0
    WHERE ID_Actividad = @ID_Actividad;
END;
GO
CREATE PROCEDURE Operaciones.InsertarMembresia
    @ID_Tipo INT,
    @Nombre NVARCHAR(100),
    @Costo DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Datos.Membresia (ID_Tipo, Nombre, Costo)
    VALUES (@ID_Tipo, @Nombre, @Costo);
END;
GO

CREATE PROCEDURE Operaciones.ActualizarMembresia
    @ID_Tipo INT,
    @Nombre NVARCHAR(100),
    @Costo DECIMAL(10,2)
AS
BEGIN
    UPDATE Datos.Membresia
    SET 
        Nombre = @Nombre,
        Costo = @Costo
    WHERE ID_Tipo = @ID_Tipo;
END;
GO

CREATE PROCEDURE Operaciones.EliminarMembresia
    @ID_Tipo INT
AS
BEGIN
    UPDATE Datos.Membresia
    SET Activo = 0
    WHERE ID_Tipo = @ID_Tipo;
END;
GO
CREATE PROCEDURE Facturacion.InsertarFactura
    @CUIT CHAR(11),
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Domicilio NVARCHAR(200),
    @CostoTotal DECIMAL(10,2),
    @Vencimiento1 DATE = NULL,
    @Vencimiento2 DATE = NULL
AS
BEGIN
    INSERT INTO Facturacion.Factura (
        CUIT, Nombre, Apellido, Domicilio, CostoTotal, Vencimiento1, Vencimiento2
    )
    VALUES (
        @CUIT, @Nombre, @Apellido, @Domicilio, @CostoTotal, @Vencimiento1, @Vencimiento2
    );
END;
GO

CREATE PROCEDURE Facturacion.ActualizarFactura
    @ID_Factura INT,
    @CUIT CHAR(11),
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Domicilio NVARCHAR(200),
    @CostoTotal DECIMAL(10,2),
    @Vencimiento1 DATE = NULL,
    @Vencimiento2 DATE = NULL
AS
BEGIN
    UPDATE Facturacion.Factura
    SET
        CUIT = @CUIT,
        Nombre = @Nombre,
        Apellido = @Apellido,
        Domicilio = @Domicilio,
        CostoTotal = @CostoTotal,
        Vencimiento1 = @Vencimiento1,
        Vencimiento2 = @Vencimiento2
    WHERE ID_Factura = @ID_Factura;
END;
GO

-- Factura no se elimina, se marca con estado "Anulada"

CREATE PROCEDURE Facturacion.AnularFactura
    @ID_Factura INT
AS
BEGIN
    UPDATE Facturacion.Factura
    SET Estado = 'Anulada'
    WHERE ID_Factura = @ID_Factura;
END;
GO
