IF EXISTS(SELECT * FROM sysobjects AS s WHERE s.[type]='p' AND s.name='xpGerencias')
DROP PROCEDURE xpGerencias
GO
CREATE PROCEDURE xpGerencias
@Ejercicio	INT,
@Periodo	INT
AS
BEGIN
	
	DECLARE @Gerencias_tbl TABLE (
			Cuenta			VARCHAR(20),
			Concepto		VARCHAR(100)
	)

	DECLARE @GerenciaColegio_tbl TABLE (
			Concepto		VARCHAR(100),
			Saldo			MONEY,
			Sucursal		VARCHAR(40),
			CentroCosto		VARCHAR(50)
	)

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Horas Adicionales profesores' 
	FROM Cta AS c
	WHERE c.cuenta IN ('41010-0001-004','41020-0001-004')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Tiempo extra administración' 
	FROM Cta AS c
	WHERE c.cuenta IN ('41040-0001-023','41040-0001-024')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Capacitación' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0001-000','51030-0017-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Aseo y limpieza' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0002-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Vigilancia' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0003-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Material Didactico en $' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0004-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Actividades Escolares' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0005-000','51030-0015-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Pasajes y transportes' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0006-000','51030-0016-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Viajes y representación en $' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0007-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Viajes y Representación EUR' 
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0008-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Energía eléctrica'
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0009-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Combustible'
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0010-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Agua'
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0011-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Correo y teléfono'
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0012-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Gastos no deducibles'
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0019-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Serv. Computo y copiadoras'
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0013-000')

	INSERT INTO @Gerencias_tbl
	SELECT c.Cuenta
		   ,'Diversos'
	FROM Cta AS c
	WHERE c.cuenta IN ('51030-0014-000','51030-0018-000');

	
	WITH gc_tbl
	AS
	(
		SELECT a.Cuenta 
			  ,SUM(ISNULL(a.Cargos,0)-ISNULL(a.Abonos,0)) AS 'Saldo'
			  ,cc.Grupo
			  ,cc.Descripcion
		FROM Acum AS a
		JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE a.SubCuenta <> '06'
		AND a.Ejercicio=@Ejercicio
		AND a.Periodo=@Periodo
		AND a.Empresa='CA'
		GROUP BY a.Cuenta,cc.Grupo,cc.Descripcion
	)
	INSERT INTO @GerenciaColegio_tbl
	SELECT gt.Concepto
	      ,ISNULL(gt2.Saldo,0) AS 'Saldo'
	      ,gt2.Grupo,gt2.Descripcion
	FROM @Gerencias_tbl AS gt
	LEFT JOIN gc_tbl AS gt2 ON gt2.Cuenta = gt.Cuenta;

	
	WITH gc2_tbl
	AS
	(
		SELECT a.Cuenta
			  ,SUM(ISNULL(a.Cargos,0)-ISNULL(a.Abonos,0)) AS 'Saldo'
			  ,'COLEGIO' AS 'Grupo'
			  ,SUBSTRING(cc.Descripcion,1,CHARINDEX(' ',cc.Descripcion,1)) AS 'Descripcion'
		FROM Acum AS a
		JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE a.SubCuenta <> '06'
		AND a.Ejercicio=@Ejercicio
		AND a.Periodo=@Periodo
		AND a.Empresa='CA'
		GROUP BY a.Cuenta,SUBSTRING(cc.Descripcion,1,CHARINDEX(' ',cc.Descripcion,1))
	)
	INSERT INTO @GerenciaColegio_tbl
	SELECT gt.Concepto
		   ,ISNULL(gt2.Saldo,0) AS 'Saldo'
		   ,gt2.Grupo,gt2.Descripcion
	FROM @Gerencias_tbl AS gt
	LEFT JOIN gc2_tbl AS gt2 ON gt2.Cuenta = gt.Cuenta;
	
	
	WITH gc3_tbl
	AS
	(
		SELECT a.Cuenta
			  ,SUM(ISNULL(a.Cargos,0)-ISNULL(a.Abonos,0)) AS 'Saldo'
			  ,'TOTAL' AS 'Grupo'
		FROM Acum AS a
		JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE a.SubCuenta <> '06'
		AND a.Ejercicio=@Ejercicio
		AND a.Periodo=@Periodo
		AND a.Empresa='CA'
		GROUP BY a.Cuenta
	)
	INSERT INTO @GerenciaColegio_tbl(Concepto,Saldo,Sucursal)
	SELECT gt.Concepto
		   ,ISNULL(gt3.Saldo,0) AS 'Saldo'
		   ,gt3.Grupo
	FROM @Gerencias_tbl AS gt
	LEFT JOIN gc3_tbl AS gt3 ON gt3.Cuenta = gt.Cuenta

	SELECT gc.Concepto
		   ,gc.Saldo
		   ,gc.Sucursal
		   ,gc.CentroCosto
		   ,CASE  gc.Sucursal
				WHEN 'PRADO' THEN 1
				WHEN 'XOCHIMILCO' THEN 2
				WHEN 'HERRADURA' THEN 3
				WHEN 'LOMAS VERDES' THEN 4
				WHEN 'COLEGIO' THEN 5
				WHEN 'TOTAL' THEN 6
			END AS 'Indice'
	FROM @GerenciaColegio_tbl gc

END

--EXEC xpGerencias 2016,2