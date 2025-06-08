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
    ID_estado INT NOT NULL,
    ID_membresia INT,
    Email NVARCHAR(100),
    FechaNacimiento DATE NOT NULL,
    Domicilio NVARCHAR(200),
    ObraSocial NVARCHAR(100),
    NumObraSocial NVARCHAR(50),
    TelObraSocial VARCHAR(20),
	Descuento DECIMAL(5,2) DEFAULT 0,
    Activo BIT DEFAULT 1
);
GO

CREATE TABLE Datos.Estado (
	ID_estado INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(15),
	Descripcion VARCHAR(140)
);
GO

CREATE TABLE Datos.SocioTelefonos (
	DNI INT NOT NULL PRIMARY KEY,
	telefono INT,
	FOREIGN KEY (DNI) REFERENCES Datos.Socio(DNI)
);
GO

CREATE TABLE Datos.SocioEmergencia (
	DNI INT NOT NULL PRIMARY KEY,
	contacto INT,
	FOREIGN KEY (DNI) REFERENCES Datos.Socio(DNI)
);
GO

CREATE TABLE Datos.Parentesco (
    DNIresponsable INT PRIMARY KEY,
    DNImenor INT NOT NULL,
    FOREIGN KEY (DNIresponsable) REFERENCES Datos.Socio(DNI),
    FOREIGN KEY (DNImenor) REFERENCES Datos.Socio(DNI)
);
GO

CREATE TABLE Datos.Actividad (
    ID_Actividad INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Costo DECIMAL(10,2) NOT NULL,
    Dias NVARCHAR(200)
);
GO

CREATE TABLE Datos.Membresia (
    ID_Tipo INT PRIMARY KEY,
    Nombre NVARCHAR(100),
    Costo DECIMAL(10,2),
    Activo BIT DEFAULT 1
);
GO

--REHACER FACTURA

CREATE TABLE Datos.MedioDePago (
    IdTipoPago INT NOT NULL ,
    IdFuentePago INT NOT NULL ,
    Fuente NVARCHAR(50) NOT NULL,
    Activo BIT DEFAULT 1,
    CONSTRAINT PK_MedioDePago PRIMARY KEY (IdTipoPago, IdFuentePago)
);


CREATE TABLE Datos.Usuario (
    ID_rol INT NOT NULL,
    Usuario NVARCHAR(100) NOT NULL PRIMARY KEY,
    Contrasenia NVARCHAR(100) NOT NULL PRIMARY KEY,
    CaducidadContrasenia DATE,
    IDCuotasPagas INT,
    Saldo DECIMAL(10,2) DEFAULT 0,
);

CREATE TABLE Datos.UsuarioCuotasPagas (
    Usuario NVARCHAR(100) NOT NULL PRIMARY KEY,
    Contrasenia NVARCHAR(100) NOT NULL PRIMARY KEY,
	
	FOREIGN KEY (Usuario) REFERENCES Datos.Usuario(Usuario),
	FOREIGN KEY (Contrasenia) REFERENCES Datos.Usuario(Contrasenia)
);

CREATE TABLE Datos.Cobro (
    ID_Factura INT NOT NULL,
    CUIT CHAR(11) NOT NULL,
    FechaHora DATETIME NOT NULL,
    Costo DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (ID_Factura, CUIT, FechaHora),
    FOREIGN KEY (ID_Factura, CUIT, FechaHora) 
        REFERENCES Facturacion.Factura(ID_Factura, CUIT, FechaHora)
);

CREATE TABLE Datos.Reembolso (
    ID_Factura INT NOT NULL,
    CUIT CHAR(11) NOT NULL,
    FechaHora DATETIME NOT NULL,
    Costo DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (ID_Factura, CUIT, FechaHora),
    FOREIGN KEY (ID_Factura, CUIT, FechaHora) 
        REFERENCES Facturacion.Factura(ID_Factura, CUIT, FechaHora)
);


--REHACER OPERACIONES SOCIO

CREATE PROCEDURE Operaciones.InsertarSocio
    @DNI INT,
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @ID_estado INT,
    @ID_membresia INT = NULL,
    @Email NVARCHAR(100) = NULL,
    @FechaNacimiento DATE,
    @Domicilio NVARCHAR(200) = NULL,
    @ObraSocial NVARCHAR(100) = NULL,
    @TelObraSocial VARCHAR(20) = NULL,
    @NumObraSocial NVARCHAR(50) = NULL,
    @Descuento DECIMAL(5,2) = 0
AS
BEGIN
    INSERT INTO Datos.Socio (DNI, Nombre, Apellido, ID_estado, ID_membresia, Email, FechaNacimiento, Domicilio, ObraSocial, TelObraSocial, NumObraSocial, Descuento)
    VALUES (@DNI, @Nombre, @Apellido, @ID_estado, @ID_membresia, @Email, @FechaNacimiento, @Domicilio, @ObraSocial,@TelObraSocial @NumObraSocial, @Descuento);
END;
GO

CREATE PROCEDURE Operaciones.ActualizarSocio
    @DNI INT,
    @Nombre NVARCHAR(100) = NULL,
    @Apellido NVARCHAR(100) = NULL,
    @ID_estado INT = NULL,
    @ID_membresia INT = NULL,
    @Email NVARCHAR(100) = NULL,
    @FechaNacimiento DATE = NULL,
    @Domicilio NVARCHAR(200) = NULL,
    @ObraSocial NVARCHAR(100) = NULL,
    @TelObraSocial VARCHAR(20) = NULL,
    @NumObraSocial NVARCHAR(50) = NULL,
    @Descuento DECIMAL(5,2) = NULL
AS
BEGIN
    UPDATE Datos.Socio
    SET
        Nombre = ISNULL(@Nombre, Nombre),
        Apellido = ISNULL(@Apellido, Apellido),
        ID_estado = ISNULL(@ID_estado, ID_estado),
        ID_membresia = ISNULL(@ID_membresia, ID_membresia),
        Email = ISNULL(@Email, Email),
        FechaNacimiento = ISNULL(@FechaNacimiento, FechaNacimiento),
        Domicilio = ISNULL(@Domicilio, Domicilio),
        ObraSocial = ISNULL(@ObraSocial, ObraSocial),
        TelObraSocial = ISNULL(@TelObraSocial, TelObraSocial),
        NumObraSocial = ISNULL(@NumObraSocial, NumObraSocial),
        Descuento = ISNULL(@Descuento, Descuento)
    WHERE DNI = @DNI;
END;
GO

CREATE PROCEDURE Operaciones.EliminarSocio
    @DNI INT
AS
BEGIN
    -- Lógica para "eliminar" el socio (marcarlo como inactivo si existe un campo Activo, o eliminar físicamente)
    -- Si se mantiene el campo 'Activo' en Datos.Socio (como en el original), se actualizaría así:
    UPDATE Datos.Socio
    SET Activo = 0 -- Si existe un campo Activo, se setea a 0
    WHERE DNI = @DNI;
    -- Si no hay campo Activo y se desea eliminación física (con cuidado por las FK):
    -- DELETE FROM Datos.Socio WHERE DNI = @DNI;
END;
GO

CREATE PROCEDURE Operaciones.InsertarActividad
    @ID_Actividad INT,
    @Nombre NVARCHAR(100),
    @Costo DECIMAL(10,2),
    @Dias NVARCHAR(100)
AS
BEGIN
    INSERT INTO Datos.Actividad (ID_Actividad, Nombre, Costo, Dias)
    VALUES (@ID_Actividad, @Nombre, @Costo, @Dias);
END;
GO

CREATE PROCEDURE Operaciones.ActualizarActividad
    @ID_Actividad INT,
    @Nombre NVARCHAR(100) = NULL,
    @Costo DECIMAL(10,2) = NULL,
    @Dias NVARCHAR(100) = NULL
AS
BEGIN
    UPDATE Datos.Actividad
    SET 
        Nombre = ISNULL(@Nombre,Nombre),
        Costo = ISNULL(@Costo),
        Dias = ISNULL(@Dias),
    WHERE ID_Actividad = @ID_Actividad;
END;
GO

CREATE PROCEDURE Operaciones.EliminarActividad
    @ID_Actividad INT
AS
BEGIN
    UPDATE Datos.Actividad
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
    @Nombre NVARCHAR(100) = NULL,
    @Costo DECIMAL(10,2) = NULL
AS
BEGIN
    UPDATE Datos.Membresia
    SET 
        Nombre = ISNULL(@Nombre,Nombre),
        Costo = ISNULL(@Costo,Costo),
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


--REHACER OPERACIONS FACTURA

-- OPERACIONES USUARIO


CREATE PROCEDURE Operaciones.InsertarUsuario
    @DNI INT,
    @Usuario NVARCHAR(100),
    @Contrasenia NVARCHAR(100),
    @CaducidadContrasenia DATE = NULL,
    @Saldo DECIMAL(10,2) = 0,
    @ID_rol INT
AS
BEGIN
    INSERT INTO Datos.Usuario (DNI, Usuario, Contrasenia, CaducidadContrasenia, Saldo, ID_rol)
    VALUES (@DNI, @Usuario, @Contrasenia, @CaducidadContrasenia, @Saldo, @ID_rol);
END;
GO

CREATE PROCEDURE Operaciones.ActualizarUsuario
    @DNI INT,
    @Usuario NVARCHAR(100) = NULL,
    @Contrasenia NVARCHAR(100) = NULL,
    @CaducidadContrasenia DATE = NULL,
    @Saldo DECIMAL(10,2) = NULL,
    @ID_rol INT = NULL
AS
BEGIN
    UPDATE Datos.Usuario
    SET
        Usuario = ISNULL(@Usuario, Usuario),
        Contrasenia = ISNULL(@Contrasenia, Contrasenia),
        CaducidadContrasenia = ISNULL(@CaducidadContrasenia, CaducidadContrasenia),
        Saldo = ISNULL(@Saldo, Saldo),
        ID_rol = ISNULL(@ID_rol, ID_rol)
    WHERE DNI = @DNI;
END;
GO

CREATE PROCEDURE Operaciones.EliminarUsuario
    @DNI INT
AS
BEGIN
    DELETE FROM Datos.Usuario
    WHERE DNI = @DNI;
END;
GO

-- OPERACIONES COBRO

CREATE PROCEDURE Operaciones.RegistrarCobro
    @ID_Factura INT,
    @CUIT CHAR(11),
    @FechaHora DATETIME,
    @Costo DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO Datos.Cobro (ID_Factura, CUIT, FechaHora, Costo)
    VALUES (@ID_Factura, @CUIT, @FechaHora, @Costo);
END;
GO

CREATE PROCEDURE Operaciones.ActualizarCobro
    @ID_Factura INT,
    @CUIT CHAR(11),
    @FechaHora DATETIME,
    @NuevoCosto DECIMAL(10, 2)
AS
BEGIN
    UPDATE Datos.Cobro
    SET Costo = @NuevoCosto
    WHERE ID_Factura = @ID_Factura AND CUIT = @CUIT AND FechaHora = @FechaHora;
END;
GO

CREATE PROCEDURE Operaciones.EliminarCobro
    @ID_Factura INT,
    @CUIT CHAR(11),
    @FechaHora DATETIME
AS
BEGIN
    DELETE FROM Datos.Cobro
    WHERE ID_Factura = @ID_Factura AND CUIT = @CUIT AND FechaHora = @FechaHora;
END;
GO

CREATE PROCEDURE Operaciones.RegistrarReembolso
    @ID_Factura INT,
    @CUIT CHAR(11),
    @FechaHora DATETIME,
    @Costo DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO Datos.Reembolso (ID_Factura, CUIT, FechaHora, Costo)
    VALUES (@ID_Factura, @CUIT, @FechaHora, @Costo);
END;
GO

CREATE PROCEDURE Operaciones.ActualizarReembolso
    @ID_Factura INT,
    @CUIT CHAR(11),
    @FechaHora DATETIME,
    @NuevoCosto DECIMAL(10, 2)
AS
BEGIN
    UPDATE Datos.Reembolso
    SET Costo = @NuevoCosto
    WHERE ID_Factura = @ID_Factura AND CUIT = @CUIT AND FechaHora = @FechaHora;
END;
GO

CREATE PROCEDURE Operaciones.EliminarReembolso
    @ID_Factura INT,
    @CUIT CHAR(11),
    @FechaHora DATETIME
AS
BEGIN
    DELETE FROM Datos.Reembolso
    WHERE ID_Factura = @ID_Factura AND CUIT = @CUIT AND FechaHora = @FechaHora;
END;
GO