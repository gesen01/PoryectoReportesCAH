IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpMovReservas')
DROP PROCEDURE xpMovReservas
GO
CREATE PROCEDURE xpMovReservas
@ejercicio	INT
,@periodo	INT
AS
BEGIN
	DECLARE @SaldoInicialMXN	MONEY,
			@SaldoInicialUSD	MONEY,
			@SaldoInicialEUR	MONEY,
			@ProcesoMesMXN		MONEY,
			@ProcesoMesUSD		MONEY,
			@ProcesoMesEUR		MONEY,
			@DepreInicialMXN	MONEY,
			@DepreInicialUSD	MONEY,
			@DepreInicialEUR	MONEY,
			@DepreciacionesMXN	MONEY,
			@DepreciacionesUSD	MONEY,
			@DepreciacionesEUR	MONEY,
			@MesAnt				INT,
			@AnioAnt			INT,
			@primerDiaMes		VARCHAR(50),
			@ultimoDiaMes		VARCHAR(50)
			
	DECLARE @Fondos_tbl  TABLE(
		Concepto		VARCHAR(100),
		PesosMXN		MONEY,
		Dolares			MONEY,
		Euros			MONEY,
		Tipo			VARCHAR(100),
		Categoria		VARCHAR(50)
	)
	
    -- Valida que el periodo sea el anterior al actual en año y mes
	
	IF @periodo=1
		BEGIN
			SET @MesAnt=12
			SET @AnioAnt=@ejercicio-1
		END
	ELSE
		BEGIN
			SET @MesAnt=@periodo-1
			SET @AnioAnt=@ejercicio
		END
	
	--Asignamos los saldos iniciales del mes anterior

	SET @SaldoInicialMXN=(SELECT SUM(cd.Debe-cd.Haber) AS 'SaldoMXN'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@MesAnt
							AND c.Ejercicio=@AnioAnt
							AND cd.Cuenta LIKE '12050%'
							AND c.OrigenMoneda='Pesos') 

	SET @SaldoInicialUSD =(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoUSD'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@MesAnt
							AND c.Ejercicio=@AnioAnt
							AND cd.Cuenta LIKE '12050%'
							AND c.OrigenMoneda='Dolares' 
	                     GROUP BY c.OrigenTipoCambio)


	SET @SaldoInicialEUR=(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoEUR'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@MesAnt
							AND c.Ejercicio=@AnioAnt
							AND cd.Cuenta LIKE '12050%'
							AND c.OrigenMoneda='Euros'
						GROUP BY c.OrigenTipoCambio)
	
	--Se asigna el saldo actual de las construcciones en proceso
	
	SET @ProcesoMesMXN=(SELECT SUM(cd.Debe-cd.Haber) AS 'SaldoMXN'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@Periodo
							AND c.Ejercicio=@Ejercicio
							AND cd.Cuenta LIKE '12050%'
							AND c.OrigenMoneda='Pesos') 

	SET @ProcesoMesUSD =(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoUSD'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@Periodo
							AND c.Ejercicio=@Ejercicio
							AND cd.Cuenta LIKE '12050%'
							AND c.OrigenMoneda='Dolares' 
	                     GROUP BY c.OrigenTipoCambio)


	SET @ProcesoMesEUR=(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoEUR'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@Periodo
							AND c.Ejercicio=@Ejercicio
							AND cd.Cuenta LIKE '12050%'
							AND c.OrigenMoneda='Euros'
						GROUP BY c.OrigenTipoCambio)
	
	--Asigna el valor de las depreciaciones iniciales del mes anterior		
	
	SET @DepreInicialMXN=(SELECT SUM(cd.Debe-cd.Haber) AS 'SaldoMXN'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@MesAnt
							AND c.Ejercicio=@AnioAnt
							AND cd.Cuenta LIKE '51110%'
							OR cd.Cuenta LIKE '51120%'
							OR Cd.Cuenta LIKE '51100%'
							AND c.OrigenMoneda='Pesos')
	
	SET @DepreInicialUSD=(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoUSD'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@MesAnt
							AND c.Ejercicio=@AnioAnt
							AND cd.Cuenta LIKE '51110%'
							OR cd.Cuenta LIKE '51120%'
							OR Cd.Cuenta LIKE '51100%'
							AND c.OrigenMoneda='Dolares' 
	                     GROUP BY c.OrigenTipoCambio)
	                     
	 SET @DepreInicialEUR=(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoEUR'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@MesAnt
							AND c.Ejercicio=@AnioAnt
							AND cd.Cuenta LIKE '51110%'
							OR cd.Cuenta LIKE '51120%'
							OR Cd.Cuenta LIKE '51100%'
							AND c.OrigenMoneda='Euros'
						GROUP BY c.OrigenTipoCambio)
	
	--Asigna el valor de las depreciaciones actuales
	
	SET @DepreciacionesMXN=(SELECT SUM(cd.Debe-cd.Haber) AS 'SaldoMXN'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@Periodo
							AND c.Ejercicio=@Ejercicio
							AND cd.Cuenta LIKE '51110%'
							OR cd.Cuenta LIKE '51120%'
							OR Cd.Cuenta LIKE '51100%'
							AND c.OrigenMoneda='Pesos')
	
	SET @DepreciacionesUSD=(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoUSD'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@Periodo
							AND c.Ejercicio=@Ejercicio
							AND cd.Cuenta LIKE '51110%'
							OR cd.Cuenta LIKE '51120%'
							OR Cd.Cuenta LIKE '51100%'
							AND c.OrigenMoneda='Dolares' 
	                     GROUP BY c.OrigenTipoCambio)
	                     
	 SET @DepreciacionesEUR=(SELECT SUM(cd.Debe-cd.Haber)/c.OrigenTipoCambio AS 'SaldoEUR'
							FROM Cont AS c
							JOIN ContD AS cd ON cd.ID = c.ID
							JOIN MovTipo AS mt ON mt.Mov = c.Mov
							WHERE mt.Modulo='CONT'
							AND mt.Clave='CONT.P'
							AND c.Estatus='CONCLUIDO'
							AND c.Empresa IN ('CA','PRTNT')
							AND IIF(C.Periodo=13,2,c.Periodo)=@Periodo
							AND c.Ejercicio=@Ejercicio
							AND cd.Cuenta LIKE '51110%'
							OR cd.Cuenta LIKE '51120%'
							OR Cd.Cuenta LIKE '51100%'
							AND c.OrigenMoneda='Euros'
						GROUP BY c.OrigenTipoCambio)
	
	SET @primerDiaMes=(SELECT UPPER(FORMAT(MIN(Fecha),'dd-MM-yyyy')) FROM Tiempo WHERE Mes=@periodo AND Anio=@Ejercicio)	
	
	SET @ultimoDiaMes=(SELECT UPPER(FORMAT(MAX(Fecha),'dd-MM-yyyy')) FROM Tiempo WHERE Mes=@periodo AND Anio=@Ejercicio)			
	
	-- Inserta los datos de Fondos a Largo Plazo
	INSERT INTO @Fondos_tbl(Concepto,PesosMXN,Dolares,Euros,Tipo)
	VALUES('SALDO INICIAL DEL '+@primerDiaMes,@SaldoInicialMXN,@SaldoInicialUSD,@SaldoInicialEUR,'LargoPlazo')
	
	INSERT INTO @Fondos_tbl(Concepto,PesosMXN,Dolares,Euros,Tipo)
	VALUES('CONSTRUC.EN PROCESO DEL MES',@ProcesoMesMXN,@ProcesoMesUSD,@ProcesoMesEUR,'LargoPlazo')
	
	INSERT INTO @Fondos_tbl
	SELECT 'SALDO FINAL AL '+@ultimoDiaMes,SUM(flpt.PesosMXN),SUM(flpt.Dolares),SUM(flpt.Euros),'LargoPlazo','Total'
	FROM @Fondos_tbl AS flpt
	WHERE flpt.Tipo LIKE 'LargoPlazo%'
	
	--Inserta los datos de Fondos de Obligaciones Laborales
	INSERT INTO @Fondos_tbl(Concepto,PesosMXN,Dolares,Euros,Tipo)
	VALUES('SALDO INICIAL DEL '+@primerDiaMes+' OBLIGACIONES LABORALES',@DepreInicialMXN,@DepreInicialUSD,@DepreInicialEUR,'ObligacionesLab')
	
	INSERT INTO @Fondos_tbl(Concepto,PesosMXN,Dolares,Euros,Tipo)
	VALUES('DEPRECIACIONES DEL MES',@DepreciacionesMXN,@DepreciacionesUSD,@DepreciacionesEUR,'ObligacionesLab')
	
	INSERT INTO @Fondos_tbl
	SELECT 'SALDO FINAL AL '+@ultimoDiaMes,SUM(flpt.PesosMXN),SUM(flpt.Dolares),SUM(flpt.Euros),'ObligacionesLab','Total'
	FROM @Fondos_tbl AS flpt
	WHERE flpt.Tipo LIKE 'ObligacionesLab%'
	
	--Inserta en la tabla de TotalesFlujo los totales para Largo plazo y obligaciones laborales
	IF EXISTS(SELECT * FROM TotalesFlujo_tbl WHERE Ejercicio=@ejercicio AND Periodo=@periodo AND ID IN(2,3))
	BEGIN
		UPDATE TotalesFlujo_tbl SET ID=2,
								    Concepto='FONDO LARGO PLAZO',
								    PesosMXN=(SELECT ft.PesosMXN*-1 FROM @Fondos_tbl AS ft WHERE ft.Categoria LIKE 'Total' AND ft.Tipo LIKE 'LargoPlazo'),
								    Dolares=(SELECT ft.Dolares-1 FROM @Fondos_tbl AS ft WHERE ft.Categoria LIKE 'Total' AND ft.Tipo LIKE 'LargoPlazo'),
								    Euros=(SELECT ft.Euros*-1 FROM @Fondos_tbl AS ft WHERE ft.Categoria LIKE 'Total' AND ft.Tipo LIKE 'LargoPlazo'),
								    Ejercicio=@ejercicio,
								    Periodo=@periodo
		WHERE Ejercicio=@ejercicio AND Periodo=@periodo AND ID=2
		
		UPDATE TotalesFlujo_tbl SET ID=3,
								    Concepto='FONDO OBLIGACIONES LABORALES',
								    PesosMXN=(SELECT ft.PesosMXN*-1 FROM @Fondos_tbl AS ft WHERE ft.Categoria LIKE 'Total' AND ft.Tipo LIKE 'ObligacionesLab'),
								    Dolares=(SELECT ft.Dolares-1 FROM @Fondos_tbl AS ft WHERE ft.Categoria LIKE 'Total' AND ft.Tipo LIKE 'ObligacionesLab'),
								    Euros=(SELECT ft.Euros*-1 FROM @Fondos_tbl AS ft WHERE ft.Categoria LIKE 'Total' AND ft.Tipo LIKE 'ObligacionesLab'),
								    Ejercicio=@ejercicio,
								    Periodo=@periodo
		WHERE Ejercicio=@ejercicio AND Periodo=@periodo AND ID=3
								    
	END
	ELSE
		BEGIN
			INSERT INTO TotalesFlujo_tbl
			SELECT 2,'FONDO LARGO PLAZO',ft.PesosMXN*-1,ft.Dolares*-1,ft.Euros*-1,@ejercicio,@periodo
			FROM @Fondos_tbl AS ft
			WHERE ft.Tipo LIKE 'LargoPlazo'
			AND ft.Categoria LIKE 'Total'
			
			INSERT INTO TotalesFlujo_tbl
			SELECT 3,'FONDO OBLIGACIONES LABORALES',ft.PesosMXN*-1,ft.Dolares*-1,ft.Euros*-1,@ejercicio,@periodo
			FROM @Fondos_tbl AS ft
			WHERE ft.Tipo LIKE 'ObligacionesLab'
			AND ft.Categoria LIKE 'Total'
		END
	
	
	
	
	--Se Obtiene la consulta principal para el reporte
	
	SELECT ft.Concepto
		   ,ft.PesosMXN
		   ,ft.Dolares
		   ,ft.Euros
		   ,ft.Tipo
		   ,ft.Categoria
	FROM @Fondos_tbl AS ft
	
END

--EXEC xpMovReservas 2016,2