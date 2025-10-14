USE [Transaccional]
GO
/****** Object:  StoredProcedure [dbo].[SP_MI_BASE_MOTOR_APTP]    Script Date: 14-10-2025 10:29:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[SP_MI_BASE_MOTOR_APTP] (
	@CIERRE AS DATE
)
AS
   
--exec [dbo].[SP_MI_BASE_MOTOR_APTP] '2025-06-30'

BEGIN


-- QUERY TABLERO_VEHICULOS

-- APERTURO LOS STROS EN AT LL Y WH

DROP TABLE IF EXISTS #AUXILIAR_STROS
SELECT 
	PER, NNUMDOCU, NNUMITEM,

	AT_DP = CASE WHEN COBERTURA = 'DP' AND TIPO_SINIESTRO = 'ATTRITIONAL' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	AT_PT = CASE WHEN COBERTURA = 'PT' AND TIPO_SINIESTRO = 'ATTRITIONAL' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	AT_ROBO = CASE WHEN COBERTURA = 'ROBO' AND TIPO_SINIESTRO = 'ATTRITIONAL' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	AT_RC = CASE WHEN COBERTURA = 'RC' AND TIPO_SINIESTRO = 'ATTRITIONAL' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	
	LARGE_DP = CASE WHEN COBERTURA = 'DP' AND TIPO_SINIESTRO = 'LARGE' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	LARGE_PT = CASE WHEN COBERTURA = 'PT' AND TIPO_SINIESTRO = 'LARGE' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	LARGE_ROBO = CASE WHEN COBERTURA = 'ROBO' AND TIPO_SINIESTRO = 'LARGE' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	LARGE_RC = CASE WHEN COBERTURA = 'RC' AND TIPO_SINIESTRO = 'LARGE' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	
	WEATHER_DP = CASE WHEN COBERTURA = 'DP' AND TIPO_SINIESTRO = 'WEATHER' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	WEATHER_PT = CASE WHEN COBERTURA = 'PT' AND TIPO_SINIESTRO = 'WEATHER' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	WEATHER_ROBO = CASE WHEN COBERTURA = 'ROBO' AND TIPO_SINIESTRO = 'WEATHER' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END,
	WEATHER_RC = CASE WHEN COBERTURA = 'RC' AND TIPO_SINIESTRO = 'WEATHER' THEN SUM(ULT_GROSS_P - ULT_TREATY_P - ULT_EXTERNAL_P) END
INTO #AUXILIAR_STROS
FROM REPORTES.DBO.MI_A3_COMPLETO_FINAL
GROUP BY PER, NNUMDOCU, NNUMITEM, COBERTURA, TIPO_SINIESTRO
-- (482975 rows affected)

DROP TABLE IF EXISTS #AUXILIAR_STROS_2
SELECT 
	PER, NNUMDOCU, NNUMITEM,
	AT_DP = SUM(AT_DP), 
	AT_DT = SUM(AT_PT), 
	AT_ROBO = SUM(AT_ROBO), 
	AT_RC = SUM(AT_RC), 
	LARGE_DP = SUM(LARGE_DP),
	LARGE_DT = SUM(LARGE_PT), 
	LARGE_ROBO = SUM(LARGE_ROBO), 
	LARGE_RC = SUM(LARGE_RC), 
	WEATHER_DP = SUM(WEATHER_DP),
	WEATHER_DT = SUM(WEATHER_PT), 
	WEATHER_ROBO = SUM(WEATHER_ROBO),
	WEATHER_RC = SUM(WEATHER_RC)
INTO #AUXILIAR_STROS_2
FROM #AUXILIAR_STROS
GROUP BY PER, NNUMDOCU, NNUMITEM
-- (443614 rows affected)


---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GENERO MARCA DE CANCELACIONES
DROP TABLE IF EXISTS #CANCELACIONES_0
SELECT NNUMDOCU, NNUMITEM, MAX(IND_CANCELACION) AS MAX_IND_CANCELACION
INTO #CANCELACIONES_0
FROM REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR
where FECTEVIG_REAL is not null and IND_CANCELACION is not null and LINEA_NEGOCIO='COMMERCIAL'
GROUP BY NNUMDOCU, NNUMITEM
-- (621765 rows affected)

DROP TABLE IF EXISTS #CANCELACIONES_1
SELECT NNUMDOCU, NNUMITEM, MAX(FECTEVIG_REAL) AS MAX_FECTEVIG_REAL
INTO #CANCELACIONES_1
FROM REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR
where FECTEVIG_REAL is not null and IND_CANCELACION is not null and LINEA_NEGOCIO='COMMERCIAL'
GROUP BY NNUMDOCU, NNUMITEM
-- (621765 rows affected)


-----------------------------------------------------
DROP TABLE IF EXISTS #CANCELACIONES
SELECT A.NNUMDOCU, A.NNUMITEM, 
ESTADO = CASE
			WHEN A.MAX_IND_CANCELACION = 1 THEN 'Cancelado' 
			WHEN B.MAX_FECTEVIG_REAL <= @CIERRE THEN 'Fin Vigencia'      ---------------------------------------------------->> EDITAR FECHA!!!!!!!!!!!!!!
			else 'Vigente' 
		 end
INTO #CANCELACIONES			                                                    
FROM #CANCELACIONES_0 A
LEFT JOIN #CANCELACIONES_1 B
ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM
--(621765 rows affected)

DROP TABLE IF EXISTS #SALIDA_CANCELACIONES
SELECT 
	NNUMDOCU, 
	CANTIDAD_ITEMS_VIGENTES = SUM(CASE WHEN ESTADO = 'VIGENTE' THEN 1 ELSE 0 END), 
	CANTIDAD_ITEMS_CANCELADOS = SUM(CASE WHEN ESTADO = 'Cancelado' THEN 1 ELSE 0 END), 
	CANTIDAD_ITEMS_FIN_VIGENCIA = SUM(CASE WHEN ESTADO = 'Fin Vigencia' THEN 1 ELSE 0 END)
INTO #SALIDA_CANCELACIONES
FROM #CANCELACIONES
GROUP BY NNUMDOCU
-- (212100 rows affected)

DROP TABLE IF EXISTS REPORTES.DBO.FLOTAS_PBI_ITEMS
SELECT 
	A.*,
	ITEMS_TOTALES_DE_FLOTA = A.CANTIDAD_ITEMS_VIGENTES+A.CANTIDAD_ITEMS_CANCELADOS+A.CANTIDAD_ITEMS_FIN_VIGENCIA,
	TAMAÑO = CASE WHEN A.CANTIDAD_ITEMS_VIGENTES > 2000 THEN A.CANTIDAD_ITEMS_VIGENTES ELSE B.TAMAÑO END,
	TAMAÑO_AGRUPADO = CASE WHEN A.CANTIDAD_ITEMS_VIGENTES > 2000 THEN '2001 - +' ELSE B.TAMAÑO_AGRUPADO END
INTO REPORTES.DBO.FLOTAS_PBI_ITEMS
FROM #SALIDA_CANCELACIONES A 
LEFT JOIN PROCESOS.DBO.BASE_AUXILIAR_TAMAÑO_AGRUPADO B
ON A.CANTIDAD_ITEMS_VIGENTES = B.TAMAÑO 
ORDER BY CANTIDAD_ITEMS_VIGENTES+CANTIDAD_ITEMS_CANCELADOS+CANTIDAD_ITEMS_FIN_VIGENCIA --ITEMS_TOTALES_DE_FLOTA
-- (212100 rows affected)


--------------------------------- Se Crea Base Loading por Poliza ---------------------------------
DROP TABLE IF EXISTS #BASE_LOADING
SELECT a.nnumdocu, a.nnumitem, b.loading
into #BASE_LOADING
FROM SGF1034.gestionPortafolio.dbo.BASE_APTP A
LEFT JOIN SGF1034.gestionPortafolio.dbo.LOADINGS_APTP B ON 
	RTRIM(A.BU) = RTRIM(B.GRUPO_CHANNEL) AND 
	RTRIM(A.CHANNEL) = RTRIM(B.CHANNEL)
WHERE B.CHANNEL IS NOT NULL 
---(1120861 rows affected)

---------------------- Creo tabla de Partner Sucursal que NO abra por origen ----------------------
drop table IF EXISTS #aux_partener
select distinct nnumdocu, canal, bu, PARTNER_SUCURSAL 
into #aux_partener 
from Almacen_de_datos.dbo.SURA_CANAL_BU_PARTNER

UPDATE #aux_partener 
SET PARTNER_SUCURSAL = 'CASA MATRIZ'
WHERE nnumdocu = 7355786

drop table IF EXISTS #aux_partner 
select distinct nnumdocu, canal, bu, PARTNER_SUCURSAL
into #aux_partner 
from #aux_partener
WHERE CANAL <>'UNDEFINED'

UPDATE #aux_partener 
SET 
	canal = b.canal,
	bu = b.bu,
	PARTNER_SUCURSAL = B.PARTNER_SUCURSAL
from #aux_partener A LEFT JOIN #aux_partner b
on a.nnumdocu = b.nnumdocu
WHERE a.CANAL = 'UNDEFINED'

drop table IF EXISTS #aux_parter_unico
SELECT Distinct *
INTO #aux_parter_unico
from #aux_partener

drop table IF EXISTS reportes.dbo.aux_parter_unico
select * into reportes.dbo.aux_parter_unico from #aux_parter_unico

drop table IF EXISTS reportes.dbo.AUXILIAR_STROS_2
select * into reportes.dbo.AUXILIAR_STROS_2 from #AUXILIAR_STROS_2

drop table IF EXISTS reportes.dbo.BASE_LOADING
select * into reportes.dbo.BASE_LOADING from #BASE_LOADING


-------------------------------------------------------------
DROP TABLE IF EXISTS #BASE_MOTOR_APTP
DECLARE @F_CORTE DATE = @CIERRE ------------------------ EDITAR FECHA CIERRE DE MES!!!
SELECT 
	A.NNUMDOCU, a.nnumitem, a.Prorroga,
	FECTEVIG_REAL = YEAR(A.FECTEVIG_REAL)*100+MONTH(A.FECTEVIG_REAL),
	FECINVIG = CONVERT(DATE,DATEADD(MS,-3,DATEADD(MM,0,DATEADD(MM,DATEDIFF(MM,0,CONVERT(DATETIME,A.FECINVIG))+1,0)))),
	MES_EMI = YEAR(A.FECINVIG)*100+MONTH(A.FECINVIG),
	--AÑO_TRIMESTRE = STR(year(A.PER),4) + 'Q' + STR(case when month(A.per)<=3 then 1 when month(A.per)<=6 then 2  when month(A.per)<=9 then 3 else 4 end,1),
	Q_PER = (DATEDIFF(month,A.per,@F_CORTE))/3,
	Q_EMI = (DATEDIFF(month,A.FECINVIG,@F_CORTE))/3,
	Q_PER_AGRUP = IIF((DATEDIFF(month,A.per,@F_CORTE))/3>5,5,(DATEDIFF(month,A.per,@F_CORTE))/3),
	Q_EMI_AGRUP = IIF((DATEDIFF(month,A.FECINVIG,@F_CORTE))/3>5,5,(DATEDIFF(month,A.FECINVIG,@F_CORTE))/3),
	ORDEN_Q_PER_AGRUP = IIF((DATEDIFF(month,A.per,@F_CORTE))/3>5,5,(DATEDIFF(month,A.per,@F_CORTE))/3)*-1,
	ORDEN_Q_PER = (DATEDIFF(month,A.per,@F_CORTE))/3*-1
INTO #AUX_FECHAS
FROM REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR a
WHERE 
	A.PER >= '01-01-2021' AND 
	cast(A.PER as date) <= @CIERRE AND
	NNUMITEM=6844 AND NNUMDOCU=6257337
--


DROP TABLE IF EXISTS #BASE_MOTOR_APTP_0
--DECLARE @F_CORTE DATE = '2024-04-30' ------------------------ EDITAR FECHA CIERRE DE MES!!!
SELECT 
	A.NNUMDOCU, a.nnumitem, a.Prorroga,
	FECHA_CORTE = @F_CORTE,
	FECTEVIG_REAL = YEAR(A.FECTEVIG_REAL)*100+MONTH(A.FECTEVIG_REAL),
	FECINVIG = CONVERT(DATE,DATEADD(MS,-3,DATEADD(MM,0,DATEADD(MM,DATEDIFF(MM,0,CONVERT(DATETIME,A.FECINVIG))+1,0)))),
	MES_EMI= YEAR(A.FECINVIG)*100+MONTH(A.FECINVIG),
	--AÑO_TRIMESTRE = STR(year(A.PER),4) + 'Q' + STR(case when month(A.per)<=3 then 1 when month(A.per)<=6 then 2  when month(A.per)<=9 then 3 else 4 end,1),
	Q_PER =(DATEDIFF(month,A.per,@F_CORTE))/3,
	Q_EMI = (DATEDIFF(month,A.FECINVIG,@F_CORTE))/3,
	Q_PER_AGRUP_2 = IIF((DATEDIFF(month,A.per,@F_CORTE))/3>5,5,(DATEDIFF(month,A.per,@F_CORTE))/3),
	Q_EMI_AGRUP_2 = IIF((DATEDIFF(month,A.FECINVIG,@F_CORTE))/3>5,5,(DATEDIFF(month,A.FECINVIG,@F_CORTE))/3),
	ORDEN_Q_PER_AGRUP = IIF((DATEDIFF(month,A.per,@F_CORTE))/3>5,5,(DATEDIFF(month,A.per,@F_CORTE))/3)*-1,
	ORDEN_Q_PER = (DATEDIFF(month,A.per,@F_CORTE))/3*-1,
	A.NNUMRUT, A.CORREDOR, A.TIPPLAN, A.DEDUCIBLE, A.LINEA_NEGOCIO, A.NANFAVEH, A.CCOMAVEH, A.CDESCORT, A.TOP100, A.GAMA, A.CCODSUCU, A.COMUNA, A.CONTRATANTE, A.nplantec, a.ACTIVIDAD_AGRUP, a.cdescrip,A.CNUMPATE, A.CCODRAMO, A.NNURUPRO,
	d.BU, d.CANAL, d.PARTNER_SUCURSAL, a.CHANNEL, COMUNA_CLIENTE = G.COMUNA, PROVINCIA_CLIENTE = G.PROVINCIA, REGION_CLIENTE = G.REGION, G.Latitud_Destino,	G.Longitud_Destino,	G.GSE, EDAD_CLIENTE=G.edad, SEXO_CLIENTE=G.SEXO, 

	NB_Reno = case when a.IND_RENOVACION = 0 then 'NB' else 'Reno' end,

	Vigente_Sum = case 
					  when rtrim(a.cdescrip) not like  '%EXCES%' then 0
					  when A.fectevig_real < @F_CORTE then 0 
					  else 1 
				  end,

	Vigente = case when A.fectevig_real < @F_CORTE then 'No Vigente' else 'Vigente' end,

	PRIMA_RIESGO = ISNULL(SUM(A.PRRIESGO_UF_DEV),0),
	LOADING = ISNULL(E.LOADING,0),
	
	PRIMA_EMI_PESOS = ISNULL(SUM(A.PRIMA_EMI),0)/1000000,
	PRIMA_DEV_PESOS = ISNULL(SUM(A.PRIMA_DEV),0)/1000000, 
	PRIMA_EMI_UF = ISNULL(SUM(A.PRIMA_EMI_UF),0),
	PRIMA_DEV_UF = ISNULL(SUM(A.PRIMA_DEV_UF),0), 
	
	COMIS_EMI_PESOS = ISNULL(SUM(A.COMIS_EMI),0)/1000000 ,
	COMIS_DEV_PESOS = ISNULL(SUM(A.COMIS_DEV),0)/1000000 , 
	COMIS_EMI_UF = ISNULL(SUM(A.COMIS_EMI_UF),0) ,
	COMIS_DEV_UF = ISNULL(SUM(A.COMIS_DEV_UF),0) , 
	EXP_AÑO_DEV  = ISNULL(SUM(A.EXP_AÑO_DEV),0) ,
	
	ULT_TOTAL = ISNULL(SUM(A.ULT_TOTAL),0) ,
	ULT_TOTAL_PESOS = ISNULL(SUM(A.ULT_TOTAL_P),0)/1000000, 
	CANTIDAD_ULT = ISNULL(SUM(A.CANTIDAD_ULT),0),
	CANT_SINIESTROS = ISNULL(SUM(A.CANTIDAD),0) ,
	
	AT_DP = ISNULL(SUM(AT_DP),0), 
	LARGE_DP = ISNULL(SUM(LARGE_DP),0),
	WEATHER_DP = ISNULL(SUM(WEATHER_DP),0),
	ULT_DP = ISNULL(SUM(A.ULT_DP),0) ,
	CANT_ULT_DP = ISNULL(SUM(A.CANT_ULT_DP),0),		
	CANT_DP = ISNULL(SUM(A.CANT_DP),0) ,
	PRDP_DEV = ISNULL(SUM(A.PRDP_DEV_UF),0) ,
	
	AT_RC = ISNULL(SUM(AT_RC),0),
	LARGE_RC = ISNULL(SUM(LARGE_RC),0), 
	WEATHER_RC = ISNULL(SUM(WEATHER_RC),0),
	ULT_RC = ISNULL(SUM(A.ULT_RC),0) ,
	CANT_ULT_RC = ISNULL(SUM(A.CANT_ULT_RC),0) ,		
	CANT_RC = ISNULL(SUM(A.CANT_RC),0),
	PRRC_DEV = ISNULL(SUM(A.PRRC_DEV_UF),0) ,

	AT_ROBO = ISNULL(SUM(AT_ROBO),0), 
	LARGE_ROBO = ISNULL(SUM(LARGE_ROBO),0), 
	WEATHER_ROBO =ISNULL(SUM(WEATHER_ROBO),0),
	ULT_ROBO = ISNULL(SUM(A.ULT_ROBO),0) ,
	CANT_ULT_ROBO = ISNULL(SUM(A.CANT_ULT_ROBO),0) ,
	CANT_ROBO = ISNULL(SUM(A.CANT_ROBO),0),
	PRROBO_DEV = ISNULL(SUM(A.PRROBO_DEV_UF),0) ,
	
	AT_PT = ISNULL(SUM(AT_DT),0),
	LARGE_PT = ISNULL(SUM(LARGE_DT),0),
	WEATHER_PT = ISNULL(SUM(WEATHER_DT),0), 
	ULT_PT = ISNULL(SUM(A.ULT_PT),0) ,
	CANT_ULT_PT = ISNULL(SUM(A.CANT_ULT_PT),0) ,
	CANT_PT = ISNULL(SUM(A.CANT_PT),0) ,
	PRPT_DEV = ISNULL(SUM(A.PRPT_DEV_UF),0) ,

	ITEMS_TOTALES_DE_FLOTA =	CASE WHEN A.LINEA_NEGOCIO = 'COMMERCIAL' THEN  B.ITEMS_TOTALES_DE_FLOTA ELSE 0 END,
	CANTIDAD_ITEMS_VIGENTES =	CASE WHEN A.LINEA_NEGOCIO = 'COMMERCIAL' THEN  B.CANTIDAD_ITEMS_VIGENTES ELSE 0 END,
	CANTIDAD_ITEMS_CANCELADOS =	CASE WHEN A.LINEA_NEGOCIO = 'COMMERCIAL' THEN  B.CANTIDAD_ITEMS_CANCELADOS  ELSE 0 END,
	CANTIDAD_ITEMS_FIN_VIGENCIA = CASE WHEN A.LINEA_NEGOCIO = 'COMMERCIAL' THEN B.CANTIDAD_ITEMS_FIN_VIGENCIA ELSE 0 END,
	TAMAÑO = CASE WHEN A.LINEA_NEGOCIO = 'COMMERCIAL' THEN B.TAMAÑO_AGRUPADO ELSE 'NO APLICA' END,

	TAMAÑO_ORDEN =	CASE 
						WHEN A.LINEA_NEGOCIO = 'PERSONAL' THEN 99
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '1'				THEN 1
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '2 - 5'			THEN 2
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '6 - 20'			THEN 3
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '21 - 50'		THEN 4
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '51 - 100'		THEN 5
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '101 - 500'		THEN 6
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '501 - 1000'		THEN 7
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '1001 - 2000'	THEN 8
						WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '2001 - +'		THEN 9 					
						ELSE 100 
					END,

	YTD =			CASE WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 0 AND month(@F_CORTE)-1 THEN 'YTD' else 'Resto' end,

	Rolling =		CASE
						WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 0  AND 11 THEN 'R0_12'
						WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 12 AND 23 THEN 'R12_24'
						WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 24 AND 35 THEN 'R24_36'
						WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 36 AND 47 THEN 'R36_48'
						WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 48 AND 59 THEN 'R48_60' END,
			
	Estado =		CASE WHEN B.CANTIDAD_ITEMS_VIGENTES = 0 THEN 'NO VIGENTE' ELSE 'VIGENTE' END,

	Tipo_Venta =	CASE 
						WHEN A.IND_RENOVACION = 0 THEN 'Nueva'
						when A.IND_RENOVACION = 1 THEN 'Renovación'
						when a.prorroga > 0 then 'Prorroga'
						else 'Indefinido' 
					end,
     						
	TIPO_VEH =		Case 
						when rtrim(A.cdescort) in ('IONIQ','IONIQ ELECTRICO','KANGOO ZE','LEAF') then 'AUTO ELECTRICO'
						when a.NPLANTEC in (6503,6504,6505,6506) then 'BUS EURO6' 
						WHEN a.NPLANTEC in (6482,6369,6837,6267) THEN 'BUS ELECTRICO'
                        ELSE a.TIPO 
					END,

	Seguro_KM =		case 
						when A.NPLANTEC IN (
							5709,5710,5711,5712,5951,5952,5953,5954,5955,5956,5957,5958,5959,5960,5961,5962,5963,5964,
							5965,5966,5967,5968,5969,5970,5971,5972,5973,5974,5975,5976,5977,5978,5979,5980,5981,5982,
							5983,5984,5985,5986,6145,6146,6147,6148,6149,6150,6151,6152,6153,6154,6155,6156,6465,6479,
							6480,6481,6677,6678,6679,6680,6681,6682,6957,6958,6959,6960,6991,6992,6993,6994,7009,7010,
							7011,7012,7013,7014,7015,7016,7017,7018,7019,7020,7080,7081,7082,7083,7520,7519,7528,7527,
							7518,7521,7524,7529,7523,7526,7525,7522
						) then 'SEGURO X KM' 
						ELSE 'OTRO' 
					END -- ,

INTO #BASE_MOTOR_APTP_0
FROM REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR a
LEFT JOIN REPORTES.DBO.FLOTAS_PBI_ITEMS B ON 
	A.NNUMDOCU=B.NNUMDOCU
LEFT JOIN reportes.dbo.AUXILIAR_STROS_2 C ON 
	A.PER=C.PER AND 
	A.NNUMDOCU=C.NNUMDOCU AND 
	A.NNUMITEM=C.NNUMITEM
LEFT JOIN reportes.dbo.aux_parter_unico D ON 
	A.NNUMDOCU = D.NNUMDOCU
LEFT JOIN reportes.dbo.BASE_LOADING E ON 
	A.NNUMDOCU=E.NNUMDOCU AND 
	A.NNUMITEM=E.NNUMITEM
left join transaccional.dbo.Base_resumen_clientes G on 
	a.NNURUPRO = G.nnuruase
WHERE A.PER >= '01-01-2021' AND cast(A.PER as date) <= @F_CORTE
GROUP BY  
	A.NNUMDOCU, a.nnumitem, a.Prorroga,  A.NNUMRUT, A.CORREDOR, A.TIPPLAN, A.DEDUCIBLE, A.LINEA_NEGOCIO, A.NANFAVEH, A.CCOMAVEH, A.CDESCORT, a.channel, A.TOP100,
	A.GAMA, A.CCODSUCU, A.COMUNA, A.CONTRATANTE, A.nplantec, a.ACTIVIDAD_AGRUP, a.cdescrip,A.CNUMPATE, A.CCODRAMO,A.NNURUPRO, d.BU, D.CANAL, D.PARTNER_SUCURSAL,
	a.CHANNEL, G.COMUNA, G.PROVINCIA, G.REGION, G.Latitud_Destino,	G.Longitud_Destino,	G.GSE, G.edad,G.SEXO, E.LOADING,

	case 
		when rtrim(a.cdescrip) not like '%EXCES%' then 0
		when a.fectevig_real < @F_CORTE then 0 
		else 1 
	end,

	case when a.IND_RENOVACION = 0 then 'NB' else 'Reno' end,
	case when a.fectevig_real < @F_CORTE then 'No Vigente' else 'Vigente' end,

	B.ITEMS_TOTALES_DE_FLOTA,
	B.CANTIDAD_ITEMS_VIGENTES, 
	B.CANTIDAD_ITEMS_CANCELADOS, 
	B.CANTIDAD_ITEMS_FIN_VIGENCIA, 

	CONVERT(DATE,DATEADD(MS,-3,DATEADD(MM,0,DATEADD(MM,DATEDIFF(MM,0,CONVERT(DATETIME,a.FECINVIG))+1,0)))) ,
	YEAR(A.FECINVIG)*100+MONTH(A.FECINVIG),
	YEAR(A.FECTEVIG_REAL)*100+MONTH(A.FECTEVIG_REAL),

	(DATEDIFF(month,A.per,@F_CORTE))/3,
	(DATEDIFF(month,A.FECINVIG,@F_CORTE))/3,
	IIF((DATEDIFF(month,A.per,@F_CORTE))/3>5,5,(DATEDIFF(month,A.per,@F_CORTE))/3),
	IIF((DATEDIFF(month,A.FECINVIG,@F_CORTE))/3>5,5,(DATEDIFF(month,A.FECINVIG,@F_CORTE))/3),
	IIF((DATEDIFF(month,A.per,@F_CORTE))/3>5,5,(DATEDIFF(month,A.per,@F_CORTE))/3)*-1,
	(DATEDIFF(month,A.per,@F_CORTE))/3*-1,   

	CASE WHEN A.LINEA_NEGOCIO = 'COMMERCIAL' THEN B.TAMAÑO_AGRUPADO ELSE 'NO APLICA' END,
	CASE WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 0  AND month(@F_CORTE)-1 THEN 'YTD' else 'Resto' end ,
	CASE
		 WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 0  AND 11 THEN 'R0_12'
		 WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 12 AND 23 THEN 'R12_24'
		 WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 24 AND 35 THEN 'R24_36'
		 WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 36 AND 47 THEN 'R36_48'
		 WHEN DATEDIFF(MONTH, cast(a.PER as date), @F_CORTE) BETWEEN 48 AND 59 THEN 'R48_60' 
	END,
    CASE 
		 WHEN A.LINEA_NEGOCIO = 'PERSONAL' THEN 99
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '1'				THEN 1
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '2 - 5'			THEN 2
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '6 - 20'		THEN 3
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '21 - 50'		THEN 4
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '51 - 100'		THEN 5
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '101 - 500'		THEN 6
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '501 - 1000'	THEN 7
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '1001 - 2000'	THEN 8
		 WHEN RTRIM(LTRIM(B.TAMAÑO_AGRUPADO)) = '2001 - +'		THEN 9 					
		 ELSE 100 
	END,
	CASE 
		 WHEN A.IND_RENOVACION = 0 THEN 'Nueva'
		 when A.IND_RENOVACION = 1 THEN 'Renovación'
		 when a.prorroga > 0 then 'Prorroga'
		 else 'Indefinido' 
	end,
	case 
		when A.NPLANTEC IN (
			5709,5710,5711,5712,5951,5952,5953,5954,5955,5956,5957,5958,5959,5960,5961,5962,5963,5964,
			5965,5966,5967,5968,5969,5970,5971,5972,5973,5974,5975,5976,5977,5978,5979,5980,5981,5982,
			5983,5984,5985,5986,6145,6146,6147,6148,6149,6150,6151,6152,6153,6154,6155,6156,6465,6479,
			6480,6481,6677,6678,6679,6680,6681,6682,6957,6958,6959,6960,6991,6992,6993,6994,7009,7010,
			7011,7012,7013,7014,7015,7016,7017,7018,7019,7020,7080,7081,7082,7083,7520,7519,7528,7527,
			7518,7521,7524,7529,7523,7526,7525,7522
		) then 'SEGURO X KM' 
		ELSE 'OTRO' 
	END,
	Case 
		when rtrim(A.cdescort) in ('IONIQ','IONIQ ELECTRICO','KANGOO ZE','LEAF') then 'AUTO ELECTRICO'
		when a.NPLANTEC in (6503,6504,6505,6506) then 'BUS EURO6' 
		WHEN a.NPLANTEC in (6482,6369,6837,6267) THEN 'BUS ELECTRICO'
        ELSE a.TIPO 
	END
-- (5714298 rows affected)
--


drop table if exists #BASE_MOTOR_APTP
select *,
	Q_Emisión = year(DATEADD(month, -(Q_EMI_AGRUP_2 * 3), fecha_corte))*100 + month(DATEADD(month, -(Q_EMI_AGRUP_2 * 3), fecha_corte)),
	Q_Periodo = year(DATEADD(month, -(Q_PER_AGRUP_2 * 3), fecha_corte))*100 + month(DATEADD(month, -(Q_PER_AGRUP_2 * 3), fecha_corte))
into #BASE_MOTOR_APTP
from #BASE_MOTOR_APTP_0 


drop table if exists REPORTES.DBO.BASE_MOTOR_APTP_salida_intermedia
select * 
into REPORTES.DBO.BASE_MOTOR_APTP_salida_intermedia
FROM #BASE_MOTOR_APTP
-- (5371809 rows affected)

--DROP TABLE IF EXISTS #BASE_MOTOR_APTP
--SELECT * INTO #BASE_MOTOR_APTP 
--FROM REPORTES.DBO.BASE_MOTOR_APTP_salida_intermedia


----------------------------------------------------    AGREGO NOMBRE DEL CONTRATANTE   ---------------------------------------------------------------------
-- IMPORTANTE!!!
/*
	-- La guardo en una tabla fija para que tarde menos tiempo
	-- Ejecutar esta parte cuando haya un descuadre en comparacion a la tabla de SOL
	-- Tarda aprox 25 minutos

	select count(*) from transaccional.dbo.TBACSMAE
	select count(*) from SOL.S1031EBB.RSASOLDB2.TBACSMAE 

	drop table if exists transaccional.dbo.TBACSMAE
	select nnumrut, CAPEPATE, CAPEMATE, CNOMPERS, CNOCOPER
	into transaccional.dbo.TBACSMAE 
	from SOL.S1031EBB.RSASOLDB2.TBACSMAE 
	--(6445689 row(s) affected)
*/

DROP TABLE IF EXISTS #BASE_MOTOR_APTP_2
SELECT A.*, 
	DEDUCIBLE_AGRUP = CASE WHEN a.DEDUCIBLE IN ('0','3','5','8','10') THEN a.DEDUCIBLE ELSE 'RESTO' END,
	COBERTURA_AGRUP = CASE 
						   WHEN C.NPLANTEC IS NOT NULL THEN 'PRODUCTOS TELEMATICOS'
						   WHEN A.TIPPLAN = 'FULL' THEN 'FULL'
						   WHEN A.TIPPLAN = 'PT + RC' THEN 'PT + RC'
						   when a.nplantec in (7912,7754,7751,7811,7457,6599,6598,6601,6600,6597,7204,6883,7348,7497,6421,6333,6422,6193) then 'MICROMOVILIDAD'
						   ELSE 'RESTO' 
					  END,
	ORDEN_COBERTURA_AGRUP = CASE 
								WHEN C.NPLANTEC IS NOT NULL THEN 3
								WHEN A.TIPPLAN = 'FULL' THEN 1
								WHEN A.TIPPLAN = 'PT + RC' THEN 2
								ELSE 4 
							END, 
	KM_TELEMATICO_RESTO = CASE WHEN C.NPLANTEC IS NOT NULL THEN C.TIPO ELSE 'RESTO' END,
	B.CNOCOPER as NOMBRE_CONTRATANTE
INTO #BASE_MOTOR_APTP_2
FROM #BASE_MOTOR_APTP  A 
LEFT JOIN transaccional.dbo.TBACSMAE B 
ON A.CONTRATANTE = B.NNUMRUT
LEFT JOIN [Transaccional].[dbo].[planes_tecnicos_sxkm_cpro] C
ON A.NPLANTEC = C.NPLANTEC
-- (5371809 rows affected)


---------------------------------------------------   Salida   ----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #aux_2
select *,
Partner_PyG = case when canal = 'AFFINITY' then
	case 
		when partner_sucursal = 'ABCDin' then 'ABC DIN'
		when partner_sucursal in ('Banco Bice','BICE') then 'BICE'
		when partner_sucursal in ('Banchile','Banco Chile','Banco de Chile') then 'Banchile'
		when partner_sucursal = 'Banco Estado' then 'Banco Estado'
		when partner_sucursal = 'Banco Falabella' then 'Banco Falabella'
		when partner_sucursal = 'Banco Internacional' then 'Banco Internacional'
		when partner_sucursal = 'Banco Itau' then 'ITAU'
		when partner_sucursal in ('Banco Santander','Santander Corredora') then 'Santander Corredora'
		when partner_sucursal = 'BBVA' then 'BBVA'
		when partner_sucursal = 'CC Los Andes' then 'CC Los Andes'
		when partner_sucursal = 'Cencosud' then 'Cencosud'
		when partner_sucursal = 'Chilectra' then 'Chilectra'
		when partner_sucursal in ('Compara','Compara Online') then 'Compara'
		when partner_sucursal = 'Corpbanca' then 'Corpbanca'
		when partner_sucursal = 'Cruz Blanca' then 'Cruz Blanca'
		when partner_sucursal in ('Dealer Directo','Dealers Directos') then 'Dealers Directos'
		when partner_sucursal = 'Derco' then 'Derco'
		when partner_sucursal = 'Entel' then 'RSA'
		when partner_sucursal = 'Ex AG' then 'Ex AG'
		when partner_sucursal = 'Falabella' then 'Falabella'
		when partner_sucursal = 'Falabella Dealers' then 'Dealers Falabella'
		when partner_sucursal = 'Forum' then 'Forum'
		when partner_sucursal = 'ITAU+Corpbanca' then 'ITAU'
		when partner_sucursal in ('La Araucana Flujo','La Araucana Stock') then 'La Araucana'
		when partner_sucursal = 'La Polar' then 'La Polar'
		when partner_sucursal = 'Mesos' then 'Mesos'
		when partner_sucursal = 'MOK' then 'MOK'
		when partner_sucursal = 'NO IDENTIFICADO' then ''
		when partner_sucursal = 'Paris' then 'Cencosud'
		when partner_sucursal in ('Renta Nacional','RSA','RSA Directo') then 'RSA'
		when partner_sucursal = 'Ripley' then 'Ripley'
		when partner_sucursal = 'Scotiabank' then 'Scotiabank'
		when partner_sucursal = 'Uber' then 'UBER'
		when partner_sucursal = 'Walmart' then 'Walmart'
		------------------------------
		when partner_sucursal in (
			'0','Automovil Club','Canal Asesor','Central Hipotecaria ','CNC' ,'Consorcio','Coopeuch','Evoluciona Mutuos','Hipotecaria Metlife',
			'Los Heroes','Movistar') then 'Others_2'
		when partner_sucursal in (
			'123 Corredora','Cerokms','Cotiza OK','Financoop','Others_3','PDI','Rentacapp','Security','SMU','Servihabit') then 'Others_3'
		when partner_sucursal in (
			'Banigualdad','BCI','Canal Directo','Casa Matriz','Concreces','Cornershop','Corporativos','Others_4','Tucar') then 'Others_4'
	end
	else Partner_sucursal 
end,

Flotas_Desviadas = case 
	when nombre_Contratante = 'Red Bus Urbano  S.  A.' then 'Transantiago - Red Bus '
	when nombre_Contratante = 'Buses Vule S. A.' then 'Transantiago - Vule'
	when nombre_Contratante = 'Banco Del Estado De Chile' then 'Banco de Estado'
	when nombre_Contratante = 'Subus Chile S. A.' then 'Subus - Transantiago'
	when nombre_Contratante = 'Banco Santander Chile' then 'Santander Banco'
	when nombre_Contratante = 'Soc. Com. Grandleasing Chile Ltda.' then 'Grandleasing'
	when nombre_Contratante = 'Inversiones Invergas S. A.' then 'Invergas'
	when nombre_Contratante = 'Salinas Y Fabres S. A.' then 'SALFA'
	when nombre_Contratante = 'Servicio De Transporte De Personas Santiago S. A.' then 'Transantiago - Servicio de Transporte de Personas SA'
	else 'Resto' 
end,

RAMO = case 
	when CCODRAMO = 'AC' then 'INCENDIO COMERCIAL'
	when CCODRAMO = 'AE' then 'SEGURO PERSONAL COMPRENSIVO ANS'
	when CCODRAMO = 'AV' then 'ASISTENCIA EN VIAJE INTEGRAL'
	when CCODRAMO = 'EC' then 'ASISTENCIA AL VEHICULO'
	when CCODRAMO = 'EE' then 'VEHICULOS MOTORIZADOS'
	when CCODRAMO = 'EL' then 'VEHICULOS COMERCIALES LIVIANOS'
	when CCODRAMO = 'EP' then 'VEHICULOS MOTORIZADOS PESADOS'
	when CCODRAMO = 'M' then 'MISCELANEOS'
	else 'No indenficado' 
end
into #aux_2
from #BASE_MOTOR_APTP_2
--(5522046 rows affected)


---------------------------------------- Inspección ----------------------------------------

drop table if exists #aux_inspecciones
select poliza, item
into #aux_inspecciones
from Transaccional.dbo.atributos2 b
group by poliza, item
-- (1870549 rows affected)


drop table if exists #aux_3_salida
select a.*
into #aux_3_salida
from #aux_2 a
left join #aux_inspecciones b
on a.nnumdocu=b.poliza and a.NNUMITEM=b.item
-- (5522046 rows affected)

DROP TABLE IF EXISTS #aux_3_salida_2
SELECT *, 
ORDEN_Q_PER_2 = Q_PER*(-1)
INTO #aux_3_salida_2
from #aux_3_salida
-- (5.384.235 rows affected)


------------------ Agrego Channel Agrupado + Marca Productos Telemáticos + Agrupo Coberturas --------------------------

----- Traigo esta base para ver si la venta del directo es televenta o web
drop table if exists #aux_channel
create table #aux_channel(
	poliza int, 
	item int, 
	channel_venta nvarchar(50), 
	grupo_channel nvarchar(50)
)

insert into #aux_channel
select poliza, item, 
max(channel) as channel_VENTA,
max(GRUPO_CHANNEL) as grupo_channel
from transaccional.dbo.atributos2
group by poliza, item

----- Armo la variable de grupo canal asociada a la agrupacion de roman de comité
drop table if exists #grupo_canal
create table #grupo_canal(
	nnumdocu int, 
	nnumitem int, 
	grupo_channel nvarchar(50), 
	channel_roman nvarchar(50)
)

insert into #grupo_canal
select nnumdocu, nnumitem, 
max(bu2) as GRUPO_CHANNEL , 
max(canal) as channel_roman
from sgf1034.GestionPortafolio.dbo.Poliza_Canal_BU
group by  nnumdocu, nnumitem
-- (2.262.751 rows affected)

drop table if exists #grupo_canal_2
select a.*, 
b.GRUPO_CHANNEL as GRUPO_CHANNEL_2, 
b.channel_roman, 
c.channel_VENTA
into #grupo_canal_2
from  #aux_3_salida_2 a
left join #grupo_canal b on 
	a.nnumdocu = b.nnumdocu and 
	a.nnumitem=b.nnumitem
left join #aux_channel c on 
	a.nnumdocu = c.poliza and 
	a.nnumitem = c.item
-- (5384235 rows affected)

drop table if exists #grupo_canal_3
select *, 
Grupo_Canal_Comite = case 
	WHEN channel_roman in ('FALABELLA','SANTANDER','RIPLEY','COMPARA','AUTOMOVIL CLUB','CENCOSUD') then channel_roman 
	WHEN channel_roman like 'masi%' then 'AFFINITY OTROS'
	ELSE GRUPO_channel_2 
END
into #grupo_canal_3
from #grupo_canal_2
-- (5384235 rows affected)


---------------------------------------- Cuento NB y Reno ---------------------------------------- 
drop table if exists #aux
SELECT nnumdocu, nnumitem, prorroga, min(Q_PER) as Q_PER_EMISION 
into #aux
FROM #grupo_canal_3
group by nnumdocu, nnumitem, prorroga
-- (1723204 rows affected)

drop table if exists #aux_22
select 
	a.*, b.Q_PER_EMISION, 
	cant_emisiones = case when b.Q_PER_EMISION is not null then 1 else 0 end
into #aux_22
FROM #grupo_canal_3 a
left join #aux b on 
	a.nnumdocu = b.nnumdocu and 
	a.nnumitem = b.nnumitem and 
	a.Prorroga = b.prorroga and 
	a.Q_PER=b.Q_PER_EMISION
--(5.822.086 row(s) affected)


---------------------------------------- SALIDA ---------------------------------------- 
drop table if exists #aux_salida_inspeccion
select a.*--, b.insp_proveedor
into #aux_salida_inspeccion
from #aux_22 a
left join #aux_inspecciones b on 
	a.nnumdocu=b.poliza and 
	a.nnumitem=b.item



DROP TABLE IF EXISTS REPORTES.DBO.BASE_MOTOR_APTP
SELECT * 
INTO REPORTES.DBO.BASE_MOTOR_APTP
from #aux_salida_inspeccion
--(5522046 row(s) affected)



------------FIN------------



--BORRAR TABLAS TEMPORALES PARA LIBERAR ESPACIO
DROP TABLE IF EXISTS #AUXILIAR_STROS
DROP TABLE IF EXISTS #AUXILIAR_STROS_2
DROP TABLE IF EXISTS #CANCELACIONES_0
DROP TABLE IF EXISTS #CANCELACIONES_1
DROP TABLE IF EXISTS #CANCELACIONES
DROP TABLE IF EXISTS #SALIDA_CANCELACIONES
DROP TABLE IF EXISTS #BASE_LOADING
DROP TABLE IF EXISTS #aux_partener
DROP TABLE IF EXISTS #aux_partner
DROP TABLE IF EXISTS #aux_parter_unico
DROP TABLE IF EXISTS #BASE_MOTOR_APTP
DROP TABLE IF EXISTS #AUX_FECHAS
DROP TABLE IF EXISTS #BASE_MOTOR_APTP_0
DROP TABLE IF EXISTS #BASE_MOTOR_APTP_2
DROP TABLE IF EXISTS #aux_2
DROP TABLE IF EXISTS #aux_inspecciones
DROP TABLE IF EXISTS #aux_3_salida
DROP TABLE IF EXISTS #aux_3_salida_2
DROP TABLE IF EXISTS #aux_channel
DROP TABLE IF EXISTS #grupo_canal
DROP TABLE IF EXISTS #grupo_canal_2
DROP TABLE IF EXISTS #grupo_canal_3
DROP TABLE IF EXISTS #aux
DROP TABLE IF EXISTS #aux_salida_inspeccion

END