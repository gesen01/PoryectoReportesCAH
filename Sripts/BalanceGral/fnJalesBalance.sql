IF EXISTS(SELECT * FROM sysobjects AS s WHERE s.[type]='FN' AND s.name='fnJalesBalance')
DROP FUNCTION fnJalesBalance
GO
CREATE FUNCTION fnJalesBalance(@cuenta VARCHAR(100))
RETURNS VARCHAR(255)
AS
BEGIN
	
	DECLARE @Concepto VARCHAR(100)
	
	SET @Concepto =(SELECT Valor FROM TablaStD AS tsd
					WHERE tsd.TablaSt='JalesBalanzaGral'
					AND tsd.Nombre=@cuenta)
					
	RETURN @Concepto
END



