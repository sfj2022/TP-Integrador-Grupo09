--Enunciado
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

-- ===============================================
-- Stored Procedures para la tabla Persona.Socio
-- ===============================================

USE SolNorteDB

GO
-- SP para insertar un nuevo socio
CREATE OR ALTER PROCEDURE InsertarSocio
    @ID_socio INT,
    @DNI VARCHAR(8),
	@Nombre VARCHAR(50),
	@Apellido VARCHAR(50),
    @Email VARCHAR(50),
    @FechaNacimiento DATE,
    @domicilio VARCHAR(100),
    @obra_social VARCHAR(50),
    @numObraSocial VARCHAR(30),
    @telObraSocial VARCHAR(15),
    @estado VARCHAR(10),
    @usuario VARCHAR(16),
    @contrasenia VARCHAR(32),
    @caducidad_contrasenia DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @DNI IS NULL
    BEGIN
        THROW 50001, 'ERROR: El DNI no puede estar vacío.', 1;
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        THROW 50001, 'ERROR: El DNI debe contener 8 dígitos numéricos.', 1;

    END

	IF @nombre IS NULL OR @nombre LIKE '%[^A-Za-zÁÉÍÓÚÑáéíóúñ ]%'
	BEGIN
		THROW 50001, 'ERROR: El nombre solo debe contener letras y espacios.', 1;
		 
	END;

	IF @apellido IS NULL OR @apellido LIKE '%[^A-Za-zÁÉÍÓÚÑáéíóúñ ]%'
	BEGIN
		THROW 50001, 'ERROR: El apellido solo debe contener letras y espacios.', 1;
		 
	END;


    IF @Email IS NULL OR @Email NOT LIKE '%@%.%'
    BEGIN
        THROW 50001, 'ERROR: El Email no es válido.', 1;
    END

    IF @FechaNacimiento IS NULL OR @FechaNacimiento > GETDATE()
    BEGIN
		DECLARE @msg NVARCHAR(200) = 'ERROR: La Fecha de Nacimiento no es válida. (F_Nac: ' + ISNULL(CAST(@FechaNacimiento AS VARCHAR), 'NULL') + ')';
		THROW 50001, @msg, 1;
    END

    IF @estado NOT IN ('activo', 'inactivo', 'moroso')
    BEGIN
        THROW 50001, 'ERROR: El estado del socio no es válido. Debe ser "activo", "inactivo" o "moroso".', 1;
         
    END

    -- Verificar si el ID_socio ya está
    IF EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio ya existe, use un ID diferente.', 1;
         
    END

    INSERT INTO Persona.Socio (
        ID_socio, DNI,Nombre, Apellido, Email, FechaNacimiento, domicilio, obra_social,
        numObraSocial, telObraSocial, estado, usuario, contrasenia, caducidad_contrasenia
    )
    VALUES (
        @ID_socio, @DNI, @Nombre, @Apellido, @Email, @FechaNacimiento, @domicilio, @obra_social,
        @numObraSocial, @telObraSocial, @estado, @usuario, @contrasenia, @caducidad_contrasenia
    );
END;
GO

-- SP para actualizar un socio existente
CREATE OR ALTER PROCEDURE ActualizarSocio
    @ID_socio INT,
    @DNI VARCHAR(8) = NULL,
    @Email VARCHAR(50) = NULL,
    @FechaNacimiento DATE = NULL,
    @domicilio VARCHAR(100) = NULL,
    @obra_social VARCHAR(50) = NULL,
    @numObraSocial VARCHAR(30) = NULL,
    @telObraSocial VARCHAR(15) = NULL,
    @estado VARCHAR(10) = NULL,
    @usuario VARCHAR(16) = NULL,
    @contrasenia VARCHAR(32) = NULL,
    @caducidad_contrasenia DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El socio con el ID especificado no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @DNI IS NOT NULL AND (LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
    BEGIN
        THROW 50001, 'ERROR: El DNI debe contener 8 dígitos numéricos.', 1;
         
    END

    IF @Email IS NOT NULL AND (@Email NOT LIKE '%@%.%')
    BEGIN
        THROW 50001, 'ERROR: El Email no es válido.', 1;
         
    END

    IF @FechaNacimiento IS NOT NULL AND (@FechaNacimiento > GETDATE())
    BEGIN
        THROW 50001, 'ERROR: La Fecha de Nacimiento no es válida.', 1;
         
    END

    IF @estado IS NOT NULL AND @estado NOT IN ('activo', 'inactivo', 'moroso')
    BEGIN
        THROW 50001, 'ERROR: El estado del socio no es válido. Debe ser "activo", "inactivo" o "moroso".', 1;
         
    END

    UPDATE Persona.Socio
    SET
        DNI = ISNULL(@DNI, DNI),
        Email = ISNULL(@Email, Email),
        FechaNacimiento = ISNULL(@FechaNacimiento, FechaNacimiento),
        domicilio = ISNULL(@domicilio, domicilio),
        obra_social = ISNULL(@obra_social, obra_social),
        numObraSocial = ISNULL(@numObraSocial, numObraSocial),
        telObraSocial = ISNULL(@telObraSocial, telObraSocial),
        estado = ISNULL(@estado, estado),
        usuario = ISNULL(@usuario, usuario),
        contrasenia = ISNULL(@contrasenia, contrasenia),
        caducidad_contrasenia = ISNULL(@caducidad_contrasenia, caducidad_contrasenia)
    WHERE
        ID_socio = @ID_socio;
END;
GO

-- SP para eliminar un socio (borrado lógico)
CREATE OR ALTER PROCEDURE EliminarSocio
    @ID_socio INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El socio con el ID especificado no existe.', 1;
         
    END

    -- Actualizar el estado a 'inactivo' para simular un borrado lógico
    UPDATE Persona.Socio
    SET estado = 'inactivo'
    WHERE ID_socio = @ID_socio;
END;
GO

-- ====================================================
-- Stored Procedures para la tabla Persona.SocioTelefonos
-- ====================================================

-- SP para insertar un nuevo teléfono de socio
CREATE OR ALTER PROCEDURE InsertarSocioTelefono
    @ID_socio INT,
    @Tel VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El socio con el ID especificado no existe.', 1;
         
    END

    -- Validar formato del teléfono
    IF @Tel IS NULL OR LTRIM(RTRIM(@Tel)) = '' OR NOT (@Tel LIKE '[0-9]%')
    BEGIN
        THROW 50001, 'ERROR: El número de teléfono no es válido.', 1;
         
    END

    -- Verificar si el teléfono ya existe para este socio
    IF EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        THROW 50001, 'ERROR: Este número de teléfono ya está registrado para el socio.', 1;
         
    END

    INSERT INTO Persona.SocioTelefonos (ID_socio, Tel)
    VALUES (@ID_socio, @Tel);
END;
GO

--  Actualizar un teléfono de socio
CREATE OR ALTER PROCEDURE ActualizarSocioTelefono
    @ID_socio INT,
    @TelAntiguo VARCHAR(15),
    @TelNuevo VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio y el teléfono antiguo existen
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo)
    BEGIN
        THROW 50001, 'ERROR: El teléfono antiguo no está registrado para el socio especificado.', 1;
         
    END

    -- Validar formato del nuevo teléfono
    IF @TelNuevo IS NULL OR LTRIM(RTRIM(@TelNuevo)) = '' OR NOT (@TelNuevo LIKE '[0-9]%')
    BEGIN
        THROW 50001, 'ERROR: El nuevo número de teléfono no es válido.', 1;
         
    END

    -- Verificar si el nuevo teléfono ya existe para este socio (evitar duplicados)
    IF EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @TelNuevo)
    BEGIN
        THROW 50001, 'ERROR: El nuevo número de teléfono ya está registrado para el socio.', 1;
         
    END

    -- Eliminar el teléfono antiguo y luego insertar el nuevo
    DELETE FROM Persona.SocioTelefonos
    WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo;

    INSERT INTO Persona.SocioTelefonos (ID_socio, Tel)
    VALUES (@ID_socio, @TelNuevo);
END;
GO

-- SP para eliminar un teléfono de socio
CREATE OR ALTER PROCEDURE EliminarSocioTelefono
    @ID_socio INT,
    @Tel VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el teléfono existe para el socio
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        THROW 50001, 'ERROR: El teléfono especificado no existe para el socio.', 1;
         
    END

    DELETE FROM Persona.SocioTelefonos
    WHERE ID_socio = @ID_socio AND Tel = @Tel;
END;
GO

-- =========================================================
-- Stored Procedures para la tabla Persona.SocioEmergencia
-- =========================================================

CREATE OR ALTER PROCEDURE InsertarSocioEmergencia
    @ID_socio INT,
    @Tel VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El socio con el ID especificado no existe.', 1;
         
    END
	
    -- Validar si el teléfono está vacío o es nulo
    IF @Tel IS NULL OR LTRIM(RTRIM(@Tel)) = ''
    BEGIN
        THROW 50001, 'ERROR: El número de teléfono de emergencia no puede estar vacío.', 1;
         
    END

    -- Verificar si el teléfono ya existe para este socio
    IF EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        THROW 50001, 'ERROR: Este número de teléfono de emergencia ya está registrado para el socio.', 1;
         
    END

    INSERT INTO Persona.SocioEmergencia (ID_socio, Tel)
    VALUES (@ID_socio, @Tel);
END;
GO

-- SP para actualizar un teléfono de emergencia de socio
CREATE OR ALTER PROCEDURE ActualizarSocioEmergencia
    @ID_socio INT,
    @TelAntiguo VARCHAR(50),
    @TelNuevo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio y el teléfono antiguo existen
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo)
    BEGIN
        THROW 50001, 'ERROR: El teléfono de emergencia antiguo no está registrado para el socio especificado.', 1;
         
    END

    -- Validar si el nuevo teléfono vacío o es nulo
    IF @TelNuevo IS NULL OR LTRIM(RTRIM(@TelNuevo)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nuevo número de teléfono de emergencia no puede estar vacío.', 1;
         
    END

    -- Verificar si el nuevo teléfono ya existe para este socio
    IF EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @TelNuevo)
    BEGIN
        THROW 50001, 'ERROR: El nuevo número de teléfono de emergencia ya está registrado para el socio.', 1;
         
    END

    -- Eliminar el teléfono antiguo y luego insertar el nuevo
    DELETE FROM Persona.SocioEmergencia
    WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo;

    INSERT INTO Persona.SocioEmergencia (ID_socio, Tel)
    VALUES (@ID_socio, @TelNuevo);
END;
GO


-- SP para eliminar un teléfono de emergencia de socio
CREATE OR ALTER PROCEDURE EliminarSocioEmergencia
    @ID_socio INT,
    @Tel VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el teléfono existe para el socio
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        THROW 50001, 'ERROR: El teléfono de emergencia especificado no existe para el socio.', 1;
         
    END

    DELETE FROM Persona.SocioEmergencia
    WHERE ID_socio = @ID_socio AND Tel = @Tel;
END;
GO


-- ===============================================
-- Stored Procedures para la tabla Persona.Invitado
-- ===============================================

-- SP para insertar un nuevo invitado
CREATE OR ALTER PROCEDURE InsertarInvitado
    @DNI VARCHAR(8),
    @fecha DATE,
    @ID_socio INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @ID_actividad INT,
    @ID_banco INT,
    @credenciales VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @DNI IS NULL OR LTRIM(RTRIM(@DNI)) = ''
    BEGIN
        THROW 50001, 'ERROR: El DNI del invitado no puede estar vacío.', 1;
         
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        THROW 50001, 'ERROR: El DNI del invitado debe contener 8 dígitos numéricos.', 1;
         
    END

    IF @fecha IS NULL OR @fecha > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La Fecha del invitado no es válida.', 1;
         
    END

    IF @ID_socio IS NULL OR NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado para el invitado no existe.', 1;
         
    END

    -- Verificar si el invitado ya existe para esa fecha y DNI
    IF EXISTS (SELECT 1 FROM Persona.Invitado WHERE DNI = @DNI AND fecha = @fecha)
    BEGIN
        THROW 50001, 'ERROR: Ya existe un invitado con este DNI para la fecha especificada.', 1;
         
    END

    INSERT INTO Persona.Invitado (
        DNI, fecha, ID_socio, nombre, apellido, ID_actividad, ID_banco, credenciales
    )
    VALUES (
        @DNI, @fecha, @ID_socio, @nombre, @apellido, @ID_actividad, @ID_banco, @credenciales
    );
END;
GO

-- SP para actualizar un invitado existente
CREATE OR ALTER PROCEDURE ActualizarInvitado
    @DNI VARCHAR(8),
    @fecha DATE,
    @ID_socio INT = NULL,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @ID_actividad INT = NULL,
    @ID_banco INT = NULL,
    @credenciales VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el invitado existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Invitado WHERE DNI = @DNI AND fecha = @fecha)
    BEGIN
        THROW 50001, 'ERROR: El invitado con el DNI y la fecha especificados no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @ID_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;
         
    END

    UPDATE Persona.Invitado
    SET
        ID_socio = ISNULL(@ID_socio, ID_socio),
        nombre = ISNULL(@nombre, nombre),
        apellido = ISNULL(@apellido, apellido),
        ID_actividad = ISNULL(@ID_actividad, ID_actividad),
        ID_banco = ISNULL(@ID_banco, ID_banco),
        credenciales = ISNULL(@credenciales, credenciales)
    WHERE
        DNI = @DNI AND fecha = @fecha;
END;
GO

-- SP para eliminar un invitado (borrado físico, ya que no tiene un estado)
CREATE OR ALTER PROCEDURE EliminarInvitado
    @DNI VARCHAR(8),
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el invitado existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Invitado WHERE DNI = @DNI AND fecha = @fecha)
    BEGIN
        THROW 50001, 'ERROR: El invitado con el DNI y la fecha especificados no existe.', 1;
         
    END

    DELETE FROM Persona.Invitado
    WHERE DNI = @DNI AND fecha = @fecha;
END;
GO

-- ====================================================
-- Stored Procedures para la tabla Persona.responsabilidad
-- ====================================================

-- SP para insertar una nueva relación de responsabilidad
CREATE OR ALTER PROCEDURE InsertarResponsabilidad
    @ID_responsable INT,
    @ID_menor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que ambos socios existan
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_responsable)
    BEGIN
        THROW 50001, 'ERROR: El ID_responsable especificado no existe.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_menor)
    BEGIN
        THROW 50001, 'ERROR: El ID_menor especificado no existe.', 1;
         
    END

    -- Evitar que un socio sea responsable de sí mismo
    IF @ID_responsable = @ID_menor
    BEGIN
        THROW 50001, 'ERROR: Un socio no puede ser responsable de sí mismo.', 1;
         
    END

    -- Verificar si la relación de responsabilidad ya existe
    IF EXISTS (SELECT 1 FROM Persona.responsabilidad WHERE ID_responsable = @ID_responsable AND ID_menor = @ID_menor)
    BEGIN
        THROW 50001, 'ERROR: Esta relación de responsabilidad ya existe.', 1;
         
    END

    INSERT INTO Persona.responsabilidad (ID_responsable, ID_menor)
    VALUES (@ID_responsable, @ID_menor);
END;
GO

-- SP para eliminar una relación de responsabilidad
CREATE OR ALTER PROCEDURE EliminarResponsabilidad
    @ID_responsable INT,
    @ID_menor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la relación de responsabilidad existe
    IF NOT EXISTS (SELECT 1 FROM Persona.responsabilidad WHERE ID_responsable = @ID_responsable AND ID_menor = @ID_menor)
    BEGIN
        THROW 50001, 'ERROR: La relación de responsabilidad especificada no existe.', 1;
         
    END

    DELETE FROM Persona.responsabilidad
    WHERE ID_responsable = @ID_responsable AND ID_menor = @ID_menor;
END;
GO
-- ===============================================
-- Stored Procedures para la tabla Gestion.rol
-- ===============================================

-- SP para insertar un nuevo rol
CREATE OR ALTER PROCEDURE InsertarRol
    @ID_rol INT,
    @nombre VARCHAR(20),
    @descripcion VARCHAR(280)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre del rol no puede estar vacío.', 1;
         
    END

    -- Verificar si el ID_rol ya existe
    IF EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        THROW 50001, 'ERROR: El ID_rol ya existe. Por favor, utilice un ID diferente.', 1;
         
    END

    INSERT INTO Gestion.rol (ID_rol, nombre, descripcion)
    VALUES (@ID_rol, @nombre, @descripcion);
END;
GO

-- SP para actualizar un rol existente
CREATE OR ALTER PROCEDURE ActualizarRol
    @ID_rol INT,
    @nombre VARCHAR(20) = NULL,
    @descripcion VARCHAR(280) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el rol existe
    IF NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        THROW 50001, 'ERROR: El rol con el ID especificado no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre del rol no puede estar vacío.', 1;
         
    END

    UPDATE Gestion.rol
    SET
        nombre = ISNULL(@nombre, nombre),
        descripcion = ISNULL(@descripcion, descripcion)
    WHERE
        ID_rol = @ID_rol;
END;
GO

-- SP para eliminar un rol
CREATE OR ALTER PROCEDURE EliminarRol
    @ID_rol INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el rol existe
    IF NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        THROW 50001, 'ERROR: El rol con el ID especificado no existe.', 1;
         
    END

    -- Verificar si hay personal asociado a este rol antes de eliminarlo
    IF EXISTS (SELECT 1 FROM Gestion.Personal WHERE ID_rol = @ID_rol)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar el rol porque hay personal asociado a él. Desasocie el personal primero.', 1;
         
    END

    DELETE FROM Gestion.rol
    WHERE ID_rol = @ID_rol;
END;
GO
-- ==================================================
-- Stored Procedures para la tabla Gestion.Personal
-- ==================================================

-- SP para insertar nuevo personal
CREATE OR ALTER PROCEDURE InsertarPersonal
    @ID_personal INT,
    @ID_rol INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @DNI VARCHAR(8),
    @usuario VARCHAR(16),
    @contrasenia VARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre del personal no puede estar vacío.', 1;
         
    END

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
    BEGIN
        THROW 50001, 'ERROR: El apellido del personal no puede estar vacío.', 1;
         
    END

    IF @DNI IS NULL OR LTRIM(RTRIM(@DNI)) = ''
    BEGIN
        THROW 50001, 'ERROR: El DNI del personal no puede estar vacío.', 1;
         
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        THROW 50001, 'ERROR: El DNI del personal debe contener 8 dígitos numéricos.', 1;
         
    END

    IF @usuario IS NULL OR LTRIM(RTRIM(@usuario)) = ''
    BEGIN
        THROW 50001, 'ERROR: El usuario del personal no puede estar vacío.', 1;
         
    END

    IF @contrasenia IS NULL OR LTRIM(RTRIM(@contrasenia)) = ''
    BEGIN
        THROW 50001, 'ERROR: La contraseña del personal no puede estar vacía.', 1;
         
    END

    -- Verificar si el ID_personal ya existe
    IF EXISTS (SELECT 1 FROM Gestion.Personal WHERE ID_personal = @ID_personal)
    BEGIN
        THROW 50001, 'ERROR: El ID_personal ya existe. Por favor, utilice un ID diferente.', 1;
         
    END

    -- Validar que el ID_rol exista
    IF NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        THROW 50001, 'ERROR: El ID_rol especificado no existe.', 1;
         
    END

    INSERT INTO Gestion.Personal (
        ID_personal, ID_rol, nombre, apellido, DNI, usuario, contrasenia
    )
    VALUES (
        @ID_personal, @ID_rol, @nombre, @apellido, @DNI, @usuario, @contrasenia
    );
END;
GO

-- SP para actualizar personal existente
CREATE OR ALTER PROCEDURE ActualizarPersonal
    @ID_personal INT,
    @ID_rol INT = NULL,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @DNI VARCHAR(8) = NULL,
    @usuario VARCHAR(16) = NULL,
    @contrasenia VARCHAR(32) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el personal existe
    IF NOT EXISTS (SELECT 1 FROM Gestion.Personal WHERE ID_personal = @ID_personal)
    BEGIN
        THROW 50001, 'ERROR: El personal con el ID especificado no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @DNI IS NOT NULL AND (LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
    BEGIN
        THROW 50001, 'ERROR: El DNI debe contener 8 dígitos numéricos.', 1;
         
    END

    IF @ID_rol IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        THROW 50001, 'ERROR: El ID_rol especificado no existe.', 1;
         
    END

    UPDATE Gestion.Personal
    SET
        ID_rol = ISNULL(@ID_rol, ID_rol),
        nombre = ISNULL(@nombre, nombre),
        apellido = ISNULL(@apellido, apellido),
        DNI = ISNULL(@DNI, DNI),
        usuario = ISNULL(@usuario, usuario),
        contrasenia = ISNULL(@contrasenia, contrasenia)
    WHERE
        ID_personal = @ID_personal;
END;
GO

-- SP para eliminar personal (borrado físico, se podría considerar lógico si se añade un campo de estado)
CREATE OR ALTER PROCEDURE EliminarPersonal
    @ID_personal INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el personal existe
    IF NOT EXISTS (SELECT 1 FROM Gestion.Personal WHERE ID_personal = @ID_personal)
    BEGIN
        THROW 50001, 'ERROR: El personal con el ID especificado no existe.', 1;
         
    END

    DELETE FROM Gestion.Personal
    WHERE ID_personal = @ID_personal;
END;
GO
-- ===================================================
-- Stored Procedures para la tabla Actividades.Membresia
-- ===================================================

-- SP para insertar una nueva membresía
CREATE OR ALTER PROCEDURE InsertarMembresia
    @ID_tipo INT = NULL,
    @nombre VARCHAR(20),
    @descripcion VARCHAR(140),
    @costo DECIMAL(10,2)
AS
BEGIN
	SET NOCOUNT ON;
	IF @ID_tipo IS NULL OR LTRIM(RTRIM(@ID_tipo)) = ''
    BEGIN
        SELECT @ID_tipo = ISNULL(MAX(ID_tipo), 0) + 1
        FROM Actividades.Membresia;

    END

    -- Validaciones básicas
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre de la membresía no puede estar vacío.', 1;
         
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la membresía debe ser un valor positivo.', 1;
         
    END

    -- Verificar si el ID_tipo ya existe
    IF EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_tipo)
    BEGIN
        THROW 50001, 'ERROR: El ID_tipo de membresía ya existe. Por favor, utilice un ID diferente.', 1;
         
    END
	 IF EXISTS (SELECT 1 FROM Actividades.Membresia WHERE nombre = @nombre)
    BEGIN
        THROW 50001, 'ERROR: El nombre de membresía ya existe. Por favor, utilice un nombre diferente.', 1; 
    END

    INSERT INTO Actividades.Membresia (ID_tipo, nombre, descripcion, costo)
    VALUES (@ID_tipo, @nombre, @descripcion, @costo);
END;
GO

-- SP para actualizar una membresía existente
CREATE OR ALTER PROCEDURE ActualizarMembresia
    @ID_tipo INT,
    @nombre VARCHAR(20) = NULL,
    @descripcion VARCHAR(140) = NULL,
    @costo DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la membresía existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_tipo)
    BEGIN
        THROW 50001, 'ERROR: La membresía con el ID especificado no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre de la membresía no puede estar vacío.', 1;
         
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la membresía debe ser un valor positivo.', 1;
         
    END

    UPDATE Actividades.Membresia
    SET
        nombre = ISNULL(@nombre, nombre),
        descripcion = ISNULL(@descripcion, descripcion),
        costo = ISNULL(@costo, costo)
    WHERE
        ID_tipo = @ID_tipo;
END;
GO

-- SP para eliminar una membresía
CREATE OR ALTER PROCEDURE EliminarMembresia
    @ID_tipo INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la membresía existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_tipo)
    BEGIN
        THROW 50001, 'ERROR: La membresía con el ID especificado no existe.', 1;
         
    END

    -- Verificar si hay inscripciones asociadas a esta membresía
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Socio WHERE ID_membresia = @ID_tipo)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la membresía porque hay inscripciones de socios asociadas a ella. Desasocie las inscripciones primero.', 1;
         
    END

    DELETE FROM Actividades.Membresia
    WHERE ID_tipo = @ID_tipo;
END;
GO

-- =========================================================
-- Stored Procedures para la tabla Actividades.Inscripcion_Socio
-- =========================================================

-- SP para insertar una nueva inscripción de socio
CREATE OR ALTER PROCEDURE InsertarInscripcionSocio
    @ID_socio INT,
    @ID_inscripcion INT,
    @ID_membresia INT,
    @fecha_inicio DATE,
    @fecha_baja DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @fecha_inicio IS NULL OR @fecha_inicio > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de inicio de la inscripción no es válida.', 1;
         
    END

    IF @fecha_baja IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        THROW 50001, 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.', 1;
         
    END

    -- Validar si el socio y la membresía existen
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_membresia)
    BEGIN
        THROW 50001, 'ERROR: El ID_membresia especificado no existe.', 1;
         
    END

    -- Verificar si la inscripción ya existe para este socio
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Socio WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: Ya existe una inscripción con este ID para el socio especificado.', 1;
         
    END

    INSERT INTO Actividades.Inscripcion_Socio (
        ID_socio, ID_inscripcion, ID_membresia, fecha_inicio, fecha_baja
    )
    VALUES (
        @ID_socio, @ID_inscripcion, @ID_membresia, @fecha_inicio, @fecha_baja
    );
END;
GO

-- SP para actualizar una inscripción de socio existente
CREATE OR ALTER PROCEDURE ActualizarInscripcionSocio
    @ID_socio INT,
    @ID_inscripcion INT,
    @ID_membresia INT = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_baja DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Socio WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: La inscripción de socio con el ID_socio e ID_inscripcion especificados no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @fecha_inicio IS NOT NULL AND @fecha_inicio > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de inicio de la inscripción no es válida.', 1;
         
    END

    IF @fecha_baja IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        THROW 50001, 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.', 1;
         
    END

    IF @ID_membresia IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_membresia)
    BEGIN
        THROW 50001, 'ERROR: El ID_membresia especificado no existe.', 1;
         
    END

    UPDATE Actividades.Inscripcion_Socio
    SET
        ID_membresia = ISNULL(@ID_membresia, ID_membresia),
        fecha_inicio = ISNULL(@fecha_inicio, fecha_inicio),
        fecha_baja = ISNULL(@fecha_baja, fecha_baja)
    WHERE
        ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO

-- SP para eliminar una inscripción de socio
CREATE OR ALTER PROCEDURE EliminarInscripcionSocio
    @ID_socio INT,
    @ID_inscripcion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Socio WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: La inscripción de socio con el ID_socio e ID_inscripcion especificados no existe.', 1;
         
    END

    DELETE FROM Actividades.Inscripcion_Socio
    WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO
-- ============================================================
-- Stored Procedures para la tabla Actividades.Actividades_Deportivas
-- ============================================================

-- SP para insertar una nueva actividad deportiva
CREATE OR ALTER PROCEDURE InsertarActividadDeportiva
    @ID_actividad INT = NULL,
    @Nombre VARCHAR(32),
    @costo DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
	IF @ID_actividad IS NULL OR LTRIM(RTRIM(@ID_actividad)) = ''
    BEGIN
        SELECT @ID_actividad = ISNULL(MAX(ID_actividad), 0) + 1
        FROM Actividades.Actividades_Deportivas;
    END

    -- Validaciones básicas

    IF EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE Nombre = @Nombre)
    BEGIN
        THROW 50001, 'ERROR: El nombre de la actividad ya existe. Por favor, utilice un nombre diferente.', 1; 
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre de la actividad deportiva no puede estar vacío.', 1;
         
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la actividad deportiva debe ser un valor positivo.', 1;
         
    END

    -- Verificar si el ID_actividad ya existe
    IF EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: El ID_actividad ya existe para Actividades_Deportivas. Por favor, utilice un ID diferente.', 1;
         
    END

    INSERT INTO Actividades.Actividades_Deportivas (ID_actividad, Nombre, costo)
    VALUES (@ID_actividad, @Nombre, @costo);
END;
GO

-- SP para actualizar una actividad deportiva existente
CREATE OR ALTER PROCEDURE ActualizarActividadDeportiva
    @ID_actividad INT,
    @Nombre VARCHAR(32) = NULL,
    @costo DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la actividad existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: La actividad deportiva con el ID especificado no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @Nombre IS NOT NULL AND LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre de la actividad deportiva no puede estar vacío.', 1;
         
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la actividad deportiva debe ser un valor positivo.', 1;
         
    END

    UPDATE Actividades.Actividades_Deportivas
    SET
        Nombre = ISNULL(@Nombre, Nombre),
        costo = ISNULL(@costo, costo)
    WHERE
        ID_actividad = @ID_actividad;
END;
GO

-- SP para eliminar una actividad deportiva
CREATE OR ALTER PROCEDURE EliminarActividadDeportiva
    @ID_actividad INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la actividad existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: La actividad deportiva con el ID especificado no existe.', 1;
         
    END

    -- Verificar si hay turnos o inscripciones asociadas a esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la actividad deportiva porque tiene turnos asociados. Elimine los turnos primero.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la actividad deportiva porque tiene inscripciones asociadas. Elimine las inscripciones primero.', 1;
         
    END

    DELETE FROM Actividades.Actividades_Deportivas
    WHERE ID_actividad = @ID_actividad;
END;
GO

-- ========================================================
-- Stored Procedures para la tabla Actividades.Actividades_Otras
-- ========================================================

-- SP para insertar una nueva actividad "otra"
CREATE OR ALTER PROCEDURE InsertarActividadOtra
    @ID_actividad INT,
    @Nombre VARCHAR(32),
    @costo_socio DECIMAL(10,2),
    @costo_invitados DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre de la actividad "otra" no puede estar vacío.', 1;
         
    END

    IF @costo_socio IS NULL OR @costo_socio < 0
    BEGIN
        THROW 50001, 'ERROR: El costo para socios debe ser un valor positivo.', 1;
         
    END

    IF @costo_invitados IS NULL OR @costo_invitados < 0
    BEGIN
        THROW 50001, 'ERROR: El costo para invitados debe ser un valor positivo.', 1;
         
    END

    -- Verificar si el ID_actividad ya existe
    IF EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: El ID_actividad ya existe para Actividades_Otras. Por favor, utilice un ID diferente.', 1;
         
    END

    INSERT INTO Actividades.Actividades_Otras (ID_actividad, Nombre, costo_socio, costo_invitados)
    VALUES (@ID_actividad, @Nombre, @costo_socio, @costo_invitados);
END;
GO

-- SP para actualizar una actividad "otra" existente
CREATE OR ALTER PROCEDURE ActualizarActividadOtra
    @ID_actividad INT,
    @Nombre VARCHAR(32) = NULL,
    @costo_socio DECIMAL(10,2) = NULL,
    @costo_invitados DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la actividad existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: La actividad "otra" con el ID especificado no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @Nombre IS NOT NULL AND LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre de la actividad "otra" no puede estar vacío.', 1;
         
    END

    IF @costo_socio IS NOT NULL AND @costo_socio < 0
    BEGIN
        THROW 50001, 'ERROR: El costo para socios debe ser un valor positivo.', 1;
         
    END

    IF @costo_invitados IS NOT NULL AND @costo_invitados < 0
    BEGIN
        THROW 50001, 'ERROR: El costo para invitados debe ser un valor positivo.', 1;
         
    END

    UPDATE Actividades.Actividades_Otras
    SET
        Nombre = ISNULL(@Nombre, Nombre),
        costo_socio = ISNULL(@costo_socio, costo_socio),
        costo_invitados = ISNULL(@costo_invitados, costo_invitados)
    WHERE
        ID_actividad = @ID_actividad;
END;
GO

-- SP para eliminar una actividad "otra"
CREATE OR ALTER PROCEDURE EliminarActividadOtra
    @ID_actividad INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la actividad existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: La actividad "otra" con el ID especificado no existe.', 1;
         
    END

    -- Verificar si hay turnos o inscripciones asociadas a esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la actividad "otra" porque tiene turnos asociados. Elimine los turnos primero.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la actividad "otra" porque tiene inscripciones asociadas. Elimine las inscripciones primero.', 1;
         
    END

    DELETE FROM Actividades.Actividades_Otras
    WHERE ID_actividad = @ID_actividad;
END;
GO

-- =======================================================
-- Stored Procedures para la tabla Actividades.AcDep_turnos
-- =======================================================

-- SP para insertar un nuevo turno de actividad deportiva
CREATE OR ALTER PROCEDURE InsertarAcDepTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
	IF @ID_turno IS NULL OR LTRIM(RTRIM(@ID_turno)) = ''
    BEGIN
        SELECT @ID_turno = ISNULL(MAX(ID_turno), 0) + 1
        FROM Actividades.AcDep_turnos;

    END
    -- Validaciones básicas
    IF @turno IS NULL OR LTRIM(RTRIM(@turno)) = ''
    BEGIN
        THROW 50001, 'ERROR: El turno no puede estar vacío.', 1;
         
    END

    -- Validar que la actividad deportiva exista
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: La ID_actividad especificada no existe en Actividades_Deportivas.', 1;
         
    END

    -- Verificar si el turno ya existe para esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: Ya existe un turno con este ID para la actividad deportiva especificada.', 1;
         
    END

    INSERT INTO Actividades.AcDep_turnos (ID_actividad, ID_turno, turno)
    VALUES (@ID_actividad, @ID_turno, @turno);
END;
GO

-- SP para actualizar un turno de actividad deportiva existente
CREATE OR ALTER PROCEDURE ActualizarAcDepTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @turno IS NOT NULL AND LTRIM(RTRIM(@turno)) = ''
    BEGIN
        THROW 50001, 'ERROR: El turno no puede estar vacío.', 1;
         
    END

    UPDATE Actividades.AcDep_turnos
    SET
        turno = ISNULL(@turno, turno)
    WHERE
        ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- SP para eliminar un turno de actividad deportiva
CREATE OR ALTER PROCEDURE EliminarAcDepTurno
    @ID_actividad INT,
    @ID_turno INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.', 1;
         
    END

    -- Verificar si hay inscripciones asociadas a este turno
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_actividad = @ID_actividad AND ID_Turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar el turno porque hay inscripciones asociadas a él. Elimine las inscripciones primero.', 1;
         
    END

    DELETE FROM Actividades.AcDep_turnos
    WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- =====================================================
-- Stored Procedures para la tabla Actividades.AcOtra_turnos
-- =====================================================

-- SP para insertar un nuevo turno de actividad "otra"
CREATE OR ALTER PROCEDURE InsertarAcOtraTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @turno IS NULL OR LTRIM(RTRIM(@turno)) = ''
    BEGIN
        THROW 50001, 'ERROR: El turno no puede estar vacío.', 1;
         
    END

    -- Validar que la actividad "otra" exista
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: La ID_actividad especificada no existe en Actividades_Otras.', 1;
         
    END

    -- Verificar si el turno ya existe para esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: Ya existe un turno con este ID para la actividad "otra" especificada.', 1;
         
    END

    INSERT INTO Actividades.AcOtra_turnos (ID_actividad, ID_turno, turno)
    VALUES (@ID_actividad, @ID_turno, @turno);
END;
GO

-- SP para actualizar un turno de actividad "otra" existente
CREATE OR ALTER PROCEDURE ActualizarAcOtraTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @turno IS NOT NULL AND LTRIM(RTRIM(@turno)) = ''
    BEGIN
        THROW 50001, 'ERROR: El turno no puede estar vacío.', 1;
         
    END

    UPDATE Actividades.AcOtra_turnos
    SET
        turno = ISNULL(@turno, turno)
    WHERE
        ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- SP para eliminar un turno de actividad "otra"
CREATE OR ALTER PROCEDURE EliminarAcOtraTurno
    @ID_actividad INT,
    @ID_turno INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.', 1;
         
    END

    -- Verificar si hay inscripciones asociadas a este turno
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_actividad = @ID_actividad AND ID_Turno = @ID_turno)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar el turno porque hay inscripciones asociadas a él. Elimine las inscripciones primero.', 1;
         
    END

    DELETE FROM Actividades.AcOtra_turnos
    WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- ==========================================================
-- Stored Procedures para la tabla Actividades.Inscripcion_Deportiva
-- ==========================================================

-- SP para insertar una nueva inscripción deportiva
CREATE OR ALTER PROCEDURE InsertarInscripcionDeportiva
    @ID_socio INT,
    @ID_inscripcion INT = NULL,
    @ID_actividad INT,
    @ID_Turno INT,
    @fecha_inicio DATE,
    @fecha_baja DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
	
	IF @ID_inscripcion IS NULL OR LTRIM(RTRIM(@ID_inscripcion)) = ''
    BEGIN
        SELECT @ID_inscripcion = ISNULL(MAX(ID_inscripcion), 0) + 1
        FROM Actividades.Inscripcion_Deportiva;

    END
    -- Validaciones básicas
    IF @fecha_inicio IS NULL OR @fecha_inicio > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de inicio de la inscripción no es válida.', 1;
         
    END

    IF @fecha_baja IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        THROW 50001, 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.', 1;
         
    END

    -- Validar si el socio, actividad y turno existen
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        THROW 50001, 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcDep_turnos.', 1;
         
    END

    -- Verificar si la inscripción ya existe para este socio
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: Ya existe una inscripción con este ID para el socio especificado.', 1;
         
    END

    INSERT INTO Actividades.Inscripcion_Deportiva (
        ID_socio, ID_inscripcion, ID_actividad, ID_Turno, fecha_inicio, fecha_baja
    )
    VALUES (
        @ID_socio, @ID_inscripcion, @ID_actividad, @ID_Turno, @fecha_inicio, @fecha_baja
    );
END;
GO

-- SP para actualizar una inscripción deportiva existente
CREATE OR ALTER PROCEDURE ActualizarInscripcionDeportiva
    @ID_socio INT,
    @ID_inscripcion INT,
    @ID_actividad INT = NULL,
    @ID_Turno INT = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_baja DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: La inscripción deportiva con el ID_socio e ID_inscripcion especificados no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @fecha_inicio IS NOT NULL AND @fecha_inicio > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de inicio de la inscripción no es válida.', 1;
         
    END

    IF @fecha_baja IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        THROW 50001, 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.', 1;
         
    END

    IF @ID_actividad IS NOT NULL AND @ID_Turno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        THROW 50001, 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcDep_turnos.', 1;
         
    END
    ELSE IF @ID_actividad IS NOT NULL AND @ID_Turno IS NULL AND NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: El ID_actividad especificado no existe en Actividades.Actividades_Deportivas.', 1;
         
    END

    UPDATE Actividades.Inscripcion_Deportiva
    SET
        ID_actividad = ISNULL(@ID_actividad, ID_actividad),
        ID_Turno = ISNULL(@ID_Turno, ID_Turno),
        fecha_inicio = ISNULL(@fecha_inicio, fecha_inicio),
        fecha_baja = ISNULL(@fecha_baja, fecha_baja)
    WHERE
        ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO

-- SP para eliminar una inscripción deportiva
CREATE OR ALTER PROCEDURE EliminarInscripcionDeportiva
    @ID_socio INT,
    @ID_inscripcion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: La inscripción deportiva con el ID_socio e ID_inscripcion especificados no existe.', 1;
         
    END

    DELETE FROM Actividades.Inscripcion_Deportiva
    WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO

-- ======================================================
-- Stored Procedures para la tabla Actividades.Inscripcion_Otra
-- ======================================================

-- SP para insertar una nueva inscripción de actividad "otra"
CREATE OR ALTER PROCEDURE InsertarInscripcionOtra
    @ID_socio INT,
    @ID_inscripcion INT,
    @ID_actividad INT,
    @ID_Turno INT,
    @fecha_inicio DATE,
    @fecha_baja DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @fecha_inicio IS NULL OR @fecha_inicio > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de inicio de la inscripción no es válida.', 1;
         
    END

    IF @fecha_baja IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        THROW 50001, 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.', 1;
         
    END

    -- Validar si el socio, actividad y turno existen
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        THROW 50001, 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcOtra_turnos.', 1;
         
    END

    -- Verificar si la inscripción ya existe para este socio
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: Ya existe una inscripción con este ID para el socio especificado.', 1;
         
    END

    INSERT INTO Actividades.Inscripcion_Otra (
        ID_socio, ID_inscripcion, ID_actividad, ID_Turno, fecha_inicio, fecha_baja
    )
    VALUES (
        @ID_socio, @ID_inscripcion, @ID_actividad, @ID_Turno, @fecha_inicio, @fecha_baja
    );
END;
GO

-- SP para actualizar una inscripción de actividad "otra" existente
CREATE OR ALTER PROCEDURE ActualizarInscripcionOtra
    @ID_socio INT,
    @ID_inscripcion INT,
    @ID_actividad INT = NULL,
    @ID_Turno INT = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_baja DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: La inscripción de actividad "otra" con el ID_socio e ID_inscripcion especificados no existe.', 1;
         
    END

    -- Validaciones para los parámetros que se actualizan
    IF @fecha_inicio IS NOT NULL AND @fecha_inicio > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de inicio de la inscripción no es válida.', 1;
         
    END

    IF @fecha_baja IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        THROW 50001, 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.', 1;
         
    END

    IF @ID_actividad IS NOT NULL AND @ID_Turno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        THROW 50001, 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcOtra_turnos.', 1;
         
    END
    ELSE IF @ID_actividad IS NOT NULL AND @ID_Turno IS NULL AND NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: El ID_actividad especificado no existe en Actividades.Actividades_Otras.', 1;
         
    END


    UPDATE Actividades.Inscripcion_Otra
    SET
        ID_actividad = ISNULL(@ID_actividad, ID_actividad),
        ID_Turno = ISNULL(@ID_Turno, ID_Turno),
        fecha_inicio = ISNULL(@fecha_inicio, fecha_inicio),
        fecha_baja = ISNULL(@fecha_baja, fecha_baja)
    WHERE
        ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO

-- SP para eliminar una inscripción de actividad "otra"
CREATE OR ALTER PROCEDURE EliminarInscripcionOtra
    @ID_socio INT,
    @ID_inscripcion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        THROW 50001, 'ERROR: La inscripción de actividad "otra" con el ID_socio e ID_inscripcion especificados no existe.', 1;
         
    END

    DELETE FROM Actividades.Inscripcion_Otra
    WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO
-- =============================
-- Stored Procedures para el esquema Finanzas
-- =============================

-- Stored Procedures para la tabla Finanzas.MedioDePago

-- SP para insertar un nuevo medio de pago
CREATE OR ALTER PROCEDURE InsertarMedioDePago
    @ID_banco INT,
    @nombre VARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre del medio de pago no puede estar vacío.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        THROW 50001, 'ERROR: El ID_banco ya existe. Por favor, utilice un ID diferente.', 1;
         
    END

    INSERT INTO Finansas.MedioDePago (ID_banco, nombre)
    VALUES (@ID_banco, @nombre);
END;
GO

-- SP para actualizar un medio de pago
CREATE OR ALTER PROCEDURE ActualizarMedioDePago
    @ID_banco INT,
    @nombre VARCHAR(32) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        THROW 50001, 'ERROR: El medio de pago con el ID especificado no existe.', 1;
         
    END

    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        THROW 50001, 'ERROR: El nombre del medio de pago no puede estar vacío.', 1;
         
    END

    UPDATE Finansas.MedioDePago
    SET nombre = ISNULL(@nombre, nombre)
    WHERE ID_banco = @ID_banco;
END;
GO

-- SP para eliminar un medio de pago
CREATE OR ALTER PROCEDURE EliminarMedioDePago
    @ID_banco INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        THROW 50001, 'ERROR: El medio de pago con el ID especificado no existe.', 1;
         
    END

    -- Verificar si hay cuentas asociadas a este medio de pago
    IF EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_banco = @ID_banco)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar el medio de pago porque hay cuentas asociadas a él. Desasocie las cuentas primero.', 1;
         
    END

    DELETE FROM Finansas.MedioDePago
    WHERE ID_banco = @ID_banco;
END;
GO

-- Stored Procedures para la tabla Finansas.Cuenta

-- SP para insertar una nueva cuenta
CREATE OR ALTER PROCEDURE InsertarCuenta
    @ID_socio INT,
    @ID_cuenta INT= NULL,
    @ID_banco INT= NULL,
    @credenciales VARCHAR(50)= NULL,
    @tipo VARCHAR(20)= NULL,
    @SaldoAFavor DECIMAL(10,2)= NULL,
    @fechaPagoAutomatico DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

	IF @ID_cuenta IS NULL OR LTRIM(RTRIM(@ID_cuenta)) = ''
	BEGIN
		 SELECT @ID_cuenta = ISNULL(MAX(ID_cuenta), 0) + 1 FROM Finansas.Cuenta;
	END

    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;
         
    END

    IF @ID_banco IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        THROW 50001, 'ERROR: El ID_banco especificado no existe.', 1;
         
    END

    IF @tipo NOT IN ('credito', 'debito','')
    BEGIN
        THROW 50001, 'ERROR: El tipo de cuenta no es válido. Debe ser "credito" o "debito".', 1;
    END
	
	IF @tipo IS NULL OR LTRIM(RTRIM(@tipo)) = ''
    SET @tipo = 'debito';


    IF @SaldoAFavor IS NULL
		SET @SaldoAFavor = 0;
	ELSE IF @SaldoAFavor < 0
		THROW 50001, 'ERROR: El saldo a favor debe ser un valor no negativo.', 1;


    IF EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: Ya existe una cuenta para el socio especificado.', 1;
    END



    INSERT INTO Finansas.Cuenta (
        ID_socio, ID_cuenta, ID_banco, credenciales, tipo, SaldoAFavor, fechaPagoAutomatico
    )
    VALUES (
        @ID_socio, @ID_cuenta, @ID_banco, @credenciales, @tipo, @SaldoAFavor, @fechaPagoAutomatico
    );
END;
GO

-- SP para actualizar una cuenta existente
CREATE OR ALTER PROCEDURE ActualizarCuenta
    @ID_socio INT,
    @ID_cuenta INT,
    @ID_banco INT = NULL,
    @credenciales VARCHAR(50) = NULL,
    @tipo VARCHAR(20) = NULL,
    @SaldoAFavor DECIMAL(10,2) = NULL,
    @fechaPagoAutomatico DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: La cuenta con el ID_socio e ID_cuenta especificados no existe.', 1;
         
    END

    IF @ID_banco IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        THROW 50001, 'ERROR: El ID_banco especificado no existe.', 1;
         
    END

    IF @credenciales IS NOT NULL AND LTRIM(RTRIM(@credenciales)) = ''
    BEGIN
        THROW 50001, 'ERROR: Las credenciales no pueden estar vacías.', 1;
         
    END

    IF @tipo IS NOT NULL AND @tipo NOT IN ('credito', 'debito')
    BEGIN
        THROW 50001, 'ERROR: El tipo de cuenta no es válido. Debe ser "credito" o "debito".', 1;
         
    END

    IF @SaldoAFavor IS NOT NULL AND @SaldoAFavor < 0
    BEGIN
        THROW 50001, 'ERROR: El saldo a favor debe ser un valor no negativo.', 1;
         
    END

    UPDATE Finansas.Cuenta
    SET
        ID_banco = ISNULL(@ID_banco, ID_banco),
        credenciales = ISNULL(@credenciales, credenciales),
        tipo = ISNULL(@tipo, tipo),
        SaldoAFavor = ISNULL(@SaldoAFavor, SaldoAFavor),
        fechaPagoAutomatico = ISNULL(@fechaPagoAutomatico, fechaPagoAutomatico)
    WHERE
        ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta;
END;
GO

-- SP para eliminar una cuenta
CREATE OR ALTER PROCEDURE EliminarCuenta
    @ID_socio INT,
    @ID_cuenta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: La cuenta con el ID_socio e ID_cuenta especificados no existe.', 1;
         
    END

    -- Verificar si hay cobros o reembolsos asociados a esta cuenta
    IF EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la cuenta porque tiene cobros asociados. Elimine los cobros primero.', 1;
         
    END
    IF EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la cuenta porque tiene reembolsos asociados. Elimine los reembolsos primero.', 1;
         
    END

    DELETE FROM Finansas.Cuenta
    WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta;
END;
GO

-- Stored Procedures para la tabla Finansas.Cuota

-- SP para insertar una nueva cuota
CREATE OR ALTER PROCEDURE InsertarCuota
    @ID_cuota INT,
    @ID_socio INT,
    @ID_inscripcion INT,
    @ID_detalle INT,
    @Tipo VARCHAR(10),
    @fecha DATE,
    @Vencimiento1 DATE,
    @Vencimiento2 DATE,
    @costo DECIMAL(10,2),
    @recargo DECIMAL(10,2),
    @descuento DECIMAL(10,2),
    @Estado VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;

    END

    IF @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        THROW 50001, 'ERROR: El tipo de cuota no es válido. Debe ser "socio", "deporte" o "otra".', 1;
         
    END

    IF @fecha IS NULL OR @fecha > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de la cuota no es válida.', 1;
         
    END

    IF @Vencimiento1 IS NULL OR @Vencimiento1 < @fecha
    BEGIN
        THROW 50001, 'ERROR: La primera fecha de vencimiento no es válida (no puede ser anterior a la fecha de la cuota).', 1;
         
    END

    IF @Vencimiento2 IS NULL OR @Vencimiento2 < @Vencimiento1
    BEGIN
        THROW 50001, 'ERROR: La segunda fecha de vencimiento no es válida (no puede ser anterior a la primera).', 1;
         
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la cuota debe ser un valor no negativo.', 1;
         
    END

    IF @recargo IS NULL OR @recargo < 0
    BEGIN
        THROW 50001, 'ERROR: El recargo de la cuota debe ser un valor no negativo.', 1;
         
    END

    IF @descuento IS NULL OR @descuento < 0
    BEGIN
        THROW 50001, 'ERROR: El descuento de la cuota debe ser un valor no negativo.', 1;
         
    END

    IF @Estado NOT IN ('impago', 'vencido1', 'vencido2', 'pago')
    BEGIN
        THROW 50001, 'ERROR: El estado de la cuota no es válido. Debe ser "impago", "vencido1", "vencido2" o "pago".', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Finansas.Cuota WHERE ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: El ID_cuota ya existe. Por favor, utilice un ID diferente.', 1;
         
    END

    INSERT INTO Finansas.Cuota (
        ID_cuota, ID_socio, ID_inscripcion, ID_detalle, Tipo, fecha,
        Vencimiento1, Vencimiento2, costo, recargo, descuento, Estado
    )
    VALUES (
        @ID_cuota, @ID_socio, @ID_inscripcion, @ID_detalle, @Tipo, @fecha,
        @Vencimiento1, @Vencimiento2, @costo, @recargo, @descuento, @Estado
    );
END;
GO

-- SP para actualizar una cuota existente
CREATE OR ALTER PROCEDURE ActualizarCuota
    @ID_cuota INT,
    @ID_socio INT = NULL,
    @ID_inscripcion INT = NULL,
    @ID_detalle INT = NULL,
    @Tipo VARCHAR(10) = NULL,
    @fecha DATE = NULL,
    @Vencimiento1 DATE = NULL,
    @Vencimiento2 DATE = NULL,
    @costo DECIMAL(10,2) = NULL,
    @recargo DECIMAL(10,2) = NULL,
    @descuento DECIMAL(10,2) = NULL,
    @Estado VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuota WHERE ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: La cuota con el ID especificado no existe.', 1;
         
    END

    IF @ID_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;
         
    END

    IF @Tipo IS NOT NULL AND @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        THROW 50001, 'ERROR: El tipo de cuota no es válido. Debe ser "socio", "deporte" o "otra".', 1;
         
    END

    IF @fecha IS NOT NULL AND @fecha > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha de la cuota no es válida.', 1;
         
    END

    IF @Vencimiento1 IS NOT NULL AND @fecha IS NOT NULL AND @Vencimiento1 < @fecha
    BEGIN
        THROW 50001, 'ERROR: La primera fecha de vencimiento no es válida (no puede ser anterior a la fecha de la cuota).', 1;
         
    END

    IF @Vencimiento2 IS NOT NULL AND @Vencimiento1 IS NOT NULL AND @Vencimiento2 < @Vencimiento1
    BEGIN
        THROW 50001, 'ERROR: La segunda fecha de vencimiento no es válida (no puede ser anterior a la primera).', 1;
         
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la cuota debe ser un valor no negativo.', 1;
         
    END

    IF @recargo IS NOT NULL AND @recargo < 0
    BEGIN
        THROW 50001, 'ERROR: El recargo de la cuota debe ser un valor no negativo.', 1;
         
    END

    IF @descuento IS NOT NULL AND @descuento < 0
    BEGIN
        THROW 50001, 'ERROR: El descuento de la cuota debe ser un valor no negativo.', 1;
         
    END

    IF @Estado IS NOT NULL AND @Estado NOT IN ('impago', 'vencido1', 'vencido2', 'pago')
    BEGIN
        THROW 50001, 'ERROR: El estado de la cuota no es válido. Debe ser "impago", "vencido1", "vencido2" o "pago".', 1;
         
    END

    UPDATE Finansas.Cuota
    SET
        ID_socio = ISNULL(@ID_socio, ID_socio),
        ID_inscripcion = ISNULL(@ID_inscripcion, ID_inscripcion),
        ID_detalle = ISNULL(@ID_detalle, ID_detalle),
        Tipo = ISNULL(@Tipo, Tipo),
        fecha = ISNULL(@fecha, fecha),
        Vencimiento1 = ISNULL(@Vencimiento1, Vencimiento1),
        Vencimiento2 = ISNULL(@Vencimiento2, Vencimiento2),
        costo = ISNULL(@costo, costo),
        recargo = ISNULL(@recargo, recargo),
        descuento = ISNULL(@descuento, descuento),
        Estado = ISNULL(@Estado, Estado)
    WHERE
        ID_cuota = @ID_cuota;
END;
GO

-- SP para eliminar una cuota
CREATE OR ALTER PROCEDURE EliminarCuota
    @ID_cuota INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuota WHERE ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: La cuota con el ID especificado no existe.', 1;
         
    END

    -- Verificar si hay detalles de factura asociados a esta cuota
    IF EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la cuota porque hay detalles de factura asociados a ella. Elimine los detalles de factura primero.', 1;
         
    END

    DELETE FROM Finansas.Cuota
    WHERE ID_cuota = @ID_cuota;
END;
GO

-- Stored Procedures para la tabla Finansas.factura

-- SP para insertar una nueva factura
CREATE OR ALTER PROCEDURE InsertarFactura
    @ID_factura INT,
    @DNI VARCHAR(8),
    @CUIT VARCHAR(13),
    @FechaYHora DATETIME,
    @costo DECIMAL(10,2),
    @estado BIT
AS
BEGIN
    SET NOCOUNT ON;
	IF @ID_factura IS NULL OR LTRIM(RTRIM(@ID_factura)) = ''
    BEGIN
        SELECT @ID_factura = ISNULL(MAX(ID_factura), 0) + 1
        FROM Finansas.factura;

    END

    IF @DNI IS NULL OR LTRIM(RTRIM(@DNI)) = ''
    BEGIN
        THROW 50001, 'ERROR: El DNI de la factura no puede estar vacío.', 1;
         
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        THROW 50001, 'ERROR: El DNI de la factura debe contener 8 dígitos numéricos.', 1;
         
    END

    IF @CUIT IS NULL OR LTRIM(RTRIM(@CUIT)) = ''
    BEGIN
        THROW 50001, 'ERROR: El CUIT de la factura no puede estar vacío.', 1;
         
    END
	


	IF @CUIT NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
	BEGIN
		THROW 50001, 'ERROR: El CUIT debe tener el formato XX-XXXXXXXX-X con dígitos numéricos.', 1;
	END


    IF @FechaYHora IS NULL OR @FechaYHora > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La Fecha y Hora de la factura no es válida.', 1;
         
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la factura debe ser un valor no negativo.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: El ID_factura ya existe. Por favor, utilice un ID diferente.', 1;
         
    END

    INSERT INTO Finansas.factura (ID_factura, DNI, CUIT, FechaYHora, costo, estado)
    VALUES (@ID_factura, @DNI, @CUIT, @FechaYHora, @costo, @estado);
END;
GO

-- SP para actualizar una factura existente
CREATE OR ALTER PROCEDURE ActualizarFactura
    @ID_factura INT,
    @DNI VARCHAR(8) = NULL,
    @CUIT VARCHAR(13) = NULL,
    @FechaYHora DATETIME = NULL,
    @costo DECIMAL(10,2) = NULL,
    @estado BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: La factura con el ID especificado no existe.', 1;
         
    END

    IF @DNI IS NOT NULL AND (LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
    BEGIN
        THROW 50001, 'ERROR: El DNI de la factura debe contener 8 dígitos numéricos.', 1;
         
    END

    IF @CUIT IS NOT NULL AND (LEN(@CUIT) != 11 OR NOT (@CUIT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'))
    BEGIN
        THROW 50001, 'ERROR: El CUIT de la factura debe contener 11 dígitos numéricos con guiones (XX-XXXXXXXX-X).', 1;
         
    END

    IF @FechaYHora IS NOT NULL AND @FechaYHora > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La Fecha y Hora de la factura no es válida.', 1;
         
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo de la factura debe ser un valor no negativo.', 1;
         
    END

    UPDATE Finansas.factura
    SET
        DNI = ISNULL(@DNI, DNI),
        CUIT = ISNULL(@CUIT, CUIT),
        FechaYHora = ISNULL(@FechaYHora, FechaYHora),
        costo = ISNULL(@costo, costo),
        estado = ISNULL(@estado, estado)
    WHERE
        ID_factura = @ID_factura;
END;
GO

-- SP para eliminar una factura
CREATE OR ALTER PROCEDURE EliminarFactura
    @ID_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: La factura con el ID especificado no existe.', 1;
         
    END

    -- Verificar si hay detalles de factura, cobros o reembolsos asociados
    IF EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la factura porque tiene detalles de factura asociados. Elimine los detalles primero.', 1;
         
    END
    IF EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la factura porque tiene cobros asociados. Elimine los cobros primero.', 1;
         
    END
    IF EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar la factura porque tiene reembolsos asociados. Elimine los reembolsos primero.', 1;
         
    END

    DELETE FROM Finansas.factura
    WHERE ID_factura = @ID_factura;
END;
GO

-- Stored Procedures para la tabla Finansas.detalle_factura

-- SP para insertar un nuevo detalle de factura
CREATE OR ALTER PROCEDURE InsertarDetalleFactura
    @ID_factura INT,
    @ID_cuota INT,
    @ID_inscripcion INT,
    @Tipo VARCHAR(10),
    @costo DECIMAL(10,2),
    @recargo DECIMAL(10,2),
    @descuento DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: El ID_factura especificado no existe.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuota WHERE ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: El ID_cuota especificado no existe.', 1;
         
    END

    IF @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        THROW 50001, 'ERROR: El tipo de detalle no es válido. Debe ser "socio", "deporte" o "otra".', 1;
         
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo del detalle de factura debe ser un valor no negativo.', 1;
         
    END

    IF @recargo IS NULL OR @recargo < 0
    BEGIN
        THROW 50001, 'ERROR: El recargo del detalle de factura debe ser un valor no negativo.', 1;
         
    END

    IF @descuento IS NULL OR @descuento < 0
    BEGIN
        THROW 50001, 'ERROR: El descuento del detalle de factura debe ser un valor no negativo.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_factura = @ID_factura AND ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: Ya existe un detalle de factura con esta combinación de ID_factura e ID_cuota.', 1;
         
    END

    INSERT INTO Finansas.detalle_factura (
        ID_factura, ID_cuota, ID_inscripcion, Tipo, costo, recargo, descuento
    )
    VALUES (
        @ID_factura, @ID_cuota, @ID_inscripcion, @Tipo, @costo, @recargo, @descuento
    );
END;
GO

-- SP para actualizar un detalle de factura existente
CREATE OR ALTER PROCEDURE ActualizarDetalleFactura
    @ID_factura INT,
    @ID_cuota INT,
    @ID_inscripcion INT = NULL,
    @Tipo VARCHAR(10) = NULL,
    @costo DECIMAL(10,2) = NULL,
    @recargo DECIMAL(10,2) = NULL,
    @descuento DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_factura = @ID_factura AND ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: El detalle de factura con la combinación de ID_factura e ID_cuota especificados no existe.', 1;
         
    END

    IF @Tipo IS NOT NULL AND @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        THROW 50001, 'ERROR: El tipo de detalle no es válido. Debe ser "socio", "deporte" o "otra".', 1;
         
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo del detalle de factura debe ser un valor no negativo.', 1;
         
    END

    IF @recargo IS NOT NULL AND @recargo < 0
    BEGIN
        THROW 50001, 'ERROR: El recargo del detalle de factura debe ser un valor no negativo.', 1;
         
    END

    IF @descuento IS NOT NULL AND @descuento < 0
    BEGIN
        THROW 50001, 'ERROR: El descuento del detalle de factura debe ser un valor no negativo.', 1;
         
    END

    UPDATE Finansas.detalle_factura
    SET
        ID_inscripcion = ISNULL(@ID_inscripcion, ID_inscripcion),
        Tipo = ISNULL(@Tipo, Tipo),
        costo = ISNULL(@costo, costo),
        recargo = ISNULL(@recargo, recargo),
        descuento = ISNULL(@descuento, descuento)
    WHERE
        ID_factura = @ID_factura AND ID_cuota = @ID_cuota;
END;
GO

-- SP para eliminar un detalle de factura
CREATE OR ALTER PROCEDURE EliminarDetalleFactura
    @ID_factura INT,
    @ID_cuota INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_factura = @ID_factura AND ID_cuota = @ID_cuota)
    BEGIN
        THROW 50001, 'ERROR: El detalle de factura con la combinación de ID_factura e ID_cuota especificados no existe.', 1;
         
    END

    DELETE FROM Finansas.detalle_factura
    WHERE ID_factura = @ID_factura AND ID_cuota = @ID_cuota;
END;
GO

-- Stored Procedures para la tabla Finansas.cobro

-- SP para insertar un nuevo cobro
CREATE OR ALTER PROCEDURE InsertarCobro
	@ID_Cobro BIGINT,
    @ID_factura INT,
    @ID_socio INT,
    @ID_cuenta INT,
    @Costo DECIMAL(10,2),
    @Estado BIT,
	@fecha date,
	@Medio_Pago varchar(20)
AS
BEGIN
    SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_Cobro = @ID_Cobro)
    BEGIN
        THROW 50001, 'ERROR: El ID_Cobro especificado ya existe.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: El ID_factura especificado no existe.', 1;
         
    END


    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: La combinación de ID_socio e ID_cuenta no existe.', 1;
         
    END

    IF @Costo IS NULL OR @Costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo del cobro debe ser un valor no negativo.', 1;
         
    END
	
	IF @Medio_Pago IS NULL OR LTRIM(RTRIM(@Medio_Pago)) = ''
    BEGIN
        THROW 50001, 'ERROR: El Medio de Pago del cobro no puede estar vacío.', 1;
         
    END
	
	IF @fecha IS NULL OR @fecha > GETDATE() 
    BEGIN
        THROW 50001, 'ERROR: La fecha no es válida.', 1;
         
    END

INSERT INTO Finansas.cobro (ID_Cobro, ID_factura, ID_socio, ID_cuenta, Costo, Estado, fecha, Medio_Pago)
VALUES (@ID_Cobro, @ID_factura, @ID_socio, @ID_cuenta, @Costo, @Estado, @fecha, @Medio_Pago);

END;
GO

-- SP para actualizar un cobro existente
CREATE OR ALTER PROCEDURE ActualizarCobro
    @ID_Cobro BIGINT,
    @Costo DECIMAL(10,2) = NULL,
    @Estado BIT = NULL,
    @Fecha DATE = NULL,
    @Medio_Pago VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_Cobro = @ID_Cobro)
    BEGIN
        THROW 50001, 'ERROR: El cobro con el ID_Cobro especificado no existe.', 1;
    END;

    IF @Costo IS NOT NULL AND @Costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo del cobro debe ser un valor no negativo.', 1;
    END;

    IF @Medio_Pago IS NOT NULL AND LTRIM(RTRIM(@Medio_Pago)) = ''
    BEGIN
        THROW 50001, 'ERROR: El Medio de Pago no puede estar vacío.', 1;
    END;

    IF @Fecha IS NOT NULL AND @Fecha > GETDATE()
    BEGIN
        THROW 50001, 'ERROR: La fecha no puede ser futura.', 1;
    END;

    UPDATE Finansas.cobro
    SET
        Costo = ISNULL(@Costo, Costo),
        Estado = ISNULL(@Estado, Estado),
        fecha = ISNULL(@Fecha, fecha),
        Medio_Pago = ISNULL(@Medio_Pago, Medio_Pago)
    WHERE
        ID_Cobro = @ID_Cobro;
END;


GO

-- SP para eliminar un cobro
CREATE OR ALTER PROCEDURE EliminarCobro
    @ID_Cobro BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_Cobro = @ID_Cobro)
    BEGIN
        THROW 50001, 'ERROR: El cobro con el ID_Cobro especificado no existe.', 1;
    END;

    DELETE FROM Finansas.cobro
    WHERE ID_Cobro = @ID_Cobro;
END;

GO

-- Stored Procedures para la tabla Finansas.reembolso

-- SP para insertar un nuevo reembolso
CREATE OR ALTER PROCEDURE InsertarReembolso
    @ID_factura INT,
    @ID_socio INT,
    @ID_cuenta INT,
    @Costo DECIMAL(10,2),
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        THROW 50001, 'ERROR: El ID_factura especificado no existe.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: La combinación de ID_socio e ID_cuenta no existe.', 1;
         
    END

    IF @Costo IS NULL OR @Costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo del reembolso debe ser un valor no negativo.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: Ya existe un reembolso con esta combinación de ID_factura, ID_socio e ID_cuenta.', 1;
         
    END

    INSERT INTO Finansas.reembolso (ID_factura, ID_socio, ID_cuenta, Costo, Estado)
    VALUES (@ID_factura, @ID_socio, @ID_cuenta, @Costo, @Estado);
END;
GO

-- SP para actualizar un reembolso existente
CREATE OR ALTER PROCEDURE ActualizarReembolso
    @ID_factura INT,
    @ID_socio INT,
    @ID_cuenta INT,
    @Costo DECIMAL(10,2) = NULL,
    @Estado BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: El reembolso con la combinación de ID_factura, ID_socio e ID_cuenta especificados no existe.', 1;
         
    END

    IF @Costo IS NOT NULL AND @Costo < 0
    BEGIN
        THROW 50001, 'ERROR: El costo del reembolso debe ser un valor no negativo.', 1;
         
    END

    UPDATE Finansas.reembolso
    SET
        Costo = ISNULL(@Costo, Costo),
        Estado = ISNULL(@Estado, Estado)
    WHERE
        ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta;
END;
GO

-- SP para eliminar un reembolso
CREATE OR ALTER PROCEDURE EliminarReembolso
    @ID_factura INT,
    @ID_socio INT,
    @ID_cuenta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        THROW 50001, 'ERROR: El reembolso con la combinación de ID_factura, ID_socio e ID_cuenta especificados no existe.', 1;
         
    END

    DELETE FROM Finansas.reembolso
    WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta;
END;
GO

-- =============================
-- Stored Procedures para el esquema Asistencia
-- =============================

-- Stored Procedures para la tabla Asistencia.dias

-- SP para insertar un nuevo día
CREATE OR ALTER PROCEDURE InsertarDia
    @fecha DATE,
    @climaMalo BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha IS NULL OR @fecha > GETDATE() -- O si permite fechas futuras, ajustar esta validación
    BEGIN
        THROW 50001, 'ERROR: La fecha no es válida.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @fecha)
    BEGIN
        THROW 50001, 'ERROR: La fecha ya existe. Por favor, utilice una fecha diferente.', 1;
         
    END

    INSERT INTO Asistencia.dias (fecha, climaMalo)
    VALUES (@fecha, @climaMalo);
END;
GO

-- SP para actualizar un día existente
CREATE OR ALTER PROCEDURE ActualizarDia
    @fecha DATE,
    @climaMalo BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @fecha)
    BEGIN
        THROW 50001, 'ERROR: La fecha especificada no existe.', 1;
         
    END

    UPDATE Asistencia.dias
    SET climaMalo = ISNULL(@climaMalo, climaMalo)
    WHERE fecha = @fecha;
END;
GO

-- SP para eliminar un día
CREATE OR ALTER PROCEDURE EliminarDia
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @fecha)
    BEGIN
        THROW 50001, 'ERROR: La fecha especificada no existe.', 1;
         
    END

    -- Verificar si hay asistencias asociadas a este día
    IF EXISTS (SELECT 1 FROM Asistencia.asistencia WHERE Fecha = @fecha)
    BEGIN
        THROW 50001, 'ERROR: No se puede eliminar el día porque hay registros de asistencia asociados. Elimine los registros de asistencia primero.', 1;
         
    END

    DELETE FROM Asistencia.dias
    WHERE fecha = @fecha;
END;
GO

-- Stored Procedures para la tabla Asistencia.asistencia

-- SP para insertar un nuevo registro de asistencia
CREATE OR ALTER PROCEDURE InsertarAsistencia
    @ID_socio INT,
    @ID_actividad INT,
    @ID_turno INT,
    @Fecha DATE,
    @Presentismo BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        THROW 50001, 'ERROR: El ID_socio especificado no existe.', 1;
         
    END
    
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad) AND
       NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        THROW 50001, 'ERROR: El ID_actividad especificado no existe en Actividades_Deportivas ni Actividades_Otras.', 1;
         
    END

    IF NOT EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @Fecha)
    BEGIN
        THROW 50001, 'ERROR: La Fecha del día no existe en la tabla de Asistencia.dias.', 1;
         
    END

    IF EXISTS (SELECT 1 FROM Asistencia.asistencia WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha)
    BEGIN
        THROW 50001, 'ERROR: Ya existe un registro de asistencia con esta combinación para el socio en esta actividad, turno y fecha.', 1;
         
    END

    INSERT INTO Asistencia.asistencia (ID_socio, ID_actividad, ID_turno, Fecha, Presentismo)
    VALUES (@ID_socio, @ID_actividad, @ID_turno, @Fecha, @Presentismo);
END;
GO

-- SP para actualizar un registro de asistencia existente
CREATE OR ALTER PROCEDURE ActualizarAsistencia
    @ID_socio INT,
    @ID_actividad INT,
    @ID_turno INT,
    @Fecha DATE,
    @Presentismo BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Asistencia.asistencia WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha)
    BEGIN
        THROW 50001, 'ERROR: El registro de asistencia con la combinación de ID_socio, ID_actividad, ID_turno y Fecha especificados no existe.', 1;
         
    END

    UPDATE Asistencia.asistencia
    SET Presentismo = ISNULL(@Presentismo, Presentismo)
    WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha;
END;
GO

-- SP para eliminar un registro de asistencia
CREATE OR ALTER PROCEDURE EliminarAsistencia
    @ID_socio INT,
    @ID_actividad INT,
    @ID_turno INT,
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Asistencia.asistencia WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha)
    BEGIN
        THROW 50001, 'ERROR: El registro de asistencia con la combinación de ID_socio, ID_actividad, ID_turno y Fecha especificados no existe.', 1;
         
    END

    DELETE FROM Asistencia.asistencia
    WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha;
END;
GO
