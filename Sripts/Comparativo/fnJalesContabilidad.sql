IF EXISTS(SELECT * FROM sysobjects AS s WHERE s.[type]='FN' AND s.name='fnJalesContabilidad')
DROP FUNCTION fnJalesContabilidad
GO
CREATE FUNCTION fnJalesContabilidad(@cuenta VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
	
	DECLARE @Concepto VARCHAR(100)
	
	SET @Concepto =(SELECT Valor FROM TablaStD AS tsd
					WHERE tsd.TablaSt='JALESContabilidad'
					AND tsd.Nombre=@cuenta)
					
	RETURN @Concepto
END


SELECT dbo.fnJalesContabilidad(a.Cuenta) AS 'Concepto'
      ,a.Ejercicio,a.periodo,a.sucursal,a.subcuenta
      ,SUM(Abonos) AS 'saldo' 
FROM Acum AS a
JOIN Cta AS c ON c.Cuenta = a.Cuenta
WHERE c.Categoria IN ('Ingresos', 'Activos')
AND c.Familia IN ('Colegiaturas','Inscripciones','Donativos')
AND a.Empresa='CA'
AND a.Ejercicio=2016
AND dbo.fnJalesContabilidad(a.Cuenta) IS NOT NULL
GROUP BY dbo.fnJalesContabilidad(a.Cuenta),a.ejercicio,a.Periodo,a.Sucursal,a.SubCuenta



SELECT * FROM Cta AS c
WHERE c.Categoria IS NOT NULL