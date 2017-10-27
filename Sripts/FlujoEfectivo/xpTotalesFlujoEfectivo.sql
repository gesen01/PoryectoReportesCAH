IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpTotalesFlujoEfectivo')
DROP PROCEDURE xpTotalesFlujoEfectivo
GO
CREATE PROCEDURE xpTotalesFlujoEfectivo
@ejercicio	INT
,@periodo	INT
AS
BEGIN
	DECLARE @TotalFlujoPesos	MONEY,
			@TotalFlujoUSD		MONEY,
			@TotalFlujoEUR		MONEY,
			@Subtotal			MONEY,
			@FondoAhorro		MONEY,
			@Total				MONEY,
			@DiferenciaBalance	MONEY,
			@FondosFijo			MONEY,
			@SaldoColegioMXN	MONEY,
			@SaldoColegioUSD	MONEY,
			@SaldoColegioEUR	MONEY,
			@SaldoColegio		MONEY,
			@SaldoPatronatoMXN	MONEY,
			@SaldoPatronatoUSD	MONEY,
			@SaldoPatronatoEUR	MONEY,
			@SaldoPatronato		MONEY,
			@TotalBalance		MONEY,
			@Balance			MONEY,
			@Diferencia			MONEY
			
	
	DECLARE @TotalesflujosEfectivo_tbl TABLE (
		ID				INT,
		Concepto		VARCHAR(100),
		Saldo			MONEY
	)
	
	--Crea totales para los flujos de efectivo en pesos, dolares y euros
	SET @TotalFlujoPesos=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Categoria IN ('CuentasMXN')
								OR c.Familia IN ('CtaMXN')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
	                      GROUP BY m.TipoCambio)
								
								
	SET @TotalFlujoUSD=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Categoria IN ('CuentasUSD')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
	                    GROUP BY m.TipoCambio)
	
	SET @TotalFlujoEUR=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Categoria IN ('CuentasEUR')
								OR c.Familia IN ('CtaEUR')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
	                    GROUP BY m.TipoCambio)
	
	SET @FondoAhorro=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
						 FROM Acum AS a
						 JOIN Cta AS c ON c.Cuenta = a.Cuenta
						 WHERE a.Periodo=@periodo
							AND a.Ejercicio=@ejercicio
							AND c.Cuenta LIKE '21020-0001-013')
	
	
	SET @Subtotal=@TotalFlujoEUR+@TotalFlujoUSD
	
	SET @Total=@Subtotal+@TotalFlujoPesos
	
	--SELECT @TOTAL AS 'Total'
	
	SET @FondosFijo=(SELECT SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
	                 FROM Acum AS a
					 JOIN Cta AS c ON c.Cuenta = a.Cuenta
	                 WHERE a.Periodo=@periodo
						AND a.Ejercicio=@ejercicio
						AND c.Cuenta LIKE '11010-0000-000') 
						
	SET @SaldoColegioMXN=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Categoria IN ('CuentasMXN')
								OR c.Familia IN ('CtaMXN')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
								AND c.Cuenta NOT IN ('11020-0001-009')
	                      GROUP BY m.TipoCambio)
	 
	 SET  @SaldoColegioUSD=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Categoria IN ('CuentasUSD')
								OR c.Familia IN ('CtaUSD')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
	                    GROUP BY m.TipoCambio)
	  
	  SET @SaldoColegioEUR=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Categoria IN ('CuentasEUR')
								OR c.Familia IN ('CtaEUR')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
	                    GROUP BY m.TipoCambio)
	
	SET @SaldoColegio=(@SaldoColegioMXN+@SaldoColegioUSD+@SaldoColegioEUR)+@FondoAhorro
	
	SET @SaldoPatronatoMXN=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Familia IN ('CtaMXN')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
								AND c.Categoria IN ('PATRONATO')
	                      GROUP BY m.TipoCambio)
	
	SET @SaldoPatronatoUSD=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Familia IN ('CtaUSD')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
								AND c.Categoria IN ('PATRONATO')
	                    GROUP BY m.TipoCambio)
	
	SET @SaldoPatronatoEUR=(SELECT SUM(DISTINCT ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))*m.TipoCambio AS 'Saldo'
							FROM Acum AS a
							JOIN Cta AS c ON c.Cuenta = a.Cuenta
							JOIN Mon AS m ON m.Moneda = a.Moneda
							WHERE c.Familia IN ('CtaEUR')
								AND a.Periodo=@periodo
								AND a.Ejercicio=@ejercicio
								AND c.Categoria IN ('PATRONATO')
	                    GROUP BY m.TipoCambio)
	
	SET @SaldoPatronato=ISNULL(@SaldoPatronatoMXN,0)+ISNULL(@SaldoPatronatoUSD,0)+ISNULL(@SaldoPatronatoEUR,0)
	
	SET @TotalBalance=@SaldoColegio+ISNULL(@SaldoPatronato,0)
	
	--SELECT @TotalBalance AS 'TotalBalance',@SaldoColegio AS 'SaldoColegio',@SaldoPatronato AS 'SaldoPatronato'
	
	SET @Balance=@TotalBalance+ISNULL(@FondosFijo,0)
	
	--SELECT @TotalBalance 'Balance', @FondosFijo  'FondosFijos'
	
	SET @DiferenciaBalance=@Total-@Balance


	SET @Diferencia=@DiferenciaBalance+@FondosFijo
	
	--Inserta a la tabla de Totalesflujosefectivo_tbl el flujo de efectivo en pesos, dolares y euros del periodo y año seleccionados
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(1,'EUROS',@TotalFlujoEUR)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(2,'DLLS',@TotalFlujoUSD)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(3,'SUB-TOTAL',@Subtotal)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(4,'PESOS',@TotalFlujoPesos)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(5,'TOTAL',@Total)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(6,'S/BALANCE',@Balance)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(7,'DIF. BALANCE',@DiferenciaBalance)

	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(8,'FONDOS FIJOS',@FondosFijo)	
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(9,'DIF.',@Diferencia)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(10,'COLEGIO',@SaldoColegio)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(11,'PATRONATO',@SaldoPatronato)
	
	INSERT INTO @TotalesflujosEfectivo_tbl(ID,Concepto,Saldo)
	VALUES(12,'TOTAL S/BALANCE',@TotalBalance)
	
	
	--Consulta principal para el reporte
	SELECT tet.ID
		   ,tet.Concepto
		   ,ISNULL(tet.Saldo,0) AS 'Saldo'
	FROM @TotalesflujosEfectivo_tbl AS tet
END


--EXEC xpTotalesFlujoEfectivo 2016,2