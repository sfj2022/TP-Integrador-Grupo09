USE SolNorteDB

GO

EXEC InsertarPersonal 101, 1, 'Romina', 'Correa', '12345678', 'rcorrea01', 'Passw0rd!001';
EXEC InsertarPersonal 102, 2, 'Lucas', 'Méndez', '23456789', 'lmendez02', 'ClaveSegura#102';
EXEC InsertarPersonal 103, 3, 'Noelia', 'Bravo', '34567890', 'nbravo03', 'NoePass!103';
EXEC InsertarPersonal 104, 1, 'Federico', 'Acosta', '45678901', 'facosta04', 'Segura104!';
EXEC InsertarPersonal 105, 2, 'Micaela', 'Bustos', '56789012', 'mbustos05', 'Clave2025$';
EXEC InsertarPersonal 106, 3, 'Tomás', 'Reyes', '67890123', 'treyes06', 'Rey3s!106';
EXEC InsertarPersonal 107, 1, 'Carla', 'Serrano', '78901234', 'cserrano07', 'CarlaS#107';
EXEC InsertarPersonal 108, 2, 'Ignacio', 'Páez', '89012345', 'ipaez08', 'Ign@2025';
EXEC InsertarPersonal 109, 3, 'Martina', 'Benítez', '90123456', 'mbenitez09', 'Marti*109';
EXEC InsertarPersonal 110, 1, 'Joaquín', 'Funes', '01234567', 'jfunes10', 'Joaq-F2025';
EXEC InsertarPersonal 111, 2, 'Lucía', 'Morales', '11223344', 'lmorales11', 'ClaveFirme11';
EXEC InsertarPersonal 112, 3, 'Gabriel', 'Herrera', '22334455', 'gherrera12', 'G@briel112';
EXEC InsertarPersonal 113, 1, 'Sofía', 'Chávez', '33445566', 'schavez13', 'Sofi_C#113';
EXEC InsertarPersonal 114, 2, 'Matías', 'Toledo', '44556677', 'mtoledo14', 'Toledo!114';
EXEC InsertarPersonal 115, 3, 'Brenda', 'Vera', '55667788', 'bvera15', 'Pass115$';
EXEC InsertarPersonal 116, 1, 'Alejandro', 'Silva', '66778899', 'asilva16', 'AleSilva*116';
EXEC InsertarPersonal 117, 2, 'Natalia', 'Cardozo', '77889900', 'ncardozo17', 'Nata#117';
EXEC InsertarPersonal 118, 3, 'Diego', 'Ríos', '88990011', 'drios18', 'DRios@2025';
EXEC InsertarPersonal 119, 1, 'Belén', 'Ramírez', '99001122', 'bramirez19', 'Bel3nPass19';
EXEC InsertarPersonal 120, 2, 'Hernán', 'Giménez', '10111213', 'hgimenez20', 'HernanG$120';

GO
select * from Gestion.rol
EXEC InsertarRol 1, 'Administrador', 'Acceso total al sistema, incluyendo gestión de usuarios, roles y auditorías.';
EXEC InsertarRol 2, 'Supervisor', 'Puede supervisar reportes, gestionar actividades y autorizar accesos restringidos.';
EXEC InsertarRol 3, 'Recepcionista', 'Encargado del ingreso de personas, control de turnos y validación de credenciales.';
EXEC InsertarRol 4, 'Cajero', 'Procesa pagos, emite recibos y genera reportes financieros diarios.';
EXEC InsertarRol 5, 'Instructor', 'Asigna actividades, toma asistencia y guía a los participantes.';
EXEC InsertarRol 6, 'Seguridad', 'Verifica accesos, controla perímetros y colabora con la recepción.';
EXEC InsertarRol 7, 'Mantenimiento', 'Reporta y soluciona problemas técnicos e infraestructurales.';
EXEC InsertarRol 8, 'Soporte', 'Asiste a usuarios en el uso del sistema y canaliza incidencias técnicas.';
EXEC InsertarRol 9, 'Coordinador', 'Gestiona equipos de trabajo, distribuye tareas y supervisa cronogramas.';
EXEC InsertarRol 10, 'Analista', 'Genera estadísticas, interpreta datos y propone mejoras operativas.';
EXEC InsertarRol 11, 'Auditor', 'Revisa registros, valida transacciones y controla cumplimiento de procesos.';
EXEC InsertarRol 12, 'Limpieza', 'Responsable de la higiene y presentación de todas las instalaciones.';
EXEC InsertarRol 13, 'Recursos', 'Gestiona recursos humanos, nómina y relaciones internas.';
EXEC InsertarRol 14, 'Marketing', 'Encargado de la comunicación institucional y campañas digitales.';
EXEC InsertarRol 15, 'Logística', 'Organiza materiales, movimientos internos y distribución de recursos.';
EXEC InsertarRol 16, 'Asistente', 'Brinda soporte administrativo, documenta procesos y realiza tareas generales.';
EXEC InsertarRol 17, 'Operador', 'Ejecuta operaciones rutinarias y colabora en múltiples áreas del sistema.';
EXEC InsertarRol 18, 'Contador', 'Supervisa transacciones contables y asegura la coherencia financiera.';
EXEC InsertarRol 19, 'Técnico', 'Realiza instalaciones, pruebas y mantenimiento de hardware o software.';
EXEC InsertarRol 20, 'Becario', 'Rol formativo con acceso limitado, bajo supervisión directa.';


gO



EXEC InsertarAcOtraTurno 101, 1, 'Mañana - 08:00 a 09:30';
EXEC InsertarAcOtraTurno 102, 1, 'Tarde - 14:00 a 15:30';
EXEC InsertarAcOtraTurno 103, 1, 'Noche - 20:00 a 21:30';
EXEC InsertarAcOtraTurno 101, 2, 'Mañana - 10:00 a 11:30';
EXEC InsertarAcOtraTurno 102, 2, 'Tarde - 16:00 a 17:30';
EXEC InsertarAcOtraTurno 103, 2, 'Noche - 18:00 a 19:30';
EXEC InsertarAcOtraTurno 101, 3, 'Mañana Extendida - 09:00 a 11:00';
EXEC InsertarAcOtraTurno 102, 3, 'Tarde Intensiva - 13:00 a 15:00';
EXEC InsertarAcOtraTurno 103, 3, 'Noche Activa - 19:30 a 21:00';
EXEC InsertarAcOtraTurno 104, 1, 'Mañana Yoga - 07:00 a 08:30';
EXEC InsertarAcOtraTurno 104, 2, 'Tarde Funcional - 17:00 a 18:30';
EXEC InsertarAcOtraTurno 104, 3, 'Noche Pilates - 20:30 a 22:00';
EXEC InsertarAcOtraTurno 105, 1, 'Mañana Cardio - 06:30 a 08:00';
EXEC InsertarAcOtraTurno 105, 2, 'Tarde Boxeo - 15:30 a 17:00';
EXEC InsertarAcOtraTurno 105, 3, 'Noche CrossFit - 21:00 a 22:30';
EXEC InsertarAcOtraTurno 106, 1, 'Inicio Rápido - 08:15 a 09:00';
EXEC InsertarAcOtraTurno 106, 2, 'Media Tarde - 12:00 a 13:30';
EXEC InsertarAcOtraTurno 106, 3, 'Cierre Relajado - 19:00 a 20:30';
EXEC InsertarAcOtraTurno 107, 1, 'Turno Libre - 11:00 a 12:30';
EXEC InsertarAcOtraTurno 108, 1, 'Especial Seniors - 09:00 a 10:30';

GO

EXEC InsertarMedioDePago 1, 'Mercado Pago';
EXEC InsertarMedioDePago 2, 'Transferencia Bancaria';
EXEC InsertarMedioDePago 3, 'Pago Fácil';
EXEC InsertarMedioDePago 4, 'Rapipago';
EXEC InsertarMedioDePago 5, 'Tarjeta de Crédito';
EXEC InsertarMedioDePago 6, 'Tarjeta de Débito';
EXEC InsertarMedioDePago 7, 'Efectivo';
EXEC InsertarMedioDePago 8, 'Cuenta DNI';
EXEC InsertarMedioDePago 9, 'Billetera Virtual';
EXEC InsertarMedioDePago 10, 'Link Pagos';
EXEC InsertarMedioDePago 11, 'Cobro Express';
EXEC InsertarMedioDePago 12, 'PagoMisCuentas';
EXEC InsertarMedioDePago 13, 'Cupo Social';
EXEC InsertarMedioDePago 14, 'Crédito en Cuenta';
EXEC InsertarMedioDePago 15, 'Pago Automático';
EXEC InsertarMedioDePago 16, 'Saldo a Favor';
EXEC InsertarMedioDePago 17, 'Descuento Directo';
EXEC InsertarMedioDePago 18, 'Débito Automático';
EXEC InsertarMedioDePago 19, 'Plataforma Interna';
EXEC InsertarMedioDePago 20, 'Convenio Especial';


--SELECT * FROM Persona.Socio;   --
--SELECT * FROM Persona.SocioTelefonos;--
--SELECT * FROM Persona.SocioEmergencia; --
--SELECT * FROM Persona.Invitado;--
--SELECT * FROM Persona.responsabilidad;  --
 
--SELECT * FROM Gestion.rol;    --
--SELECT * FROM Gestion.Personal;  --

--SELECT * FROM Actividades.Membresia;  --
--SELECT * FROM Actividades.Inscripcion_Socio;--
--SELECT * FROM Actividades.Actividades_Deportivas;  --
--SELECT * FROM Actividades.Actividades_Otras;  --
--SELECT * FROM Actividades.AcDep_turnos;    ---
--SELECT * FROM Actividades.AcOtra_turnos;
---SELECT * FROM Actividades.Inscripcion_Deportiva;  --
--SELECT * FROM Actividades.Inscripcion_Otra;  

--SELECT * FROM Finansas.MedioDePago; ---
--SELECT * FROM Finansas.Cuenta;   ---
--SELECT * FROM Finansas.Cuota;   --
--SELECT * FROM Finansas.factura;  --
--SELECT * FROM Finansas.detalle_factura;--
--SELECT * FROM Finansas.cobro;       --
--SELECT * FROM Finansas.reembolso;--

--SELECT * FROM Asistencia.dias;       --
--SELECT * FROM Asistencia.asistencia; --



GO

EXEC InsertarReembolso 
    @ID_factura = 1, 
    @ID_socio = 4001, 
    @ID_cuenta = 1, 
    @Costo = 2500.00, 
    @Estado = 0;

EXEC InsertarReembolso 
    @ID_factura = 2, 
    @ID_socio = 4002, 
    @ID_cuenta = 2, 
    @Costo = 3200.00, 
    @Estado = 1;
GO
-- Actividades
INSERT INTO Actividades.Actividades_Otras (ID_actividad, Nombre, TipoDuracion, TipoPersona, Condicion, costo)
VALUES (101, 'Yoga', 'Día', 'Adulto', 'Invitado', 250.00),
       (102, 'Cocina', 'Mes', 'Adulto', 'Invitado', 1500.00);

-- Bancos
INSERT INTO Finansas.MedioDePago (ID_banco, nombre)
VALUES (10, 'Banco Nación'),
       (11, 'MercadoPago');


GO
EXEC InsertarInvitado '11112222', '2025-06-15', 4001, 'Ana', 'López', 101, 10, 'MP-1111';
EXEC InsertarInvitado '11112223', '2025-06-14', 4002, 'Pablo', 'Martín', 102, 11, 'BN-2222';
EXEC InsertarInvitado '11112224', '2025-06-10', 4003, 'Luis', 'Fernández', 101, 10, 'MP-3333';
EXEC InsertarInvitado '11112225', '2025-06-05', 4001, 'Romina', 'Gómez', 102, 11, 'BN-4444';
EXEC InsertarInvitado '11112226', '2025-06-20', 4002, 'Ezequiel', 'Alvarez', 101, 10, 'MP-5555';
EXEC InsertarInvitado '11112227', '2025-06-18', 4005, 'Joaquín', 'Herrera', 102, 11, 'BN-6666';
EXEC InsertarInvitado '11112228', '2025-06-12', 4003, 'Natalia', 'Soria', 101, 10, 'MP-7777';
EXEC InsertarInvitado '11112229', '2025-06-11', 4004, 'Carlos', 'Medina', 102, 11, 'BN-8888';
EXEC InsertarInvitado '11112230', '2025-06-09', 4005, 'Cecilia', 'Torres', 101, 10, 'MP-9999';
EXEC InsertarInvitado '11112231', '2025-06-06', 4002, 'Martina', 'Bravo', 102, 11, 'BN-0000';
EXEC InsertarInvitado '11112232', '2025-06-08', 4004, 'Sergio', 'Vera', 101, 10, 'MP-1212';
EXEC InsertarInvitado '11112233', '2025-06-07', 4001, 'Julieta', 'Paz', 102, 11, 'BN-1313';
EXEC InsertarInvitado '11112234', '2025-06-03', 4003, 'Ignacio', 'Reyes', 101, 10, 'MP-1414';
EXEC InsertarInvitado '11112235', '2025-06-02', 4005, 'Valeria', 'Ojeda', 102, 11, 'BN-1515';
EXEC InsertarInvitado '11112236', '2025-06-01', 4001, 'Matías', 'Campos', 101, 10, 'MP-1616';
EXEC InsertarInvitado '11112237', '2025-05-30', 4002, 'Estela', 'Molina', 102, 11, 'BN-1717';
EXEC InsertarInvitado '11112238', '2025-05-29', 4004, 'Diego', 'Acosta', 101, 10, 'MP-1818';
EXEC InsertarInvitado '11112239', '2025-05-28', 4005, 'Laura', 'Ríos', 102, 11, 'BN-1919';
EXEC InsertarInvitado '11112240', '2025-05-27', 4003, 'Camila', 'Silva', 101, 10, 'MP-2020';
EXEC InsertarInvitado '11112241', '2025-05-26', 4002, 'Ricardo', 'Funes', 102, 11, 'BN-2121';

GO
EXEC InsertarInscripcionSocio 4001, 1001, 1, '2024-12-10', NULL;
EXEC InsertarInscripcionSocio 4002, 1002, 2, '2025-01-15', '2025-06-15';
EXEC InsertarInscripcionSocio 4003, 1003, 3, '2023-09-01', NULL;
EXEC InsertarInscripcionSocio 4004, 1004, 1, '2024-11-20', NULL;
EXEC InsertarInscripcionSocio 4005, 1005, 2, '2024-08-05', NULL;

EXEC InsertarInscripcionSocio 4001, 1006, 3, '2025-02-01', '2025-05-10';
EXEC InsertarInscripcionSocio 4002, 1007, 1, '2024-10-12', NULL;
EXEC InsertarInscripcionSocio 4003, 1008, 2, '2023-06-25', '2024-06-25';
EXEC InsertarInscripcionSocio 4004, 1009, 3, '2024-01-01', NULL;
EXEC InsertarInscripcionSocio 4005, 1010, 1, '2024-03-14', NULL;

EXEC InsertarInscripcionSocio 4001, 1011, 2, '2025-03-01', NULL;
EXEC InsertarInscripcionSocio 4002, 1012, 3, '2023-12-12', NULL;
EXEC InsertarInscripcionSocio 4003, 1013, 1, '2024-09-15', NULL;
EXEC InsertarInscripcionSocio 4004, 1014, 2, '2023-11-30', NULL;
EXEC InsertarInscripcionSocio 4005, 1015, 3, '2024-02-28', '2024-09-30';

GO
-- Actividades_Otras (si no existen aún)
INSERT INTO Actividades.Actividades_Otras (ID_actividad, Nombre, TipoDuracion, TipoPersona, Condicion, costo)
VALUES (201, 'Ajedrez', 'Mes', 'Adulto', 'Socio', 1200.00),
       (202, 'Cine Debate', 'Día', 'Adulto', 'Socio', 800.00),
       (203, 'Teatro', 'Temporada', 'Menor', 'Socio', 1800.00);

-- Turnos para cada actividad
INSERT INTO Actividades.AcOtra_turnos (ID_actividad, ID_turno, turno)
VALUES 
(201, 1, 'Lunes 18:00'),
(201, 2, 'Miércoles 20:00'),
(202, 1, 'Viernes 17:00'),
(202, 2, 'Sábado 14:00'),
(203, 1, 'Martes 19:00'),
(203, 2, 'Domingo 16:00');


GO
-- Para la actividad 101 (Yoga - Día - Adulto - Invitado)
EXEC InsertarAcOtraTurno @ID_actividad = 101, @ID_turno = 1, @turno = 'Martes 10:00 hs';

-- Para la actividad 102 (Cocina - Mes - Adulto - Invitado)
EXEC InsertarAcOtraTurno @ID_actividad = 102, @ID_turno = 1, @turno = 'Viernes 18:30 hs';

-- Para la actividad 1 (Pileta - Día - Adulto - Socio)
EXEC InsertarAcOtraTurno @ID_actividad = 1, @ID_turno = 1, @turno = 'Turno Mañana';

-- Para la actividad 2 (Pileta - Día - Adulto - Invitado)
EXEC InsertarAcOtraTurno @ID_actividad = 2, @ID_turno = 1, @turno = 'Turno Tarde';

-- Para la actividad 5 (Pileta - Temporada - Adulto - Socio)
EXEC InsertarAcOtraTurno @ID_actividad = 5, @ID_turno = 1, @turno = 'Temporada Alta';

-- Para la actividad 7 (Pileta - Mes - Adulto - Socio)
EXEC InsertarAcOtraTurno @ID_actividad = 7, @ID_turno = 1, @turno = 'Mes Julio - Socios';

-- Para la actividad 8 (Pileta - Mes - Menor - Socio)
EXEC InsertarAcOtraTurno @ID_actividad = 8, @ID_turno = 2, @turno = 'Mes Julio - Menores';

GO


EXEC InsertarInscripcionOtra 4001, 2001, 201, 1, '2024-12-01', NULL;
EXEC InsertarInscripcionOtra 4002, 2002, 201, 2, '2024-11-20', NULL;
EXEC InsertarInscripcionOtra 4003, 2003, 202, 1, '2024-10-15', NULL;
EXEC InsertarInscripcionOtra 4004, 2004, 203, 1, '2024-09-01', NULL;
EXEC InsertarInscripcionOtra 4005, 2005, 203, 2, '2024-08-28', NULL;

EXEC InsertarInscripcionOtra 4006, 2006, 201, 1, '2024-11-01', '2025-02-01';
EXEC InsertarInscripcionOtra 4007, 2007, 202, 2, '2024-07-01', NULL;
EXEC InsertarInscripcionOtra 4008, 2008, 203, 1, '2024-06-01', NULL;
EXEC InsertarInscripcionOtra 4009, 2009, 201, 2, '2024-05-10', NULL;
EXEC InsertarInscripcionOtra 4010, 2010, 202, 1, '2024-04-01', '2024-10-01';

EXEC InsertarInscripcionOtra 4001, 2011, 203, 2, '2024-03-15', NULL;
EXEC InsertarInscripcionOtra 4002, 2012, 202, 2, '2024-02-01', NULL;
EXEC InsertarInscripcionOtra 4003, 2013, 201, 1, '2024-01-10', NULL;
EXEC InsertarInscripcionOtra 4004, 2014, 202, 1, '2023-12-20', NULL;
EXEC InsertarInscripcionOtra 4005, 2015, 203, 1, '2023-11-05', NULL;

EXEC InsertarInscripcionOtra 4006, 2016, 201, 2, '2023-10-10', NULL;
EXEC InsertarInscripcionOtra 4007, 2017, 202, 1, '2023-09-15', NULL;
EXEC InsertarInscripcionOtra 4008, 2018, 203, 2, '2023-08-01', NULL;
EXEC InsertarInscripcionOtra 4009, 2019, 201, 1, '2023-07-07', NULL;
EXEC InsertarInscripcionOtra 4010, 2020, 202, 2, '2023-06-03', NULL;

GO
-- Cuotas de membresía
EXEC InsertarCuota 9001, 4001, 1001, 5001, 'socio', '2024-12-15', '2025-01-15', '2025-02-15', 25000, 0, 0, 'impago';
EXEC InsertarCuota 9002, 4001, 1006, 5002, 'socio', '2025-02-10', '2025-03-10', '2025-03-25', 10000, 0, 500, 'pago';
EXEC InsertarCuota 9003, 4002, 1002, 5003, 'socio', '2025-01-20', '2025-02-20', '2025-03-01', 15000, 200, 0, 'vencido1';
EXEC InsertarCuota 9004, 4003, 1003, 5004, 'socio', '2023-10-01', '2023-11-01', '2023-11-15', 10000, 0, 0, 'pago';
EXEC InsertarCuota 9005, 4005, 1010, 5005, 'socio', '2024-04-01', '2024-05-01', '2024-05-15', 25000, 0, 1000, 'vencido2';

-- Cuotas deportivas
EXEC InsertarCuota 9006, 4001, 514, 5006, 'deporte', '2025-01-10', '2025-01-25', '2025-02-10', 5000, 0, 0, 'pago';
EXEC InsertarCuota 9007, 4002, 820, 5007, 'deporte', '2025-01-12', '2025-01-28', '2025-02-15', 5000, 0, 100, 'impago';

-- Cuotas de otras actividades
EXEC InsertarCuota 9008, 4003, 2003, 5008, 'otra', '2024-10-20', '2024-11-20', '2024-12-01', 1500, 50, 0, 'pago';
EXEC InsertarCuota 9009, 4001, 2001, 5009, 'otra', '2024-12-05', '2025-01-05', '2025-01-20', 1200, 0, 200, 'vencido1';
EXEC InsertarCuota 9010, 4004, 2014, 5010, 'otra', '2023-12-25', '2024-01-25', '2024-02-05', 800, 0, 0, 'impago';

-- Más cuotas de membresía
EXEC InsertarCuota 9011, 4004, 1014, 5011, 'socio', '2024-01-05', '2024-02-05', '2024-02-20', 15000, 500, 0, 'pago';
EXEC InsertarCuota 9012, 4003, 1013, 5012, 'socio', '2024-10-01', '2024-11-01', '2024-11-20', 25000, 0, 1500, 'impago';

-- Más cuotas deportivas
EXEC InsertarCuota 9013, 4001, 515, 5013, 'deporte', '2025-01-11', '2025-01-26', '2025-02-11', 5000, 0, 0, 'vencido2';
EXEC InsertarCuota 9014, 4002, 821, 5014, 'deporte', '2025-01-13', '2025-01-27', '2025-02-12', 5000, 150, 0, 'pago';

-- Más cuotas de otras actividades
EXEC InsertarCuota 9015, 4002, 2012, 5015, 'otra', '2024-02-05', '2024-03-05', '2024-03-15', 800, 0, 0, 'vencido2';
EXEC InsertarCuota 9016, 4003, 2013, 5016, 'otra', '2024-01-15', '2024-02-15', '2024-03-01', 1200, 0, 50, 'pago';
EXEC InsertarCuota 9017, 4005, 2015, 5017, 'otra', '2023-11-10', '2023-12-10', '2023-12-20', 1800, 0, 100, 'impago';

-- Extras mixtas
EXEC InsertarCuota 9018, 4005, 1005, 5018, 'socio', '2024-08-10', '2024-09-10', '2024-09-25', 15000, 0, 750, 'pago';
EXEC InsertarCuota 9019, 4001, 1435, 5019, 'deporte', '2025-01-20', '2025-02-20', '2025-03-01', 5000, 0, 250, 'impago';
EXEC InsertarCuota 9020, 4001, 2011, 5020, 'otra', '2024-03-20', '2024-04-20', '2024-05-01', 1500, 0, 0, 'vencido1';

GO







EXEC InsertarFactura 
    @ID_factura = 6001, 
    @DNI = '27169626', 
    @CUIT = '27-27169626-5', 
    @FechaYHora = '2025-06-30 10:00:00', 
    @costo = 25000.00, 
    @estado = 0;

EXEC InsertarFactura 
    @ID_factura = 6002, 
    @DNI = '29324246', 
    @CUIT = '20-29324246-3', 
    @FechaYHora = '2025-06-28 14:30:00', 
    @costo = 18000.00, 
    @estado = 1;

EXEC InsertarFactura 
    @ID_factura = 6003, 
    @DNI = '23381679', 
    @CUIT = '27-23381679-4', 
    @FechaYHora = '2025-06-25 17:45:00', 
    @costo = 12000.00, 
    @estado = 0;

	-- Para factura 6001 (DNI 27169626 - SILVIA VIVIANA)
EXEC InsertarDetalleFactura 6001, 9001, 1001, 'socio', 25000.00, 0.00, 0.00;
EXEC InsertarDetalleFactura 6001, 9019, 1435, 'deporte', 5000.00, 0.00, 250.00;
EXEC InsertarDetalleFactura 6001, 9020, 2011, 'otra', 1500.00, 0.00, 0.00;

-- Para factura 6002 (DNI 29324246 - SERGIO JAVIER)
EXEC InsertarDetalleFactura 6002, 9003, 1002, 'socio', 15000.00, 200.00, 0.00;
EXEC InsertarDetalleFactura 6002, 9007, 820, 'deporte', 5000.00, 0.00, 100.00;
EXEC InsertarDetalleFactura 6002, 9015, 2012, 'otra', 800.00, 0.00, 0.00;

-- Para factura 6003 (DNI 23381679 - SAMANTA L)
EXEC InsertarDetalleFactura 6003, 9011, 1014, 'socio', 15000.00, 500.00, 0.00;
EXEC InsertarDetalleFactura 6003, 9010, 2014, 'otra', 800.00, 0.00, 0.00;


GO
EXEC InsertarReembolso 
    @ID_factura = 1, 
    @ID_socio = 4001, 
    @ID_cuenta = 1, 
    @Costo = 2500.00, 
    @Estado = 0;

EXEC InsertarReembolso 
    @ID_factura = 2, 
    @ID_socio = 4002, 
    @ID_cuenta = 2, 
    @Costo = 3200.00, 
    @Estado = 1;

	-- Socio 4001 - Cuotas vencidas por inscripción 1001
EXEC InsertarCuota 9101, 4001, 1001, 5101, 'socio', '2024-03-01', '2024-04-01', '2024-04-15', 25000.00, 0.00, 0.00, 'vencido1';
EXEC InsertarCuota 9102, 4001, 1001, 5102, 'socio', '2024-04-01', '2024-05-01', '2024-05-15', 25000.00, 100.00, 0.00, 'vencido2';

-- Socio 4002 - Cuotas vencidas por inscripción 1002
EXEC InsertarCuota 9103, 4002, 1002, 5103, 'socio', '2024-01-10', '2024-02-10', '2024-03-01', 15000.00, 0.00, 0.00, 'vencido1';
EXEC InsertarCuota 9104, 4002, 1002, 5104, 'socio', '2024-02-15', '2024-03-15', '2024-04-01', 15000.00, 200.00, 0.00, 'vencido2';

-- Socio 4003 - Cuotas vencidas por inscripción 1003
EXEC InsertarCuota 9105, 4003, 1003, 5105, 'socio', '2023-11-01', '2023-12-01', '2023-12-20', 10000.00, 0.00, 0.00, 'vencido1';
EXEC InsertarCuota 9106, 4003, 1003, 5106, 'socio', '2023-12-15', '2024-01-15', '2024-01-30', 10000.00, 0.00, 0.00, 'vencido2';

-- Socio 4004 - Cuotas vencidas por inscripción 1004
EXEC InsertarCuota 9107, 4004, 1004, 5107, 'socio', '2024-02-01', '2024-03-01', '2024-03-15', 25000.00, 50.00, 100.00, 'vencido1';
EXEC InsertarCuota 9108, 4004, 1004, 5108, 'socio', '2024-03-15', '2024-04-15', '2024-04-30', 25000.00, 150.00, 200.00, 'vencido2';

-- Socio 4005 - Cuotas vencidas por inscripción 1005
EXEC InsertarCuota 9109, 4005, 1005, 5109, 'socio', '2024-06-01', '2024-07-01', '2024-07-15', 15000.00, 0.00, 0.00, 'vencido1';
EXEC InsertarCuota 9110, 4005, 1005, 5110, 'socio', '2024-07-10', '2024-08-10', '2024-08-25', 15000.00, 0.00, 0.00, 'vencido2';

-- Socio 4001 - tercera cuota vencida
EXEC InsertarCuota 9111, 4001, 1001, 5111, 'socio', '2024-05-01', '2024-06-01', '2024-06-15', 25000.00, 150.00, 0.00, 'vencido2';

-- Socio 4002 - tercera cuota vencida
EXEC InsertarCuota 9112, 4002, 1002, 5112, 'socio', '2024-03-01', '2024-04-01', '2024-04-15', 15000.00, 0.00, 0.00, 'vencido2';

-- Socio 4003 - tercera cuota vencida
EXEC InsertarCuota 9113, 4003, 1003, 5113, 'socio', '2024-02-01', '2024-03-01', '2024-03-15', 10000.00, 100.00, 0.00, 'vencido1';

-- Socio 4004 - tercera cuota vencida
EXEC InsertarCuota 9114, 4004, 1004, 5114, 'socio', '2024-05-01', '2024-06-01', '2024-06-15', 25000.00, 200.00, 0.00, 'vencido2';

-- Socio 4005 - tercera cuota vencida
EXEC InsertarCuota 9115, 4005, 1005, 5115, 'socio', '2024-09-01', '2024-10-01', '2024-10-15', 15000.00, 0.00, 0.00, 'vencido2';


