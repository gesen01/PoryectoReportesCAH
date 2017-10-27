CREATE PROCEDURE spVerContBalanza
@Empresa            varchar(5),
@Ejercicio          int,
@PeriodoD           int,
@PeriodoA           int,
@ConMovs            varchar(20) = 'NO',
@Tipo               varchar(20) = 'MAYOR',
@CuentaD            varchar(20) = NULL,
@CuentaA            varchar(20) = NULL,
@CentroCostos       varchar(20) = NULL,
@Categoria          varchar(50) = NULL,
@Grupo              varchar(50) = NULL,
@Familia            varchar(50) = NULL,
@Sucursal           int        = NULL,
@Moneda                    varchar(10) = NULL,
@Controladora       varchar(5)  = NULL,
@UEN                int        = NULL,
@Proyecto           varchar(50) = NULL,
@CentroCostos2             varchar(50) = NULL,
@CentroCostos3             varchar(50) = NULL
AS BEGIN
DECLARE
@Rama               varchar(5),
@CuentaRangoD       varchar(20),
@CuentaRangoA       varchar(20),
@Tipos              varchar(100),
@Inicio             money
SELECT @Rama = 'CONT',
@Tipo = NULLIF(RTRIM(UPPER(@Tipo)), '')
SELECT @CuentaRangoD = NULLIF(RTRIM(@CuentaD), '0'), @CuentaRangoA = NULLIF(RTRIM(@CuentaA), '0')
IF @CuentaRangoD IS NULL SELECT @CuentaRangoD = MIN(Cuenta) FROM Cta
IF @CuentaRangoA IS NULL SELECT @CuentaRangoA = MAX(Cuenta) FROM Cta
IF UPPER(@CentroCostos)  IN ('0', 'NULL', '(TODOS)','', '(ALL)') SELECT @CentroCostos = NULL
IF UPPER(@Categoria)     IN ('0', 'NULL', '(TODOS)','', '(ALL)') SELECT @Categoria = NULL
IF UPPER(@Grupo)     IN ('0', 'NULL', '(TODOS)','', '(ALL)') SELECT @Grupo = NULL
IF UPPER(@Familia)  IN ('0', 'NULL', '(TODOS)','', '(ALL)') SELECT @Familia = NULL
IF UPPER(@Proyecto)         IN ('0', 'NULL', '(TODOS)','', '(ALL)') SELECT @Proyecto = NULL
IF UPPER(@CentroCostos2) IN ('0', 'NULL', '(TODOS)','', '(ALL)') SELECT @CentroCostos2 = NULL
IF UPPER(@CentroCostos3) IN ('0', 'NULL', '(TODOS)','', '(ALL)') SELECT @CentroCostos3 = NULL
IF @UEN = 0 SELECT @UEN = NULL
IF @Sucursal <0 SELECT @Sucursal = NULL
SELECT @Moneda = NULLIF(NULLIF(RTRIM(@Moneda), ''), '0')
IF @Moneda IS NULL SELECT @Moneda = ContMoneda FROM EmpresaCfg WHERE Empresa = @Empresa
CREATE TABLE #VerContBalanza(
Cuenta       varchar(20)  COLLATE Database_Default NULL,
Descripcion  varchar(100) COLLATE Database_Default NULL,
Tipo         varchar(15)  COLLATE Database_Default NULL,
Categoria    varchar(50)  COLLATE Database_Default NULL,
Grupo        varchar(50)  COLLATE Database_Default NULL,
Familia             varchar(50)  COLLATE Database_Default NULL,
EsAcumulativa bit          NULL,
EsAcreedora  bit          NULL,
Inicio       money        NULL,
Cargos       money        NULL,
Abonos       money        NULL)
IF @ConMovs='NO'
BEGIN
IF @Tipo = 'MAYOR'
BEGIN
INSERT #VerContBalanza (Cuenta, Descripcion, Tipo, Categoria, Grupo, Familia, EsAcumulativa, EsAcreedora, Inicio, Cargos, Abonos)
SELECT aa.Cuenta,
aa.Descripcion,
aa.Tipo,
aa.Categoria,
aa.Grupo,
aa.Familia,
"EsAcumulativa" = Convert(varchar,aa.EsAcumulativa),
"EsAcreedora" = Convert(varchar,aa.EsAcreedora),
"Inicio" = (
SELECT SUM(a2.Cargos)-SUM(a2.Abonos)
FROM Cta ab
LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta
AND a2.Empresa = @Empresa
AND a2.Rama = @Rama
AND a2.Ejercicio = @Ejercicio
AND a2.Periodo BETWEEN 0 AND @PeriodoD-1
AND a2.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
AND ISNULL(a2.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, a2.Sucursal), 0)
AND ISNULL(a2.UEN, 0) = ISNULL(ISNULL(@UEN, a2.UEN), 0)
AND ISNULL(a2.Proyecto, '') = ISNULL(ISNULL(@Proyecto, a2.Proyecto), '')
AND ISNULL(a2.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, a2.SubCuenta), '')
AND ISNULL(a2.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, a2.SubCuenta2), '')
AND ISNULL(a2.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, a2.SubCuenta3), '')
AND a2.Moneda = @Moneda
WHERE UPPER(ab.Tipo) = @Tipo
AND aa.Cuenta = ab.Cuenta
),
"Cargos" = Sum(Acum.Cargos),
"Abonos" = Sum(Acum.Abonos)
FROM Cta aa
LEFT OUTER JOIN Acum ON aa.Cuenta = Acum.Cuenta
AND Acum.Empresa = @Empresa
AND Acum.Rama = @Rama
AND Acum.Ejercicio = @Ejercicio
AND Acum.Periodo BETWEEN @PeriodoD AND @PeriodoA
AND ISNULL(Acum.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, Acum.Sucursal), 0)
AND ISNULL(Acum.UEN, 0) = ISNULL(ISNULL(@UEN, Acum.UEN), 0)
AND ISNULL(Acum.Proyecto, '') = ISNULL(ISNULL(@Proyecto, Acum.Proyecto), '')
AND ISNULL(Acum.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, Acum.SubCuenta), '')
AND ISNULL(Acum.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, Acum.SubCuenta2), '')
AND ISNULL(Acum.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, Acum.SubCuenta3), '')
AND Acum.Moneda = @Moneda
WHERE UPPER(aa.Tipo) = @Tipo
AND aa.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
GROUP BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
ORDER BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
END
ELSE
IF @Tipo = 'SUBCUENTA'
BEGIN
INSERT #VerContBalanza (Cuenta, Descripcion, Tipo, Categoria, Grupo, Familia, EsAcumulativa, EsAcreedora, Inicio, Cargos, Abonos)
SELECT aa.Cuenta,
aa.Descripcion,
aa.Tipo,
aa.Categoria,
aa.Grupo,
aa.Familia,
"EsAcumulativa" = Convert(varchar,aa.EsAcumulativa),
"EsAcreedora" = Convert(varchar,aa.EsAcreedora),
"Inicio" = (
SELECT SUM(a2.Cargos)-SUM(a2.Abonos)
FROM Cta ab
LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta
AND a2.Empresa = @Empresa
AND a2.Rama = @Rama
AND a2.Ejercicio = @Ejercicio
AND a2.Periodo BETWEEN 0 AND @PeriodoD-1
AND a2.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
AND ISNULL(a2.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, a2.Sucursal), 0)
AND ISNULL(a2.UEN, 0) = ISNULL(ISNULL(@UEN, a2.UEN), 0)
AND ISNULL(a2.Proyecto, '') = ISNULL(ISNULL(@Proyecto, a2.Proyecto), '')
AND ISNULL(a2.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, a2.SubCuenta), '')
AND ISNULL(a2.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, a2.SubCuenta2), '')
AND ISNULL(a2.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, a2.SubCuenta3), '')
AND a2.Moneda = @Moneda
WHERE UPPER(ab.Tipo) IN ('MAYOR', 'SUBCUENTA')
AND aa.Cuenta = ab.Cuenta
),
"Cargos" = Sum(Acum.Cargos),
"Abonos" = Sum(Acum.Abonos)
FROM Cta aa
LEFT OUTER JOIN Acum ON aa.Cuenta = Acum.Cuenta
AND Acum.Empresa = @Empresa
AND Acum.Rama = @Rama
AND Acum.Ejercicio = @Ejercicio
AND Acum.Periodo BETWEEN @PeriodoD AND @PeriodoA
AND ISNULL(Acum.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, Acum.Sucursal), 0)
AND ISNULL(Acum.UEN, 0) = ISNULL(ISNULL(@UEN, Acum.UEN), 0)
AND ISNULL(Acum.Proyecto, '') = ISNULL(ISNULL(@Proyecto, Acum.Proyecto), '')
AND ISNULL(Acum.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, Acum.SubCuenta), '')
AND ISNULL(Acum.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, Acum.SubCuenta2), '')
AND ISNULL(Acum.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, Acum.SubCuenta3), '')
AND Acum.Moneda = @Moneda
WHERE UPPER(aa.Tipo) IN ('MAYOR', 'SUBCUENTA')
AND aa.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
GROUP BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
ORDER BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
END
ELSE
IF @Tipo = 'AUXILIAR'
BEGIN
INSERT #VerContBalanza (Cuenta, Descripcion, Tipo, Categoria, Grupo, Familia, EsAcumulativa, EsAcreedora, Inicio, Cargos, Abonos)
SELECT aa.Cuenta,
aa.Descripcion,
aa.Tipo,
aa.Categoria,
aa.Grupo,
aa.Familia,
"EsAcumulativa" = Convert(varchar,aa.EsAcumulativa),
"EsAcreedora" = Convert(varchar,aa.EsAcreedora),
"Inicio" = (
SELECT SUM(a2.Cargos)-SUM(a2.Abonos)
FROM Cta ab
LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta
AND a2.Empresa = @Empresa
AND a2.Rama = @Rama
AND a2.Ejercicio = @Ejercicio
AND a2.Periodo BETWEEN 0 AND @PeriodoD-1
AND ISNULL(a2.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, a2.Sucursal), 0)
AND ISNULL(a2.UEN, 0) = ISNULL(ISNULL(@UEN, a2.UEN), 0)
AND ISNULL(a2.Proyecto, '') = ISNULL(ISNULL(@Proyecto, a2.Proyecto), '')
AND ISNULL(a2.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, a2.SubCuenta), '')
AND ISNULL(a2.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, a2.SubCuenta2), '')
AND ISNULL(a2.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, a2.SubCuenta3), '')
AND a2.Moneda = @Moneda
AND a2.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
WHERE UPPER(ab.Tipo) IN ('MAYOR', 'SUBCUENTA', 'AUXILIAR')
AND aa.Cuenta = ab.Cuenta
),
"Cargos" = Sum(Acum.Cargos),
"Abonos" = Sum(Acum.Abonos)
FROM Cta aa
LEFT OUTER JOIN Acum ON aa.Cuenta = Acum.Cuenta
AND Acum.Empresa = @Empresa
AND Acum.Rama = @Rama
AND Acum.Ejercicio = @Ejercicio
AND Acum.Periodo BETWEEN @PeriodoD AND @PeriodoA
AND ISNULL(Acum.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, Acum.Sucursal), 0)
AND ISNULL(Acum.UEN, 0) = ISNULL(ISNULL(@UEN, Acum.UEN), 0)
AND ISNULL(Acum.Proyecto, '') = ISNULL(ISNULL(@Proyecto, Acum.Proyecto), '')
AND ISNULL(Acum.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, Acum.SubCuenta), '')
AND ISNULL(Acum.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, Acum.SubCuenta2), '')
AND ISNULL(Acum.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, Acum.SubCuenta3), '')
AND Acum.Moneda = @Moneda
WHERE UPPER(aa.Tipo) IN ('MAYOR', 'SUBCUENTA', 'AUXILIAR')
AND aa.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
GROUP BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
ORDER BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
END
END
ELSE
IF @Tipo = 'MAYOR'
BEGIN
INSERT #VerContBalanza (Cuenta, Descripcion, Tipo, Categoria, Grupo, Familia, EsAcumulativa, EsAcreedora, Inicio, Cargos, Abonos)
SELECT aa.Cuenta,
aa.Descripcion,
aa.Tipo,
aa.Categoria,
aa.Grupo,
aa.Familia,
"EsAcumulativa" = Convert(varchar,aa.EsAcumulativa),
"EsAcreedora" = Convert(varchar,aa.EsAcreedora),
"Inicio" = (
SELECT SUM(a2.Cargos)-SUM(a2.Abonos)
FROM Cta ab
LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta
AND a2.Empresa = @Empresa
AND a2.Rama = @Rama
AND a2.Ejercicio = @Ejercicio
AND a2.Periodo BETWEEN 0 AND @PeriodoD-1
AND a2.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
AND ISNULL(a2.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, a2.Sucursal), 0)
AND ISNULL(a2.UEN, 0) = ISNULL(ISNULL(@UEN, a2.UEN), 0)
AND ISNULL(a2.Proyecto, '') = ISNULL(ISNULL(@Proyecto, a2.Proyecto), '')
AND ISNULL(a2.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, a2.SubCuenta), '')
AND ISNULL(a2.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, a2.SubCuenta2), '')
AND ISNULL(a2.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, a2.SubCuenta3), '')
AND a2.Moneda = @Moneda
WHERE UPPER(ab.Tipo) = @Tipo
AND aa.Cuenta = ab.Cuenta
),
"Cargos" = Sum(Acum.Cargos),
"Abonos" = Sum(Acum.Abonos)
FROM Cta aa
LEFT OUTER JOIN Acum ON aa.Cuenta = Acum.Cuenta
AND Acum.Empresa = @Empresa
AND Acum.Rama = @Rama
AND Acum.Ejercicio = @Ejercicio
AND Acum.Periodo BETWEEN @PeriodoD AND @PeriodoA
AND ISNULL(Acum.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, Acum.Sucursal), 0)
AND ISNULL(Acum.UEN, 0) = ISNULL(ISNULL(@UEN, Acum.UEN), 0)
AND ISNULL(Acum.Proyecto, '') = ISNULL(ISNULL(@Proyecto, Acum.Proyecto), '')
AND ISNULL(Acum.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, Acum.SubCuenta), '')
AND ISNULL(Acum.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, Acum.SubCuenta2), '')
AND ISNULL(Acum.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, Acum.SubCuenta3), '')
AND Acum.Moneda = @Moneda
WHERE UPPER(aa.Tipo) = @Tipo
AND aa.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
GROUP BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
HAVING ( Sum(ISNULL(Acum.Cargos,0.0))<>0.0 OR Sum(ISNULL(Acum.Abonos,0.0))<>0.0 OR
(SELECT SUM(ISNULL(a2.Cargos,0.0))-SUM(ISNULL(a2.Abonos,0.0)) FROM Cta ab LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta AND a2.Empresa = @Empresa AND a2.Rama = @Rama AND a2.Ejercicio = @Ejercicio AND a2.Periodo BETWEEN 0 AND @PeriodoD-1 AND a2.Cuenta B
ETWEEN @CuentaRangoD AND @CuentaRangoA WHERE UPPER(ab.Tipo) = @Tipo AND aa.Cuenta = ab.Cuenta) <> 0.0)
ORDER BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
END
ELSE
IF @Tipo = 'SUBCUENTA'
BEGIN
INSERT #VerContBalanza (Cuenta, Descripcion, Tipo, Categoria, Grupo, Familia, EsAcumulativa, EsAcreedora, Inicio, Cargos, Abonos)
SELECT aa.Cuenta,
aa.Descripcion,
aa.Tipo,
aa.Categoria,
aa.Grupo,
aa.Familia,
"EsAcumulativa" = Convert(varchar,aa.EsAcumulativa),
"EsAcreedora" = Convert(varchar,aa.EsAcreedora),
"Inicio" = (
SELECT SUM(a2.Cargos)-SUM(a2.Abonos)
FROM Cta ab
LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta
AND a2.Empresa = @Empresa
AND a2.Rama = @Rama
AND a2.Ejercicio = @Ejercicio
AND a2.Periodo BETWEEN 0 AND @PeriodoD-1
AND a2.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
AND ISNULL(a2.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, a2.Sucursal), 0)
AND ISNULL(a2.UEN, 0) = ISNULL(ISNULL(@UEN, a2.UEN), 0)
AND ISNULL(a2.Proyecto, '') = ISNULL(ISNULL(@Proyecto, a2.Proyecto), '')
AND ISNULL(a2.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, a2.SubCuenta), '')
AND ISNULL(a2.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, a2.SubCuenta2), '')
AND ISNULL(a2.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, a2.SubCuenta3), '')
AND a2.Moneda = @Moneda
WHERE UPPER(ab.Tipo) IN ('MAYOR', 'SUBCUENTA')
AND aa.Cuenta = ab.Cuenta
),
"Cargos" = Sum(Acum.Cargos),
"Abonos" = Sum(Acum.Abonos)
FROM Cta aa
LEFT OUTER JOIN Acum ON aa.Cuenta = Acum.Cuenta
AND Acum.Empresa = @Empresa
AND Acum.Rama = @Rama
AND Acum.Ejercicio = @Ejercicio
AND Acum.Periodo BETWEEN @PeriodoD AND @PeriodoA
AND ISNULL(Acum.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, Acum.Sucursal), 0)
AND ISNULL(Acum.UEN, 0) = ISNULL(ISNULL(@UEN, Acum.UEN), 0)
AND ISNULL(Acum.Proyecto, '') = ISNULL(ISNULL(@Proyecto, Acum.Proyecto), '')
AND ISNULL(Acum.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, Acum.SubCuenta), '')
AND ISNULL(Acum.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, Acum.SubCuenta2), '')
AND ISNULL(Acum.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, Acum.SubCuenta3), '')
AND Acum.Moneda = @Moneda
WHERE UPPER(aa.Tipo) IN ('MAYOR', 'SUBCUENTA')
AND aa.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
GROUP BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
HAVING ( Sum(ISNULL(Acum.Cargos,0.0))<>0.0 OR Sum(ISNULL(Acum.Abonos,0.0))<>0.0 OR
(SELECT SUM(ISNULL(a2.Cargos,0.0))-SUM(ISNULL(a2.Abonos,0.0)) FROM Cta ab LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta AND a2.Empresa = @Empresa AND a2.Rama = @Rama AND a2.Ejercicio = @Ejercicio AND a2.Periodo BETWEEN 0 AND @PeriodoD-1 AND a2.Cuenta B
ETWEEN @CuentaRangoD AND @CuentaRangoA WHERE UPPER(ab.Tipo) IN ('MAYOR', 'SUBCUENTA') AND aa.Cuenta = ab.Cuenta) <> 0.0)
ORDER BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
END
ELSE
IF @Tipo = 'AUXILIAR'
BEGIN
INSERT #VerContBalanza (Cuenta, Descripcion, Tipo, Categoria, Grupo, Familia, EsAcumulativa, EsAcreedora, Inicio, Cargos, Abonos)
SELECT aa.Cuenta,
aa.Descripcion,
aa.Tipo,
aa.Categoria,
aa.Grupo,
aa.Familia,
"EsAcumulativa" = Convert(varchar,aa.EsAcumulativa),
"EsAcreedora" = Convert(varchar,aa.EsAcreedora),
"Inicio" = (
SELECT SUM(a2.Cargos)-SUM(a2.Abonos)
FROM Cta ab
LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta
AND a2.Empresa = @Empresa
AND a2.Rama = @Rama
AND a2.Ejercicio = @Ejercicio
AND a2.Periodo BETWEEN 0 AND @PeriodoD-1
AND a2.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
AND ISNULL(a2.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, a2.Sucursal), 0)
AND ISNULL(a2.UEN, 0) = ISNULL(ISNULL(@UEN, a2.UEN), 0)
AND ISNULL(a2.Proyecto, '') = ISNULL(ISNULL(@Proyecto, a2.Proyecto), '')
AND ISNULL(a2.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, a2.SubCuenta), '')
AND ISNULL(a2.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, a2.SubCuenta2), '')
AND ISNULL(a2.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, a2.SubCuenta3), '')
AND a2.Moneda = @Moneda
WHERE UPPER(ab.Tipo) IN ('MAYOR', 'SUBCUENTA', 'AUXILIAR')
AND aa.Cuenta = ab.Cuenta
),
"Cargos" = Sum(Acum.Cargos),
"Abonos" = Sum(Acum.Abonos)
FROM Cta aa
LEFT OUTER JOIN Acum ON aa.Cuenta = Acum.Cuenta
AND Acum.Empresa = @Empresa
AND Acum.Rama = @Rama
AND Acum.Ejercicio = @Ejercicio
AND Acum.Periodo BETWEEN @PeriodoD AND @PeriodoA
AND ISNULL(Acum.Sucursal, 0) = ISNULL(ISNULL(@Sucursal, Acum.Sucursal), 0)
AND ISNULL(Acum.UEN, 0) = ISNULL(ISNULL(@UEN, Acum.UEN), 0)
AND ISNULL(Acum.Proyecto, '') = ISNULL(ISNULL(@Proyecto, Acum.Proyecto), '')
AND ISNULL(Acum.SubCuenta, '') = ISNULL(ISNULL(@CentroCostos, Acum.SubCuenta), '')
AND ISNULL(Acum.SubCuenta2, '') = ISNULL(ISNULL(@CentroCostos2, Acum.SubCuenta2), '')
AND ISNULL(Acum.SubCuenta3, '') = ISNULL(ISNULL(@CentroCostos3, Acum.SubCuenta3), '')
AND Acum.Moneda = @Moneda
WHERE UPPER(aa.Tipo) IN ('MAYOR', 'SUBCUENTA', 'AUXILIAR')
AND aa.Cuenta BETWEEN @CuentaRangoD AND @CuentaRangoA
GROUP BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
HAVING ( Sum(ISNULL(Acum.Cargos,0.0))<>0.0 OR Sum(ISNULL(Acum.Abonos,0.0))<>0.0 OR
(SELECT SUM(ISNULL(a2.Cargos,0.0))-SUM(ISNULL(a2.Abonos,0.0)) FROM Cta ab LEFT OUTER JOIN Acum a2 ON ab.Cuenta = a2.Cuenta AND a2.Empresa = @Empresa AND a2.Rama = @Rama AND a2.Ejercicio = @Ejercicio AND a2.Periodo BETWEEN 0 AND @PeriodoD-1 AND a2.Cuenta B
ETWEEN @CuentaRangoD AND @CuentaRangoA WHERE UPPER(ab.Tipo) IN ('MAYOR', 'SUBCUENTA', 'AUXILIAR') AND aa.Cuenta = ab.Cuenta) <> 0.0)
ORDER BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia, Convert(varchar,aa.EsAcumulativa), Convert(varchar,aa.EsAcreedora)
END
SELECT Cuenta,
Descripcion,
Tipo,
EsAcumulativa,
EsAcreedora,
Inicio,
Cargos,
Abonos
FROM #VerContBalanza
WHERE ISNULL(Categoria, '') = ISNULL(ISNULL(@Categoria, Categoria) , '')
AND ISNULL(Grupo, '')     = ISNULL(ISNULL(@Grupo, Grupo) , '')
AND ISNULL(Familia, '')   = ISNULL(ISNULL(@Familia, Familia) , '')
END



EXEC spVerContBalanza   'CA',
2016,
2,
2,
'NO',
'Auxiliar',
'11010-0000-000',
'61050-0001-000',
'(Todos)',
'(Todos)',
'(Todos)',
'(Todos)',
-1,
'Pesos',
'NULL',
NULL,
'(Todos)',
'(Todos)',
'(Todos)'

SELECT *
FROM VERCON