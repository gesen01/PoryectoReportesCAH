IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpTiposCambios')
DROP PROCEDURE xpTiposCambios
GO
CREATE PROCEDURE xpTiposCambios
@ejercicio	INT
,@periodo	INT
AS
BEGIN
	
	DECLARE @INPC	MONEY,
			@Euro	MONEY,
			@USD	MONEY
	
	DECLARE @TiposCambio_tbl TABLE(
		EUROS		MONEY,
		USD			MONEY,
		INPC		MONEY		
	)
	
	--Se obtiene el INPC del mes actual en el ejercicio actual
	SET @INPC =(SELECT tad.Importe
				FROM TablaAnual AS ta
				JOIN TablaAnualD tad ON tad.TablaAnual = ta.TablaAnual
				WHERE ta.TablaAnual='INPC'
				AND tad.Ejercicio=@ejercicio
				AND tad.Periodo=@periodo)
	
	--Se obtiene el tipo cambiario actual de euros y dolares
	SET @Euro=(SELECT TipoCambio
	           FROM Mon AS m
	           WHERE m.Moneda='Euros')
	
	SET @USD=(SELECT TipoCambio
	           FROM Mon AS m
	           WHERE m.Moneda='Dolares')
	
	INSERT INTO @TiposCambio_tbl(EUROS,USD,INPC)
	VALUES(@Euro,@USD,@INPC)
	
	
	SELECT EUROS,USD,ISNULL(INPC,0) AS 'INPC'
	FROM @TiposCambio_tbl
	
END

--EXEC xpTiposCambios 2016,2