USE CATEST
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.xpVerContBalance
@Empresa		varchar(5),
@Ejercicio		int,
@PeriodoA		int
AS BEGIN
DECLARE
@ID			int,
@Lado		int,
@UltLado		int,
@Renglon		int,
@UltRenglon		int,
@UltRama		varchar(20),
@UltRama1		varchar(20),
@UltRama2		varchar(20),
@LadoDesc		varchar(100),
@UltLadoDesc	varchar(100),
@Rama		varchar(20),
@RamaDesc		varchar(100),
@Cuenta		varchar(20),
@Descripcion	varchar(100),
@EsAcreedora	bit,
@EsTitulo		bit,
@EsFinRama		bit,
@EsFinLado		bit,
@Saldo    		money,
@CtaActivo		varchar(20),
@CtaPasivo		varchar(20),
@CtaCapital		varchar(20),
@CtaResultados	varchar(20),
@ContMoneda		varchar(10)
CREATE TABLE #Balance(
ID			int		IDENTITY(1,1) NOT NULL,
Renglon 		int		NULL,
EsTitulo		bit		NOT NULL DEFAULT 0,
EsFinRama		bit		NOT NULL DEFAULT 0,
EsFinLado		bit		NOT NULL DEFAULT 0,
Lado		int		NULL,
LadoDesc		varchar(20)	COLLATE Database_Default NULL,
Rama		varchar(20)	COLLATE Database_Default NULL,
RamaDesc		varchar(100)	COLLATE Database_Default NULL,
Cuenta		varchar(20)	COLLATE Database_Default NULL,
Descripcion	varchar(100)	COLLATE Database_Default NULL,
EsAcreedora	bit		NOT NULL DEFAULT 0,
Saldo		money		NULL,
CONSTRAINT priTempBalance PRIMARY KEY CLUSTERED (ID)
)
CREATE TABLE #VerBalance(
Renglon 		int		NULL,
Lado		int		NULL,
EsTitulo1		bit		NOT NULL DEFAULT 0,
EsFinRama1		bit		NOT NULL DEFAULT 0,
EsFinLado1		bit		NOT NULL DEFAULT 0,
LadoDesc1		varchar(20)	COLLATE Database_Default NULL,
Rama1		varchar(20)	COLLATE Database_Default NULL,
RamaDesc1		varchar(100)	COLLATE Database_Default NULL,
Cuenta1		varchar(20)	COLLATE Database_Default NULL,
Descripcion1	varchar(100)	COLLATE Database_Default NULL,
EsAcreedora1	bit		NOT NULL DEFAULT 0,
Saldo1		money		NULL,
EsTitulo2		bit		NOT NULL DEFAULT 0,
EsFinRama2		bit		NOT NULL DEFAULT 0,
EsFinLado2		bit		NOT NULL DEFAULT 0,
LadoDesc2		varchar(20)	COLLATE Database_Default NULL,
Rama2		varchar(20)	COLLATE Database_Default NULL,
RamaDesc2		varchar(100)	COLLATE Database_Default NULL,
Cuenta2		varchar(20)	COLLATE Database_Default NULL,
Descripcion2	varchar(100)	COLLATE Database_Default NULL,
EsAcreedora2	bit		NOT NULL DEFAULT 0,
Saldo2		money		NULL
)

SELECT @CtaActivo	  = CtaActivo,
@CtaPasivo	  = CtaPasivo,
@CtaCapital	  = CtaCapital,
@CtaResultados  = CtaResultados,
@ContMoneda	  = ContMoneda
FROM EmpresaCfg
WHERE Empresa = @Empresa

INSERT #Balance
SELECT 0,0,0,0,1,
'Activo',
E2.Cuenta,
E2.Descripcion,
Cta.Cuenta,
Cta.Descripcion,
Cta.EsAcreedora,
NULL
FROM Cta, Cta E1, Cta E2
WHERE Cta.Rama   = E2.Cuenta
AND E2.Rama    = E1.Cuenta
AND UPPER(Cta.Tipo) = 'MAYOR'
AND (Cta.Rama = @CtaActivo OR E1.Rama = @CtaActivo OR E2.Rama = @CtaActivo)
ORDER BY Cta.Cuenta
INSERT #Balance
SELECT 0,0,0,0,2,
'Pasivo',
E2.Cuenta,
E2.Descripcion,
Cta.Cuenta,
Cta.Descripcion,
Cta.EsAcreedora,
NULL
FROM Cta, Cta E1, Cta E2
WHERE Cta.Rama   = E2.Cuenta
AND E2.Rama    = E1.Cuenta
AND UPPER(Cta.Tipo) = 'MAYOR'
AND (Cta.Rama = @CtaPasivo OR E1.Rama = @CtaPasivo OR E2.Rama = @CtaPasivo)
ORDER BY Cta.Cuenta
INSERT #Balance
SELECT 0,0,0,0,2,
'Capital',
E2.Cuenta,
E2.Descripcion,
Cta.Cuenta,
Cta.Descripcion,
Cta.EsAcreedora,
NULL
FROM Cta, Cta E1, Cta E2
WHERE Cta.Rama   = E2.Cuenta
AND E2.Rama    = E1.Cuenta
AND UPPER(Cta.Tipo) = 'MAYOR'
AND (Cta.Rama = @CtaCapital OR E1.Rama = @CtaCapital OR E2.Rama = @CtaCapital)
ORDER BY Cta.Cuenta
INSERT #Balance
SELECT 0,0,0,0,2,
'Capital',
E2.Cuenta,
E2.Descripcion,
Cta.Cuenta,
Cta.Descripcion,
Cta.EsAcreedora,
NULL
FROM Cta, Cta E2
WHERE E2.Cuenta = @CtaCapital
AND Cta.Cuenta = @CtaResultados
ORDER BY Cta.Cuenta
SELECT @UltLado = NULL, @UltRama = NULL, @UltLadoDesc = NULL
DECLARE crBalance CURSOR FOR
SELECT ID, Lado, LadoDesc, Rama, RamaDesc, EsTitulo, Cuenta
FROM #Balance b
OPEN crBalance
FETCH NEXT FROM crBalance INTO @ID, @Lado, @LadoDesc, @Rama, @RamaDesc, @EsTitulo, @Cuenta
WHILE @@FETCH_STATUS <> -1 AND @@Error = 0
BEGIN
IF @@FETCH_STATUS <> -2 AND @EsTitulo = 0
BEGIN
SELECT @Saldo = NULL
SELECT @Saldo = SUM(ISNULL(a.Cargos, 0.0)-ISNULL(a.Abonos, 0.0))
FROM Acum a
WHERE a.Empresa = @Empresa
AND a.Rama = 'CONT'
AND a.Cuenta = @Cuenta
AND a.Ejercicio = @Ejercicio
AND a.Periodo BETWEEN 0 AND @PeriodoA
IF ISNULL(@Saldo, 0.0) = 0.0 
DELETE FROM #Balance WHERE ID = @ID
ELSE
BEGIN
IF @Rama <> @UltRama
BEGIN
SELECT @Renglon = @Renglon + 1
INSERT #Balance (EsTitulo, EsFinRama, Renglon, Lado) VALUES (1, 1, @Renglon, @UltLado)
END
IF @UltLadoDesc<>@LadoDesc
BEGIN
SELECT @Renglon = @Renglon + 1
INSERT #Balance (EsTitulo, EsFinLado, Renglon, Lado) VALUES (1, 1, @Renglon, @UltLado)
END
IF @Lado <> @UltLado SELECT @Renglon = 1 ELSE SELECT @Renglon = @Renglon + 1
IF @Rama <> @UltRama
BEGIN
INSERT #Balance (EsTitulo, Renglon, Lado, Descripcion) VALUES (1, @Renglon, @Lado, @RamaDesc)
SELECT @Renglon = @Renglon + 1
END
UPDATE #Balance
SET Renglon = @Renglon,
Saldo = @Saldo
WHERE ID = @ID
SELECT @UltLado = @Lado, @UltLadoDesc = @LadoDesc, @UltRama = @Rama
END
END
FETCH NEXT FROM crBalance INTO @ID, @Lado, @LadoDesc, @Rama, @RamaDesc, @EsTitulo, @Cuenta
END
SELECT @Renglon = @Renglon + 1
INSERT #Balance (EsTitulo, EsFinRama, Renglon, Lado) VALUES (1, 1, @Renglon, @UltLado)
SELECT @Renglon = @Renglon + 1
INSERT #Balance (EsTitulo, EsFinLado, Renglon, Lado) VALUES (1, 1, @Renglon, @UltLado)
CLOSE crBalance
DEALLOCATE crBalance
SELECT @UltRenglon = NULL, @UltRama1 = NULL, @UltRama2 = NULL
DECLARE crVerBalance CURSOR FOR
SELECT EsTitulo, EsFinRama, EsFinLado, Renglon, Lado, LadoDesc, Rama, RamaDesc, Cuenta, Descripcion, EsAcreedora, Saldo
FROM #Balance ORDER BY Renglon, Lado, Rama
OPEN crVerBalance
FETCH NEXT FROM crVerBalance INTO @EsTitulo, @EsFinRama, @EsFinLado, @Renglon, @Lado, @LadoDesc, @Rama, @RamaDesc, @Cuenta, @Descripcion, @EsAcreedora, @Saldo
WHILE @@FETCH_STATUS <> -1 AND @@Error = 0
BEGIN
IF @@FETCH_STATUS <> -2
BEGIN
IF @Lado = 1
BEGIN
IF @UltRenglon <> @Renglon 
INSERT #VerBalance (Renglon, Lado, EsTitulo1, EsFinRama1, EsFinLado1, LadoDesc1, Rama1, RamaDesc1, Cuenta1, Descripcion1, EsAcreedora1, Saldo1)
VALUES (@Renglon, @Lado, @EsTitulo, @EsFinRama, @EsFinLado, @LadoDesc, @Rama, @RamaDesc, @Cuenta, @Descripcion, @EsAcreedora, @Saldo)
ELSE
UPDATE #VerBalance
SET EsTitulo1 = @EsTitulo, EsFinRama1 = @EsFinRama, EsFinLado1 = @EsFinLado, LadoDesc1 = @LadoDesc, Rama1 = @Rama, RamaDesc1 = @RamaDesc, Cuenta1 = @Cuenta, Descripcion1 = @Descripcion, EsAcreedora1 = @EsAcreedora, Saldo1 = @Saldo
WHERE Renglon = @Renglon
END ELSE BEGIN
IF @UltRenglon <> @Renglon 
INSERT #VerBalance (Renglon, Lado, EsTitulo2, EsFinRama2, EsFinLado2, LadoDesc2, Rama2, RamaDesc2, Cuenta2, Descripcion2, EsAcreedora2, Saldo2)
VALUES (@Renglon, @Lado, @EsTitulo, @EsFinRama, @EsFinLado, @LadoDesc, @Rama, @RamaDesc, @Cuenta, @Descripcion, @EsAcreedora, @Saldo)
ELSE
UPDATE #VerBalance
SET EsTitulo2 = @EsTitulo, EsFinRama2 = @EsFinRama, EsFinLado2 = @EsFinLado, LadoDesc2 = @LadoDesc, Rama2 = @Rama, RamaDesc2 = @RamaDesc, Cuenta2 = @Cuenta, Descripcion2 = @Descripcion, EsAcreedora2 = @EsAcreedora, Saldo2 = @Saldo
WHERE Renglon = @Renglon
END
SELECT @UltRenglon = @Renglon
END
FETCH NEXT FROM crVerBalance INTO @EsTitulo, @EsFinRama, @EsFinLado, @Renglon, @Lado, @LadoDesc, @Rama, @RamaDesc, @Cuenta, @Descripcion, @EsAcreedora, @Saldo
END
CLOSE crVerBalance
DEALLOCATE crVerBalance

SELECT * FROM #VerBalance
WHERE Renglon IS NOT NULL
ORDER BY Lado
END
GO


EXEC xpVerContBalance 'CA',2016,2