--Crea las categorias 'Cheques','Gastos','Anticipo','Otros'
INSERT INTO CtaCat(Categoria)
VALUES('Cheques')

INSERT INTO CtaCat(Categoria)
VALUES('Gastos')

INSERT INTO CtaCat(Categoria)
VALUES('Anticipo')

INSERT INTO CtaCat(Categoria)
VALUES('Otros')
--Crea las familias de deudores 'FamCheques','FamGastos','FamAnticipo','FamOtros','FamPatronato'
INSERT INTO CtaFam(Familia)
VALUES('FamCheques')

INSERT INTO CtaFam(Familia)
VALUES('FamGastos')

INSERT INTO CtaFam(Familia)
VALUES('FamAnticipo')

INSERT INTO CtaFam(Familia)
VALUES('FamOtros')

INSERT INTO CtaFam(Familia)
VALUES('FamPatronato')

INSERT INTO CtaGrupo(Grupo)
VALUES('Herradura')

INSERT INTO CtaGrupo(Grupo)
VALUES('KinderLomas')

INSERT INTO CtaGrupo(Grupo)
VALUES('LomasVerdes')

INSERT INTO CtaGrupo(Grupo)
VALUES('Xochimilco')
--Actualiza la tabla de cuentas contable con las categorias y familias correspondientes a los deudores

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN ('11050-0002-016','11050-0002-014','11050-0002-017'
                 ,'11050-0002-018','51040-0006-000','11050-0005-000'
                 ,'11050-0005-001','11050-0004-004','11050-0004-005'
				 ,'11050-0004-001','11050-0004-002','11010-0016-000'
				 ,'11010-0017-000','11010-0018-000','11010-0019-000')

UPDATE Cta SET Categoria = 'Cheques', Familia = 'FamCheques'
WHERE Cuenta IN ('11050-0003-000','11050-0003-001','11050-0003-002'
				 ,'11050-0003-003','11050-0003-004')
				 
UPDATE Cta SET Categoria = '', Familia = ''
WHERE Cuenta IN ('11050-0003-001','11050-0003-002'
				 ,'11050-0003-003','11050-0003-004')

UPDATE Cta SET Categoria = 'Otros', Familia = 'FamOtros'
WHERE Cuenta IN ('11050-0002-003','11050-0001-001','11050-0002-004'
				 ,'11050-0002-005','11050-0002-027','11050-0001-002'
				 ,'11050-0002-012','11050-0002-001','11050-0002-007'
				 ,'11050-0002-019','11050-0002-020','11050-0002-021')

UPDATE Cta SET Categoria = 'PATRONATO', Familia = 'FamPatronato'
WHERE Cuenta IN ('11050-0002-002')

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta LIKE '11050-0004-028'

UPDATE Cta SET Categoria='Anticipo', Familia='FamAnticipo'
WHERE Cuenta LIKE '11050-0002-032'

UPDATE Cta SET Categoria = 'Otros', Familia = 'FamOtros'
WHERE Cuenta LIKE '11050-0002-032'

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta LIKE '11050-0002-006'

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN('11050-0004-024','11050-0004-021')

UPDATE Cta SET Grupo='Herradura'
WHERE Cuenta IN('11050-0004-024','11050-0004-021','11050-0004-004')

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN('11050-0004-023')

UPDATE Cta SET Grupo='KinderLomas'
WHERE Cuenta IN('11050-0004-005','11050-0004-023')

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN('11050-0004-003')

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN('11050-0004-020','11050-0004-027','11050-0004-001')

UPDATE Cta SET Grupo='LomasVerdes'
WHERE Cuenta IN('11050-0004-020','11050-0004-027','11050-0004-001')

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN('11050-0004-002','11050-0004-015','11050-0004-019','11050-0004-022')

UPDATE Cta SET Grupo='Xochimilco'
WHERE Cuenta IN('11050-0004-002','11050-0004-015','11050-0004-019','11050-0004-022')

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN('11050-0004-018')

UPDATE Cta SET Categoria = 'Gastos', Familia = 'FamGastos'
WHERE Cuenta IN('11050-0004-017','11050-0004-011','11050-0004-008','11050-0004-029')

UPDATE Cta SET Categoria = '', Familia = ''
WHERE Cuenta IN('11010-0017-000','11010-0018-000','11010-0016-000','11010-0019-000')

UPDATE Cta SET Categoria = 'Otros', Familia = 'FamOtros'
WHERE Cuenta IN('11050-0002-031')

SELECT *
FROM Cta AS c