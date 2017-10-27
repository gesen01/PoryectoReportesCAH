--Carga a categorias  de las cuentas contables
INSERT INTO CtaCat(Categoria)
VALUES('Ingresos')
INSERT INTO CtaCat(Categoria)
VALUES('Activos')
INSERT INTO CtaCat(Categoria)
VALUES('Becas')
INSERT INTO CtaCat(Categoria)
VALUES('Gastos')
INSERT INTO CtaCat(Categoria)
VALUES('Finanzas')
--Carga a familias de las cuentas contables
INSERT INTO CtaFam(Familia)
VALUES('Colegiaturas')
INSERT INTO CtaFam(Familia)
VALUES('Inscripciones')
INSERT INTO CtaFam(Familia)
VALUES('Donativos')
INSERT INTO CtaFam(Familia)
VALUES('SEP/UNAM')
INSERT INTO CtaFam(Familia)
VALUES('Consejo')
INSERT INTO CtaFam(Familia)
VALUES('Profesores/Empleados')
INSERT INTO CtaFam(Familia)
VALUES('Personal Administrativo')
INSERT INTO CtaFam(Familia)
VALUES('Personal Docente')
INSERT INTO CtaFam(Familia)
VALUES('Generales')
INSERT INTO CtaFam(Familia)
VALUES('Intereses Inversiones')
INSERT INTO CtaFam(Familia)
VALUES('Otros Ingresos')
INSERT INTO CtaFam(Familia)
VALUES('Intereses Bancarios')
INSERT INTO CtaFam(Familia)
VALUES('Fluctuacion')
INSERT INTO CtaFam(Familia)
VALUES('Subsidio')
--Actualiza la tabla de cuentas contables con su respectiva familia y grupo
UPDATE Cta SET Categoria = 'Ingresos',Familia='Inscripciones'
WHERE Cuenta LIKE '31010-0002%'
UPDATE Cta SET Categoria = 'Ingresos',Familia='Colegiaturas'
WHERE Cuenta LIKE '31010-0001%'
UPDATE Cta SET Categoria = 'Ingresos',Familia='Colegiaturas'
WHERE Cuenta LIKE '11030-0003%'
UPDATE Cta SET Categoria = 'Ingresos',Familia='Colegiaturas'
WHERE Cuenta LIKE '11030-0002%'
UPDATE Cta SET Categoria = 'Activos',Familia='Donativos'
WHERE Cuenta LIKE '31010-0003%'
UPDATE Cta SET Categoria = 'Becas',Familia='SEP/UNAM'
WHERE Cuenta LIKE '31030-0001%'
UPDATE Cta SET Categoria = 'Becas',Familia='SEP/UNAM'
WHERE Cuenta LIKE '31030-0002%'
UPDATE Cta SET Categoria = 'Becas',Familia='Consejo'
WHERE Cuenta LIKE '31030-0003%'
UPDATE Cta SET Categoria = 'Becas',Familia='Profesores/Empleados'
WHERE Cuenta LIKE '31030-0004%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Personal Docente'
WHERE Cuenta LIKE '41010%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Personal Docente'
WHERE Cuenta LIKE '41020%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Personal Docente'
WHERE Cuenta LIKE '41030%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Personal Administrativo'
WHERE Cuenta LIKE '41040%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51010%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51020%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51030%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51040%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51050%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51060%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51070%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51080%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51090%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51100%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51110%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51120%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51130%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51140%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51150%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51160%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51170%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51180%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51190%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51200%'
UPDATE Cta SET Categoria = 'Gastos',Familia='Generales'
WHERE Cuenta LIKE '51210%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Subsidio'
WHERE Cuenta LIKE '31010-0003-001'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Fluctuacion'
WHERE Cuenta LIKE '52030%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Fluctuacion'
WHERE Cuenta LIKE '31020-0001-014%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Intereses Inversiones'
WHERE Cuenta LIKE '31020-0001%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Intereses Bancarios'
WHERE Cuenta LIKE '52010%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Intereses Bancarios'
WHERE Cuenta LIKE '52020%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Otros Ingresos'
WHERE Cuenta LIKE '31020%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Otros Ingresos'
WHERE Cuenta LIKE '51200%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Otros Ingresos'
WHERE Cuenta LIKE '51210%'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Otros Ingresos'
WHERE Cuenta LIKE '31020-0001-011'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Otros Ingresos'
WHERE Cuenta LIKE '31020-0001-012'
UPDATE Cta SET Categoria = 'Finanzas',Familia='Otros Ingresos'
WHERE Cuenta LIKE '51080%'

--Mapeo para la tabla de conversion Jales Contabilidad

INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Inscripciones'
FROM Cta AS c
WHERE Cuenta LIKE '31010-0002%'

INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Colegiaturas recibidas'
FROM Cta AS c
 WHERE Cuenta LIKE '31010-0001%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Col.vencidas no recibidas'
FROM Cta AS c
 WHERE Cuenta LIKE '11030-0001%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Col.vencidas no recibidas'
FROM Cta AS c
 WHERE Cuenta LIKE '11030-0002%'


 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Donativos'
FROM Cta AS c
 WHERE Cuenta LIKE '31010-0003%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Becas SEP/UNAM'
FROM Cta AS c
 WHERE Cuenta LIKE '31030-0001%'

 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Becas SEP/UNAM'
FROM Cta AS c
 WHERE Cuenta LIKE '31030-0002%'
 
  INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Becas Consejo'
FROM Cta AS c
 WHERE Cuenta LIKE '31030-0003%'

INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Becas Prof/Empleados'
FROM Cta AS c
 WHERE Cuenta LIKE '31030-0004%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS PERSONAL DOCENTE'
FROM Cta AS c
 WHERE Cuenta LIKE '41010%'

INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS PERSONAL DOCENTE'
FROM Cta AS c
 WHERE Cuenta LIKE '41020%'

 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS PERSONAL DOCENTE'
FROM Cta AS c
 WHERE Cuenta LIKE '41030%'

 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS PERSONAL ADMINISTRATIVO'
FROM Cta AS c
 WHERE Cuenta LIKE '41040%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51010%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51020%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51030%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51040%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51050%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51060%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51070%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51080%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51090%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51100%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51110%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51120%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51130%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51140%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51150%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51160%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51170%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51180%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51190%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51200%'
 
 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'GASTOS GENERALES'
FROM Cta AS c
 WHERE Cuenta LIKE '51210%'

UPDATE TablaStD SET Valor = 'Subsidio Gob. Alemán'
WHERE TablaSt='JALESContabilidad' AND Nombre='31010-0003-001'


INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Fluctuación cambiaria'
FROM Cta AS c
 WHERE Cuenta LIKE '52030%'
 
INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Intereses y gastos bancarios'
FROM Cta AS c
 WHERE Cuenta LIKE '52010%'

 INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Intereses y gastos bancarios'
FROM Cta AS c
 WHERE Cuenta LIKE '52020%'


INSERT INTO TablaStD
SELECT 'JALESContabilidad',Cuenta,'Otros ingresos y Gastos'
FROM Cta AS c
 WHERE Cuenta LIKE '31020%'
 
UPDATE tablastd SET Valor = 'Intereses sobre inversiones'
WHERE tablast='JALESContabilidad' AND Nombre LIKE '31020-0001%'

UPDATE TablaStD SET Valor = 'Fluctuación cambiaria'
WHERE TablaSt='JALESContabilidad' AND Nombre LIKE '31020-0001-014%'

UPDATE TablaStD SET Valor = 'Otros ingresos y Gastos'
WHERE TablaSt='JALESContabilidad' AND Nombre LIKE '51200%'

UPDATE TablaStD SET Valor = 'Otros ingresos y Gastos'
WHERE TablaSt='JALESContabilidad' AND Nombre LIKE '51210%'

UPDATE TablaStD SET Valor = 'Otros ingresos y Gastos'
WHERE TablaSt='JALESContabilidad' AND Nombre LIKE '31020-0001-012'

UPDATE TablaStD SET Valor = 'Otros ingresos y Gastos'
WHERE TablaSt='JALESContabilidad' AND Nombre LIKE '51080%'

