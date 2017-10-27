--Inserta Categorias CuentasMXN, CuentasUSD, CuentasEUR
INSERT INTO CtaCat(Categoria)
VALUES('CuentasMXN')

INSERT INTO CtaCat(Categoria)
VALUES('CuentasUSD')

INSERT INTO CtaCat(Categoria)
VALUES('CuentasEUR')

--Inserta Familias CtaMXN, CtaUSD, CtaEUR para las cuentas de los bancos del patronato
INSERT INTO CtaFam(Familia)
VALUES('CtaMXN')

INSERT INTO CtaFam(Familia)
VALUES('CtaUSD')

INSERT INTO CtaFam(Familia)
VALUES('CtaEUR')

--Actualiza la tabla de Ctas para asignar la categoria de cuenta para los bancos
UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-001'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-002'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-003'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-004'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-005'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-006'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-007'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-013'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0002-001'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-009'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-008'

UPDATE Cta SET Familia = 'CtaMXN'
WHERE Cuenta='11020-0001-019' AND Categoria='PATRONATO'

UPDATE Cta SET Familia = 'CtaMXN'
WHERE Cuenta='11020-0001-020' AND Categoria='PATRONATO'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-010'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-011'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0001-012'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0002-004'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0002-002'


UPDATE Cta SET Categoria = 'CuentasEUR'
WHERE Cuenta IN (SELECT Cuenta
					FROM Cta AS c
					WHERE c.Descripcion LIKE '%( EUR )%'
					AND C.Categoria IS NULL)

UPDATE Cta SET Familia = 'CtaEUR'
WHERE Cuenta IN (SELECT Cuenta
					FROM Cta AS c
					WHERE c.Descripcion LIKE '%( EUR )%'
					AND C.Categoria='PATRONATO')

UPDATE Cta SET Categoria = 'CuentasUSD'
WHERE Cuenta IN (SELECT Cuenta
					FROM Cta AS c
					WHERE c.Descripcion LIKE '%( USD )%'
					AND C.Categoria IS NULL)

UPDATE Cta SET Familia = 'CtaUSD'
WHERE Cuenta IN (SELECT Cuenta
					FROM Cta AS c
					WHERE c.Descripcion LIKE '%( USD )%'
					AND C.Categoria='PATRONATO')

UPDATE Cta SET Categoria = 'CuentasUSD'
WHERE Cuenta='11020-0001-018'

UPDATE Cta SET Categoria = 'CuentasMXN'
WHERE Cuenta='11020-0002-003'

UPDATE Cta SET Categoria = 'CuentasUSD'
WHERE Cuenta='11020-0003-005'

UPDATE Cta SET Familia = 'CtaUSD'
WHERE Cuenta='11020-0004-002' AND Categoria='PATRONATO'

UPDATE Cta SET Familia = 'CtaUSD'
WHERE Cuenta='11020-0001-022' AND Categoria='PATRONATO'

UPDATE Cta SET Familia = 'CtaMXN'
WHERE Cuenta='11020-0002-006' AND Categoria='PATRONATO'

UPDATE Cta SET Categoria = 'CuentasUSD'
WHERE Cuenta='11020-0003-007'