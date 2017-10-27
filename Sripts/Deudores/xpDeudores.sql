IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpDeudores')
DROP PROCEDURE xpDeudores
GO
CREATE PROCEDURE xpDeudores
@Ejercicio		INT,
@Periodo		INT
AS
BEGIN
	
DECLARE @deudores_tbl TABLE(
	Cuenta				VARCHAR(50),
	SaldoCheques		MONEY,
	SaldoGastos			MONEY,
	SaldoAnticipo		MONEY,
	SaldoOtros			MONEY,
	SaldoPatronato		MONEY,
	Concepto			VARCHAR(150),
	Ejercicio			INT,
	Periodo				INT
)

INSERT INTO @deudores_tbl(Cuenta,SaldoCheques,Concepto,Ejercicio,Periodo)
SELECT c.Cuenta 
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
      ,IIF(c.cuenta LIKE '11050-0003-000','Cheques Devueltos',c.Descripcion) AS 'Descripcion'
      ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Cheques'
AND c.Familia='FamCheques'
AND a.Empresa='CA'
GROUP BY c.cuenta,c.Descripcion
		,a.Ejercicio
		,a.Periodo

INSERT INTO @deudores_tbl(Cuenta,SaldoGastos,Concepto,Ejercicio,Periodo)
SELECT c.Cuenta
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,CASE c.Cuenta
			WHEN '11050-0004-029' THEN 'Caja Kinder Lomas'
			WHEN '11050-0004-008' THEN 'Caja Sur'
			WHEN '11050-0004-011' THEN 'Caja Lomas Verdes'
			WHEN '11050-0004-017' THEN 'Caja Herradura'
			ELSE c.Descripcion
	  END AS 'Descripcion'	
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Gastos'
AND c.Familia IN ('FamGastos')
AND a.Empresa='CA'
AND c.Grupo IS NULL
GROUP BY c.cuenta,c.Descripcion
		,a.Ejercicio
		,a.Periodo
			
			
INSERT INTO @deudores_tbl(Cuenta,SaldoGastos,Concepto,Ejercicio,Periodo)
SELECT '51040-0006-000'
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,c.Descripcion
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Gastos'
AND c.Familia='Generales'
AND c.Grupo IS NULL
AND a.Empresa='CA'
AND c.Cuenta LIKE '51040-0006-000'
GROUP BY c.descripcion,a.Ejercicio
		,a.Periodo
			
INSERT INTO @deudores_tbl(Cuenta,SaldoGastos,Concepto,Ejercicio,Periodo)
SELECT '11050-0004-000'
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,'Gastos a Comprobar Herradura'
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Gastos'
AND c.Familia='FamGastos'
AND c.Grupo='Herradura'
AND a.Empresa='CA'
GROUP BY a.Ejercicio
		,a.Periodo

INSERT INTO @deudores_tbl(Cuenta,SaldoGastos,Concepto,Ejercicio,Periodo)
SELECT '11050-0004-001'
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,'Gastos a Comprobar Kinder Lomas'
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Gastos'
AND c.Familia='FamGastos'
AND c.Grupo='KinderLomas'
AND a.Empresa='CA'
GROUP BY a.Ejercicio
		,a.Periodo

INSERT INTO @deudores_tbl(Cuenta,SaldoGastos,Concepto,Ejercicio,Periodo)
SELECT '11050-0004-002'
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,'Gastos a Comprobar Lomas Verdes'
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Gastos'
AND c.Familia='FamGastos'
AND c.Grupo='LomasVerdes'
AND a.Empresa='CA'
GROUP BY a.Ejercicio
		,a.Periodo

INSERT INTO @deudores_tbl(Cuenta,SaldoGastos,Concepto,Ejercicio,Periodo)
SELECT '11050-0004-003'
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,'Gastos a Comprobar Xochimilco'
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Gastos'
AND c.Familia='FamGastos'
AND c.Grupo='Xochimilco'
AND a.Empresa='CA'
GROUP BY a.Ejercicio
		,a.Periodo

INSERT INTO @deudores_tbl(Cuenta,SaldoAnticipo,Concepto,Ejercicio,Periodo)
SELECT c.Cuenta
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,c.Descripcion
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Anticipo'
AND c.Familia='FamAnticipo'
AND a.Empresa='CA'
GROUP BY c.cuenta,c.Descripcion
		,a.Ejercicio
		,a.Periodo
			
			
INSERT INTO @deudores_tbl(Cuenta,SaldoOtros,Concepto,Ejercicio,Periodo)
SELECT c.Cuenta
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,c.Descripcion
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='Otros'
AND c.Familia='FamOtros'
AND a.Empresa='CA'
GROUP BY c.cuenta,c.Descripcion
		,a.Ejercicio
		,a.Periodo

INSERT INTO @deudores_tbl(Cuenta,SaldoPatronato,Concepto,Ejercicio,Periodo)
SELECT c.Cuenta
	  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	  ,c.Descripcion
	  ,a.Ejercicio
      ,a.Periodo
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria='PATRONATO'
AND c.Familia='FamPatronato'
AND a.Empresa='CA'
GROUP BY c.cuenta,c.Descripcion
		,a.Ejercicio
		,a.Periodo

SELECT * FROM @deudores_tbl


SELECT d.cuenta
	  ,d.Concepto
	  ,d.SaldoCheques
	  ,d.SaldoGastos
	  ,d.SaldoAnticipo
	  ,d.SaldoOtros
	  ,d.SaldoPatronato
	  ,d.Periodo
	  ,ISNULL(d.SaldoCheques,0)+ISNULL(D.SaldoGastos,0)+ISNULL(d.SaldoAnticipo,0)+ISNULL(d.SaldoOtros,0)+ISNULL(d.SaldoPatronato,0) AS 'TOTAL'	
FROM @deudores_tbl d
WHERE Ejercicio=@Ejercicio
AND Periodo=@Periodo
ORDER BY d.Concepto

END 

--EXEC xpDeudores 2016,2