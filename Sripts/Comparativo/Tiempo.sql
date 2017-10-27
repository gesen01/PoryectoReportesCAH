IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('Tiempo')) 
	DROP TABLE Tiempo
GO
CREATE TABLE Tiempo (
	[Fecha] 	[smalldatetime] NOT NULL ,
	[NoDia] 	[SMALLINT] NULL ,
	[Dia] 		[tinyint] NULL ,
	[Mes] 		[tinyint] NULL ,
	[Anio] 		[smallint] NULL ,
	[DiaNombre] 	[VARCHAR] (30)  NULL ,
	[MesNombre] 	[VARCHAR] (30) NULL ,
	[NoSemana] 	[tinyint]   NULL ,
	[Semana] 	[VARCHAR] (50) NULL ,
	[Trimestre] 	[VARCHAR] (30) NULL ,
	[CuaTrimestre] 	[VARCHAR] (30) NULL ,
	[Quincena] 	[VARCHAR] (30) NULL ,
	[Bimestre] 	[VARCHAR] (30) NULL ,
	[Semestre] 	[VARCHAR] (30) NULL 

   CONSTRAINT priTiempo PRIMARY KEY CLUSTERED (Fecha)
) 
GO

DECLARE @fecha 	SMALLDATETIME
DECLARE @fechaAux 	SMALLDATETIME
DECLARE @i 		INT
DECLARE @Dia		TINYINT		
DECLARE @Mes		TINYINT
DECLARE @Anio		SMALLINT
DECLARE @AnioAux	SMALLINT
DECLARE @NoSemana	SMALLINT
DECLARE @NoDia	SMALLINT
DECLARE @DiaNombre	VARCHAR(30)
DECLARE @MesNombre	VARCHAR(30)
DECLARE @Semana	VARCHAR(50)
DECLARE @Trimestre	VARCHAR(30)
DECLARE @CuaTrimestre	VARCHAR(30)
DECLARE @Quincena	VARCHAR(30)
DECLARE @Bimestre	VARCHAR(30)
DECLARE @Semestre	VARCHAR(30)
DECLARE @PrimerDia	INT

SELECT @i 	= 0
SELECT @fecha 	= '1990/01/01'
SELECT @fechaAux = '1990/01/01'
SELECT @AnioAux = 1990
SELECT @NoDia = 0

SELECT @PrimerDia = @@DATEFIRST 
SET DATEFIRST 1

WHILE @i < 14700 ---16 años 1990 - 2006
  BEGIN
    SET @Dia 	= DATEPART(DD,@fecha)
    SET	@Mes 	= DATEPART(M,@fecha)
    SET	@Anio	= DATEPART(YY,@fecha)		
	
--- Se cambio Nodia del AÑo por dia de la semana 8/10/2003
    SET @NoDia    = DATEPART(DW,@fecha)
    SET @DiaNombre = CASE DATEPART(DW,@fecha)
			WHEN 1 THEN '1 Lunes ' 
			WHEN 2 THEN '2 Martes ' 
			WHEN 3 THEN '3 Miercoles ' 
			WHEN 4 THEN '4 Jueves '
			WHEN 5 THEN '5 Viernes ' 
			WHEN 6 THEN '6 Sabado ' 
			WHEN 7 THEN '7 Domingo' 
		      END
    SET @MesNombre = CASE MONTH(@fecha)
			WHEN  1 THEN '01Enero' 
			WHEN  2 THEN '02Febrero'
			WHEN  3 THEN '03Marzo' 
			WHEN  4 THEN '04Abril' 
			WHEN  5 THEN '05Mayo' 
			WHEN  6 THEN '06Junio' 
			WHEN  7 THEN '07Julio' 
			WHEN  8 THEN '08Agosto' 
			WHEN  9 THEN '09Septiembre' 
			WHEN 10 THEN '10Octubre' 
			WHEN 11 THEN '11Noviembre' 
			WHEN 12 THEN '12Diciembre' 
		      END

	SET @Nosemana =  DATEPART(WK,@fecha) 

	IF  DATEPART(DW,@fecha) = 1
		SET @fechaAux = @fecha

	SET @Semana = 'Semana ' + CASE WHEN DATEPART(WK,@fecha) < 10 THEN '0' ELSE '' END 
  				   + CONVERT(CHAR(2),DATEPART(WK,@fecha)) + ' ('
				   + CONVERT(VARCHAR,DAY(@fechaAux))  
				   + CONVERT(VARCHAR,CASE MONTH(@fechaAux)
							WHEN  1 THEN 'ENE' 
							WHEN  2 THEN 'FEB'
							WHEN  3 THEN 'MAR' 
							WHEN  4 THEN 'ABR' 
							WHEN  5 THEN 'MAY' 
							WHEN  6 THEN 'JUN' 
							WHEN  7 THEN 'JUL' 
							WHEN  8 THEN 'AGO' 
							WHEN  9 THEN 'SEP' 
							WHEN 10 THEN 'OCT' 
							WHEN 11 THEN 'NOV' 
							WHEN 12 THEN 'DIC' END) + '-'
 				   + CONVERT(VARCHAR,DAY(dateadd(d,6,@fechaAux))) 
				   + CONVERT(VARCHAR,CASE MONTH(dateadd(d,6,@fechaAux))
							WHEN  1 THEN 'ENE' 
							WHEN  2 THEN 'FEB'
							WHEN  3 THEN 'MAR' 
							WHEN  4 THEN 'ABR' 
							WHEN  5 THEN 'MAY' 
							WHEN  6 THEN 'JUN' 
							WHEN  7 THEN 'JUL' 
							WHEN  8 THEN 'AGO' 
							WHEN  9 THEN 'SEP' 
							WHEN 10 THEN 'OCT' 
							WHEN 11 THEN 'NOV' 
							WHEN 12 THEN 'DIC' END) + ')'

     SET @Quincena = CASE 
			WHEN DAY(@FECHA) <16 THEN 'Quincena 1 '
				            ELSE 'Quincena 2 '    	    
		      END


     SET @Bimestre = CASE 
			WHEN MONTH(@FECHA) in(1,2) 	THEN 'Bimestre 1 '
			WHEN MONTH(@FECHA) in(3,4) 	THEN 'Bimestre 2 ' 
			WHEN MONTH(@FECHA) in(5,6) 	THEN 'Bimestre 3 ' 
			WHEN MONTH(@FECHA) in(7,8) 	THEN 'Bimestre 4 ' 
			WHEN MONTH(@FECHA) in(9,10) 	THEN 'Bimestre 5 ' 
			WHEN MONTH(@FECHA) in(11,12) 	THEN 'Bimestre 6 ' 
		      END

     SET @Trimestre =  CASE 
			WHEN MONTH(@FECHA) in(1,2,3) 	THEN 'Trimestre 1 ' 
			WHEN MONTH(@FECHA) in(4,5,6) 	THEN 'Trimestre 2 ' 
			WHEN MONTH(@FECHA) in(7,8,9) 	THEN 'Trimestre 3 ' 
			WHEN MONTH(@FECHA) in(10,11,12) THEN 'Trimestre 4 ' 
		      END

     SET @semestre = CASE 
			WHEN MONTH(@FECHA) in(1,2,3,4,5,6) 	THEN 'Semestre 1 ' 
			WHEN MONTH(@FECHA)in(7,8,9,10,11,12) 	THEN 'Semestre 2 ' 
		      END

     SET @cuaTrimestre = CASE 
			WHEN MONTH(@FECHA) in(1,2,3,4	) 	THEN 'Cuatrimestre 1 ' 
			WHEN MONTH(@FECHA) in(5,6,7,8	) 	THEN 'Cuatrimestre 2 ' 
			WHEN MONTH(@FECHA) in(9,10,11,12	)	THEN 'Cuatrimestre 3 ' 
		      END

    INSERT INTO Tiempo (Fecha,NoDia,Dia,Mes,Anio,DiaNombre,MesNombre,NoSemana,Semana,Trimestre,CuaTrimestre,Quincena,Bimestre,Semestre)
	VALUES( @fecha, @NoDia, @Dia,@Mes,@Anio,@DiaNombre,@MesNombre,@NoSemana,@Semana,@Trimestre,@CuaTrimestre,@Quincena,@Bimestre,@Semestre)
    SELECT @fecha = dateadd(d,1,@fecha )
    SELECT @i 	  = @i +1
  END

SET DATEFIRST @PrimerDia

GO

--select * from tiempo