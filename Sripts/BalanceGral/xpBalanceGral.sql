IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpBalanceGral')
DROP PROCEDURE xpBalanceGral
GO
CREATE PROCEDURE xpBalanceGral
@empresa	VARCHAR(30),
@periodo	INT,
@ejercicio	INT
AS
BEGIN
	DECLARE @esConsolidado		VARCHAR(10),
			@FondoAhorro		MONEY,
			@ConsumoAgua		MONEY,
			@Subsidio			MONEY,
			@OtroAcreedores		MONEY,
			@TotalAcreedores	MONEY,
			@Colegiaturas		MONEY,
			@Descuentos			MONEY,
			@TotalColegiaturas	MONEY,
			@Contigente			MONEY,
			@DepGarantia		MONEY,
			@TotalContigente	MONEY,
			@comparativo		MONEY,
			@Efectivo			MONEY,
			@Obligaciones		MONEY,
			@TotalEfectivo		MONEY,
			@FuturoFirme		MONEY
	
	SET @esConsolidado=@empresa
	
DECLARE @balanza_tbl TABLE (
	TipoCuenta	VARCHAR(20),
	Cuenta		VARCHAR(30)		NULL,
	Grupo		VARCHAR(250)	NULL,
	Descripcion	VARCHAR(250)	NULL,
	CtaDesc		VARCHAR(250)	NULL,
	Tipo		VARCHAR(20)		NULL
)

--Carga de Activos
INSERT INTO @balanza_tbl
SELECT 'Activo' AS 'TipoCuenta',
Cta.Cuenta,
CASE E2.Descripcion 
		WHEN 'CAJA' THEN 'CIRCULANTE'
		WHEN 'BANCOS E INVERSIONES Y VALORES' THEN 'CIRCULANTE'
		WHEN 'GASTOS PAGADOS POR ANTICIPADO' THEN 'DIFERIDO'
		WHEN 'TERRENO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'EDIFICIO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'ALBERCA' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'MUEBLES Y ENSERES' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'TERRENO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'CONSTRUCCIONES EN PROCESO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'EQUIPO DE FOTOCOPIADO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'EQUIPO DE TRANSPORTE' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'EQUIPO DE COMPUTO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'MAQUINARIA Y EQUIPO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'MONUMENTO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'EQUIPO DE LABORATORIO' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'DEPRECIACION' THEN 'PROPIEDADES Y EQUIPO'
		WHEN 'DEPOSITOS EN GARANTIAS' THEN 'DIFERIDO'
	ELSE E2.Descripcion
END AS 'Grupo',
dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
Cta.Descripcion
,CASE E2.Descripcion
	WHEN 'TERRENO' THEN 'APRECIACION'
	WHEN 'EDIFICIO' THEN 'APRECIACION'
	WHEN 'MONUMENTO' THEN 'APRECIACION'
	WHEN 'ALBERCA'	THEN 'APRECIACION'
	WHEN 'MUEBLES Y ENSERES' THEN 'APRECIACION'
	WHEN 'EQUIPO DE COMPUTO' THEN 'APRECIACION'
	WHEN 'MAQUINARIA Y EQUIPO' THEN 'APRECIACION'
	WHEN 'EQUIPO DE LABORATORIO' THEN 'APRECIACION'
	WHEN 'CONSTRUCCIONES EN PROCESO' THEN 'APRECIACION'
	WHEN 'EQUIPO DE FOTOCOPIADO' THEN 'APRECIACION'
	WHEN 'EQUIPO DE TRANSPORTE' THEN 'APRECIACION'
	WHEN 'DEPRECIACION'	THEN 'DEPRECIACION'
END AS 'Tipo'
FROM Cta, Cta E1, Cta E2
WHERE Cta.Rama   = E2.Cuenta
AND E2.Rama    = E1.Cuenta
--AND UPPER(Cta.Tipo) = 'MAYOR'
AND (Cta.Rama = 'B' OR E1.Rama = 'B' OR E2.Rama = 'B')
AND E2.Cuenta NOT IN ('B','C','D','E')
AND Cta.cuenta NOT LIKE '11050-0002%'
ORDER BY Cta.Cuenta


INSERT INTO @balanza_tbl(TipoCuenta,Grupo,Cuenta,Descripcion,CtaDesc)
SELECT 'Activo' AS 'TipoCuenta'
	   ,'DEUDORES DIVERSOS'
	   ,c.Cuenta
	   ,dbo.fnJalesBalance(c.Cuenta) AS 'Descripcion'
	   ,c.Descripcion
FROM Cta AS c
WHERE c.Cuenta   LIKE '11050-0002%'
AND c.Cuenta NOT LIKE '11050-0002-000'


INSERT INTO @balanza_tbl(TipoCuenta,Grupo,Cuenta,Descripcion,CtaDesc,Tipo)
SELECT 'Activo' AS 'TipoCuenta'
	   ,'FONDOS'
	   ,c.Cuenta
	   ,dbo.fnJalesBalance(c.Cuenta) AS 'Descripcion'
	   ,c.Descripcion
	   ,'LABORAL'
FROM Cta AS c
WHERE c.Cuenta  LIKE '51110-0000%'
OR c.Cuenta LIKE '51120-0000%'
OR c.Cuenta LIKE '51100-0000%'

INSERT INTO @balanza_tbl(TipoCuenta,Grupo,Cuenta,Descripcion,CtaDesc,Tipo)
SELECT 'Activo' AS 'TipoCuenta'
	   ,'FONDOS'
	   ,c.Cuenta
	   ,dbo.fnJalesBalance(c.Cuenta) AS 'Descripcion'
	   ,c.Descripcion
	   ,'LARGO PLAZO'
FROM Cta AS c
WHERE c.Cuenta  LIKE '12050-0000-000'

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
SELECT 'Activo' AS 'TipoCuenta'
	   ,c.Cuenta
	   ,'INTANGIBLE'
	   ,dbo.fnJalesBalance(c.Cuenta) AS 'Descripcion'
	   ,c.Descripcion
FROM Cta AS c
WHERE c.Cuenta LIKE '21050-0001-005%'

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
SELECT 'Activo' AS 'TipoCuenta'
	   ,c.Cuenta
	   ,'INTANGIBLE'
	   ,'INDEMNIZACIONES NEGATIVA'
	   ,c.Descripcion
FROM Cta AS c
WHERE c.Cuenta LIKE '21050-0001-005%'

--Carga de Pasivos

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'CUENTAS Y DOCUMENTOS POR PAGAR',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) LIKE 'BONO%'
	AND (Cta.Rama = 'I' OR E1.Rama = 'I' OR E2.Rama = 'I')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'GASTOS ACUM. Y OTRAS CUENTAS  POR PAGAR',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('I.S.P.T.','INFONAVIT','OTRAS CONTRIBUCIONES','OTROS ACREEDORES','S.A.R','SEGURO SOCIAL')
	AND (Cta.Rama = 'H' OR E1.Rama = 'H' OR E2.Rama = 'H')
	AND E2.Cuenta NOT IN ('H','J','K')
	AND cta.Cuenta <> '21050-0001-000'
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'GASTOS ACUM. Y OTRAS CUENTAS  POR PAGAR',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('DERECHOS POR CONSUMO DE AGUA','PROVISION PRIMA DE VACACIONES','PROVISION  DE AGUINALDOS','PROVISION DE EXCELENCIA')
	AND (Cta.Rama = 'I' OR E1.Rama = 'I' OR E2.Rama = 'I')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'GASTOS ACUM. Y OTRAS CUENTAS  POR PAGAR',
			'OTROS ACREEDORES',
			Cta.Descripcion
	FROM Cta
	WHERE Cta.Cuenta LIKE '21020%'
	 AND Cta.Cuenta NOT LIKE '21020-0000-000'
	 AND Cta.Cuenta NOT LIKE '21020-0001-007'
	 AND Cta.Cuenta NOT LIKE '21020-0001-008'

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'GASTOS ACUM. Y OTRAS CUENTAS  POR PAGAR',
			'OTROS ACREEDORES',
			Cta.Descripcion
	FROM Cta
	WHERE Cta.Cuenta LIKE  '21050-0001-006'

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'GASTOS ACUM. Y OTRAS CUENTAS  POR PAGAR',
			'FONDO DE AHORRO POR PAGAR',
			Cta.Descripcion
	FROM Cta
	WHERE Cta.Cuenta IN ('21020-0001-013')

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'GASTOS ACUM. Y OTRAS CUENTAS  POR PAGAR',
			'SUBSIDIO RECIBIDO POR APLICAR',
			Cta.Descripcion
	FROM Cta
	WHERE Cta.Cuenta IN ('21020-0002-076')

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'CREDITOS DIFERIDOS',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('COL E INSC COBRADAS POR ANTICIPADO')
	AND (Cta.Rama = 'K' OR E1.Rama = 'K' OR E2.Rama = 'K')
	AND E2.Cuenta NOT IN ('K')
	AND cta.Cuenta NOT LIKE '23030%'
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'CREDITOS DIFERIDOS',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('DEPOSITOS EN GARANTIA')
	AND (Cta.Rama = 'E' OR E1.Rama = 'E' OR E2.Rama = 'E')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	AND cta.Cuenta NOT LIKE '13020-0000-000'
	ORDER BY E2.Grupo ASC


INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'LARGO PLAZO',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('BONO DEL CENTENARIO','PRESTAMO BANCOMER')
	AND (Cta.Rama = 'H' OR E1.Rama = 'H' OR E2.Rama = 'H')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	AND Cta.Cuenta NOT LIKE '21040%'
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'CONTINGENTE',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('PROV. PARA OBLIGACIONES LABORALES')
	AND (Cta.Rama = 'H' OR E1.Rama = 'H' OR E2.Rama = 'H')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta'
		   ,c.Cuenta
		   ,'CONTINGENTE'
		   ,dbo.fnJalesBalance(c.Cuenta) AS 'Descripcion'
		   ,c.Descripcion
	FROM Cta AS c
	WHERE c.Cuenta LIKE '21050-0001-005%'


INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'CONTINGENTE',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('PROV. PARA LIQUIDACIONES')
	AND (Cta.Rama = 'U' OR E1.Rama = 'U' OR E2.Rama = 'U')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'CONTINGENTE',
			'PROV. PARA LIQUIDACIONES (Ajuste)',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('PROV. PARA LIQUIDACIONES')
	AND (Cta.Rama = 'U' OR E1.Rama = 'U' OR E2.Rama = 'U')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'CONTINGENTE',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('MI FUTURO FIRME')
	AND (Cta.Rama = 'I' OR E1.Rama = 'I' OR E2.Rama = 'I')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	ORDER BY E2.Grupo ASC


INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	SELECT 'Pasivo' AS 'TipoCuenta',
			Cta.Cuenta,
			'PATRIMONIO',
			dbo.fnJalesBalance(Cta.Cuenta) AS 'Descripcion',
			Cta.Descripcion
	FROM Cta, Cta E1, Cta E2
	WHERE Cta.Rama   = E2.Cuenta
	AND E2.Rama    = E1.Cuenta
	AND dbo.fnJalesBalance(Cta.Cuenta) IN ('PATRIMONIO SOCIAL','PATRIMONIO DONADO','SUPERAVIT POR REVALUACION ACTIVO FIJO','RESULTADO CICLO ESCOLAR')
	AND (Cta.Rama = 'Q' OR E1.Rama = 'Q' OR E2.Rama = 'Q')
	AND E2.Cuenta NOT IN ('H','I','J','K')
	AND cta.Cuenta NOT IN('61030-0000-000','61020-0000-000','61030-0000-000','61010-0000-000')
	ORDER BY E2.Grupo ASC

INSERT INTO @balanza_tbl(TipoCuenta,Cuenta,Grupo,Descripcion,CtaDesc)
	  SELECT 'Pasivo'
		     ,c.Cuenta
		     ,'PATRIMONIO'
		     ,c.Descripcion
		     ,c.Descripcion
	  FROM Comparativo_tbl c
	  WHERE c.Periodo=@periodo
	  	AND c.ejercicio=@ejercicio


	--Resuleve el calculo de la obtencion de OTROS ACREEDORES
	IF @esConsolidado NOT LIKE 'CON'
	BEGIN
		--Resuleve el calculo de la obtencion de OTROS ACREEDORES
			SET @OtroAcreedores=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
									FROM Acum a
									WHERE a.Ejercicio=@ejercicio
										AND IIF(a.Periodo=13,2,a.periodo)=@periodo
										AND a.Empresa=@empresa
										AND a.Cuenta IN ('21020-0000-000','21050-0001-006','21030-0000-000','23050-0000-000'))
			
			SET @Subsidio= (SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('21020-0002-076'))
			
			SET @ConsumoAgua=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('21020-0002-005'))
			
			SET @FondoAhorro=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('21020-0001-013'))

			SET @FuturoFirme=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
									FROM Acum a
									WHERE a.Ejercicio=@ejercicio
										AND IIF(a.Periodo=13,2,a.periodo)=@periodo
										AND a.Empresa=@empresa
										AND a.Cuenta IN ('21020-0001-007','21020-0001-008'))
			
			SET @TotalAcreedores=(ISNULL(@OtroAcreedores,0)-(ISNULL(@Subsidio,0)+ISNULL(@ConsumoAgua,0)+ISNULL(@FondoAhorro,0)))-@FuturoFirme;
			
		--Resuelve el calculo para las Colegiaturas pagadas por anticipado
		
			SET @Colegiaturas=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('23010-0000-000','23020-0000-000','23060-0000-000','23040-0000-000')
									AND a.Cuenta not LIKE '23030%'
									AND a.Cuenta NOT LIKE '23050%')
									
			SET @Descuentos=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('23030-0000-000'))
			
			SET @TotalColegiaturas=ISNULL(@Colegiaturas,0)+ISNULL(@Descuentos,0);
		
		--Reuelve el calculo para Prov. para obligaciones laborales
			SET @Contigente=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('21050-0002-000'))
			SET @DepGarantia=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta LIKE '13020-0001-000')

			SET @TotalContigente=ISNULL(ABS(@Contigente),0)-ISNULL(@DepGarantia,0);
		
		--Se obtiene el total del comparativo
		
			SET @comparativo=(SELECT ct.Saldo
			                  FROM Comparativo_tbl AS ct
			                  WHERE ct.Ejercicio=@ejercicio
								AND ct.periodo=@periodo);
								
		--Se obtiene el total para el flujo de efectivo
		
			SET @Efectivo=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('11010-0000-000','11020-0000-000'))
			
			SET @Obligaciones=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Empresa=@empresa
									AND a.Cuenta IN ('12050-0001-000','51110-0000-000'))
			
			SET @TotalEfectivo=ISNULL(@Efectivo,0)-ISNULL(@Obligaciones,0);						
			
			
		WITH acum_tbl
		AS
		(
			SELECT a.Cuenta
				  --,IIF(a.cuenta LIKE '21020-0002-000' OR a.cuenta LIKE '21020-0001-000',SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*-1,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))) AS 'Acumulado'
				  ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
			FROM Acum a
			WHERE a.Ejercicio=@ejercicio
				AND IIF(a.Periodo=13,2,a.periodo)=@periodo
				AND a.Empresa=@empresa
			GROUP BY a.Cuenta
		)
		SELECT DISTINCT at.TipoCuenta,at.Grupo
		      ,IIF(at.Tipo='DEPRECIACION',LTRIM(SUBSTRING(at.Descripcion,CHARINDEX(' ',at.Descripcion,1),50)),at.Descripcion) AS 'Descripcion'
		      ,at.Tipo
			  ,CASE at.Descripcion
				WHEN 'EFECTIVO'								THEN ISNULL(@TotalEfectivo,0)
				WHEN 'OTROS ACREEDORES'						THEN ISNULL(ABS(@TotalAcreedores),0)
				WHEN 'COL E INSC COBRADAS POR ANTICIPADO'	THEN ISNULL(ABS(@TotalColegiaturas),0)
				WHEN 'PROV. PARA OBLIGACIONES LABORALES'	THEN ISNULL(@TotalContigente,0)
				WHEN 'RESULTADO DEL EJERCICIO'				THEN ISNULL(@comparativo,0)
				WHEN 'INDEMNIZACIONES NEGATIVA'				THEN ISNULL(SUM(a.Acumulado)*-1,0)
				WHEN 'PROV. PARA LIQUIDACIONES (Ajuste)'	THEN ISNULL(SUM(ABS(a.Acumulado)),0)
				WHEN 'PROV. PARA LIQUIDACIONES'				THEN ISNULL(SUM(a.Acumulado)*-1,0)
			   ELSE ISNULL(SUM(a.Acumulado),0)
			   END AS 'Acumulado'
		FROM @balanza_tbl AS at
		LEFT JOIN Acum_tbl AS a ON a.Cuenta = at.Cuenta	
		GROUP BY at.TipoCuenta,at.Grupo,at.Descripcion,at.Tipo
	END
	
	IF @esConsolidado LIKE 'CON' 
	BEGIN
		--Resuleve el calculo de la obtencion de OTROS ACREEDORES
			SET @OtroAcreedores=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
									FROM Acum a
									WHERE a.Ejercicio=@ejercicio
										AND IIF(a.Periodo=13,2,a.periodo)=@periodo
										AND a.Empresa=@empresa
										AND a.Cuenta IN ('21020-0000-000','21050-0001-006','21030-0000-000','23050-0000-000'))
			
			SET @Subsidio= (SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('21020-0002-076'))
			
			SET @ConsumoAgua=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('21020-0002-005'))
			
			SET @FondoAhorro=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('21020-0001-013'))
			
			SET @FuturoFirme=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
									FROM Acum a
									WHERE a.Ejercicio=@ejercicio
										AND IIF(a.Periodo=13,2,a.periodo)=@periodo
										AND a.Empresa=@empresa
										AND a.Cuenta IN ('21020-0001-007','21020-0001-008'))
			
			SET @TotalAcreedores=(ISNULL(@OtroAcreedores,0)-(ISNULL(@Subsidio,0)+ISNULL(@ConsumoAgua,0)+ISNULL(@FondoAhorro,0)))-@FuturoFirme;
			
			--Resuelve el calculo para las Colegiaturas pagadas por anticipado
		
			SET @Colegiaturas=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('23010-0000-000','23020-0000-000','23060-0000-000','23040-0000-000')
									AND a.Cuenta not LIKE '23030%'
									AND a.Cuenta NOT LIKE '23050%')
									
			SET @Descuentos=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('23030-0000-000'))
			
			SET @TotalColegiaturas=ISNULL(@Colegiaturas,0)-ISNULL(@Descuentos,0);
		
		--Reuelve el calculo para Prov. para obligaciones laborales
			SET @Contigente=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('21050-0002-000'))
			SET @DepGarantia=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta LIKE '13020-0001-000')
			SET @TotalContigente=ISNULL(ABS(@Contigente),0)-ISNULL(@DepGarantia,0);
			
			--Se obtiene el total del comparativo
		
			SET @comparativo=(SELECT ct.Saldo
			                  FROM Comparativo_tbl AS ct
			                  WHERE ct.Ejercicio=@ejercicio
								AND ct.periodo=@periodo);
			
			--Se obtiene el total para el flujo de efectivo
		
			SET @Efectivo=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('11010-0000-000','11020-0000-000'))
			
			SET @Obligaciones=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
								FROM Acum a
								WHERE a.Ejercicio=@ejercicio
									AND IIF(a.Periodo=13,2,a.periodo)=@periodo
									AND a.Cuenta IN ('12050-0001-000','51110-0000-000'))
			
			SET @TotalEfectivo=ISNULL(@Efectivo,0)-ISNULL(@Obligaciones,0);	
		
		WITH acum_tbl
		AS
		(
			SELECT a.Cuenta
				  --,IIF(a.cuenta LIKE '21020-0002-005' OR a.cuenta LIKE '21020-0002-000' OR a.cuenta LIKE '21020-0001-000',SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*-1,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))) AS 'Acumulado'
				   ,SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Acumulado'
			FROM Acum a
			WHERE a.Ejercicio=@ejercicio
			AND IIF(a.Periodo=13,2,a.periodo)=@periodo
			GROUP BY a.Cuenta
		)
		SELECT at.TipoCuenta,at.Grupo
			  ,IIF(at.Tipo='DEPRECIACION',LTRIM(SUBSTRING(at.Descripcion,CHARINDEX(' ',at.Descripcion,1),50)),at.Descripcion) AS 'Descripcion'
			  ,at.Tipo
			  ,CASE at.Descripcion
				WHEN 'EFECTIVO'								THEN ISNULL(@TotalEfectivo,0)
				WHEN 'OTROS ACREEDORES'						THEN ISNULL(ABS(@TotalAcreedores),0)
				WHEN 'COL E INSC COBRADAS POR ANTICIPADO'	THEN ISNULL(ABS(@TotalColegiaturas),0)
				WHEN 'PROV. PARA OBLIGACIONES LABORALES'	THEN ISNULL(@TotalContigente,0)
				WHEN 'RESULTADO DEL EJERCICIO'				THEN ISNULL(@comparativo,0)
				WHEN 'INDEMNIZACIONES NEGATIVA'				THEN ISNULL(SUM(a.Acumulado)*-1,0)
				WHEN 'PROV. PARA LIQUIDACIONES (Ajuste)'	THEN ISNULL(SUM(ABS(a.Acumulado)),0)
				WHEN 'PROV. PARA LIQUIDACIONES'				THEN ISNULL(SUM(a.Acumulado)*-1,0)
			   ELSE ISNULL(SUM(a.Acumulado),0)
			   END AS 'Acumulado'
		FROM @balanza_tbl AS at
		LEFT JOIN Acum_tbl AS a ON a.Cuenta = at.Cuenta
		GROUP BY at.TipoCuenta,at.Grupo,at.Descripcion,at.Tipo
	END
END

--EXEC xpBalanceGral 'CA',2,2016