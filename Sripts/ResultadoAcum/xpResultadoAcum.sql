IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpResultadoAcum')
DROP PROCEDURE xpResultadoAcum
GO
CREATE PROCEDURE xpResultadoAcum
@EjercicioD		INT,
@PeriodoD		INT,
@EjercicioA		INT,
@PeriodoA		INT
AS
BEGIN
	DECLARE @PeriodoEjercicioD			VARCHAR(10),
			@PeriodoEjercicioA			VARCHAR(10)

	DECLARE @comparativo_btl TABLE(
		ID					INT,
		Empresa				VARCHAR(50),
		Concepto			VARCHAR(255),
		Ejercicio			INT,
		Periodo				INT,
		PeriodoEjercicio	VARCHAR(15),
		NomSucursal			VARCHAR(100),
		CentroCostos		VARCHAR(10),
		NombreCC			VARCHAR(100),
		Saldo				MONEY,
		Titulo				VARCHAR(100)
	)
	
	--Inserta los datos de todas las cuentas con ingresos operativos

	INSERT INTO @comparativo_btl
	SELECT 1
			 ,a. empresa
			 ,'Colegiaturas recibidas'
			 ,a.Ejercicio
			 ,IIF(a.periodo=13,2,a.periodo)
			 ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
			 ,CASE cc.Grupo
					WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
					WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
					WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
					WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
				END AS 'Sucursal'
			  ,a.subcuenta
			  ,cc.Descripcion
			 ,IIF(Cargos=0,Abonos,(Cargos-Abonos)*-1) AS 'saldo'
			 ,'INGRESOS OPERATIVOS' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Ingresos', 'Activos')
	AND c.Familia IN ('Colegiaturas')
	AND a.Empresa IN ('CA','PTRNT')
	AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL

	INSERT INTO @comparativo_btl
	SELECT 1
			  ,a. empresa
			  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
			  ,a.Ejercicio
			  ,IIF(a.periodo=13,2,a.periodo)
			  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
			  ,CASE cc.Grupo
					WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
					WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
					WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
					WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
				END AS 'Sucursal'
			  ,a.subcuenta
			  ,cc.Descripcion
			  ,IIF(Cargos=0,Abonos,Cargos-Abonos) AS 'saldo'
			  ,'INGRESOS OPERATIVOS' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Ingresos', 'Activos')
	AND c.Familia IN ('Colegiaturas','Inscripciones','Donativos')
	AND a.Empresa IN ('CA','PTRNT')
	AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
	AND dbo.fnJalesContabilidad(a.Cuenta) <>'Colegiaturas recibidas'


	--Inserta los datos de todas las cuentas con becas

	INSERT INTO @comparativo_btl
	SELECT 2,a.empresa,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,a.Ejercicio
		  ,a.periodo
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,CASE cc.Grupo
					WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
					WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
					WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
					WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
				END AS 'Sucursal'
			,a.subcuenta
			,cc.Descripcion
		  ,-Cargos-Abonos AS 'saldo'
		  ,'BECAS Y DEDUCCIONES' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Becas')
	  AND c.Familia IN ('SEP/UNAM','Consejo','Profesores/Empleados')
	  AND a.Empresa IN ('CA','PTRNT')
	  AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL

	--Inserta los datos de todas las cuentas con gastos

    INSERT INTO @comparativo_btl
	SELECT 4
		  ,a.empresa
		  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,CASE cc.Grupo
					WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
					WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
					WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
					WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
		   END AS 'Sucursal'
		  ,a.subcuenta
		  ,cc.Descripcion
		  ,IIF(a.Cargos=0,a.Abonos,(a.Cargos-a.Abonos)*-1) AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM Acum AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Gastos')
		AND c.Familia IN ('Personal Administrativo','Personal Docente','Generales')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Cuenta NOT LIKE '51020-0007%'
		
		INSERT INTO @comparativo_btl
		SELECT 4
		  ,a.empresa
		  ,'GASTOS GENERALES'
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,CASE cc.Grupo
					WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
					WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
					WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
					WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
			END AS 'Sucursal'
		  ,a.subcuenta
		  ,cc.Descripcion
		  ,IIF(a.Cargos=0,a.Abonos,(a.Cargos-a.Abonos)*-1) AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM Acum AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Gastos')
		AND c.Familia IN ('Generales')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Cuenta LIKE '51020-0007%'
	
		
		INSERT INTO @comparativo_btl
		SELECT 4
		   ,a.empresa
		   ,'GASTOS GENERALES'
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
		  ,CASE cc.Grupo
					WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
					WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
					WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
					WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
	       END AS 'Sucursal'
		  ,a.subcuenta
		  ,cc.Descripcion
		  ,-Cargos-Abonos AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM Acum AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Finanzas')
		AND c.Familia IN ('Otros Ingresos')
		AND a.Empresa IN ('CA','PTRNT')
		AND a.cuenta NOT LIKE '31020%'

--Inserta los datos de todas las cuentas financieras

    INSERT INTO @comparativo_btl
	SELECT 6,a.empresa,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,a.Ejercicio
		  ,a.periodo
		  ,CONVERT(VARCHAR(5),a.Periodo)+CONVERT(VARCHAR(10),a.Ejercicio)
			,CASE cc.Grupo
					WHEN 'XOCHIMILCO' THEN 'PLANTEL SUR'
					WHEN 'LOMAS VERDES' THEN 'PLANTEL NORTE'
					WHEN 'PRADO' THEN 'PLANTEL PONIENTE'
					WHEN 'HERRADURA' THEN 'PLANTEL HERRADURA'
				END AS 'Sucursal'
			,a.subcuenta
			,cc.Descripcion
		  ,Cargos-Abonos AS 'saldo'
		  ,'FINANCIERO' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Finanzas')
	  AND c.Familia IN ('Subsidio','Intereses Inversiones','Otros Ingresos','Intereses Bancarios','Fluctuacion')
	  AND a.Empresa IN ('CA','PTRNT')
	  AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL


   --Inserta dentro de la tabla de comparativo el ingreso neto		
   INSERT INTO @comparativo_btl(ID,Ejercicio,Periodo,PeriodoEjercicio,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
   SELECT 3,cb.Ejercicio,cb.Periodo,cb.PeriodoEjercicio,cb.NomSucursal,cb.CentroCostos,cb.NombreCC
	       ,IIF(cb.Titulo='INGRESOS OPERATIVOS',SUM(cb.Saldo),0)+IIF(cb.Titulo='BECAS Y DEDUCCIONES',SUM(cb.Saldo),0)
	       ,'INGRESOS NETOS'
			FROM @comparativo_btl AS cb
			GROUP BY cb.Ejercicio,cb.Periodo,cb.PeriodoEjercicio,cb.NomSucursal,cb.CentroCostos,cb.NombreCC,cb.Titulo
   
   --Insertar dentro de la tabla comparativo el resultado operativo   
	INSERT INTO @comparativo_btl(ID,Ejercicio,Periodo,PeriodoEjercicio,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 5
	      ,cb.Ejercicio
	      ,cb.Periodo
	      ,cb.PeriodoEjercicio
	      ,cb.NomSucursal
	      ,cb.CentroCostos
	      ,cb.NombreCC
	      --,100
	      ,IIF(cb.Titulo='INGRESOS NETOS' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0)+IIF(cb.Titulo='GASTOS' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0) AS 'ResultadoOperativo'
	      ,'RESULTADO OPERATIVO'
	FROM @comparativo_btl AS cb
	--ORDER BY cb.ID 
	
	--Inserta dentro de la tabla comparativo el resultado neto
	INSERT INTO @comparativo_btl(ID,Ejercicio,Periodo,PeriodoEjercicio,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 7
	      ,cb.Ejercicio
	      ,cb.Periodo
	      ,cb.PeriodoEjercicio
	      ,cb.NomSucursal
	      ,cb.CentroCostos
	      ,cb.NombreCC
	      --,100
	      ,IIF(cb.Titulo='RESULTADO OPERATIVO' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0)-IIF(cb.Titulo='FINANCIERO' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0) AS 'ResultadoNeto'
	      ,'RESULTADO NETO'
	FROM @comparativo_btl AS cb

	--Asignamos el rango de fechas de acuerdo al rango del periodo y año
	SET @PeriodoEjercicioD=CONVERT(VARCHAR(5),@PeriodoD)+CONVERT(VARCHAR(10),@EjercicioD)

	SET @PeriodoEjercicioA=CONVERT(VARCHAR(5),@PeriodoA)+CONVERT(VARCHAR(10),@EjercicioA)
		
	--Consulta general para el reporte
		SELECT cb.ID
			   ,cb.Concepto
			   ,cb.Ejercicio
			   ,cb.Periodo
			   ,cb.NomSucursal
			   ,cb.CentroCostos
			   ,cb.NombreCC
			   ,cb.Saldo
			   ,cb.Titulo
		FROM @comparativo_btl cb
		WHERE cb.PeriodoEjercicio BETWEEN @PeriodoEjercicioD AND @PeriodoEjercicioA
		--AND cb.Titulo IN ('INGRESOS OPERATIVOS','BECAS Y DEDUCCIONES','INGRESOS NETOS','GASTOS')
		ORDER BY cb.NomSucursal,cb.CentroCostos
		
		
END



--EXEC xpResultadoAcum 2016,3,2016,3

--EXEC xpIngresos 'CA',2016,'01','0,1,2,3,4'