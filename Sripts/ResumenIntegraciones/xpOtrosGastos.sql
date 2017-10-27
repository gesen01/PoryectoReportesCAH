IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpOtrosGastos')
DROP PROCEDURE xpOtrosGastos
GO
CREATE PROCEDURE xpOtrosGastos
@Ejercicio		INT,
@Periodo		INT
AS
BEGIN

		DECLARE @OtrosGastos_tbl TABLE (
			Concepto		VARCHAR(150),
			Saldo			MONEY,
			Tipo			VARCHAR(50)
		)

		INSERT INTO @OtrosGastos_tbl
			SELECT c.Descripcion,SUM(a.Cargos-a.Abonos),'otros'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta LIKE '51210-0000%'
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'
			GROUP BY c.Descripcion

		INSERT INTO @OtrosGastos_tbl
			SELECT c.Descripcion,SUM(a.Cargos-a.Abonos),'talleres'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta LIKE '51080-0000%'
			AND c.Cuenta NOT LIKE '51080-0000-000%'
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'
			GROUP BY c.Descripcion

		SELECT Concepto
			   ,Saldo
			   ,Tipo
		FROM @OtrosGastos_tbl

END

--xpOtrosGastos 2016,2