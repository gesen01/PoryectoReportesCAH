IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpTotalesCiclo')
DROP PROCEDURE xpTotalesCiclo
GO
CREATE PROCEDURE xpTotalesCiclo
@FechaInicioCiclo	DATETIME,
@FechaFinCiclo		DATETIME
AS
BEGIN
	DECLARE @TotalesCiclo_tbl TABLE (
		Saldo		MONEY,
		Concepto	VARCHAR(50)
	)
	
	
	INSERT INTO @TotalesCiclo_tbl
	SELECT SUM(ISNULL(cd.Debe,0)-ISNULL(cd.haber,0)),'DEPOSITO EN GARANTIA'
	FROM Cont AS c
	JOIN ContD AS cd ON cd.ID = c.ID
	JOIN Cta AS c2 ON c2.Cuenta = cd.Cuenta
	WHERE C.Empresa='CA'
	AND cd.Cuenta LIKE '13020%'
	AND c.FechaEmision BETWEEN @FechaInicioCiclo AND @FechaFinCiclo

	
	INSERT INTO @TotalesCiclo_tbl
	SELECT SUM(ISNULL(cd.Debe,0)-ISNULL(cd.haber,0)),'VIAJE DE GRUPO'
	FROM Cont AS c
	JOIN ContD AS cd ON cd.ID = c.ID
	JOIN Cta AS c2 ON c2.Cuenta = cd.Cuenta
	WHERE C.Empresa='CA'
	AND cd.Cuenta IN ('21020-0002-028','21020-0002-029','21020-0002-030')
	AND c.FechaEmision BETWEEN @FechaInicioCiclo AND @FechaFinCiclo

	INSERT INTO @TotalesCiclo_tbl
	SELECT SUM(ISNULL(cd.Debe,0)-ISNULL(cd.haber,0)) AS 'Saldo','Transporte Ciclo'
	FROM Cont AS c
	JOIN ContD AS cd ON cd.ID = c.ID
	JOIN Cta AS c2 ON c2.Cuenta = cd.Cuenta
	WHERE cd.Cuenta LIKE  '23050-0001%'
	OR cd.Cuenta LIKE  '23050-0002%'
	OR cd.Cuenta LIKE  '23050-0003%'
    AND c.FechaEmision BETWEEN @FechaInicioCiclo AND @FechaFinCiclo
    AND c.Empresa='CA'

	INSERT INTO @TotalesCiclo_tbl
	SELECT SUM(ISNULL(cd.Debe,0)-ISNULL(cd.haber,0)) AS 'Saldo','COBROS ANTICIPADOS'
	FROM Cont AS c
	JOIN ContD AS cd ON cd.ID = c.ID
	JOIN Cta AS c2 ON c2.Cuenta = cd.Cuenta
	WHERE cd.Cuenta LIKE  '23010%'
	OR cd.Cuenta LIKE  '23020%'
    AND c.FechaEmision BETWEEN @FechaInicioCiclo AND @FechaFinCiclo
    AND c.Empresa='CA'
	
	
	SELECT tct.Saldo,tct.Concepto
	FROM @TotalesCiclo_tbl AS tct
END


--EXEC xpTotalesCiclo '20150824','20160715'