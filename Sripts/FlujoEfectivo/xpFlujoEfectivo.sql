IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpFlujoEfectivo')
DROP PROCEDURE xpFlujoEfectivo
GO
CREATE PROCEDURE xpFlujoEfectivo
@ejercicio	INT
,@periodo	INT
AS
BEGIN
	DECLARE @TotalFlujoPesos	MONEY,
			@TotalFlujoUSD		MONEY,
			@TotalFlujoEUR		MONEY
	
	DECLARE @flujosEfectivo_tbl TABLE (
		Concepto		VARCHAR(100),
		Saldo			MONEY,
		Periodo			INT,
		Ejercicio		INT,
		TotalMXN		MONEY,
		TotalUSD		MONEY,
		TotalEUR		MONEY,
		Categoria		VARCHAR(25),
		Familia			VARCHAR(25)
	)
	
	--Crea totales para los flujos de efectivo en pesos, dolares y euros
	SET @TotalFlujoPesos=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							WHERE c.Categoria IN ('CuentasMXN')
								OR c.Familia IN ('CtaMXN')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio)
								
								
	SET @TotalFlujoUSD=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							WHERE c.Categoria IN ('CuentasUSD')
								OR c.Familia IN ('CtaUSD')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio)
	
	SET @TotalFlujoEUR=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0)) AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							WHERE c.Categoria IN ('CuentasEUR')
								OR c.Familia IN ('CtaEUR')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio)
	
	--Inserta a la tabla de flujosefectivo_tbl el flujo de efectivo en pesos, dolares y euros del periodo y año seleccionados
	INSERT INTO @flujosEfectivo_tbl	
	SELECT DISTINCT c.Descripcion
			,ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0) AS 'Saldo'
			,@periodo
			,@ejercicio
			,@TotalFlujoPesos AS 'TotalMXN'
			,@TotalFlujoUSD AS 'TotalUSD'
			,@TotalFlujoEUR AS 'TotalEUR'
			,c.Categoria
			,IIF(c.Familia IS NULL, IIF(c.Categoria='CuentasMXN','CtaMXN',IIF(c.Categoria='CuentasUSD','CtaUSD',IIF(c.Categoria='CuentasEUR','CtaEUR',c.Familia))),c.Familia) AS 'Familia'
	FROM Acum AS a
	JOIN Cta AS c ON c.Cuenta = a.Cuenta
	WHERE c.Categoria IN ('CuentasMXN','CuentasUSD','CuentasEUR','PATRONATO')
	OR c.Familia IN ('CtaMXN','CtaUSD','CtaEUR')
	AND a.Periodo=@periodo
	AND a.Ejercicio=@ejercicio

			
	--Inserta en la tabla TotalesFlujo el total de efectivo por cada moneda
	IF EXISTS(SELECT * FROM TotalesFlujo_tbl WHERE Ejercicio=@ejercicio AND Periodo=@periodo AND ID=1)
	BEGIN
		UPDATE TotalesFlujo_tbl SET ID=1,
								    Concepto='TOTAL CASH',
								    PesosMXN=@TotalFlujoPesos,
								    Dolares=@TotalFlujoUSD,
								    Euros=@TotalFlujoEUR,
								    Ejercicio=@ejercicio,
								    Periodo=@periodo
		WHERE Ejercicio=@ejercicio AND Periodo=@periodo AND ID=1
	END
	ELSE
		BEGIN
			INSERT INTO TotalesFlujo_tbl
			VALUES(1,'TOTAL CASH',@TotalFlujoPesos,@TotalFlujoUSD,@TotalFlujoEUR,@ejercicio,@periodo)
		END
	
	
	--Consulta principal para el reporte
	SELECT fet.Concepto
		  ,SUM(fet.Saldo) AS 'Saldo'
		  ,fet.TotalMXN
		  ,fet.TotalUSD
		  ,fet.TotalEUR
		  ,fet.Categoria
		  ,fet.Familia
		  ,fet.Periodo
		  ,fet.Ejercicio
	FROM @flujosEfectivo_tbl AS fet
	WHERE fet.Saldo <> 0
	GROUP BY fet.Concepto
		  ,fet.TotalMXN
		  ,fet.TotalUSD
		  ,fet.TotalEUR
		  ,fet.Categoria
		  ,fet.Familia
		  ,fet.Periodo
		  ,fet.Ejercicio
	
END


--EXEC xpFlujoEfectivo 2016,2