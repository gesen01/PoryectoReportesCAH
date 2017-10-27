CREATE TABLE TotalesFlujo_tbl (
		ID				INT,
		Concepto		VARCHAR(100),
		PesosMXN		MONEY,
		Dolares			MONEY,
		Euros			MONEY,
		Ejercicio		INT,
		Periodo			INT
)

DROP TABLE TotalesFlujo_tbl

SELECT *
FROM TotalesFlujo_tbl
ORDER BY ID,Periodo ASC