--Crea una nueva tabla de conversion para el balance general
INSERT INTO TablaSt(TablaSt)
VALUES('JalesBalanzaGral')

--Inserta los datos dentro de la tabla de conversion
INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EFECTIVO'
FROM Cta AS c
WHERE c.Cuenta LIKE '11010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EFECTIVO'
FROM Cta AS c
WHERE c.Cuenta LIKE '11020%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'COLEGIATURAS E INSCRIPCIONES POR COBRAR'
FROM Cta AS c
WHERE c.Cuenta LIKE '11030%'


INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'CHEQUES DEVUELTOS'
FROM Cta AS c
WHERE c.Cuenta LIKE '11050-0003%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'GASTOS A COMPROBAR'
FROM Cta AS c
WHERE c.Cuenta LIKE '11050-0004%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'ANTICIPO A PROVEEDORES'
FROM Cta AS c
WHERE c.Cuenta LIKE '11050-0005%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTROS DEUDORES'
FROM Cta AS c
WHERE c.Cuenta LIKE '11050-0001%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTROS DEUDORES'
FROM Cta AS c
WHERE c.Cuenta LIKE '11050-0002%'

UPDATE TablaStD SET Valor = 'PATRONATO CUENTA CORRIENTE'
WHERE Nombre LIKE '11050-0002-002%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'MENOS RESERVA PARA CTAS.DE COBRO DUDOSO'
FROM Cta AS c
WHERE c.Cuenta LIKE '11040%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'TERRENOS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EDIFICIOS E INSTALACIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '12020%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DREPRECIACION EDIFICIOS E INSTALACIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0001%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DREPRECIACION EDIFICIOS E INSTALACIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0009%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'GIMNASIOS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12020%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION GIMNASIOS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION GIMNASIOS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0013%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'MONUMENTO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12100%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'ALBERCAS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12030%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION ALBERCAS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0002%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION ALBERCAS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0011%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION ALBERCAS'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0012%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'MUEBLES Y ENSERES'
FROM Cta AS c
WHERE c.Cuenta LIKE '12040%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION MUEBLES Y ENSERES'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0003%'


INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EQUIPO DE FOTOCOPIADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0003%'


INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION EQUIPO DE FOTOCOPIADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0003%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EQUIPO DE TRANSPORTE'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0003%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION EQUIPO DE TRANSPORTE'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0004%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EQUIPO DE COMPUTO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12080%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION EQUIPO DE COMPUTO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0005%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EQUIPO DE LABORATORIO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12110%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION EQUIPO DE LABORATORIO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0008%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'CONSTRUCCIONES EN PROCESO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12050%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'BONO DEL CENTENARIO'
FROM Cta AS c
WHERE c.Cuenta LIKE '21040%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'I.S.P.T.'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0001-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'INFONAVIT'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0002-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SEGURO SOCIAL'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0008-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SEGURO SOCIAL'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0009-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SEGURO SOCIAL'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0010-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SEGURO SOCIAL'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0011-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SEGURO SOCIAL'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0012-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'S.A.R'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0007-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0003-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0004-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0005-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0006-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0013-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0014-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0015-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTRAS CONTRIBUCIONES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21010-0015-000%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTROS ACREEDORES'
FROM Cta AS c
WHERE c.Cuenta LIKE '23050%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTROS ACREEDORES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21050-0001%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'OTROS ACREEDORES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21030%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SUBSIDIO RECIBIDO POR APLICAR'
FROM Cta AS c
WHERE c.Cuenta LIKE '21020-0002%'

UPDATE TablaStD SET Valor = 'DERECHOS POR CONSUMO DE AGUA'
WHERE TablaSt='JalesBalanzaGral' AND Nombre LIKE '21020-0002-005%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'FONDO DE AHORRO POR PAGAR'
FROM Cta AS c
WHERE c.Cuenta LIKE '21020-0001%'

UPDATE TablaStD SET Valor = 'PROVISION PRIMA DE VACACIONES'
WHERE TablaSt='JalesBalanzaGral' AND Nombre LIKE '21050-0001-002%'

UPDATE TablaStD SET Valor = 'PROVISION  DE AGUINALDOS'
WHERE TablaSt='JalesBalanzaGral' AND Nombre LIKE '21050-0001-001%'

UPDATE TablaStD SET Valor = 'PROVISION DE EXCELENCIA'
WHERE TablaSt='JalesBalanzaGral' AND Nombre LIKE '21050-0001-003%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'COLEGIATURAS E INSCRIPCIONES ANTICIPADAS'
FROM Cta AS c
WHERE c.Cuenta LIKE '23050%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPOSITOS EN GARANTIA'
FROM Cta AS c
WHERE c.Cuenta LIKE '13020%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'BONO DEL CENTENARIO'
FROM Cta AS c
WHERE c.Cuenta LIKE '22020%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'PRESTAMO BANCOMER'
FROM Cta AS c
WHERE c.Cuenta LIKE '22010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'PROV. PARA OBLIGACIONES LABORALES'
FROM Cta AS c
WHERE c.Cuenta LIKE '21050-0002%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'PROV. PARA OBLIGACIONES LABORALES2'
FROM Cta AS c
WHERE c.Cuenta LIKE '21050-0002%'

UPDATE TablaStD SET Valor = 'MI FUTURO FIRME'
WHERE TablaSt='JalesBalanzaGral' AND Nombre LIKE '21020-0001-007%'

UPDATE TablaStD SET Valor = 'MI FUTURO FIRME'
WHERE TablaSt='JalesBalanzaGral' AND Nombre LIKE '21020-0001-008%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'PATRIMONIO SOCIAL'
FROM Cta AS c
WHERE c.Cuenta LIKE '61020%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'PATRIMONIO DONADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '61030%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SUPERAVIT POR REVALUACION ACTIVO FIJO'
FROM Cta AS c
WHERE c.Cuenta LIKE '61010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'RESULTADO CICLO ESCOLAR'
FROM Cta AS c
WHERE c.Cuenta LIKE '61010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'SEGUROS Y OTROS PAGOS ANTICIPADOS'
FROM Cta AS c
WHERE c.Cuenta LIKE '13010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EQUIPO DE FOTOCOPIADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12060%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION EQUIPO DE FOTOCOPIADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0006%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'EQUIPO DE TRANSPORTE'
FROM Cta AS c
WHERE c.Cuenta LIKE '12070%'



INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'MAQUINARIA Y EQUIPO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12090%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPRECIACION MAQUINARIA Y EQUIPO'
FROM Cta AS c
WHERE c.Cuenta LIKE '12120-0007%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'COL E INSC COBRADAS POR ANTICIPADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '23010%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'COL E INSC COBRADAS POR ANTICIPADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '23020%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'COL E INSC COBRADAS POR ANTICIPADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '23030%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'COL E INSC COBRADAS POR ANTICIPADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '23040%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'COL E INSC COBRADAS POR ANTICIPADO'
FROM Cta AS c
WHERE c.Cuenta LIKE '23060%'

INSERT INTO Tablastd
SELECT 'JalesBalanzaGral',c.Cuenta,'DEPOSITOS EN GARANTIA'
FROM Cta AS c
WHERE c.Cuenta LIKE '21060-0001-000%'