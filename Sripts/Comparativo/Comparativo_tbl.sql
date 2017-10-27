CREATE TABLE Comparativo_tbl(
	Cuenta			VARCHAR(20),
	Saldo			MONEY,
	Descripcion		VARCHAR(50),
	Periodo			INT,
	Ejercicio		INT,
	Empresa			VARCHAR(10)
)

DROP TABLE Comparativo_tbl
SELECT *
FROM Comparativo_tbl AS ct
