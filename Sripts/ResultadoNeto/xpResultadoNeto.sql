IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpResultadoNeto')
DROP PROCEDURE xpResultadoNeto
GO
CREATE PROCEDURE xpResultadoNeto
@Ejercicio		INT,
@Periodo		INT
AS
BEGIN

	DECLARE @comparativo_btl TABLE(
		ID					INT,
		Empresa				VARCHAR(50),
		Concepto			VARCHAR(255),
		Ejercicio			INT,
		Periodo				INT,
		NomSucursal			VARCHAR(100),
		CentroCostos		VARCHAR(10),
		NombreCC			VARCHAR(100),
		Saldo				MONEY,
		Titulo				VARCHAR(100),
		SaldoConsolidado	MONEY
	)

	DECLARE @Consolidado TABLE (
		ID						INT,
		Ejercicio				INT,
		Periodo					INT,
		Saldo					MONEY,
		Titulo					VARCHAR(50)
	)

	DECLARE @CentroCostos TABLE(
		CentroCostos		VARCHAR(10),
		Descripcion			VARCHAR(50),
		Grupo				VARCHAR(50),
		Sucursal			INT
	)

	--Inserta los respectivos centro de costo de acuerdo a la sucursal correspondiente
	INSERT INTO @CentroCostos
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

	INSERT INTO @comparativo_btl(ID,Empresa,Concepto,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 1
			 ,a. empresa
			 ,'Colegiaturas recibidas'
			 ,a.Ejercicio
			 ,IIF(a.periodo=13,2,a.periodo)
			 ,cc.Grupo
			  ,a.subcuenta
			  ,cc.Descripcion
			 ,IIF(Cargos=0,Abonos,(Cargos-Abonos)*-1) AS 'saldo'
			 ,'INGRESOS OPERATIVOS' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN @CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Ingresos', 'Activos')
	AND c.Familia IN ('Colegiaturas')
	AND a.Empresa IN ('CA','PTRNT')
	AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL

	INSERT INTO @comparativo_btl(ID,Empresa,Concepto,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 1
			  ,a. empresa
			  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
			  ,a.Ejercicio
			  ,IIF(a.periodo=13,2,a.periodo)
			  ,cc.Grupo
			  ,a.subcuenta
			  ,cc.Descripcion
			  ,IIF(Cargos=0,Abonos,Cargos-Abonos) AS 'saldo'
			  ,'INGRESOS OPERATIVOS' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN @CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Ingresos', 'Activos')
	AND c.Familia IN ('Colegiaturas','Inscripciones','Donativos')
	AND a.Empresa IN ('CA','PTRNT')
	AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
	AND dbo.fnJalesContabilidad(a.Cuenta) <>'Colegiaturas recibidas'


  --Inserta los datos de todas las cuentas con becas

	INSERT INTO @comparativo_btl(ID,Empresa,Concepto,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 2,a.empresa,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,a.Ejercicio,a.periodo
		  ,cc.Grupo
			,a.subcuenta
			,cc.Descripcion
		  ,-Cargos-Abonos AS 'saldo'
		  ,'BECAS Y DEDUCCIONES' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN @CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta 
	WHERE c.Categoria IN ('Becas')
	  AND c.Familia IN ('SEP/UNAM','Consejo','Profesores/Empleados')
	  AND a.Empresa IN ('CA','PTRNT')
	  AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL

	--Inserta los datos de todas las cuentas con gastos

    INSERT INTO @comparativo_btl(ID,Empresa,Concepto,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 4
		  ,a.empresa
		  ,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,cc.Grupo
		  ,a.subcuenta
		  ,cc.Descripcion
		  ,IIF(a.Cargos=0,a.Abonos,(a.Cargos-a.Abonos)*-1) AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM Acum AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Gastos')
		AND c.Familia IN ('Personal Administrativo','Personal Docente','Generales')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Cuenta NOT LIKE '51020-0007%'
		
		INSERT INTO @comparativo_btl(ID,Empresa,Concepto,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
		SELECT 4
		  ,a.empresa
		  ,'GASTOS GENERALES'
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,cc.Grupo
		  ,a.subcuenta
		  ,cc.Descripcion
		  ,IIF(a.Cargos=0,a.Abonos,(a.Cargos-a.Abonos)*-1) AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM Acum AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Gastos')
		AND c.Familia IN ('Generales')
		AND a.Empresa IN ('CA','PTRNT')
		AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
		AND a.Cuenta LIKE '51020-0007%'
		
		INSERT INTO @comparativo_btl(ID,Empresa,Concepto,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
		SELECT 4
		   ,a.empresa
		   ,'GASTOS GENERALES'
		  ,a.Ejercicio
		  ,IIF(a.periodo=13,2,a.periodo)
		  ,cc.Grupo
		  ,a.subcuenta
		  ,cc.Descripcion
		  ,-Cargos-Abonos AS 'saldo'
		  ,'GASTOS' AS 'Titulo'
		FROM Acum AS a
		JOIN Cta AS c ON c.Cuenta = a.Cuenta
		JOIN @CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
		WHERE c.Categoria IN ('Finanzas')
		AND c.Familia IN ('Otros Ingresos')
		AND a.Empresa IN ('CA','PTRNT')
		AND a.cuenta NOT LIKE '31020%'

--Inserta los datos de todas las cuentas financieras

    INSERT INTO @comparativo_btl(ID,Empresa,Concepto,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 6,a.empresa,dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
		  ,a.Ejercicio,a.periodo
			,cc.Grupo
			,a.subcuenta
			,cc.Descripcion
		  ,Cargos-Abonos AS 'saldo'
		  ,'FINANCIERO' AS 'Titulo'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	JOIN @CentroCostos AS cc ON cc.CentroCostos=a.SubCuenta
	WHERE c.Categoria IN ('Finanzas')
	  AND c.Familia IN ('Subsidio','Intereses Inversiones','Otros Ingresos','Intereses Bancarios','Fluctuacion')
	  AND a.Empresa IN ('CA','PTRNT')
	  AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL


   --Inserta dentro de la tabla de comparativo el ingreso neto		
   INSERT INTO @comparativo_btl(ID,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
   SELECT 3,cb.Ejercicio,cb.Periodo,cb.NomSucursal,cb.CentroCostos,cb.NombreCC
	       ,IIF(cb.Titulo='INGRESOS OPERATIVOS',SUM(cb.Saldo),0)+IIF(cb.Titulo='BECAS Y DEDUCCIONES',SUM(cb.Saldo),0)
	       ,'INGRESOS NETOS'
			FROM @comparativo_btl AS cb
			GROUP BY cb.Ejercicio,cb.Periodo,cb.NomSucursal,cb.CentroCostos,cb.NombreCC,cb.Titulo
   
   --Insertar dentro de la tabla comparativo el resultado operativo   
	INSERT INTO @comparativo_btl(ID,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 5
	      ,cb.Ejercicio
	      ,cb.Periodo
	      ,cb.NomSucursal
	      ,cb.CentroCostos
	      ,cb.NombreCC
	      --,100
	      ,IIF(cb.Titulo='INGRESOS NETOS' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0)+IIF(cb.Titulo='GASTOS' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0) AS 'ResultadoOperativo'
	      ,'RESULTADO OPERATIVO'
	FROM @comparativo_btl AS cb
	--ORDER BY cb.ID 
	
	--Inserta dentro de la tabla comparativo el resultado neto
	INSERT INTO @comparativo_btl(ID,Ejercicio,Periodo,NomSucursal,CentroCostos,NombreCC,Saldo,Titulo)
	SELECT 7
	      ,cb.Ejercicio
	      ,cb.Periodo
	      ,cb.NomSucursal
	      ,cb.CentroCostos
	      ,cb.NombreCC
	      --,100
	      ,IIF(cb.Titulo='RESULTADO OPERATIVO' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0)-IIF(cb.Titulo='FINANCIERO' OR cb.Titulo IS NULL,ISNULL(cb.Saldo,0),0) AS 'ResultadoNeto'
	      ,'RESULTADO NETO'
	FROM @comparativo_btl AS cb
	WHERE cb.Ejercicio=@Ejercicio
	AND cb.Periodo=@Periodo
		
	--Inserta en la tabla de consolidado el resultado total de cada concepto
		-- INGRESOS OPERATIVOS
		 INSERT INTO @Consolidado
			 SELECT 1
				    ,cb.Ejercicio
				    ,cb.Periodo
					,SUM(cb.Saldo)
				   ,cb.Titulo
			FROM @comparativo_btl cb
			WHERE cb.Periodo=@Periodo
			AND cb.Ejercicio=@Ejercicio
			AND cb.Titulo IN ('INGRESOS OPERATIVOS')
			GROUP BY cb.ejercicio,cb.periodo,cb.Titulo
		
		--BECAS Y DEDUCCCIONES
		 INSERT INTO @Consolidado
			 SELECT 2
				   ,cb.Ejercicio
				   ,cb.Periodo
				   ,SUM(cb.Saldo)
				   ,cb.Titulo
			FROM @comparativo_btl cb
			WHERE cb.Periodo=@Periodo
			AND cb.Ejercicio=@Ejercicio
			AND cb.Titulo IN ('BECAS Y DEDUCCIONES')
			GROUP BY cb.ejercicio,cb.periodo,cb.Titulo
		 
		 --INGRESOS NETOS
		 INSERT INTO @Consolidado
			SELECT 3
				 ,c.Ejercicio
				 ,c.Periodo
				 ,SUM(IIF(c.Titulo='INGRESOS OPERATIVOS',c.Saldo,0)+IIF(C.Titulo='BECAS Y DEDUCCIONES',c.Saldo,0))
				 ,'INGRESOS NETOS'
			FROM @Consolidado AS c
			GROUP BY c.Ejercicio,c.Periodo
				 
		  --GASTOS
		  INSERT INTO @Consolidado
			SELECT 4
					,cb.Ejercicio
					,cb.Periodo
					,SUM(cb.Saldo)
				   ,cb.Titulo
			FROM @comparativo_btl cb
			WHERE cb.Periodo=@Periodo
			AND cb.Ejercicio=@Ejercicio 
			AND cb.Titulo IN ('GASTOS')
			GROUP BY cb.ejercicio,cb.periodo,cb.Titulo
			
		--RESULTADO OPERATIVO
		 INSERT INTO @Consolidado
		 	SELECT 5
		 		  ,cb.Ejercicio
		 		  ,cb.Periodo
				  ,SUM(IIF(cb.Titulo='INGRESOS OPERATIVOS',cb.Saldo,0)+IIF(Cb.Titulo='BECAS Y DEDUCCIONES',cb.Saldo,0))+SUM(IIF(Cb.Titulo='GASTOS',cb.Saldo,0))
				  ,'RESULTADO OPERATIVO'
			FROM @comparativo_btl AS cb
			WHERE cb.Periodo=@Periodo
			AND cb.Ejercicio=@Ejercicio 
			GROUP BY cb.ejercicio,cb.periodo,cb.Titulo
			
		 --FINANCIERO
		 INSERT INTO @Consolidado
		 	SELECT 6
		 		   ,cb.Ejercicio
		 		   ,cb.Periodo
		 		   ,SUM(cb.Saldo)
				   ,cb.Titulo
			FROM @comparativo_btl cb
			WHERE cb.Periodo=@Periodo
			AND cb.Ejercicio=@Ejercicio 
			AND cb.Titulo IN ('FINANCIERO')
			GROUP BY cb.ejercicio,cb.periodo,cb.Titulo
		 	
		 --RESULTADO NETO
		 INSERT INTO @Consolidado
			  SELECT 7
					  ,cb.Ejercicio
					  ,cb.Periodo
					  ,(SUM(IIF(cb.Titulo='INGRESOS OPERATIVOS',cb.Saldo,0)+IIF(Cb.Titulo='BECAS Y DEDUCCIONES',cb.Saldo,0))+SUM(IIF(Cb.Titulo='GASTOS',cb.Saldo,0)))-SUM(IIF(Cb.Titulo='FINANCIERO',cb.Saldo,0))
					  ,'RESULTADO NETO'
				FROM @comparativo_btl AS cb
				WHERE cb.Periodo=@Periodo
				AND cb.Ejercicio=@Ejercicio 
				GROUP BY cb.ejercicio,cb.periodo,cb.Titulo
		
		INSERT INTO @comparativo_btl(ID,Ejercicio,Periodo,Titulo,SaldoConsolidado)
			SELECT c.ID,c.Ejercicio,c.Periodo,c.Titulo,c.Saldo
			FROM @Consolidado c
	  	
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
			   ,cb.SaldoConsolidado
		FROM @comparativo_btl cb
		WHERE cb.Periodo=@Periodo
		AND cb.Ejercicio=@Ejercicio
		--AND cb.Titulo IN ('INGRESOS OPERATIVOS','BECAS Y DEDUCCIONES','INGRESOS NETOS','GASTOS')
		ORDER BY cb.NomSucursal,cb.CentroCostos
		
		
END



--EXEC xpResultadoNeto 2016,2

--EXEC xpIngresos 'CA',2016,'01','0,1,2,3,4'
