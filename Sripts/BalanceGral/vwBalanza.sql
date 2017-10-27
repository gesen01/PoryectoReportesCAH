/*Vista que se utiliza para la generacion de la balanza*/
IF EXISTS(SELECT * FROM sysobjects AS s WHERE s.[type]='v' AND s.name='vwBalanza')
DROP VIEW vwBalanza
GO
CREATE VIEW vwBalanza
AS 
SELECT aa.Cuenta,
aa.Descripcion,
aa.Tipo,
aa.Categoria,
aa.Grupo,
aa.Familia,
"EsAcumulativa" = Convert(varchar,aa.EsAcumulativa),
"EsAcreedora" = Convert(varchar,aa.EsAcreedora),
"Cargos" = Sum(Acum.Cargos),
"Abonos" = Sum(Acum.Abonos),
SUM(acum.cargos)-SUM(acum.abonos) AS 'Acumulado',
Acum.Empresa,
Acum.Ejercicio,
Acum.Periodo
FROM Cta aa
LEFT OUTER JOIN Acum ON aa.Cuenta = Acum.Cuenta
WHERE UPPER(aa.Tipo) IN ('MAYOR', 'SUBCUENTA', 'AUXILIAR')
AND Acum.Rama='CONT'
GROUP BY aa.Cuenta, aa.Descripcion, aa.Tipo, aa.Categoria, aa.Grupo, aa.Familia
        ,Convert(varchar,aa.EsAcumulativa)
        ,Convert(varchar,aa.EsAcreedora)
        ,Acum.Empresa,Acum.Ejercicio,Acum.Periodo
 
 
 SELECT *
 FROM vwBalanza

        
        
