IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpIngresos')
DROP PROCEDURE xpIngresos
GO
CREATE PROCEDURE xpIngresos
@Empresa		VARCHAR(150),
@EjercicioD		INT,
@PeriodoD		INT,
@EjercicioA		INT,
@PeriodoA		INT,
@CentroCostos	VARCHAR(MAX),
@sucursal		VARCHAR(MAX)
AS
BEGIN

	DECLARE @esConsolidado				VARCHAR(50),
			@totalInscripcionesAcum		MONEY,
			@totalBecasAcum				MONEY,
			@totalGastosAcum			MONEY,
			@totalFinancieroAcum		MONEY,
			@PeriodoEjercicioD			VARCHAR(10),
			@PeriodoEjercicioA			VARCHAR(10),
			@financieroMes1				MONEY,
			@financieroMes2				MONEY,
			@TotalFinancieroMes			MONEY,
			@financieroAcum1			MONEY,
			@financieroAcum2			MONEY,
			@TotalFinanAcum				MONEY

	DECLARE @comparativo_btl TABLE(
		ID					INT,
		OrdenCon			VARCHAR(5),
		Empresa				VARCHAR(50),
		Concepto			VARCHAR(255),
		Cuenta				VARCHAR(30),
		CtaDesc				VARCHAR(100),
		Ejercicio			INT,
		Periodo				INT,
		PeriodoEjercicio	VARCHAR(15),
		Sucursal			INT,
		CentroCostos		VARCHAR(10),
		Saldo				MONEY,
		Titulo				VARCHAR(100)
	)

	DECLARE @TotalesIngresos	TABLE (
		ID			INT,
		Ejercicio	INT,
		Periodo		INT,
		TotalSaldo	MONEY
	)

	DECLARE @TotalesBecas	TABLE (
		ID			INT,
		Ejercicio	INT,
		Periodo		INT,
		TotalSaldo	MONEY
	)

	DECLARE @TotalesGastos	TABLE (
		ID			INT,
		Ejercicio	INT,
		Periodo		INT,
		TotalSaldo	MONEY
	)

	DECLARE @TotalesFinanciero	TABLE (
		ID			INT,
		Ejercicio	INT,
		Periodo		INT,
		TotalSaldo	MONEY
	)

	DECLARE @CCostos TABLE(
		CentroCostos		VARCHAR(10),
		Descripcion			VARCHAR(50),
		Grupo				VARCHAR(50),
		Sucursal			INT
	)

	--Inserta los respectivos centro de costo de acuerdo a la sucursal correspondiente
	INSERT INTO @CCostos
		SELECT cc.CentroCostos,cc.Descripcion,
			   CASE cc.Grupo
						WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
						WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
						WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
						WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
			   END AS 'Grupo',
			   CASE SUBSTRING(cc.Descripcion,CHARINDEX(' ',cc.Descripcion,1)+1,30)
					WHEN 'PONIENTE'		    THEN 0
					WHEN 'HERRADURA'		THEN 1
					WHEN 'HERRADURA GASTOS' THEN 1
					WHEN 'NORTE'			THEN 2
					WHEN 'SUR'				THEN 3
					WHEN 'PEDREGAL'		    THEN 4
				END AS 'Sucursal'
		FROM CentroCostos cc

	--Inserta los datos de todas las cuentas con ingresos operativos

	INSERT INTO @comparativo_btl
	SELECT 1
			,'B'
			 ,a. empresa
			 ,'Colegiaturas recibidas'
			 ,c.Cuenta
			 ,c.Descripcion
			 ,a.Ejercicio
			 ,IIF(a.periodo=13,2,a.periodo)
			 ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
			 ,cc.sucursal
			 ,cc.centrocostos
			 ,SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0))  AS 'saldo'
			 ,'INGRESOS OPERATIVOS' AS 'Titulo'
	FROM ContAux AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN @CCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Ingresos')
	AND c.Familia IN ('Colegiaturas')
	AND a.Empresa IN ('CA','PTRNT')
	AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
	AND a.Periodo <> 13
	AND a.Estatus='CONCLUIDO'
	GROUP BY a.Empresa,c.Cuenta,c.Descripcion,a.Ejercicio,a.Periodo,cc.Sucursal,cc.CentroCostos

	INSERT INTO @comparativo_btl
	SELECT 1
			  ,CASE dbo.fnJalesContabilidad(a.Cuenta)
				  WHEN 'Inscripciones' THEN 'A'
				  WHEN 'Col.vencidas no recibidas' THEN 'C'
				  WHEN 'Donativos' THEN 'D'
			  END AS 'OrdenConcepto'
			  ,a. empresa
			  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
			  ,c.Cuenta
			 ,c.Descripcion
			  ,a.Ejercicio
			  ,IIF(a.periodo=13,2,a.periodo)
			  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
			  ,cc.sucursal
			  ,cc.centrocostos
			  ,SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0))  AS 'saldo'
			  ,'INGRESOS OPERATIVOS' AS 'Titulo'
	FROM ContAux AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN @CCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Ingresos', 'Activos')
	AND c.Familia IN ('Colegiaturas','Inscripciones','Donativos')
	AND a.Empresa IN ('CA','PTRNT')
	AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
	AND dbo.fnJalesContabilidad(a.Cuenta) <>'Colegiaturas recibidas'
	AND a.Periodo <> 13
	AND a.Estatus='CONCLUIDO'
	GROUP BY A.Empresa,a.Cuenta,c.Cuenta,c.Descripcion,a.Ejercicio,a.Periodo,cc.Sucursal,cc.CentroCostos


	--Inserta los datos de todas las cuentas con becas

	INSERT INTO @comparativo_btl
	SELECT 2
		  ,CASE dbo.fnJalesContabilidad(a.Cuenta)
				WHEN 'Becas SEP/UNAM' THEN 'E'
				WHEN 'Becas Consejo' THEN 'F'
				WHEN 'Becas Prof/Empleados' THEN 'G'
			END AS 'OrdenConcepto'
		  ,a.empresa
		  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,c.Cuenta
		  ,c.Descripcion
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,cc.sucursal
	      ,cc.centrocostos
		  ,SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0)) AS 'saldo'
		  ,'BECAS Y DEDUCCIONES' AS 'Titulo'
		FROM ContAux AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Becas')
		AND c.Familia IN ('SEP/UNAM','Consejo','Profesores/Empleados')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Periodo <> 13
		AND a.Estatus='CONCLUIDO'
		GROUP BY A.Empresa,a.Cuenta,c.Cuenta,c.Descripcion,a.Ejercicio,a.Periodo,cc.Sucursal,cc.CentroCostos


	--Inserta los datos de todas las cuentas con gastos

    INSERT INTO @comparativo_btl
	SELECT 3
		  ,CASE dbo.fnJalesContabilidad(a.Cuenta) 
				WHEN 'GASTOS PERSONAL DOCENTE' THEN 'H'
				WHEN 'GASTOS PERSONAL ADMINISTRATIVO' THEN 'I'
				WHEN 'GASTOS GENERALES' THEN 'J'
			END AS 'OrdenConcepto'
		  ,a.empresa
		  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,c.Cuenta
		  ,c.Descripcion
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,cc.sucursal
		  ,cc.centrocostos
		  ,SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0))  AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM ContAux AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Gastos')
		AND c.Familia IN ('Personal Administrativo','Personal Docente','Generales')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Cuenta NOT LIKE '51020-0007%'
		AND a.Periodo <> 13
		AND a.Estatus='CONCLUIDO'
		GROUP BY A.Empresa,a.Cuenta,c.Cuenta,c.Descripcion,a.Ejercicio,a.Periodo,cc.Sucursal,cc.CentroCostos

	INSERT INTO @comparativo_btl
	SELECT 3
		  ,'J'
		  ,a.empresa
		  ,'GASTOS GENERALES'
		  ,c.Cuenta
		  ,c.Descripcion
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,cc.sucursal
		  ,cc.centrocostos
		  ,SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0))  AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM ContAux AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Gastos')
		AND c.Familia IN ('Generales')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Cuenta LIKE '51020-0007%'
		AND a.Periodo <> 13
		AND a.Estatus='CONCLUIDO'
		GROUP BY A.Empresa,a.Cuenta,c.Cuenta,c.Descripcion,a.Ejercicio,a.Periodo,cc.Sucursal,cc.CentroCostos

	INSERT INTO @comparativo_btl
	SELECT 3
	       ,'J'
		   ,a.empresa
		   ,'GASTOS GENERALES'
		   ,c.Cuenta
		   ,c.Descripcion
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,cc.sucursal
		  ,cc.centrocostos
		  ,SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0))  AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM ContAux AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Finanzas')
		AND c.Familia IN ('Otros Ingresos')
		AND a.Empresa IN ('CA','PTRNT')
		AND a.cuenta NOT LIKE '31020%'
		AND a.Periodo <> 13
		AND a.Estatus='CONCLUIDO'
		GROUP BY A.Empresa,a.Cuenta,c.Cuenta,c.Descripcion,a.Ejercicio,a.Periodo,cc.Sucursal,cc.CentroCostos
	--Inserta los datos de todas las cuentas financieras

    INSERT INTO @comparativo_btl
	SELECT 4
		  ,CASE dbo.fnJalesContabilidad(a.Cuenta) 
				WHEN 'Subsidio Gob. Alemán' THEN 'K'
				WHEN 'Fluctuación cambiaria' THEN 'L'
				WHEN 'Intereses sobre inversiones' THEN 'M'
				WHEN 'Intereses y gastos bancarios' THEN 'N'
				WHEN 'Otros ingresos y Gastos' THEN 'O'
			END AS 'OrdenConceptos'
	      ,a.empresa
		  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,c.Cuenta
		  ,c.Descripcion
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,cc.sucursal
		  ,IIF(cc.centrocostos='','01',cc.centrocostos) AS 'Subcuenta'
		  ,IIF(dbo.fnJalesContabilidad(a.Cuenta)='Intereses y gastos bancarios',SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0))*-1,SUM(ISNULL(a.Debe,0)-ISNULL(a.Haber,0)) ) AS 'saldo'
		  ,'FINANCIERO' AS 'Titulo'
		FROM ContAux AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Finanzas')
		AND c.Familia IN ('Subsidio','Intereses Inversiones','Otros Ingresos','Intereses Bancarios','Fluctuacion')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Periodo <> 13
		AND a.Estatus='CONCLUIDO'
		GROUP BY A.Empresa,a.Cuenta,c.Cuenta,c.Descripcion,a.Ejercicio,a.Periodo,cc.Sucursal,cc.CentroCostos
	--Asignamos el valor de la empresa para saber si va crear el comparativo del colegio, del patronato o consolidado
	SET @esConsolidado=@Empresa

	--Asignamos el rango de fechas de acuerdo al rango del periodo y año
	SET @PeriodoEjercicioD=CONVERT(VARCHAR(5),@PeriodoD)+CONVERT(VARCHAR(10),@EjercicioD)

	SET @PeriodoEjercicioA=CONVERT(VARCHAR(5),@PeriodoA)+CONVERT(VARCHAR(10),@EjercicioA)

	--SELECT * FROM @comparativo_btl

	IF @esConsolidado NOT LIKE 'CON'
	BEGIN
		
		DELETE FROM Comparativo_tbl
		
		--Ingresa datos a las tablas de totales de ingresos, becas, gastos y financieros

		INSERT INTO @TotalesIngresos
		SELECT 1
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(c.Saldo) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa=@Empresa
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,',')) 
		AND c.ID=1
		GROUP BY c.ID,c.Ejercicio,c.Periodo


		INSERT INTO @TotalesBecas
		SELECT 2
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(c.Saldo) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa=@Empresa
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
		AND c.ID=2
		GROUP BY c.ID,c.Ejercicio,c.Periodo

		INSERT INTO @TotalesGastos
		SELECT 3
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(c.Saldo) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa=@Empresa
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
		AND c.ID=3
		GROUP BY c.ID,c.Ejercicio,c.Periodo

		INSERT INTO @TotalesFinanciero
		SELECT 4
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(IIF(c.Concepto='Intereses y gastos bancarios',c.Saldo,c.Saldo*-1)) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa=@Empresa
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
		AND c.ID=4
		GROUP BY c.ID,c.Ejercicio,c.Periodo
		
	--Totales acumulados por empresa y por ejercicio 
			
	SET @totalInscripcionesAcum=(SELECT SUM(c.Saldo) AS 'Saldo'
								FROM @comparativo_btl c
								WHERE C.Empresa=@Empresa
								AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
								AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
								AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
								AND c.ID=1)
	
	SET @totalBecasAcum=(SELECT SUM(c.Saldo) AS 'Saldo'
								FROM @comparativo_btl c
								WHERE C.Empresa=@Empresa
								AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA 
								AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
								AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
								AND c.ID=2)
	
	 SET @totalGastosAcum=(SELECT SUM(c.Saldo) AS 'Saldo'
								FROM @comparativo_btl c
								WHERE C.Empresa=@Empresa
								AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
								AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
								AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,',')) 
								AND c.ID=3)

	SET @totalFinancieroAcum=(SELECT SUM(IIF(c.Concepto='Intereses y gastos bancarios',c.Saldo,c.Saldo*-1)) AS 'Saldo'
								FROM @comparativo_btl c
								WHERE C.Empresa=@Empresa
								AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
								AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
								AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,',')) 
								AND c.ID=4)

	--Inserta el Resultado Neto del comparativo a la tabla Comparativo_tbl
	INSERT INTO Comparativo_tbl
	SELECT '61060-0000-000'
		   ,(@totalInscripcionesAcum+@totalBecasAcum+@totalGastosAcum)+@totalFinancieroAcum AS 'Saldo'
		   ,'RESULTADO DEL EJERCICIO'
		   ,@PeriodoA
		   ,@EjercicioA
		   ,@Empresa
	
	--Consulta general para el reporte
		SELECT cb.ID
		       ,cb.OrdenCon
			   ,cb.Concepto
			   ,cb.Cuenta
			   ,cb.CtaDesc
			   ,cb.Ejercicio
			   ,cb.Periodo
			   ,cb.Sucursal
			   ,cb.CentroCostos
			   ,cb.Saldo
			   ,cb.Titulo
			   ,ISNULL(ti.TotalSaldo,0)		AS 'TotalIngresos'
			   ,ISNULL(tb.TotalSaldo,0)		AS 'TotalBecas'
			   ,ISNULL(tg.TotalSaldo,0)		AS 'TotalGastos'
			   ,ISNULL(tf.TotalSaldo,0)		AS 'TotalFinan'
			   ,ISNULL(@totalInscripcionesAcum,0)		AS 'TotalIngresosAcum'  
			   ,ISNULL(@totalBecasAcum,0)				AS 'TotalBecasAcum'
			   ,ISNULL(@totalGastosAcum,0)			AS 'TotalGastosAcum'
			   ,ISNULL(@totalFinancieroAcum,0)		AS 'TotalFinancieroAcum'	
		FROM @comparativo_btl cb
		LEFT JOIN @TotalesIngresos ti ON ti.Ejercicio=cb.Ejercicio and ti.Periodo=cb.Periodo 
		LEFT JOIN @TotalesBecas tb ON tb.Ejercicio=cb.Ejercicio AND tb.Periodo=cb.Periodo 
		LEFT JOIN @TotalesGastos tg ON tg.Ejercicio= cb.Ejercicio AND tg.Periodo=cb.Periodo 
		LEFT JOIN @TotalesFinanciero tf ON tf.Ejercicio=cb.Ejercicio AND tf.Periodo=cb.Periodo 
		WHERE cb.Empresa=@Empresa
		AND cb.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND cb.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
		AND cb.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA 
		AND cb.Saldo <> 0
		
	END

	IF @esConsolidado LIKE 'CON'
	BEGIN
		
		DELETE FROM Comparativo_tbl
		
		--Ingresa datos a las tablas de totales de ingresos, becas, gastos y financieros
		INSERT INTO @TotalesIngresos
		SELECT 1
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(c.Saldo) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa IN ('CA','PTRNT')
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,',')) 
		AND c.ID=1
		GROUP BY c.ID,c.Ejercicio,c.Periodo

		INSERT INTO @TotalesBecas
		SELECT 2
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(c.Saldo) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa IN ('CA','PTRNT')
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,',')) 
		AND c.ID=2
		GROUP BY c.ID,c.Ejercicio,c.Periodo
		
		INSERT INTO @TotalesGastos
		SELECT 3
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(c.Saldo) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa IN ('CA','PTRNT')
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
		AND c.ID=3
		GROUP BY c.ID,c.Ejercicio,c.Periodo

		INSERT INTO @TotalesFinanciero
		SELECT 4
			  ,c.Ejercicio
			  ,c.Periodo
			  ,SUM(IIF(c.Concepto='Intereses y gastos bancarios',c.Saldo,c.Saldo*-1)) AS 'Saldo'
		FROM @comparativo_btl c
		WHERE C.Empresa IN ('CA','PTRNT')
		AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
		AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
		AND c.ID=4
		GROUP BY c.ID,c.Ejercicio,c.Periodo

		--Totales acumulados consolidados
	
		SET @totalInscripcionesAcum=(SELECT SUM(c.Saldo) AS 'Saldo'
										FROM @comparativo_btl c
										WHERE C.Empresa IN ('CA','PTRNT')
										AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
										AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
										AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,',')) 
										AND c.ID=1)

		SET @totalBecasAcum=(SELECT SUM(c.Saldo) AS 'Saldo'
										FROM @comparativo_btl c
										WHERE C.Empresa IN ('CA','PTRNT')
										AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
										AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
									    AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
										AND c.ID=2)

		SET @totalGastosAcum=(SELECT SUM(c.Saldo) AS 'Saldo'
										FROM @comparativo_btl c
										WHERE C.Empresa IN ('CA','PTRNT')
										AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
										AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
										AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
										AND c.ID=3)

	SET @totalFinancieroAcum=(SELECT SUM(IIF(c.Concepto='Intereses y gastos bancarios',c.Saldo,c.Saldo*-1)) AS 'Saldo'
										FROM @comparativo_btl c
										WHERE C.Empresa IN ('CA','PTRNT')
										AND c.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
										AND C.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
										AND c.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
										AND c.ID=4)
	
	--Inserta el Resultado Neto del comparativo a la tabla Comparativo_tbl
	INSERT INTO Comparativo_tbl
	SELECT '61060-0000-000'
		   ,(@totalInscripcionesAcum-@totalBecasAcum-@totalGastosAcum)+@totalFinancieroAcum AS 'Saldo'
		   ,'RESULTADO DEL EJERCICIO'
		   ,@PeriodoA
		   ,@EjercicioA
		   ,'CON'
	
	--Consulta General del reporte
		SELECT cb.ID
			   ,cb.OrdenCon
			   ,cb.Concepto
			   ,cb.Cuenta
			   ,cb.CtaDesc
			   ,cb.Ejercicio
			   ,cb.Periodo
			   ,cb.Sucursal
			   ,cb.CentroCostos
			   ,cb.Saldo
			   ,cb.Titulo
			   ,ISNULL(ti.TotalSaldo,0)		AS 'TotalIngresos'
			   ,ISNULL(tb.TotalSaldo,0)		AS 'TotalBecas'
			   ,ISNULL(tg.TotalSaldo,0)		AS 'TotalGastos'
			   ,ISNULL(tf.TotalSaldo,0)		AS 'TotalFinan' 
			   ,ISNULL(@totalInscripcionesAcum,0)		AS 'TotalIngresosAcum'
			   ,ISNULL(@totalBecasAcum,0)				AS 'TotalBecasAcum'
			   ,ISNULL(@totalGastosAcum,0)			AS 'TotalGastosAcum'
			   ,ISNULL(@totalFinancieroAcum,0)		AS 'TotalFinancieroAcum'
		FROM @comparativo_btl cb
		LEFT JOIN @TotalesIngresos ti ON ti.Ejercicio=cb.Ejercicio and ti.Periodo=cb.Periodo
		LEFT JOIN @TotalesBecas tb ON tb.Ejercicio=cb.Ejercicio AND tb.Periodo=cb.Periodo
		LEFT JOIN @TotalesGastos tg ON tg.Ejercicio= cb.Ejercicio AND tg.Periodo=cb.Periodo
		LEFT JOIN @TotalesFinanciero tf ON tf.Ejercicio=cb.Ejercicio AND tf.Periodo=cb.Periodo
		WHERE cb.CentroCostos IN (SELECT DATA FROM dbo.Split(@CentroCostos,','))
			AND cb.Sucursal IN (SELECT CAST(DATA AS INT) FROM dbo.Split(@sucursal,','))
			AND cb.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA 	
			AND cb.Empresa IN ('CA','PTRNT')
			AND cb.Saldo <> 0
	END

END



--EXEC xpIngresos 'CA',2016,'01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20','0,1,2,3,4,99'

--EXEC xpIngresos 'CA',2016,'01','0,1,2,3,4'



--EXEC xpIngresos 'CA',2016,'01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20','0,1,2,3,4'

--EXEC xpIngresos 'CA',2016,'01','0,1,2,3,4'

--EXEC xpIngresos 'CA',2016,'5,7,8,9,12,13','0,1,3,4'

--EXEC xpIngresos 'CA',2016,'13,4,7,9,10,11,15,3','0,1,3,4'

--EXEC xpIngresos 'CA',2016,2,2016,2,'01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20','0,1,2,3,4,99'

--EXEC xpIngresos 'CA',2016,2,2016,2,'13','3'


--EXEC xpIngresos 'CA',2016,2,2016,2,'01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20','0'





