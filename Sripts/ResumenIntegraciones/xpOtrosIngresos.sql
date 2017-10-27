IF EXISTS(SELECT * FROM Sysobjects WHERE type='p' and name='xpOtrosIngresos')
DROP PROCEDURE xpOtrosIngresos
GO
CREATE PROCEDURE xpOtrosIngresos
@Ejercicio		INT,
@Periodo		INT
AS
BEGIN

		DECLARE @OtrosIngresos_tbl TABLE (
			Concepto		VARCHAR(150),
			Saldo			MONEY,
			Tipo			VARCHAR(50)
		)

		INSERT INTO @OtrosIngresos_tbl
			SELECT c.Descripcion,SUM(a.Abonos-a.Cargos),'otros'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta IN ('31020-0001-011','31020-0001-012','31020-0001-013')
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'
			GROUP BY c.Descripcion

		INSERT INTO @OtrosIngresos_tbl
			SELECT c.Descripcion,SUM(a.Abonos-a.Cargos),'otros'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta LIKE '31020-0002%'
			AND c.Descripcion LIKE 'Cuota por Examen de Admision'
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'
			GROUP BY c.Descripcion

		INSERT INTO @OtrosIngresos_tbl
			SELECT 'Varios',SUM(a.Abonos-a.Cargos),'otros'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta LIKE '31020-0002%'
			AND c.Cuenta NOT LIKE '31020-0002-000'
			AND c.Cuenta NOT LIKE '31020-0002-000'
			AND c.Cuenta NOT LIKE '31020-0002-005'
			AND c.Cuenta NOT LIKE '31020-0002-010'
			AND c.Cuenta NOT LIKE '31020-0002-008'
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'

		INSERT INTO @OtrosIngresos_tbl
			SELECT c.Descripcion,SUM(a.Abonos-a.Cargos),'otros'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta LIKE '31020-0004%'
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'
			GROUP BY c.Descripcion
		
		INSERT INTO @OtrosIngresos_tbl
			SELECT c.Descripcion,SUM(a.Abonos-a.Cargos),'otros'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta LIKE '31020-0005-000%'
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'
			GROUP BY c.Descripcion

		INSERT INTO @OtrosIngresos_tbl
			SELECT c.Descripcion,SUM(a.Abonos-a.Cargos),'talleres'
			FROM Acum AS a
			JOIN Cta AS c ON c.Cuenta = a.Cuenta
			WHERE c.Cuenta LIKE '31020-0005%'
			AND c.Cuenta NOT LIKE '31020-0005-000%'
			AND a.Ejercicio=@ejercicio
			AND a.Periodo=@periodo
			AND a.Empresa='CA'
			GROUP BY c.Descripcion

		SELECT Concepto
			   ,Saldo
			   ,Tipo
		FROM @OtrosIngresos_tbl
		ORDER BY Tipo

END

--xpOtrosIngresos 2016,2