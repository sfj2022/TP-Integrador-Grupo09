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

-- SP para insertar un nuevo socio
CREATE PROCEDURE InsertarSocio
    @ID_socio INT,
    @DNI VARCHAR(8),
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
        PRINT 'ERROR: El DNI no puede estar vacío.';
        RETURN;
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'ERROR: El DNI debe contener 8 dígitos numéricos.';
        RETURN;
    END

    IF @Email IS NULL OR @Email NOT LIKE '%@%.%'
    BEGIN
        PRINT 'ERROR: El Email no es válido.';
        RETURN;
    END

    IF @FechaNacimiento IS NULL OR @FechaNacimiento > GETDATE()
    BEGIN
        PRINT 'ERROR: La Fecha de Nacimiento no es válida.';
        RETURN;
    END

    IF @estado NOT IN ('activo', 'inactivo', 'moroso')
    BEGIN
        PRINT 'ERROR: El estado del socio no es válido. Debe ser "activo", "inactivo" o "moroso".';
        RETURN;
    END

    -- Verificar si el ID_socio ya está
    IF EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio ya existe, use un ID diferente.';
        RETURN;
    END

    INSERT INTO Persona.Socio (
        ID_socio, DNI, Email, FechaNacimiento, domicilio, obra_social,
        numObraSocial, telObraSocial, estado, usuario, contrasenia, caducidad_contrasenia
    )
    VALUES (
        @ID_socio, @DNI, @Email, @FechaNacimiento, @domicilio, @obra_social,
        @numObraSocial, @telObraSocial, @estado, @usuario, @contrasenia, @caducidad_contrasenia
    );
END;
GO

-- SP para actualizar un socio existente
CREATE PROCEDURE ActualizarSocio
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
        PRINT 'ERROR: El socio con el ID especificado no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @DNI IS NOT NULL AND (LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
    BEGIN
        PRINT 'ERROR: El DNI debe contener 8 dígitos numéricos.';
        RETURN;
    END

    IF @Email IS NOT NULL AND (@Email NOT LIKE '%@%.%')
    BEGIN
        PRINT 'ERROR: El Email no es válido.';
        RETURN;
    END

    IF @FechaNacimiento IS NOT NULL AND (@FechaNacimiento > GETDATE())
    BEGIN
        PRINT 'ERROR: La Fecha de Nacimiento no es válida.';
        RETURN;
    END

    IF @estado IS NOT NULL AND @estado NOT IN ('activo', 'inactivo', 'moroso')
    BEGIN
        PRINT 'ERROR: El estado del socio no es válido. Debe ser "activo", "inactivo" o "moroso".';
        RETURN;
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
CREATE PROCEDURE EliminarSocio
    @ID_socio INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El socio con el ID especificado no existe.';
        RETURN;
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

- SP para insertar un nuevo teléfono de socio
CREATE PROCEDURE InsertarSocioTelefono
    @ID_socio INT,
    @Tel VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El socio con el ID especificado no existe.';
        RETURN;
    END

    -- Validar formato del teléfono
    IF @Tel IS NULL OR LTRIM(RTRIM(@Tel)) = '' OR NOT (@Tel LIKE '[0-9]%')
    BEGIN
        PRINT 'ERROR: El número de teléfono no es válido.';
        RETURN;
    END

    -- Verificar si el teléfono ya existe para este socio
    IF EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        PRINT 'ERROR: Este número de teléfono ya está registrado para el socio.';
        RETURN;
    END

    INSERT INTO Persona.SocioTelefonos (ID_socio, Tel)
    VALUES (@ID_socio, @Tel);
END;
GO

--  Actualizar un teléfono de socio
CREATE PROCEDURE ActualizarSocioTelefono
    @ID_socio INT,
    @TelAntiguo VARCHAR(15),
    @TelNuevo VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio y el teléfono antiguo existen
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo)
    BEGIN
        PRINT 'ERROR: El teléfono antiguo no está registrado para el socio especificado.';
        RETURN;
    END

    -- Validar formato del nuevo teléfono
    IF @TelNuevo IS NULL OR LTRIM(RTRIM(@TelNuevo)) = '' OR NOT (@TelNuevo LIKE '[0-9]%')
    BEGIN
        PRINT 'ERROR: El nuevo número de teléfono no es válido.';
        RETURN;
    END

    -- Verificar si el nuevo teléfono ya existe para este socio (evitar duplicados)
    IF EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @TelNuevo)
    BEGIN
        PRINT 'ERROR: El nuevo número de teléfono ya está registrado para el socio.';
        RETURN;
    END

    -- Eliminar el teléfono antiguo y luego insertar el nuevo
    DELETE FROM Persona.SocioTelefonos
    WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo;

    INSERT INTO Persona.SocioTelefonos (ID_socio, Tel)
    VALUES (@ID_socio, @TelNuevo);
END;
GO

-- SP para eliminar un teléfono de socio
CREATE PROCEDURE EliminarSocioTelefono
    @ID_socio INT,
    @Tel VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el teléfono existe para el socio
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioTelefonos WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        PRINT 'ERROR: El teléfono especificado no existe para el socio.';
        RETURN;
    END

    DELETE FROM Persona.SocioTelefonos
    WHERE ID_socio = @ID_socio AND Tel = @Tel;
END;
GO

-- =========================================================
-- Stored Procedures para la tabla Persona.SocioEmergencia
-- =========================================================

CREATE PROCEDURE InsertarSocioEmergencia
    @ID_socio INT,
    @Tel VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El socio con el ID especificado no existe.';
        RETURN;
    END

    -- Validar si el teléfono está vacío o es nulo
    IF @Tel IS NULL OR LTRIM(RTRIM(@Tel)) = ''
    BEGIN
        PRINT 'ERROR: El número de teléfono de emergencia no puede estar vacío.';
        RETURN;
    END

    -- Verificar si el teléfono ya existe para este socio
    IF EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        PRINT 'ERROR: Este número de teléfono de emergencia ya está registrado para el socio.';
        RETURN;
    END

    INSERT INTO Persona.SocioEmergencia (ID_socio, Tel)
    VALUES (@ID_socio, @Tel);
END;
GO

-- SP para actualizar un teléfono de emergencia de socio
CREATE PROCEDURE ActualizarSocioEmergencia
    @ID_socio INT,
    @TelAntiguo VARCHAR(50),
    @TelNuevo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el socio y el teléfono antiguo existen
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo)
    BEGIN
        PRINT 'ERROR: El teléfono de emergencia antiguo no está registrado para el socio especificado.';
        RETURN;
    END

    -- Validar si el nuevo teléfono vacío o es nulo
    IF @TelNuevo IS NULL OR LTRIM(RTRIM(@TelNuevo)) = ''
    BEGIN
        PRINT 'ERROR: El nuevo número de teléfono de emergencia no puede estar vacío.';
        RETURN;
    END

    -- Verificar si el nuevo teléfono ya existe para este socio
    IF EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @TelNuevo)
    BEGIN
        PRINT 'ERROR: El nuevo número de teléfono de emergencia ya está registrado para el socio.';
        RETURN;
    END

    -- Eliminar el teléfono antiguo y luego insertar el nuevo
    DELETE FROM Persona.SocioEmergencia
    WHERE ID_socio = @ID_socio AND Tel = @TelAntiguo;

    INSERT INTO Persona.SocioEmergencia (ID_socio, Tel)
    VALUES (@ID_socio, @TelNuevo);
END;
GO


-- SP para eliminar un teléfono de emergencia de socio
CREATE PROCEDURE EliminarSocioEmergencia
    @ID_socio INT,
    @Tel VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el teléfono existe para el socio
    IF NOT EXISTS (SELECT 1 FROM Persona.SocioEmergencia WHERE ID_socio = @ID_socio AND Tel = @Tel)
    BEGIN
        PRINT 'ERROR: El teléfono de emergencia especificado no existe para el socio.';
        RETURN;
    END

    DELETE FROM Persona.SocioEmergencia
    WHERE ID_socio = @ID_socio AND Tel = @Tel;
END;
GO


-- ===============================================
-- Stored Procedures para la tabla Persona.Invitado
-- ===============================================

-- SP para insertar un nuevo invitado
CREATE PROCEDURE InsertarInvitado
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
        PRINT 'ERROR: El DNI del invitado no puede estar vacío.';
        RETURN;
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'ERROR: El DNI del invitado debe contener 8 dígitos numéricos.';
        RETURN;
    END

    IF @fecha IS NULL OR @fecha > GETDATE()
    BEGIN
        PRINT 'ERROR: La Fecha del invitado no es válida.';
        RETURN;
    END

    IF @ID_socio IS NULL OR NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio especificado para el invitado no existe.';
        RETURN;
    END

    -- Verificar si el invitado ya existe para esa fecha y DNI
    IF EXISTS (SELECT 1 FROM Persona.Invitado WHERE DNI = @DNI AND fecha = @fecha)
    BEGIN
        PRINT 'ERROR: Ya existe un invitado con este DNI para la fecha especificada.';
        RETURN;
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
CREATE PROCEDURE ActualizarInvitado
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
        PRINT 'ERROR: El invitado con el DNI y la fecha especificados no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @ID_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
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
CREATE PROCEDURE EliminarInvitado
    @DNI VARCHAR(8),
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el invitado existe
    IF NOT EXISTS (SELECT 1 FROM Persona.Invitado WHERE DNI = @DNI AND fecha = @fecha)
    BEGIN
        PRINT 'ERROR: El invitado con el DNI y la fecha especificados no existe.';
        RETURN;
    END

    DELETE FROM Persona.Invitado
    WHERE DNI = @DNI AND fecha = @fecha;
END;
GO

-- ====================================================
-- Stored Procedures para la tabla Persona.responsabilidad
-- ====================================================

-- SP para insertar una nueva relación de responsabilidad
CREATE PROCEDURE InsertarResponsabilidad
    @ID_responsable INT,
    @ID_menor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que ambos socios existan
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_responsable)
    BEGIN
        PRINT 'ERROR: El ID_responsable especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_menor)
    BEGIN
        PRINT 'ERROR: El ID_menor especificado no existe.';
        RETURN;
    END

    -- Evitar que un socio sea responsable de sí mismo
    IF @ID_responsable = @ID_menor
    BEGIN
        PRINT 'ERROR: Un socio no puede ser responsable de sí mismo.';
        RETURN;
    END

    -- Verificar si la relación de responsabilidad ya existe
    IF EXISTS (SELECT 1 FROM Persona.responsabilidad WHERE ID_responsable = @ID_responsable AND ID_menor = @ID_menor)
    BEGIN
        PRINT 'ERROR: Esta relación de responsabilidad ya existe.';
        RETURN;
    END

    INSERT INTO Persona.responsabilidad (ID_responsable, ID_menor)
    VALUES (@ID_responsable, @ID_menor);
END;
GO

-- SP para eliminar una relación de responsabilidad
CREATE PROCEDURE EliminarResponsabilidad
    @ID_responsable INT,
    @ID_menor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la relación de responsabilidad existe
    IF NOT EXISTS (SELECT 1 FROM Persona.responsabilidad WHERE ID_responsable = @ID_responsable AND ID_menor = @ID_menor)
    BEGIN
        PRINT 'ERROR: La relación de responsabilidad especificada no existe.';
        RETURN;
    END

    DELETE FROM Persona.responsabilidad
    WHERE ID_responsable = @ID_responsable AND ID_menor = @ID_menor;
END;
GO
-- ===============================================
-- Stored Procedures para la tabla Gestion.rol
-- ===============================================

-- SP para insertar un nuevo rol
CREATE PROCEDURE InsertarRol
    @ID_rol INT,
    @nombre VARCHAR(20),
    @descripcion VARCHAR(280)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre del rol no puede estar vacío.';
        RETURN;
    END

    -- Verificar si el ID_rol ya existe
    IF EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        PRINT 'ERROR: El ID_rol ya existe. Por favor, utilice un ID diferente.';
        RETURN;
    END

    INSERT INTO Gestion.rol (ID_rol, nombre, descripcion)
    VALUES (@ID_rol, @nombre, @descripcion);
END;
GO

-- SP para actualizar un rol existente
CREATE PROCEDURE ActualizarRol
    @ID_rol INT,
    @nombre VARCHAR(20) = NULL,
    @descripcion VARCHAR(280) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el rol existe
    IF NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        PRINT 'ERROR: El rol con el ID especificado no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre del rol no puede estar vacío.';
        RETURN;
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
CREATE PROCEDURE EliminarRol
    @ID_rol INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el rol existe
    IF NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        PRINT 'ERROR: El rol con el ID especificado no existe.';
        RETURN;
    END

    -- Verificar si hay personal asociado a este rol antes de eliminarlo
    IF EXISTS (SELECT 1 FROM Gestion.Personal WHERE ID_rol = @ID_rol)
    BEGIN
        PRINT 'ERROR: No se puede eliminar el rol porque hay personal asociado a él. Desasocie el personal primero.';
        RETURN;
    END

    DELETE FROM Gestion.rol
    WHERE ID_rol = @ID_rol;
END;
GO
-- ==================================================
-- Stored Procedures para la tabla Gestion.Personal
-- ==================================================

-- SP para insertar nuevo personal
CREATE PROCEDURE InsertarPersonal
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
        PRINT 'ERROR: El nombre del personal no puede estar vacío.';
        RETURN;
    END

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
    BEGIN
        PRINT 'ERROR: El apellido del personal no puede estar vacío.';
        RETURN;
    END

    IF @DNI IS NULL OR LTRIM(RTRIM(@DNI)) = ''
    BEGIN
        PRINT 'ERROR: El DNI del personal no puede estar vacío.';
        RETURN;
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'ERROR: El DNI del personal debe contener 8 dígitos numéricos.';
        RETURN;
    END

    IF @usuario IS NULL OR LTRIM(RTRIM(@usuario)) = ''
    BEGIN
        PRINT 'ERROR: El usuario del personal no puede estar vacío.';
        RETURN;
    END

    IF @contrasenia IS NULL OR LTRIM(RTRIM(@contrasenia)) = ''
    BEGIN
        PRINT 'ERROR: La contraseña del personal no puede estar vacía.';
        RETURN;
    END

    -- Verificar si el ID_personal ya existe
    IF EXISTS (SELECT 1 FROM Gestion.Personal WHERE ID_personal = @ID_personal)
    BEGIN
        PRINT 'ERROR: El ID_personal ya existe. Por favor, utilice un ID diferente.';
        RETURN;
    END

    -- Validar que el ID_rol exista
    IF NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        PRINT 'ERROR: El ID_rol especificado no existe.';
        RETURN;
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
CREATE PROCEDURE ActualizarPersonal
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
        PRINT 'ERROR: El personal con el ID especificado no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @DNI IS NOT NULL AND (LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
    BEGIN
        PRINT 'ERROR: El DNI debe contener 8 dígitos numéricos.';
        RETURN;
    END

    IF @ID_rol IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Gestion.rol WHERE ID_rol = @ID_rol)
    BEGIN
        PRINT 'ERROR: El ID_rol especificado no existe.';
        RETURN;
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
CREATE PROCEDURE EliminarPersonal
    @ID_personal INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el personal existe
    IF NOT EXISTS (SELECT 1 FROM Gestion.Personal WHERE ID_personal = @ID_personal)
    BEGIN
        PRINT 'ERROR: El personal con el ID especificado no existe.';
        RETURN;
    END

    DELETE FROM Gestion.Personal
    WHERE ID_personal = @ID_personal;
END;
GO
-- ===================================================
-- Stored Procedures para la tabla Actividades.Membresia
-- ===================================================

-- SP para insertar una nueva membresía
CREATE PROCEDURE InsertarMembresia
    @ID_tipo INT,
    @nombre VARCHAR(20),
    @descripcion VARCHAR(140),
    @costo DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre de la membresía no puede estar vacío.';
        RETURN;
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la membresía debe ser un valor positivo.';
        RETURN;
    END

    -- Verificar si el ID_tipo ya existe
    IF EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_tipo)
    BEGIN
        PRINT 'ERROR: El ID_tipo de membresía ya existe. Por favor, utilice un ID diferente.';
        RETURN;
    END

    INSERT INTO Actividades.Membresia (ID_tipo, nombre, descripcion, costo)
    VALUES (@ID_tipo, @nombre, @descripcion, @costo);
END;
GO

-- SP para actualizar una membresía existente
CREATE PROCEDURE ActualizarMembresia
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
        PRINT 'ERROR: La membresía con el ID especificado no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre de la membresía no puede estar vacío.';
        RETURN;
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la membresía debe ser un valor positivo.';
        RETURN;
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
CREATE PROCEDURE EliminarMembresia
    @ID_tipo INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la membresía existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_tipo)
    BEGIN
        PRINT 'ERROR: La membresía con el ID especificado no existe.';
        RETURN;
    END

    -- Verificar si hay inscripciones asociadas a esta membresía
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Socio WHERE ID_membresia = @ID_tipo)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la membresía porque hay inscripciones de socios asociadas a ella. Desasocie las inscripciones primero.';
        RETURN;
    END

    DELETE FROM Actividades.Membresia
    WHERE ID_tipo = @ID_tipo;
END;
GO

-- =========================================================
-- Stored Procedures para la tabla Actividades.Inscripcion_Socio
-- =========================================================

-- SP para insertar una nueva inscripción de socio
CREATE PROCEDURE InsertarInscripcionSocio
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
        PRINT 'ERROR: La fecha de inicio de la inscripción no es válida.';
        RETURN;
    END

    IF @fecha_baja IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        PRINT 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.';
        RETURN;
    END

    -- Validar si el socio y la membresía existen
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_membresia)
    BEGIN
        PRINT 'ERROR: El ID_membresia especificado no existe.';
        RETURN;
    END

    -- Verificar si la inscripción ya existe para este socio
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Socio WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        PRINT 'ERROR: Ya existe una inscripción con este ID para el socio especificado.';
        RETURN;
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
CREATE PROCEDURE ActualizarInscripcionSocio
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
        PRINT 'ERROR: La inscripción de socio con el ID_socio e ID_inscripcion especificados no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @fecha_inicio IS NOT NULL AND @fecha_inicio > GETDATE()
    BEGIN
        PRINT 'ERROR: La fecha de inicio de la inscripción no es válida.';
        RETURN;
    END

    IF @fecha_baja IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        PRINT 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.';
        RETURN;
    END

    IF @ID_membresia IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Actividades.Membresia WHERE ID_tipo = @ID_membresia)
    BEGIN
        PRINT 'ERROR: El ID_membresia especificado no existe.';
        RETURN;
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
CREATE PROCEDURE EliminarInscripcionSocio
    @ID_socio INT,
    @ID_inscripcion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Socio WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        PRINT 'ERROR: La inscripción de socio con el ID_socio e ID_inscripcion especificados no existe.';
        RETURN;
    END

    DELETE FROM Actividades.Inscripcion_Socio
    WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO
-- ============================================================
-- Stored Procedures para la tabla Actividades.Actividades_Deportivas
-- ============================================================

-- SP para insertar una nueva actividad deportiva
CREATE PROCEDURE InsertarActividadDeportiva
    @ID_actividad INT,
    @Nombre VARCHAR(32),
    @costo DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre de la actividad deportiva no puede estar vacío.';
        RETURN;
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la actividad deportiva debe ser un valor positivo.';
        RETURN;
    END

    -- Verificar si el ID_actividad ya existe
    IF EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: El ID_actividad ya existe para Actividades_Deportivas. Por favor, utilice un ID diferente.';
        RETURN;
    END

    INSERT INTO Actividades.Actividades_Deportivas (ID_actividad, Nombre, costo)
    VALUES (@ID_actividad, @Nombre, @costo);
END;
GO

-- SP para actualizar una actividad deportiva existente
CREATE PROCEDURE ActualizarActividadDeportiva
    @ID_actividad INT,
    @Nombre VARCHAR(32) = NULL,
    @costo DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la actividad existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: La actividad deportiva con el ID especificado no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @Nombre IS NOT NULL AND LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre de la actividad deportiva no puede estar vacío.';
        RETURN;
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la actividad deportiva debe ser un valor positivo.';
        RETURN;
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
CREATE PROCEDURE EliminarActividadDeportiva
    @ID_actividad INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la actividad existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: La actividad deportiva con el ID especificado no existe.';
        RETURN;
    END

    -- Verificar si hay turnos o inscripciones asociadas a esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la actividad deportiva porque tiene turnos asociados. Elimine los turnos primero.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la actividad deportiva porque tiene inscripciones asociadas. Elimine las inscripciones primero.';
        RETURN;
    END

    DELETE FROM Actividades.Actividades_Deportivas
    WHERE ID_actividad = @ID_actividad;
END;
GO

-- ========================================================
-- Stored Procedures para la tabla Actividades.Actividades_Otras
-- ========================================================

-- SP para insertar una nueva actividad "otra"
CREATE PROCEDURE InsertarActividadOtra
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
        PRINT 'ERROR: El nombre de la actividad "otra" no puede estar vacío.';
        RETURN;
    END

    IF @costo_socio IS NULL OR @costo_socio < 0
    BEGIN
        PRINT 'ERROR: El costo para socios debe ser un valor positivo.';
        RETURN;
    END

    IF @costo_invitados IS NULL OR @costo_invitados < 0
    BEGIN
        PRINT 'ERROR: El costo para invitados debe ser un valor positivo.';
        RETURN;
    END

    -- Verificar si el ID_actividad ya existe
    IF EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: El ID_actividad ya existe para Actividades_Otras. Por favor, utilice un ID diferente.';
        RETURN;
    END

    INSERT INTO Actividades.Actividades_Otras (ID_actividad, Nombre, costo_socio, costo_invitados)
    VALUES (@ID_actividad, @Nombre, @costo_socio, @costo_invitados);
END;
GO

-- SP para actualizar una actividad "otra" existente
CREATE PROCEDURE ActualizarActividadOtra
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
        PRINT 'ERROR: La actividad "otra" con el ID especificado no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @Nombre IS NOT NULL AND LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre de la actividad "otra" no puede estar vacío.';
        RETURN;
    END

    IF @costo_socio IS NOT NULL AND @costo_socio < 0
    BEGIN
        PRINT 'ERROR: El costo para socios debe ser un valor positivo.';
        RETURN;
    END

    IF @costo_invitados IS NOT NULL AND @costo_invitados < 0
    BEGIN
        PRINT 'ERROR: El costo para invitados debe ser un valor positivo.';
        RETURN;
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
CREATE PROCEDURE EliminarActividadOtra
    @ID_actividad INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la actividad existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: La actividad "otra" con el ID especificado no existe.';
        RETURN;
    END

    -- Verificar si hay turnos o inscripciones asociadas a esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la actividad "otra" porque tiene turnos asociados. Elimine los turnos primero.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la actividad "otra" porque tiene inscripciones asociadas. Elimine las inscripciones primero.';
        RETURN;
    END

    DELETE FROM Actividades.Actividades_Otras
    WHERE ID_actividad = @ID_actividad;
END;
GO

-- =======================================================
-- Stored Procedures para la tabla Actividades.AcDep_turnos
-- =======================================================

-- SP para insertar un nuevo turno de actividad deportiva
CREATE PROCEDURE InsertarAcDepTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @turno IS NULL OR LTRIM(RTRIM(@turno)) = ''
    BEGIN
        PRINT 'ERROR: El turno no puede estar vacío.';
        RETURN;
    END

    -- Validar que la actividad deportiva exista
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: La ID_actividad especificada no existe en Actividades_Deportivas.';
        RETURN;
    END

    -- Verificar si el turno ya existe para esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: Ya existe un turno con este ID para la actividad deportiva especificada.';
        RETURN;
    END

    INSERT INTO Actividades.AcDep_turnos (ID_actividad, ID_turno, turno)
    VALUES (@ID_actividad, @ID_turno, @turno);
END;
GO

-- SP para actualizar un turno de actividad deportiva existente
CREATE PROCEDURE ActualizarAcDepTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @turno IS NOT NULL AND LTRIM(RTRIM(@turno)) = ''
    BEGIN
        PRINT 'ERROR: El turno no puede estar vacío.';
        RETURN;
    END

    UPDATE Actividades.AcDep_turnos
    SET
        turno = ISNULL(@turno, turno)
    WHERE
        ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- SP para eliminar un turno de actividad deportiva
CREATE PROCEDURE EliminarAcDepTurno
    @ID_actividad INT,
    @ID_turno INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.';
        RETURN;
    END

    -- Verificar si hay inscripciones asociadas a este turno
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_actividad = @ID_actividad AND ID_Turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: No se puede eliminar el turno porque hay inscripciones asociadas a él. Elimine las inscripciones primero.';
        RETURN;
    END

    DELETE FROM Actividades.AcDep_turnos
    WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- =====================================================
-- Stored Procedures para la tabla Actividades.AcOtra_turnos
-- =====================================================

-- SP para insertar un nuevo turno de actividad "otra"
CREATE PROCEDURE InsertarAcOtraTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @turno IS NULL OR LTRIM(RTRIM(@turno)) = ''
    BEGIN
        PRINT 'ERROR: El turno no puede estar vacío.';
        RETURN;
    END

    -- Validar que la actividad "otra" exista
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: La ID_actividad especificada no existe en Actividades_Otras.';
        RETURN;
    END

    -- Verificar si el turno ya existe para esta actividad
    IF EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: Ya existe un turno con este ID para la actividad "otra" especificada.';
        RETURN;
    END

    INSERT INTO Actividades.AcOtra_turnos (ID_actividad, ID_turno, turno)
    VALUES (@ID_actividad, @ID_turno, @turno);
END;
GO

-- SP para actualizar un turno de actividad "otra" existente
CREATE PROCEDURE ActualizarAcOtraTurno
    @ID_actividad INT,
    @ID_turno INT,
    @turno VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @turno IS NOT NULL AND LTRIM(RTRIM(@turno)) = ''
    BEGIN
        PRINT 'ERROR: El turno no puede estar vacío.';
        RETURN;
    END

    UPDATE Actividades.AcOtra_turnos
    SET
        turno = ISNULL(@turno, turno)
    WHERE
        ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- SP para eliminar un turno de actividad "otra"
CREATE PROCEDURE EliminarAcOtraTurno
    @ID_actividad INT,
    @ID_turno INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: El turno con el ID_actividad e ID_turno especificados no existe.';
        RETURN;
    END

    -- Verificar si hay inscripciones asociadas a este turno
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_actividad = @ID_actividad AND ID_Turno = @ID_turno)
    BEGIN
        PRINT 'ERROR: No se puede eliminar el turno porque hay inscripciones asociadas a él. Elimine las inscripciones primero.';
        RETURN;
    END

    DELETE FROM Actividades.AcOtra_turnos
    WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_turno;
END;
GO

-- ==========================================================
-- Stored Procedures para la tabla Actividades.Inscripcion_Deportiva
-- ==========================================================

-- SP para insertar una nueva inscripción deportiva
CREATE PROCEDURE InsertarInscripcionDeportiva
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
        PRINT 'ERROR: La fecha de inicio de la inscripción no es válida.';
        RETURN;
    END

    IF @fecha_baja IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        PRINT 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.';
        RETURN;
    END

    -- Validar si el socio, actividad y turno existen
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        PRINT 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcDep_turnos.';
        RETURN;
    END

    -- Verificar si la inscripción ya existe para este socio
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        PRINT 'ERROR: Ya existe una inscripción con este ID para el socio especificado.';
        RETURN;
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
CREATE PROCEDURE ActualizarInscripcionDeportiva
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
        PRINT 'ERROR: La inscripción deportiva con el ID_socio e ID_inscripcion especificados no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @fecha_inicio IS NOT NULL AND @fecha_inicio > GETDATE()
    BEGIN
        PRINT 'ERROR: La fecha de inicio de la inscripción no es válida.';
        RETURN;
    END

    IF @fecha_baja IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        PRINT 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.';
        RETURN;
    END

    IF @ID_actividad IS NOT NULL AND @ID_Turno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Actividades.AcDep_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        PRINT 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcDep_turnos.';
        RETURN;
    END
    ELSE IF @ID_actividad IS NOT NULL AND @ID_Turno IS NULL AND NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: El ID_actividad especificado no existe en Actividades.Actividades_Deportivas.';
        RETURN;
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
CREATE PROCEDURE EliminarInscripcionDeportiva
    @ID_socio INT,
    @ID_inscripcion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Deportiva WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        PRINT 'ERROR: La inscripción deportiva con el ID_socio e ID_inscripcion especificados no existe.';
        RETURN;
    END

    DELETE FROM Actividades.Inscripcion_Deportiva
    WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion;
END;
GO

-- ======================================================
-- Stored Procedures para la tabla Actividades.Inscripcion_Otra
-- ======================================================

-- SP para insertar una nueva inscripción de actividad "otra"
CREATE PROCEDURE InsertarInscripcionOtra
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
        PRINT 'ERROR: La fecha de inicio de la inscripción no es válida.';
        RETURN;
    END

    IF @fecha_baja IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        PRINT 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.';
        RETURN;
    END

    -- Validar si el socio, actividad y turno existen
    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        PRINT 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcOtra_turnos.';
        RETURN;
    END

    -- Verificar si la inscripción ya existe para este socio
    IF EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        PRINT 'ERROR: Ya existe una inscripción con este ID para el socio especificado.';
        RETURN;
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
CREATE PROCEDURE ActualizarInscripcionOtra
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
        PRINT 'ERROR: La inscripción de actividad "otra" con el ID_socio e ID_inscripcion especificados no existe.';
        RETURN;
    END

    -- Validaciones para los parámetros que se actualizan
    IF @fecha_inicio IS NOT NULL AND @fecha_inicio > GETDATE()
    BEGIN
        PRINT 'ERROR: La fecha de inicio de la inscripción no es válida.';
        RETURN;
    END

    IF @fecha_baja IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_baja < @fecha_inicio
    BEGIN
        PRINT 'ERROR: La fecha de baja no puede ser anterior a la fecha de inicio.';
        RETURN;
    END

    IF @ID_actividad IS NOT NULL AND @ID_Turno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Actividades.AcOtra_turnos WHERE ID_actividad = @ID_actividad AND ID_turno = @ID_Turno)
    BEGIN
        PRINT 'ERROR: La combinación de ID_actividad e ID_Turno no existe en Actividades.AcOtra_turnos.';
        RETURN;
    END
    ELSE IF @ID_actividad IS NOT NULL AND @ID_Turno IS NULL AND NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: El ID_actividad especificado no existe en Actividades.Actividades_Otras.';
        RETURN;
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
CREATE PROCEDURE EliminarInscripcionOtra
    @ID_socio INT,
    @ID_inscripcion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la inscripción existe
    IF NOT EXISTS (SELECT 1 FROM Actividades.Inscripcion_Otra WHERE ID_socio = @ID_socio AND ID_inscripcion = @ID_inscripcion)
    BEGIN
        PRINT 'ERROR: La inscripción de actividad "otra" con el ID_socio e ID_inscripcion especificados no existe.';
        RETURN;
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
CREATE PROCEDURE InsertarMedioDePago
    @ID_banco INT,
    @nombre VARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre del medio de pago no puede estar vacío.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        PRINT 'ERROR: El ID_banco ya existe. Por favor, utilice un ID diferente.';
        RETURN;
    END

    INSERT INTO Finansas.MedioDePago (ID_banco, nombre)
    VALUES (@ID_banco, @nombre);
END;
GO

-- SP para actualizar un medio de pago
CREATE PROCEDURE ActualizarMedioDePago
    @ID_banco INT,
    @nombre VARCHAR(32) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        PRINT 'ERROR: El medio de pago con el ID especificado no existe.';
        RETURN;
    END

    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        PRINT 'ERROR: El nombre del medio de pago no puede estar vacío.';
        RETURN;
    END

    UPDATE Finansas.MedioDePago
    SET nombre = ISNULL(@nombre, nombre)
    WHERE ID_banco = @ID_banco;
END;
GO

-- SP para eliminar un medio de pago
CREATE PROCEDURE EliminarMedioDePago
    @ID_banco INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        PRINT 'ERROR: El medio de pago con el ID especificado no existe.';
        RETURN;
    END

    -- Verificar si hay cuentas asociadas a este medio de pago
    IF EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_banco = @ID_banco)
    BEGIN
        PRINT 'ERROR: No se puede eliminar el medio de pago porque hay cuentas asociadas a él. Desasocie las cuentas primero.';
        RETURN;
    END

    DELETE FROM Finansas.MedioDePago
    WHERE ID_banco = @ID_banco;
END;
GO

-- Stored Procedures para la tabla Finansas.Cuenta

-- SP para insertar una nueva cuenta
CREATE PROCEDURE InsertarCuenta
    @ID_socio INT,
    @ID_cuenta INT,
    @ID_banco INT,
    @credenciales VARCHAR(50),
    @tipo VARCHAR(20),
    @SaldoAFavor DECIMAL(10,2),
    @fechaPagoAutomatico DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        PRINT 'ERROR: El ID_banco especificado no existe.';
        RETURN;
    END

    IF @credenciales IS NULL OR LTRIM(RTRIM(@credenciales)) = ''
    BEGIN
        PRINT 'ERROR: Las credenciales no pueden estar vacías.';
        RETURN;
    END

    IF @tipo NOT IN ('credito', 'debito')
    BEGIN
        PRINT 'ERROR: El tipo de cuenta no es válido. Debe ser "credito" o "debito".';
        RETURN;
    END

    IF @SaldoAFavor IS NULL OR @SaldoAFavor < 0
    BEGIN
        PRINT 'ERROR: El saldo a favor debe ser un valor no negativo.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: Ya existe una cuenta con este ID para el socio especificado.';
        RETURN;
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
CREATE PROCEDURE ActualizarCuenta
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
        PRINT 'ERROR: La cuenta con el ID_socio e ID_cuenta especificados no existe.';
        RETURN;
    END

    IF @ID_banco IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Finansas.MedioDePago WHERE ID_banco = @ID_banco)
    BEGIN
        PRINT 'ERROR: El ID_banco especificado no existe.';
        RETURN;
    END

    IF @credenciales IS NOT NULL AND LTRIM(RTRIM(@credenciales)) = ''
    BEGIN
        PRINT 'ERROR: Las credenciales no pueden estar vacías.';
        RETURN;
    END

    IF @tipo IS NOT NULL AND @tipo NOT IN ('credito', 'debito')
    BEGIN
        PRINT 'ERROR: El tipo de cuenta no es válido. Debe ser "credito" o "debito".';
        RETURN;
    END

    IF @SaldoAFavor IS NOT NULL AND @SaldoAFavor < 0
    BEGIN
        PRINT 'ERROR: El saldo a favor debe ser un valor no negativo.';
        RETURN;
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
CREATE PROCEDURE EliminarCuenta
    @ID_socio INT,
    @ID_cuenta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: La cuenta con el ID_socio e ID_cuenta especificados no existe.';
        RETURN;
    END

    -- Verificar si hay cobros o reembolsos asociados a esta cuenta
    IF EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la cuenta porque tiene cobros asociados. Elimine los cobros primero.';
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la cuenta porque tiene reembolsos asociados. Elimine los reembolsos primero.';
        RETURN;
    END

    DELETE FROM Finansas.Cuenta
    WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta;
END;
GO

-- Stored Procedures para la tabla Finansas.Cuota

-- SP para insertar una nueva cuota
CREATE PROCEDURE InsertarCuota
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
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
    END

    IF @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        PRINT 'ERROR: El tipo de cuota no es válido. Debe ser "socio", "deporte" o "otra".';
        RETURN;
    END

    IF @fecha IS NULL OR @fecha > GETDATE()
    BEGIN
        PRINT 'ERROR: La fecha de la cuota no es válida.';
        RETURN;
    END

    IF @Vencimiento1 IS NULL OR @Vencimiento1 < @fecha
    BEGIN
        PRINT 'ERROR: La primera fecha de vencimiento no es válida (no puede ser anterior a la fecha de la cuota).';
        RETURN;
    END

    IF @Vencimiento2 IS NULL OR @Vencimiento2 < @Vencimiento1
    BEGIN
        PRINT 'ERROR: La segunda fecha de vencimiento no es válida (no puede ser anterior a la primera).';
        RETURN;
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la cuota debe ser un valor no negativo.';
        RETURN;
    END

    IF @recargo IS NULL OR @recargo < 0
    BEGIN
        PRINT 'ERROR: El recargo de la cuota debe ser un valor no negativo.';
        RETURN;
    END

    IF @descuento IS NULL OR @descuento < 0
    BEGIN
        PRINT 'ERROR: El descuento de la cuota debe ser un valor no negativo.';
        RETURN;
    END

    IF @Estado NOT IN ('impago', 'vencido1', 'vencido2', 'pago')
    BEGIN
        PRINT 'ERROR: El estado de la cuota no es válido. Debe ser "impago", "vencido1", "vencido2" o "pago".';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Finansas.Cuota WHERE ID_cuota = @ID_cuota)
    BEGIN
        PRINT 'ERROR: El ID_cuota ya existe. Por favor, utilice un ID diferente.';
        RETURN;
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
CREATE PROCEDURE ActualizarCuota
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
        PRINT 'ERROR: La cuota con el ID especificado no existe.';
        RETURN;
    END

    IF @ID_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
    END

    IF @Tipo IS NOT NULL AND @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        PRINT 'ERROR: El tipo de cuota no es válido. Debe ser "socio", "deporte" o "otra".';
        RETURN;
    END

    IF @fecha IS NOT NULL AND @fecha > GETDATE()
    BEGIN
        PRINT 'ERROR: La fecha de la cuota no es válida.';
        RETURN;
    END

    IF @Vencimiento1 IS NOT NULL AND @fecha IS NOT NULL AND @Vencimiento1 < @fecha
    BEGIN
        PRINT 'ERROR: La primera fecha de vencimiento no es válida (no puede ser anterior a la fecha de la cuota).';
        RETURN;
    END

    IF @Vencimiento2 IS NOT NULL AND @Vencimiento1 IS NOT NULL AND @Vencimiento2 < @Vencimiento1
    BEGIN
        PRINT 'ERROR: La segunda fecha de vencimiento no es válida (no puede ser anterior a la primera).';
        RETURN;
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la cuota debe ser un valor no negativo.';
        RETURN;
    END

    IF @recargo IS NOT NULL AND @recargo < 0
    BEGIN
        PRINT 'ERROR: El recargo de la cuota debe ser un valor no negativo.';
        RETURN;
    END

    IF @descuento IS NOT NULL AND @descuento < 0
    BEGIN
        PRINT 'ERROR: El descuento de la cuota debe ser un valor no negativo.';
        RETURN;
    END

    IF @Estado IS NOT NULL AND @Estado NOT IN ('impago', 'vencido1', 'vencido2', 'pago')
    BEGIN
        PRINT 'ERROR: El estado de la cuota no es válido. Debe ser "impago", "vencido1", "vencido2" o "pago".';
        RETURN;
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
CREATE PROCEDURE EliminarCuota
    @ID_cuota INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuota WHERE ID_cuota = @ID_cuota)
    BEGIN
        PRINT 'ERROR: La cuota con el ID especificado no existe.';
        RETURN;
    END

    -- Verificar si hay detalles de factura asociados a esta cuota
    IF EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_cuota = @ID_cuota)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la cuota porque hay detalles de factura asociados a ella. Elimine los detalles de factura primero.';
        RETURN;
    END

    DELETE FROM Finansas.Cuota
    WHERE ID_cuota = @ID_cuota;
END;
GO

-- Stored Procedures para la tabla Finansas.factura

-- SP para insertar una nueva factura
CREATE PROCEDURE InsertarFactura
    @ID_factura INT,
    @DNI VARCHAR(8),
    @CUIT VARCHAR(11),
    @FechaYHora DATETIME,
    @costo DECIMAL(10,2),
    @estado BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @DNI IS NULL OR LTRIM(RTRIM(@DNI)) = ''
    BEGIN
        PRINT 'ERROR: El DNI de la factura no puede estar vacío.';
        RETURN;
    END

    IF LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'ERROR: El DNI de la factura debe contener 8 dígitos numéricos.';
        RETURN;
    END

    IF @CUIT IS NULL OR LTRIM(RTRIM(@CUIT)) = ''
    BEGIN
        PRINT 'ERROR: El CUIT de la factura no puede estar vacío.';
        RETURN;
    END

    IF LEN(@CUIT) != 11 OR NOT (@CUIT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')
    BEGIN
        PRINT 'ERROR: El CUIT de la factura debe contener 11 dígitos numéricos con guiones (XX-XXXXXXXX-X).';
        RETURN;
    END

    IF @FechaYHora IS NULL OR @FechaYHora > GETDATE()
    BEGIN
        PRINT 'ERROR: La Fecha y Hora de la factura no es válida.';
        RETURN;
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la factura debe ser un valor no negativo.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        PRINT 'ERROR: El ID_factura ya existe. Por favor, utilice un ID diferente.';
        RETURN;
    END

    INSERT INTO Finansas.factura (ID_factura, DNI, CUIT, FechaYHora, costo, estado)
    VALUES (@ID_factura, @DNI, @CUIT, @FechaYHora, @costo, @estado);
END;
GO

-- SP para actualizar una factura existente
CREATE PROCEDURE ActualizarFactura
    @ID_factura INT,
    @DNI VARCHAR(8) = NULL,
    @CUIT VARCHAR(11) = NULL,
    @FechaYHora DATETIME = NULL,
    @costo DECIMAL(10,2) = NULL,
    @estado BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        PRINT 'ERROR: La factura con el ID especificado no existe.';
        RETURN;
    END

    IF @DNI IS NOT NULL AND (LEN(@DNI) != 8 OR NOT (@DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
    BEGIN
        PRINT 'ERROR: El DNI de la factura debe contener 8 dígitos numéricos.';
        RETURN;
    END

    IF @CUIT IS NOT NULL AND (LEN(@CUIT) != 11 OR NOT (@CUIT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'))
    BEGIN
        PRINT 'ERROR: El CUIT de la factura debe contener 11 dígitos numéricos con guiones (XX-XXXXXXXX-X).';
        RETURN;
    END

    IF @FechaYHora IS NOT NULL AND @FechaYHora > GETDATE()
    BEGIN
        PRINT 'ERROR: La Fecha y Hora de la factura no es válida.';
        RETURN;
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        PRINT 'ERROR: El costo de la factura debe ser un valor no negativo.';
        RETURN;
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
CREATE PROCEDURE EliminarFactura
    @ID_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.factura WHERE ID_factura = @ID_factura)
    BEGIN
        PRINT 'ERROR: La factura con el ID especificado no existe.';
        RETURN;
    END

    -- Verificar si hay detalles de factura, cobros o reembolsos asociados
    IF EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_factura = @ID_factura)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la factura porque tiene detalles de factura asociados. Elimine los detalles primero.';
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_factura = @ID_factura)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la factura porque tiene cobros asociados. Elimine los cobros primero.';
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_factura = @ID_factura)
    BEGIN
        PRINT 'ERROR: No se puede eliminar la factura porque tiene reembolsos asociados. Elimine los reembolsos primero.';
        RETURN;
    END

    DELETE FROM Finansas.factura
    WHERE ID_factura = @ID_factura;
END;
GO

-- Stored Procedures para la tabla Finansas.detalle_factura

-- SP para insertar un nuevo detalle de factura
CREATE PROCEDURE InsertarDetalleFactura
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
        PRINT 'ERROR: El ID_factura especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuota WHERE ID_cuota = @ID_cuota)
    BEGIN
        PRINT 'ERROR: El ID_cuota especificado no existe.';
        RETURN;
    END

    IF @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        PRINT 'ERROR: El tipo de detalle no es válido. Debe ser "socio", "deporte" o "otra".';
        RETURN;
    END

    IF @costo IS NULL OR @costo < 0
    BEGIN
        PRINT 'ERROR: El costo del detalle de factura debe ser un valor no negativo.';
        RETURN;
    END

    IF @recargo IS NULL OR @recargo < 0
    BEGIN
        PRINT 'ERROR: El recargo del detalle de factura debe ser un valor no negativo.';
        RETURN;
    END

    IF @descuento IS NULL OR @descuento < 0
    BEGIN
        PRINT 'ERROR: El descuento del detalle de factura debe ser un valor no negativo.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_factura = @ID_factura AND ID_cuota = @ID_cuota)
    BEGIN
        PRINT 'ERROR: Ya existe un detalle de factura con esta combinación de ID_factura e ID_cuota.';
        RETURN;
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
CREATE PROCEDURE ActualizarDetalleFactura
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
        PRINT 'ERROR: El detalle de factura con la combinación de ID_factura e ID_cuota especificados no existe.';
        RETURN;
    END

    IF @Tipo IS NOT NULL AND @Tipo NOT IN ('socio', 'deporte', 'otra')
    BEGIN
        PRINT 'ERROR: El tipo de detalle no es válido. Debe ser "socio", "deporte" o "otra".';
        RETURN;
    END

    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        PRINT 'ERROR: El costo del detalle de factura debe ser un valor no negativo.';
        RETURN;
    END

    IF @recargo IS NOT NULL AND @recargo < 0
    BEGIN
        PRINT 'ERROR: El recargo del detalle de factura debe ser un valor no negativo.';
        RETURN;
    END

    IF @descuento IS NOT NULL AND @descuento < 0
    BEGIN
        PRINT 'ERROR: El descuento del detalle de factura debe ser un valor no negativo.';
        RETURN;
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
CREATE PROCEDURE EliminarDetalleFactura
    @ID_factura INT,
    @ID_cuota INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.detalle_factura WHERE ID_factura = @ID_factura AND ID_cuota = @ID_cuota)
    BEGIN
        PRINT 'ERROR: El detalle de factura con la combinación de ID_factura e ID_cuota especificados no existe.';
        RETURN;
    END

    DELETE FROM Finansas.detalle_factura
    WHERE ID_factura = @ID_factura AND ID_cuota = @ID_cuota;
END;
GO

-- Stored Procedures para la tabla Finansas.cobro

-- SP para insertar un nuevo cobro
CREATE PROCEDURE InsertarCobro
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
        PRINT 'ERROR: El ID_factura especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: La combinación de ID_socio e ID_cuenta no existe.';
        RETURN;
    END

    IF @Costo IS NULL OR @Costo < 0
    BEGIN
        PRINT 'ERROR: El costo del cobro debe ser un valor no negativo.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: Ya existe un cobro con esta combinación de ID_factura, ID_socio e ID_cuenta.';
        RETURN;
    END

    INSERT INTO Finansas.cobro (ID_factura, ID_socio, ID_cuenta, Costo, Estado)
    VALUES (@ID_factura, @ID_socio, @ID_cuenta, @Costo, @Estado);
END;
GO

-- SP para actualizar un cobro existente
CREATE PROCEDURE ActualizarCobro
    @ID_factura INT,
    @ID_socio INT,
    @ID_cuenta INT,
    @Costo DECIMAL(10,2) = NULL,
    @Estado BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: El cobro con la combinación de ID_factura, ID_socio e ID_cuenta especificados no existe.';
        RETURN;
    END

    IF @Costo IS NOT NULL AND @Costo < 0
    BEGIN
        PRINT 'ERROR: El costo del cobro debe ser un valor no negativo.';
        RETURN;
    END

    UPDATE Finansas.cobro
    SET
        Costo = ISNULL(@Costo, Costo),
        Estado = ISNULL(@Estado, Estado)
    WHERE
        ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta;
END;
GO

-- SP para eliminar un cobro
CREATE PROCEDURE EliminarCobro
    @ID_factura INT,
    @ID_socio INT,
    @ID_cuenta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.cobro WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: El cobro con la combinación de ID_factura, ID_socio e ID_cuenta especificados no existe.';
        RETURN;
    END

    DELETE FROM Finansas.cobro
    WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta;
END;
GO

-- Stored Procedures para la tabla Finansas.reembolso

-- SP para insertar un nuevo reembolso
CREATE PROCEDURE InsertarReembolso
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
        PRINT 'ERROR: El ID_factura especificado no existe.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Finansas.Cuenta WHERE ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: La combinación de ID_socio e ID_cuenta no existe.';
        RETURN;
    END

    IF @Costo IS NULL OR @Costo < 0
    BEGIN
        PRINT 'ERROR: El costo del reembolso debe ser un valor no negativo.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: Ya existe un reembolso con esta combinación de ID_factura, ID_socio e ID_cuenta.';
        RETURN;
    END

    INSERT INTO Finansas.reembolso (ID_factura, ID_socio, ID_cuenta, Costo, Estado)
    VALUES (@ID_factura, @ID_socio, @ID_cuenta, @Costo, @Estado);
END;
GO

-- SP para actualizar un reembolso existente
CREATE PROCEDURE ActualizarReembolso
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
        PRINT 'ERROR: El reembolso con la combinación de ID_factura, ID_socio e ID_cuenta especificados no existe.';
        RETURN;
    END

    IF @Costo IS NOT NULL AND @Costo < 0
    BEGIN
        PRINT 'ERROR: El costo del reembolso debe ser un valor no negativo.';
        RETURN;
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
CREATE PROCEDURE EliminarReembolso
    @ID_factura INT,
    @ID_socio INT,
    @ID_cuenta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finansas.reembolso WHERE ID_factura = @ID_factura AND ID_socio = @ID_socio AND ID_cuenta = @ID_cuenta)
    BEGIN
        PRINT 'ERROR: El reembolso con la combinación de ID_factura, ID_socio e ID_cuenta especificados no existe.';
        RETURN;
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
CREATE PROCEDURE InsertarDia
    @fecha DATE,
    @climaMalo BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha IS NULL OR @fecha > GETDATE() -- O si permite fechas futuras, ajustar esta validación
    BEGIN
        PRINT 'ERROR: La fecha no es válida.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @fecha)
    BEGIN
        PRINT 'ERROR: La fecha ya existe. Por favor, utilice una fecha diferente.';
        RETURN;
    END

    INSERT INTO Asistencia.dias (fecha, climaMalo)
    VALUES (@fecha, @climaMalo);
END;
GO

-- SP para actualizar un día existente
CREATE PROCEDURE ActualizarDia
    @fecha DATE,
    @climaMalo BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @fecha)
    BEGIN
        PRINT 'ERROR: La fecha especificada no existe.';
        RETURN;
    END

    UPDATE Asistencia.dias
    SET climaMalo = ISNULL(@climaMalo, climaMalo)
    WHERE fecha = @fecha;
END;
GO

-- SP para eliminar un día
CREATE PROCEDURE EliminarDia
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @fecha)
    BEGIN
        PRINT 'ERROR: La fecha especificada no existe.';
        RETURN;
    END

    -- Verificar si hay asistencias asociadas a este día
    IF EXISTS (SELECT 1 FROM Asistencia.asistencia WHERE Fecha = @fecha)
    BEGIN
        PRINT 'ERROR: No se puede eliminar el día porque hay registros de asistencia asociados. Elimine los registros de asistencia primero.';
        RETURN;
    END

    DELETE FROM Asistencia.dias
    WHERE fecha = @fecha;
END;
GO

-- Stored Procedures para la tabla Asistencia.asistencia

-- SP para insertar un nuevo registro de asistencia
CREATE PROCEDURE InsertarAsistencia
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
        PRINT 'ERROR: El ID_socio especificado no existe.';
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Deportivas WHERE ID_actividad = @ID_actividad) AND
       NOT EXISTS (SELECT 1 FROM Actividades.Actividades_Otras WHERE ID_actividad = @ID_actividad)
    BEGIN
        PRINT 'ERROR: El ID_actividad especificado no existe en Actividades_Deportivas ni Actividades_Otras.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Asistencia.dias WHERE fecha = @Fecha)
    BEGIN
        PRINT 'ERROR: La Fecha del día no existe en la tabla de Asistencia.dias.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Asistencia.asistencia WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha)
    BEGIN
        PRINT 'ERROR: Ya existe un registro de asistencia con esta combinación para el socio en esta actividad, turno y fecha.';
        RETURN;
    END

    INSERT INTO Asistencia.asistencia (ID_socio, ID_actividad, ID_turno, Fecha, Presentismo)
    VALUES (@ID_socio, @ID_actividad, @ID_turno, @Fecha, @Presentismo);
END;
GO

-- SP para actualizar un registro de asistencia existente
CREATE PROCEDURE ActualizarAsistencia
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
        PRINT 'ERROR: El registro de asistencia con la combinación de ID_socio, ID_actividad, ID_turno y Fecha especificados no existe.';
        RETURN;
    END

    UPDATE Asistencia.asistencia
    SET Presentismo = ISNULL(@Presentismo, Presentismo)
    WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha;
END;
GO

-- SP para eliminar un registro de asistencia
CREATE PROCEDURE EliminarAsistencia
    @ID_socio INT,
    @ID_actividad INT,
    @ID_turno INT,
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Asistencia.asistencia WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha)
    BEGIN
        PRINT 'ERROR: El registro de asistencia con la combinación de ID_socio, ID_actividad, ID_turno y Fecha especificados no existe.';
        RETURN;
    END

    DELETE FROM Asistencia.asistencia
    WHERE ID_socio = @ID_socio AND ID_actividad = @ID_actividad AND ID_turno = @ID_turno AND Fecha = @Fecha;
END;
GO
