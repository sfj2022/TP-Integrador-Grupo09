
CREATE TABLE Gestion.area (
  ID_area INT PRIMARY KEY,
  nombre_area VARCHAR(20)
);
GO

ALTER TABLE Gestion.rol
ADD ID_area INT;
GO

ALTER TABLE Gestion.rol
ADD CONSTRAINT FK_rol_area FOREIGN KEY (ID_area) REFERENCES Gestion.area(ID_area);
GO

ALTER TABLE Gestion.Personal
ADD ID_area INT;
GO

ALTER TABLE Gestion.Personal
ADD CONSTRAINT FK_personal_area FOREIGN KEY (ID_area) REFERENCES Gestion.area(ID_area);
GO

INSERT INTO Gestion.area (ID_area, nombre_area)
VALUES 
  (1, 'Tesoreria'),
  (2, 'Socios'),
  (3, 'Autoridades');
GO

INSERT INTO Gestion.rol (ID_rol, nombre, descripcion, ID_area)
VALUES
  (1, 'Jefe de Tesoreria', 'placeholder', 1),
  (2, 'AdminCobranza', 'placeholder', 1),
  (3, 'AdminMorosidad', 'placeholder', 1),
  (4, 'AdminFacturacion', 'placeholder', 1),
  (5, 'AdminSocio', 'placeholder', 2),
  (6, 'Socios Web', 'placeholder', 2),
  (7, 'Presidente', 'placeholder', 3),
  (8, 'Vicepresidente', 'placeholder', 3),
  (9, 'Secretario', 'placeholder', 3),
  (10, 'Vocales', 'placeholder', 3);
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'GallardoLlevoAR1verALaC';
GO

CREATE CERTIFICATE CertEntidad
WITH SUBJECT = 'certificao de encriptacion';
GO

CREATE SYMMETRIC KEY ClaveEntidad
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertEntidad;
GO

ALTER TABLE Finansas.Cuenta
ADD credenciales_encrypted VARBINARY(512);
GO

ALTER TABLE Finansas.factura
ADD DNI_encrypted VARBINARY(128),
    CUIT_encrypted VARBINARY(128);
GO

ALTER TABLE Gestion.Personal
ADD nombre_encrypted VARBINARY(128),
    apellido_encrypted VARBINARY(128),
    DNI_encrypted VARBINARY(128),
    contrasenia_encrypted VARBINARY(256);
GO

OPEN SYMMETRIC KEY ClaveEntidad DECRYPTION BY CERTIFICATE CertEntidad;
GO

UPDATE Finansas.Cuenta
SET credenciales_encrypted = ENCRYPTBYKEY(KEY_GUID('ClaveEntidad'), credenciales);
GO

UPDATE Finansas.factura
SET DNI_encrypted = ENCRYPTBYKEY(KEY_GUID('ClaveEntidad'), DNI),
    CUIT_encrypted = ENCRYPTBYKEY(KEY_GUID('ClaveEntidad'), CUIT);
GO

UPDATE Gestion.Personal
SET nombre_encrypted = ENCRYPTBYKEY(KEY_GUID('ClaveEntidad'), nombre),
    apellido_encrypted = ENCRYPTBYKEY(KEY_GUID('ClaveEntidad'), apellido),
    DNI_encrypted = ENCRYPTBYKEY(KEY_GUID('ClaveEntidad'), DNI),
    contrasenia_encrypted = ENCRYPTBYKEY(KEY_GUID('ClaveEntidad'), contrasenia);
GO

CLOSE SYMMETRIC KEY ClaveEntidad;
GO

OPEN SYMMETRIC KEY ClaveEntidad DECRYPTION BY CERTIFICATE CertEntidad;
GO

SELECT
  ID_socio,
  ID_cuenta,
  CONVERT(VARCHAR(50), DECRYPTBYKEY(credenciales_encrypted)) AS credenciales
FROM Finansas.Cuenta;
GO

SELECT
  ID_personal,
  CONVERT(VARCHAR(50), DECRYPTBYKEY(nombre_encrypted)) AS nombre,
  CONVERT(VARCHAR(50), DECRYPTBYKEY(apellido_encrypted)) AS apellido,
  CONVERT(VARCHAR(8), DECRYPTBYKEY(DNI_encrypted)) AS DNI,
  usuario,
  CONVERT(VARCHAR(32), DECRYPTBYKEY(contrasenia_encrypted)) AS contrasenia
FROM Gestion.Personal;
GO

CLOSE SYMMETRIC KEY ClaveEntidad;
GO

--POLITICA DE RESPALDO
--se tendra un log de transacciones, que registrara todos los cambios de la DB cuando sucedan
--Todos los dias, cuando se cierre el polideportivo, se ejecutara un backup diferencial
--Los sabados, cuando se cierre el polideportivo, se ejecutara un backup completo
--Se utilizara una estrategia 3-2-1, guardandose un backup en el servidor local, y otro en la nube
--RPO: 1 dia






