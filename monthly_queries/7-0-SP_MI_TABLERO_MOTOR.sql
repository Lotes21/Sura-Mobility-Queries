USE [Transaccional]
GO
/****** Object:  StoredProcedure [dbo].[SP_MI_TABLERO_MOTOR]    Script Date: 14-10-2025 10:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER  PROCEDURE [dbo].[SP_MI_TABLERO_MOTOR] (
	@CIERRE AS INT
)
AS
   
--exec [dbo].[SP_MI_TABLERO_MOTOR] 202506

BEGIN

/****** Checkpoint Inicio ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR INICIADO', SYSDATETIME())
/*********************************************************************************/
---- INICIA PROCESO
-- tabla auxiliar para marcar polizas de uber
SELECT distinct num_poliza as nnumdocu,ramo_keira
into #polizas_uber
--FROM sgf1034.Actuarial.dbo.pagos_rvas
FROM (select * from openquery(sgf1034, 'select num_poliza, ramo_keira, RAMO_ibnr_ifrs from Actuarial.dbo.pagos_rvas') ) A
where (RAMO_ibnr_ifrs LIKE '%UBER%' or RAMO_ibnr_ifrs LIKE '%UBER') AND RAMO_KEIRA='Motor'

-------------------------------------------------------
--TRUNCATE TABLE AUX_MOTOR_06_CHECKPOINTS
--SELECT * FROM AUX_MOTOR_06_CHECKPOINTS
-------------------------------------------------------

DROP TABLE IF EXISTS #Tablero_Motor
DROP TABLE IF EXISTS #Tablero_Motor_final

/****** Checkpoint 0 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 0', SYSDATETIME())
/****************************************************************************/

--- genera tabla con info para tablero por poliza item
select a.nnumdocu,A.NNUMITEM,A.[LINEA_NEGOCIO],rtrim(ccodramo) as codramo,contratante,NNUMRUT,NNURUPRO,rtrim(cnumpate) patente,
	case when f.nnumdocu is not null and A.linea_negocio='COMMERCIAL' then 'UBER'
	WHEN A.NPLANTEC IN (6245,6246,6247,6248,6244,5824,5828,5829,5337,6273,5335,6159,5253,6692,6660,6686,6666,6672,6654) AND A.LINEA_NEGOCIO='PERSONAL' THEN 'UBER' ELSE a.CHANNEL END AS CHANNEL,
	case when f.nnumdocu is not null and A.linea_negocio='COMMERCIAL' then 'AFFINITY' when rtrim(a.bu) ='CANAL ASESOR'  then 'CANAL ASESOR' ELSE C.GRUPO_CHANNEL END AS GRUPO_CHANNEL,
	case when f.nnumdocu is not null and A.linea_negocio='COMMERCIAL' then 'NEGOCIOS MASIVOS Y CLIENTES' when rtrim(a.bu) ='CANAL ASESOR'  then 'CANAL ASESOR'ELSE  a.BU END  AS BU,CORREDOR,
	A.NPLANTEC,[TIPPLAN],CASE WHEN A.FLOTA LIKE 'TSTGO%' THEN case when a.NPLANTEC in (6503,6504,6505,6506) then 'BUS EURO6' WHEN a.NPLANTEC in (6482,6369,6837,6267) THEN 'BUS ELECTRICO' ELSE 'BUS CONVENCIONAL' end ELSE D.NOMBRE2 END as PLAN_TECNICO,RTRIM(A.CDESCRIP) PLAN_TECNICO2,D.[PRODUCTO NUEVO] as PRODUCTOS_NUEVOS,[DEDUCIBLE],
	case when rtrim(A.cdescort) in ('IONIQ','IONIQ ELECTRICO','KANGOO ZE','LEAF') then 'AUTO ELECTRICO' ELSE [TIPO] END AS TIPO_VEH,GAMA AS GAMA_VEH,
	rtrim(CCOMAVEH) AS MARCA,rtrim(CDESCORT) AS MODELO,RTRIM(CCOMAVEH) + ' - ' + RTRIM(CDESCORT)  AS MARCA_MODELO,NANFAVEH,
	CASE WHEN g.MARCA_MODELO IS NULL THEN 'NO TOP100' ELSE g.MARCA_MODELO END as TOP100,
	case WHEN rtrim(NOMSUCU) in ('TALCA','CURICO','VI—A DEL MAR','RANCAGUA') THEN 'CENTRO' WHEN rtrim(NOMSUCU) in ('TEMUCO','CONCEPCION','CHILLAN','LOS ANGELES') THEN 'CENTRO SUR'
	WHEN rtrim(NOMSUCU) in ('IQUIQUE','ARICA','ANTOFAGASTA','CALAMA','BBC  COPIAPO','LA SERENA') THEN 'NORTE' WHEN rtrim(NOMSUCU) in ('PUERTO MONTT','PUNTA ARENAS','*PUNTA ARENAS','OSORNO','VALDIVIA') THEN 'SUR' 
	WHEN rtrim(NOMSUCU) in ('CASA MATRIZ','SUCURSAL PROVIDENCIA','SANTIAGO CENTRO','SUC AGUSTINAS') THEN 'CASA MATRIZ' ELSE RTRIM(NOMSUCU) END AS ZONA_SUCURSAL,
	RTRIM(NOMSUCU) AS SUCURSAL,REGION,REGIONES_URBES AS REGION_URBE,PROVINCIA,
	case when IND_RENOVACION=1 THEN 'RENOVACION' when IND_RENOVACION=0 THEN 'NUEVA' ELSE 'Unknown' END AS NUEVA_RENOV,
	CASE WHEN I.RUT_ASEG IS NOT NULL AND A.LINEA_NEGOCIO='COMMERCIAL' THEN I.FLOTA2 ELSE case when A.FLOTA IS NULL then 'SIN ASIGNAR' ELSE A.FLOTA END END AS FLOTA,
	case when b.AGRUP_FLOTA IS NULL then 'SIN ASIGNAR' ELSE b.agrup_flota END AS GRUPO_FLOTA,TAMA—O,
	STR(year(PER),4) + 'Q' + STR(case when month(per)<=3 then 1 when month(per)<=6 then 2  when month(per)<=9 then 3 else 4 end,1) AS PERIODO,PER,
	(CASE WHEN YEAR(PER)-NANFAVEH=0 THEN '0' WHEN YEAR(PER)-NANFAVEH <= 3 THEN '1 a 3' WHEN YEAR(PER)-NANFAVEH <= 5 THEN '4 a 5' WHEN YEAR(PER)-NANFAVEH <= 8 THEN '5 a 8' WHEN YEAR(PER)-NANFAVEH <= 10 THEN '8 a 10' WHEN YEAR(PER)-NANFAVEH >10 THEN 'Mayor a 10' ELSE 'SIN A—O' end) as ANT_VEH,
	(CASE WHEN EDAD='Unknown' then 'DESCONOCIDO' WHEN EDAD='NO APLICA' then 'NO APLICA' WHEN cast(EDAD as int)<=25 THEN '18 A 25' WHEN cast(EDAD as int)<=30 THEN '26 A 30' WHEN cast(EDAD as int)<=40 THEN '31 A 40' WHEN cast(EDAD as int)<=50 THEN '41 A 50' WHEN cast(EDAD as int)<=60 THEN '51 A 60' WHEN cast(EDAD as int)>60 THEN '>60' ELSE 'DESCONOCIDO' END) AS EDAD,
	CASE WHEN a.LINEA_NEGOCIO='PERSONAL' THEN CASE WHEN NNURUPRO>=21600000 and NNURUPRO<=35000000 THEN 'EXTRANJERO' ELSE 'CHILENO' END ELSE 'NA' END AS EXTRANJERO,
	CASE WHEN j.mm is not null then 'PERFIL UBER' ELSE 'OTRO' END AS PERFIL_UBER,
	min(SISUF) SISUF,
	case when VIGENCIA_TEORICA between 364 and 367 then 'ANUAL' when VIGENCIA_TEORICA between 27 and 32 then 'MENSUAL' when VIGENCIA_TEORICA between 728 and 733 then 'BIENAL' when VIGENCIA_TEORICA=0 THEN 'NULA' WHEN VIGENCIA_TEORICA<=27 THEN 'CORTA' WHEN VIGENCIA_TEORICA> 733 THEN 'LARGA' ELSE 'OTRA' END AS VIGENCIA, 
	SUM(PRIMA_EMI_UF) AS PRIMA_EMI,SUM(COMIS_EMI_UF) AS COMIS_EMI,sum(case when prima_emi_uf>0 then 1 else 0 end) as c_emisiones,
	SUM(EXP_A—O_DEV) AS EXPOS,SUM(PRIMA_DEV_UF) AS PRIMA_DEV,SUM(COMIS_DEV_UF) AS COMIS_DEV,
	SUM(case when vigencia_exp_aÒo=0 or vigencia_exp_aÒo is null or vigencia_teorica is null then prima_emi_uf else PRIMA_EMI_UF*vigencia_teorica/vigencia_exp_aÒo end) AS PRIMA_EMI_ENT,
	SUM((case when E.channel is null then 0 else E.factor_canal end)*PRIMA_DEV_uf) as Gtos_Adq,
	sum(PRDP_DEV_UF) AS PRDP_EMI,sum(PRPT_DEV_UF) AS PRPT_EMI,	sum(PRRC_DEV_UF) AS PRRC_EMI,
	sum(PRROBO_DEV_UF) AS PRROBO_EMI,
	sum(PRDP_DEV_UF) + sum(PRPT_DEV_UF) + sum(PRRC_DEV_UF) + sum(PRROBO_DEV_UF) AS PRRIESGO_EMI,	
	sum(PRDP_DEV_UF) AS PRDP_DEV, sum(PRPT_DEV_UF) AS PRPT_DEV,	sum(PRRC_DEV_UF) AS PRRC_DEV, sum(PRROBO_DEV_UF) AS PRROBO_DEV,
	sum(PRDP_DEV_UF) + sum(PRPT_DEV_UF) + sum(PRRC_DEV_UF) + sum(PRROBO_DEV_UF) AS PRRIESGO_DEV,	
	sum(FRECDP_DEV) AS FRECDP_DEV,	sum(FRECPT_DEV) AS FRECPT_DEV,	sum(FRECRC_DEV) AS FRECRC_DEV,	sum(FRECROBO_DEV) AS FRECROBO_DEV,
	sum(FRECDP_DEV) + sum(FRECPT_DEV) + sum(FRECRC_DEV) + sum(FRECROBO_DEV)  AS FRECTOT_DEV,
	sum(CANT_ULT_DP) AS CANT_ULT_DP,sum(CANT_ULT_PT) AS CANT_ULT_PT,sum(CANT_ULT_RC) AS CANT_ULT_RC,sum(CANT_ULT_ROBO) AS CANT_ULT_ROBO,sum(CANT_ULT_ASIST) AS CANT_ULT_ASIST,sum(CANTIDAD_ULT) AS CANT_ULT_TOTAL,
	sum(ULT_DP) AS ULT_DP,sum(ULT_PT) AS ULT_PT,sum(ULT_RC) AS ULT_RC,sum(ULT_ROBO) AS ULT_ROBO,sum(ULT_ASIST) AS ULT_ASIST,sum(ULT_TOTAL) AS ULT_TOTAL,
	sum(CANT_DP) AS CANT_DP,sum(CANT_PT) AS CANT_PT,sum(CANT_RC) AS CANT_RC,sum(CANT_ROBO) AS CANT_ROBO,sum(CANT_ASIST) AS CANT_ASIST,sum(CANTIDAD) AS CANT_ULT,
	sum(PAGO_DP) AS PAGO_DP,sum(PAGO_PT) AS PAGO_PT,sum(PAGO_RC) AS PAGO_RC,sum(PAGO_ROBO) AS PAGO_ROBO,sum(PAGO_ASIST) AS PAGO_ASIST,sum(PAGO_DP)+sum(PAGO_PT)+sum(PAGO_RC)+sum(PAGO_ROBO)AS PAGO_TOTAL,
	sum(RESERVA_DP) AS RESERVA_DP,sum(RESERVA_PT) AS RESERVA_PT,sum(RESERVA_RC) AS RESERVA_RC,sum(RESERVA_ROBO) AS RESERVA_ROBO,sum(RESERVA_ASIST) AS RESERVA_ASIST,sum(RESERVA_DP)+sum(RESERVA_PT)+sum(RESERVA_RC)+sum(RESERVA_ROBO)AS RESERVA_TOTAL
INTO #Tablero_Motor
from Reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR a
left join sgf1034.GestionPortafolio.dbo.Agrupamiento_Flotas b
	on a.flota=b.flota
left join sgf1034.GestionPortafolio.dbo.Agrupamiento_Canales c
	on a.CHANNEL=c.CHANNEL
left join sgf1034.GestionPortafolio.dbo.Agrupamiento_Planes d
	on a.NPLANTEC=d.NPLANTEC
left join sgf1034.GestionPortafolio.dbo.Tablero_Factores_OtrosGtosAdq E
	on a.linea_negocio=E.linea_negocio and a.channel=E.channel
left join #polizas_uber f
	on a.nnumdocu=f.nnumdocu
LEFT JOIN sgf1034.gestionPortafolio.dbo.TOP100_VEH g
	ON a.LINEA_NEGOCIO=g.linea_negocio 
	AND RTRIM(CCOMAVEH)=g.marca 
	AND RTRIM(CDESCORT)=g.MODELO
LEFT JOIN sgf1034.gestionPortafolio.dbo.factores_ajuste_riesgo H
	on a.channel=H.channel and (CASE WHEN A.TIPPLAN='PT+RC' THEN 'PT + RC' ELSE A.TIPPLAN END)=H.[tipo producto]
left join sgf1034.GestionPortafolio.dbo.MAPEO_FLOTAS I
	on a.CONTRATANTE=I.RUT_ASEG
left join sgf1034.gestionPortafolio.dbo.Autos_UBER j
	on RTRIM(CCOMAVEH) + ' - ' + RTRIM(CDESCORT)=j.MM
WHERE 
	--YEAR(per)>=2019 and year(PER)*100+month(per)<=@CIERRE ---- CAMBIAR FECHA
	YEAR(per)>=2020 and year(PER)*100+month(per)<=@CIERRE ---- CAMBIAR FECHA
GROUP BY 
	a.nnumdocu,A.NNUMITEM,A.[LINEA_NEGOCIO],NNUMRUT,NNURUPRO,
	case when f.nnumdocu is not null and A.linea_negocio='COMMERCIAL' then 'UBER'
	WHEN A.NPLANTEC IN (6245,6246,6247,6248,6244,5824,5828,5829,5337,6273,5335,6159,5253,6692,6660,6686,6666,6672,6654) AND A.LINEA_NEGOCIO='PERSONAL' THEN 'UBER' ELSE a.CHANNEL END,
	case when f.nnumdocu is not null and A.linea_negocio='COMMERCIAL' then 'AFFINITY' when rtrim(a.bu) ='CANAL ASESOR'  then 'CANAL ASESOR' ELSE C.GRUPO_CHANNEL END,
	case when f.nnumdocu is not null and A.linea_negocio='COMMERCIAL' then 'NEGOCIOS MASIVOS Y CLIENTES' when rtrim(a.bu) ='CANAL ASESOR'  then 'CANAL ASESOR' ELSE a.BU END,
	A.NPLANTEC,[TIPPLAN],CASE WHEN A.FLOTA LIKE 'TSTGO%' THEN case when a.NPLANTEC in (6503,6504,6505,6506) then 'BUS EURO6' WHEN a.NPLANTEC in (6482,6369,6837,6267) THEN 'BUS ELECTRICO' ELSE 'BUS CONVENCIONAL' end ELSE D.NOMBRE2 END,
	D.[PRODUCTO NUEVO],[DEDUCIBLE],rtrim(cnumpate),
	case when rtrim(A.cdescort) in ('IONIQ','IONIQ ELECTRICO','KANGOO ZE','LEAF') then 'AUTO ELECTRICO' ELSE [TIPO] END,GAMA,
	NOMSUCU,REGION,REGIONES_URBES,PROVINCIA,TOP100, 
	CASE WHEN I.RUT_ASEG IS NOT NULL AND A.LINEA_NEGOCIO='COMMERCIAL' THEN I.FLOTA2 ELSE case when A.FLOTA IS NULL then 'SIN ASIGNAR' ELSE A.FLOTA END END,
	STR(year(PER),4) + 'Q' + STR(case when month(per)<=3 then 1 when month(per)<=6 then 2  when month(per)<=9 then 3 else 4 end,1),PER,
	case when IND_RENOVACION=1 THEN 'RENOVACION' when IND_RENOVACION=0 THEN 'NUEVA' ELSE 'Unknown' END,
	(CASE WHEN YEAR(PER)-NANFAVEH=0 THEN '0' WHEN YEAR(PER)-NANFAVEH <= 3 THEN '1 a 3' WHEN YEAR(PER)-NANFAVEH <= 5 THEN '4 a 5' WHEN YEAR(PER)-NANFAVEH <= 8 THEN '5 a 8' WHEN YEAR(PER)-NANFAVEH <= 10 THEN '8 a 10' WHEN YEAR(PER)-NANFAVEH >10 THEN 'Mayor a 10' ELSE 'SIN A—O' end),
	(CASE WHEN EDAD='Unknown' then 'DESCONOCIDO' WHEN EDAD='NO APLICA' then 'NO APLICA' WHEN cast(EDAD as int)<=25 THEN '18 A 25' WHEN cast(EDAD as int)<=30 THEN '26 A 30' WHEN cast(EDAD as int)<=40 THEN '31 A 40' WHEN cast(EDAD as int)<=50 THEN '41 A 50' WHEN cast(EDAD as int)<=60 THEN '51 A 60' WHEN cast(EDAD as int)>60 THEN '>60' ELSE 'DESCONOCIDO' END),
	CCOMAVEH,CDESCORT,CASE WHEN g.MARCA_MODELO IS NULL THEN 'NO TOP100' ELSE g.MARCA_MODELO END,	case when b.AGRUP_FLOTA IS NULL then 'SIN ASIGNAR' ELSE b.agrup_flota END,CORREDOR,
	CASE WHEN a.LINEA_NEGOCIO='PERSONAL' THEN CASE WHEN NNURUPRO>=21600000 and NNURUPRO<=35000000 THEN 'EXTRANJERO' ELSE 'CHILENO' END ELSE 'NA' END,
	CASE WHEN j.mm is not null then 'PERFIL UBER' ELSE 'OTRO' END,TAMA—O,rtrim(ccodramo),
	case when VIGENCIA_TEORICA between 364 and 367 then 'ANUAL' when VIGENCIA_TEORICA between 27 and 32 then 'MENSUAL' when VIGENCIA_TEORICA between 728 and 733 then 'BIENAL' when VIGENCIA_TEORICA=0 THEN 'NULA' WHEN VIGENCIA_TEORICA<=27 THEN 'CORTA' WHEN VIGENCIA_TEORICA> 733 THEN 'LARGA' ELSE 'OTRA' END, 
	case WHEN rtrim(NOMSUCU) in ('TALCA','CURICO','VI—A DEL MAR','RANCAGUA') THEN 'CENTRO NORTE' WHEN rtrim(NOMSUCU) in ('TEMUCO','CONCEPCION','CHILLAN','LOS ANGELES') THEN 'CENTRO SUR'
	WHEN rtrim(NOMSUCU) in ('IQUIQUE','ARICA','ANTOFAGASTA','CALAMA','BBC  COPIAPO','LA SERENA') THEN 'NORTE' WHEN rtrim(NOMSUCU) in ('PUERTO MONTT','PUNTA ARENAS','*PUNTA ARENAS','OSORNO','VALDIVIA') THEN 'SUR' 
	WHEN rtrim(NOMSUCU) in ('CASA MATRIZ','SUCURSAL PROVIDENCIA','SANTIAGO CENTRO','SUC AGUSTINAS') THEN 'CASA MATRIZ' ELSE RTRIM(NOMSUCU) END ,a.contratante,NANFAVEH,RTRIM(CDESCRIP)



/****** Checkpoint 1 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 1', SYSDATETIME())
/****************************************************************************/
---- proceso auxiliar para generar la marca nueva_renov2 que consiste considerar nuevo a lo que se encuentra dentro de los primeros 12 meses de devengamiento, independiente de la vigencia de la poliza
select linea_negocio,rtrim(CCOMAVEH) AS MARCA,rtrim(CDESCORT) AS MODELO,nanfaveh,nnurupro,contratante,nnumrut,min(FECINVIG) min_per,min(FECINVIG)+365 max_per
into #min_per
from Reportes.dbo.MI_PRIMA_EMITIDA_ACCESS
group by rtrim(CCOMAVEH),rtrim(CDESCORT),nanfaveh,nnurupro,contratante,nnumrut,linea_negocio

alter table #Tablero_Motor
add IND_1ERA—O INTEGER

UPDATE #Tablero_Motor
SET IND_1ERA—O=1

UPDATE #Tablero_Motor
SET IND_1ERA—O=0
from #Tablero_Motor a
left join #min_per b
on a.linea_negocio=b.linea_negocio and a.MARCA=b.MARCA and a.MODELO=b.MODELO and a.nanfaveh=b.nanfaveh and a.nnurupro=b.nnurupro and a.contratante=b.contratante and a.nnumrut=b.nnumrut
where year(per)*100+month(per)<=year(max_per)*100+month(max_per)

alter table #Tablero_Motor
add MES_INI INTEGER

UPDATE #Tablero_Motor
SET MES_INI=YEAR(MIN_PER)*100+MONTH(MIN_PER)
from #Tablero_Motor a
left join #min_per b
on a.linea_negocio=b.linea_negocio and a.MARCA=b.MARCA and a.MODELO=b.MODELO and a.nanfaveh=b.nanfaveh and a.nnurupro=b.nnurupro and a.contratante=b.contratante and a.nnumrut=b.nnumrut

alter table #Tablero_Motor
add NUEVA_RENOV2 VARCHAR(10) NULL

UPDATE #Tablero_Motor
SET NUEVA_RENOV2=CASE WHEN IND_1ERA—O=0 THEN 'NUEVA' ELSE 'RENOVACION' END
from #Tablero_Motor



/****** Checkpoint 2 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 2', SYSDATETIME())
/****************************************************************************/
----- crea campo para productos nuevos/especificos 
UPDATE #Tablero_Motor
SET PRODUCTOS_NUEVOS=B.[PRODUCTO] 
FROM #Tablero_Motor A
LEFT JOIN sgf1034.GestionPortafolio.dbo.Agrupamiento_Planes2 B
ON A.NPLANTEC=B.NPLANTEC
WHERE B.[PRODUCTO] IS NOT NULL

---- crea campo para perfil socio economico
alter table #Tablero_Motor
add CALIDAD_CLIENTE VARCHAR(50) NULL

UPDATE #Tablero_Motor
SET CALIDAD_CLIENTE=B.[CALIDAD] + ' - ' + b.siniestralidad
FROM #Tablero_Motor A
LEFT JOIN sgf1034.GestionPortafolio.dbo.RUTS_SEGMENTACION B
ON A.NNURUPRO=B.RUT
WHERE B.[RUT] IS NOT NULL

UPDATE #Tablero_Motor
SET channel='DIRECTO'
FROM #Tablero_Motor
where RTRIM(grupo_CHANNEL)='DIRECTO'

UPDATE #Tablero_Motor
SET Flota='AWTO',GRUPO_FLOTA='AWTO'
FROM #Tablero_Motor
where nnumdocu in (5129738,5483060,5852361,6181750,6529057,5130407,5483333,5852408,6181972,6529217)

UPDATE #Tablero_Motor
SET PRODUCTOS_NUEVOS = CASE 
	WHEN PLAN_TECNICO2 LIKE 'SEGURO MOTO%' THEN 'MOTO'
	WHEN PLAN_TECNICO2 LIKE '%CICLO%' THEN 'MICROMOVILIDAD'
END
WHERE PLAN_TECNICO2 LIKE 'SEGURO MOTO%' OR PLAN_TECNICO2 LIKE '%CICLO%'

UPDATE #Tablero_Motor
SET flota = 'SEGURO X KM',grupo_flota='SEGURO X KM'
from #Tablero_Motor
WHERE NPLANTEC IN (5709,5710,
5711,5712,5951,5952,5953,5954,5955,5956,5957,5958,5959,5960,5961,5962,
5963,5964,5965,5966,5967,5968,5969,5970,5971,5972,5973,5974,5975,5976,5977,5978,5979,5980,5981,5982,5983,5984,5985,5986,6002,6145,6146,6147,
6148,6149,6150,6151,6152,6153,6154,6155,6156,6465,6479,6480,6481,6677,6678,6679,6680,6681,6682,6957,6958,6959,6960,6991,6992,6993,6994,7009,
7010,7011,7012,7013,7014,7015,7016,7017,7018,7019,7020,7080,7081,7082,7083,7294,7295,7296,7297,7349,7350,7351,7352,7353,7354,7355,7356,7357,
7358,7359,7360,7361,7362,7363,7364,7365,7366,7367,7368,7369,7370,7371,7372,7373,7374,7375,7376,7377,7378,7379,7380,7381,7382,7383,7384,7385,
7486,7487,7488,7489,7502,7503,7504,7505,7506,7507,7508,7509,7518,7519,7520,7521,7522,7523,7524,7525,7526,7527,7528,7529,7598,7599,7600,7601)

UPDATE #Tablero_Motor
SET TIPO_VEH='CAMION'
from #Tablero_Motor
WHERE TIPO_VEH LIKE 'CLAS%'

alter table #Tablero_Motor
add INTERMEDIARIO NVARCHAR(255)

alter table #Tablero_Motor
add EJECUTIVO NVARCHAR(255)

alter table #Tablero_Motor
add RUT_EJECUTIVO INTEGER



/****** Checkpoint 3 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 3', SYSDATETIME())
/****************************************************************************/
---- corrije variable canal con tabla que se genera en en query aparte 'Poliza Canal'
UPDATE #Tablero_Motor
SET 
GRUPO_CHANNEL = CASE 
	WHEN RTRIM(BU2)='CANAL ASESOR' THEN 'CANAL ASESOR' 
	WHEN RTRIM(BU2)='CORPORATIVO' THEN 'LBR' 
	WHEN RTRIM(BU2)='DIRECTO' THEN 'DIRECTO'
	WHEN RTRIM(BU2)='MASIVOS' THEN 'AFFINITY' 
	WHEN RTRIM(BU2)='TRADICIONAL' THEN 'E&P' 
	WHEN GRUPO_CHANNEL IS NULL THEN 'UNDEFINED'
	ELSE GRUPO_CHANNEL 
END,
CHANNEL = CASE WHEN B.CANAL IS NOT NULL THEN RTRIM(B.CANAL) ELSE RTRIM(CHANNEL) END,
RUT_EJECUTIVO = B.RUT_EJECUTIVO,
INTERMEDIARIO = RTRIM(B.INTERMEDIARIO),
EJECUTIVO = RTRIM(B.EJECUTIVO)
FROM #Tablero_Motor A
LEFT JOIN sgf1034.GestionPortafolio.dbo.Poliza_Canal_BU B
ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM
where b.nnumdocu is not null

---- segmenta canal directo en web y tmk
UPDATE #Tablero_Motor
SET CHANNEL = CASE WHEN RUT_EJECUTIVO=13098157 THEN 'DIRECTO WEB' ELSE 'DIRECTO TMK' END
WHERE GRUPO_CHANNEL='DIRECTO'

--- corrige nombre de algunos canales
UPDATE #Tablero_Motor
SET channel='SANTANDER'
FROM #Tablero_Motor
where channel LIKE 'SANTAN%'

UPDATE #Tablero_Motor
SET channel='COMPARA'
FROM #Tablero_Motor
where channel LIKE 'COMPAR%'

UPDATE #Tablero_Motor
SET 
	CHANNEL='CENCOSUD',
	GRUPO_CHANNEL='AFFINITY'
FROM #Tablero_Motor
where RTRIM(CHANNEL) LIKE 'PARI%'

UPDATE #Tablero_Motor
SET 
	CHANNEL='AUTOMOVIL CLUB',
	GRUPO_CHANNEL='AFFINITY'
FROM #Tablero_Motor
WHERE nnumrut=76449877

---- marca salfa
update #Tablero_Motor
set flota='SALFA',GRUPO_FLOTA='SALFA'
FROM #Tablero_Motor A
WHERE nnumdocu in (6907171,6907172,6907175,6907176,6909916,6909917,6909919,6924529,6924531,6924532,												
6924533,6926092,6926093,6960766,6964302,7039522,6894162,6894172,6894180,6894188,6894196,6894201,6907176,6924529,6924531,6924532,6924533,6926093,6964302)												

---- pone en cero la exposici—n de las polizas de rc en exceso para no duplicar, es decir contar solo exposici—n una vez por la capa de rc primaria
UPDATE #Tablero_Motor 
SET EXPOS=0
where PLAN_TECNICO2 like '%EXCES%'



/****** Checkpoint 4 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 4', SYSDATETIME())
/****************************************************************************/

UPDATE #Tablero_Motor
SET 
	PRRIESGO_EMI = PRDP_EMI+PRPT_EMI+PRRC_EMI+PRROBO_EMI,
	PRRIESGO_DEV = PRDP_DEV+PRPT_DEV+PRRC_DEV+PRROBO_DEV,
	FRECTOT_DEV  = FRECDP_DEV+FRECPT_DEV+FRECRC_DEV+FRECROBO_DEV,
	ULT_TOTAL	 = ULT_DP+ULT_PT+ULT_RC+ULT_ROBO,
	CANT_ULT_TOTAL = CANT_ULT_DP+CANT_ULT_PT+CANT_ULT_RC+CANT_ULT_ROBO
FROM #Tablero_Motor A

--ALTER TABLE sgf1034.gestionPortafolio.dbo.Homologacion_regiones
--ALTER COLUMN [REGION_REAL] varchar(100) 
--COLLATE SQL_Latin1_General_CP1_CI_AS NULL

alter table #Tablero_Motor
ADD REGION_REAL VARCHAR(255)

UPDATE #Tablero_Motor
SET REGION_REAL= REGION

UPDATE #Tablero_Motor
SET REGION_REAL = RTRIM(C.REGION_BASE)
FROM #Tablero_Motor A
left join transaccional.dbo.Base_resumen_clientes b
on a.NNURUPRO=b.nnuruase
LEFT JOIN sgf1034.gestionPortafolio.dbo.Homologacion_regiones c
on rtrim(c.REGION_REAL)=rtrim(b.region)
where b.region is not null 

---- corrije cobertura de algunos planes tecnicos mal clasificados
UPDATE #Tablero_Motor
SET TIPPLAN = 'PT + RC'
FROM #Tablero_Motor
where RTRIM(PLAN_TECNICO2) IN ('PERDIDA TOTAL + RC ABCDIN','RIPLEY PERDIDA TOTAL + RESPONSABILIDAD CIVIL ASISTENCIA LEGAL')

UPDATE #Tablero_Motor
SET TIPPLAN='FULL'
where LINEA_NEGOCIO like 'PER%'AND RTRIM(PLAN_TECNICO2) IS NULL



/****** Checkpoint 4 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 5', SYSDATETIME())
/****************************************************************************/
----- marca modelos agravados y bloqueados por robo 
update #Tablero_Motor
set GAMA_VEH = 'AGRAVADOS'
FROM #Tablero_Motor
WHERE RTRIM(MARCA_MODELO) IN (
	'Chevrolet - SAIL','Chevrolet - SPARK GT','Chevrolet - PRISMA','Dodge - JOURNEY','FORD - EXPLORER','FORD - RANGER','FORD - FOCUS','HYUNDAI - ACCENT'
	,'HYUNDAI - TUCSON','HYUNDAI - H-1','KIA MOTORS - MORNING','KIA MOTORS - SPORTAGE','KIA MOTORS - CERATO','KIA MOTORS - RIO 4','KIA MOTORS - RIO','KIA MOTORS - SOLUTO',
	'MAZDA - 3.','MAZDA - 3 SPORT.','PEUGEOT - 2008','TOYOTA - YARIS','VOLVO - V40','HONDA - PILOT') OR 
(
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%FRONT%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%GRAND CHE%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '&FRONTI%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like 'ToYOTA - HI-L%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%F-15%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%ACCEN%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%L-20%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%PORTER%' AND RTRIM(MARCA)='HYUNDAI' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%ECOSP%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%3008%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%EXPED%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like 'MG - 3.' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%X-TR%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%QASH%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%NP300%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%NAVAR%%' AND RTRIM(MARCA)='NISSAN' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%PATHFI%'
)


update #Tablero_Motor
set GAMA_VEH='BLOQUEADOS'
FROM #Tablero_Motor
WHERE (
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%FRONT%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%GRAND CHE%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '&FRONTI%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like 'ToYOTA - HI-L%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%F-15%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%ACCEN%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%L-20%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%PORTER%' AND RTRIM(MARCA)='HYUNDAI' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%ECOSP%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like'%3008%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%EXPED%' OR 
	RTRIM(MARCA)+' - '+rtrim(MODELO) like 'MG - 3.' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%X-TR%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%QASH%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%NP300%' OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%NAVAR%%' AND RTRIM(MARCA)='NISSAN'OR
	RTRIM(MARCA)+' - '+rtrim(MODELO) like '%PATHFI%')
and region_REAL in (
	'METROPOLITANA DE SANTIAGO','DE TARAPACA','DE ANTOFAGASTA','DE COQUIMBO',
	'DE ARICA Y PARINACOTA','DE VALPARAISO','DE ATACAMA','DEL LIBERTADOR B. OHIGGINS') 
AND NANFAVEH>=2017

select nnumdocu, nnumitem, min(SISUF) SISUF
INTO #SISGEN
from [SGF1025].Reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR
GROUP BY nnumdocu,nnumitem

alter table #Tablero_Motor
ADD SISTOT_0_36 VARCHAR(255)

UPDATE #Tablero_Motor
SET SISUF = B.SISUF
FROM #Tablero_Motor A
LEFT JOIN #SISGEN B ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM
where b.nnumdocu IS NOT NULL

UPDATE #Tablero_Motor
SET GRUPO_FLOTA = 'SCANIA', FLOTA = 'SCANIA'
FROM #Tablero_Motor A
WHERE contratante=76574810 and corredor like 'Arth%'

----- se genera segmentacion de la cartera de motor c por tama—o de flota y segmentos
alter table #Tablero_Motor
add INCLUSI”N NVARCHAR(255)

DROP TABLE if exists #TAMA—O
drop table if exists #TAMA—O2

select CONTRATANTE,YEAR(FECTEVIG)*100+MONTH(FECTEVIG) MES, COUNT(*) CANTIDAD
INTO #TAMA—O
from Reportes.dbo.MI_PRIMA_EMITIDA_ACCESS 
where linea_negocio like 'COM%'
group by CONTRATANTE,YEAR(FECTEVIG)*100+MONTH(FECTEVIG)

select nnumdocu,nnumitem,min(ccodramo) CODRAMO,min(nnumrut) nnumrut,min(A.contratante) contratante,min(cantidad) CANTIDAD,MIN(CCODRAMO) CCODRAMO,
MIN(CASE WHEN C.CANTIDAD=1 THEN 'A.1_1' WHEN C.CANTIDAD=2 THEN 'B.2_2' WHEN C.CANTIDAD=3 THEN 'C.3_3' WHEN C.CANTIDAD=4 THEN 'D.4_4' WHEN C.CANTIDAD=5 THEN 'E.5_5' WHEN C.CANTIDAD<=10 THEN 'F.6_10' 
WHEN C.CANTIDAD<=20 THEN 'G.11_20' WHEN C.CANTIDAD<=50 THEN 'H.21_50' WHEN C.CANTIDAD<=100 THEN 'I.51_100' WHEN C.CANTIDAD<=300 THEN 'J.101_300' WHEN C.CANTIDAD<=1000 THEN 'K.301_1000'
WHEN C.CANTIDAD<=2000 THEN 'L.1001_2000' WHEN C.CANTIDAD<=3000 THEN 'M.2001_3000' WHEN C.CANTIDAD>3000 THEN 'N.>3000' ELSE NULL END) TAMA—O
INTO #TAMA—O2
FROM Reportes.dbo.MI_PRIMA_EMITIDA_ACCESS a
left join #TAMA—O C on  A.CONTRATANTE=C.CONTRATANTE AND YEAR(FECTEVIG)*100+MONTH(FECTEVIG)=C.MES
where linea_negocio like 'COM%'
group by nnumdocu,nnumitem

UPDATE #Tablero_Motor
SET 
	CODRAMO = B.CODRAMO,
	TAMA—O = B.TAMA—O,
	INCLUSI”N = CASE 
		WHEN GRUPO_FLOTA IN ('INVERSIONES INVERGAS','TSTGO','SALFA','SCANIA') THEN 'EXCLUIDO' 
		ELSE 'INCLUIDO' 
	END
FROM #Tablero_Motor A
LEFT JOIN #TAMA—O2 B ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM 
WHERE B.NNUMDOCU IS NOT NULL

UPDATE #Tablero_Motor
SET TAMA—O='A.1_1'
WHERE GRUPO_CHANNEL='AFFINITY' AND LINEA_NEGOCIO='COMMERCIAL' --AND TAMA—O='NO APLICA'



/****** Checkpoint 4 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 6', SYSDATETIME())
/****************************************************************************/

alter table #Tablero_Motor
add PRIMA_TEC_DEV NUMERIC(38,6)

alter table #Tablero_Motor
add PRIMA_TEC_EMI NUMERIC(38,6)

UPDATE #Tablero_Motor
SET 
	PRRIESGO_DEV = PRRIESGO_DEV/(1.05),
	PRRIESGO_EMI = PRRIESGO_EMI/(1.05)
FROM #Tablero_Motor
WHERE LINEA_NEGOCIO LIKE 'PER%'

-- Ejecutar lo siguiente tal como esta
----- genera primas tecnicas devengadas y emitidas. Para correr esta parte debe estar actualizada primero la base de aptp
UPDATE #Tablero_Motor
SET 
	PRIMA_TEC_DEV = A.PRIMA_DEV*B.prima_tec/B.prima_dev,
	PRIMA_TEC_EMI = A.PRIMA_EMI*B.prima_tec_EMI/B.prima
FROM #Tablero_Motor A
LEFT JOIN sgf1034.gestionPortafolio.dbo.BASE_APTP B ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM
WHERE A.LINEA_NEGOCIO LIKE 'PER%' AND B.prima_dev > 0

---- correccion tipo de vehiculo
SELECT NNUMDOCU, NNUMITEM, MAX(TIPO_VEHICULO) TIPO2
INTO #TIPOS
FROM Reportes.[dbo].[SURA_MOVILIDAD_TRANSACCIONAL]
GROUP BY NNUMDOCU,NNUMITEM

select a.nnumdocu, a.nnumitem, MAX(CASE 
	WHEN CDESCRIP LIKE '%CICL%' OR TIPO2 LIKE 'BICI%' THEN 'BICILETA/SCOOTER' 
	WHEN RTRIM(TIPO) IN ('AUTO','DEPORTIVO','STATION WAGON','') OR RTRIM(TIPO2) IN ('AUTOMOVIL','DEPORTIVO','STATION WAGON','SUV','') OR rtrim(A.cdescort) LIKE 'RENEGAD%' OR RTRIM(TIPO_VEH_RVM) IN ('AUTOMOVIL') THEN 'AUTOMOVIL' 
	WHEN RTRIM(TIPO) IN ('MICRO','MINIBUS','BUS') OR RTRIM(TIPO2) IN ('MICRO','MINIBUS','BUS','MINI-BUS') OR RTRIM(TIPO_VEH_RVM) IN ('MICRO','MINIBUS','BUS','MINI-BUS') THEN 'BUS'
	WHEN RTRIM(TIPO) IN ('CLASE I','CLASE II','SEMIREMOLQUE','MAQUINARIA','CAMION') OR RTRIM(TIPO2) IN ('CLASE I','CLASE II','SEMIREMOLQUE','MAQUINARIA','CAMION','TRACTO CAMION') OR RTRIM(TIPO_VEH_RVM) IN ('CLASE I','CLASE II','SEMIREMOLQUE','MAQUINARIA','CAMION','TRACTO CAMION','TRACTOCAMION') OR rtrim(A.cCOMAVEH)='SCANIA' OR TIPO_VEH_RVM IN ('CAMION') THEN 'CAMION'
	WHEN RTRIM(TIPO) IN ('CAMIONETA','FURGON','JEEP','TODO TERRENO','VAN') OR RTRIM(TIPO2) IN ('CAMIONETA','FURGON','JEEP','TODO TERRENO','VAN','VEHICULO DE EMERGENCIA') OR TIPO_VEH_RVM IN ('CAMIONETA','FURGON','JEEP','STATION WAGON') THEN 'CAMIONETA' 
	WHEN RTRIM(TIPO) IN ('MOTO') OR RTRIM(TIPO2) IN ('MOTO','MOTO, MOTONETA') OR RTRIM(TIPO_VEH_RVM) IN ('MOTO','MOTO, MOTONETA') OR rtrim(A.cCOMAVEH) IN ('YAMAHA') THEN 'MOTO' 
	WHEN RTRIM(TIPO) IN ('REMOLQUE','ACOPLADO, TRAILER','RAMPLA') OR RTRIM(TIPO2) IN ('REMOLQUE','ACOPLADO, TRAILER','RAMPLA','CARROS DE ARRASTRE') OR RTRIM(TIPO_VEH_RVM) IN ('REMOLQUE','ACOPLADO, TRAILER','RAMPLA') THEN 'REMOLQUE/ACOPLADO'
	ELSE A.TIPO 
END) TIPO
into #tipo2
From Reportes.dbo.MI_PRIMA_EMITIDA_ACCESS a
LEFT JOIN #TIPOS B ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM
GROUP BY a.nnumdocu,a.nnumitem

UPDATE #Tablero_Motor
SET tipo_veh=b.tipo
from #Tablero_Motor a
LEFT JOIN #tipo2 B ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM
WHERE a.nnumdocu is not null

--marca autos electricos
UPDATE  #Tablero_Motor
SET TIPO_VEH='AUTO ELECTRICO'
from #Tablero_Motor a
where 
	(RTRIM(MARCA) like 'BMW%' AND RTRIM(MODELO) like '%I8%') OR
	(RTRIM(MARCA) like 'CIT%' AND RTRIM(MODELO) like '%BELINGO C E%') OR
	(RTRIM(MARCA) like 'HON%' AND RTRIM(MODELO) like '%ACCORD 4%') OR
	(RTRIM(MARCA) like 'HON%' AND RTRIM(MODELO) like '%CIVIC H%') OR
	(RTRIM(MARCA) like 'HON%' AND RTRIM(MODELO) like '%CR Z%') OR
	(RTRIM(MARCA) like 'HON%' AND RTRIM(MODELO) like '%INSIGHT H%') OR
	(RTRIM(MARCA) like 'HYU%' AND RTRIM(MODELO) like '%IONIQ%') OR
	(RTRIM(MARCA) like 'HYU%' AND RTRIM(MODELO) like '%SONATA L%') OR
	(RTRIM(MARCA) like 'INF%' AND RTRIM(MODELO) like '%Q 50 H%') OR
	(RTRIM(MARCA) like 'INF%' AND RTRIM(MODELO) like '%Q50 H%') OR
	(RTRIM(MARCA) like 'KIA%' AND RTRIM(MODELO) like '%OPTIMA J%') OR
	(RTRIM(MARCA) like 'KIA%' AND RTRIM(MODELO) like '%CERATO H%') OR
	(RTRIM(MARCA) like 'KIA%' AND RTRIM(MODELO) like '%NIRO%') OR
	(RTRIM(MARCA) like 'KIA%' AND RTRIM(MODELO) like '%OPTIMA H%') OR
	(RTRIM(MARCA) like 'LEX%' AND RTRIM(MODELO) like '%CT200H E%') OR
	(RTRIM(MARCA) like 'LEX%' AND RTRIM(MODELO) like '%RX 450 H%') OR
	(RTRIM(MARCA) like 'MAX%' AND RTRIM(MODELO) like '%EV 80%') OR
	(RTRIM(MARCA) like 'MER%' AND RTRIM(MODELO) like '%S400 H%') OR
	(RTRIM(MARCA) like 'MIT%' AND RTRIM(MODELO) like '%I MIEV%') OR
	(RTRIM(MARCA) like 'MIT%' AND RTRIM(MODELO) like '%OUTLANDER PH%') OR
	(RTRIM(MARCA) like 'NIS%' AND RTRIM(MODELO) like '%LEAF%') OR
	(RTRIM(MARCA) like 'POR%' AND RTRIM(MODELO) like '%CAYENNE E H%') OR
	(RTRIM(MARCA) like 'POR%' AND RTRIM(MODELO) like '%CAYENNE H%') OR
	(RTRIM(MARCA) like 'POR%' AND RTRIM(MODELO) like '%CAYENNE S H%') OR
	(RTRIM(MARCA) like 'POR%' AND RTRIM(MODELO) like '%PANAMERA 4 E H%') OR
	(RTRIM(MARCA) like 'REN%' AND RTRIM(MODELO) like '%FLUENCE ZE%') OR
	(RTRIM(MARCA) like 'REN%' AND RTRIM(MODELO) like '%KANGOO ZE%') OR
	(RTRIM(MARCA) like 'REN%' AND RTRIM(MODELO) like '%ZOE H%') OR
	(RTRIM(MARCA) like 'REN%' AND RTRIM(MODELO) like '%ZOE T%') OR
	(RTRIM(MARCA) like 'TOY%' AND RTRIM(MODELO) like '%CAMRY H%') OR
	(RTRIM(MARCA) like 'TOY%' AND RTRIM(MODELO) like '%CAMRY ZE%') OR
	(RTRIM(MARCA) like 'TOY%' AND RTRIM(MODELO) like '%PRIUS C H%') OR
	(RTRIM(MARCA) like 'TOY%' AND RTRIM(MODELO) like '%PRIUS H%')

drop table if exists #nuevas

select nnumdocu,nnumitem,MIN(IND_RENOVACION) IND_RENOVACION
INTO #nuevas
from [SGF1025].Reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR a
GROUP BY nnumdocu,nnumitem

UPDATE #Tablero_Motor
set NUEVA_RENOV = case when ind_renovacion=0 then 'NUEVA' ELSE 'RENOVACION' END
from #Tablero_Motor A
LEFT JOIN #NUEVAS B ON A.NNUMDOCU=B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM



/****** Checkpoint 4 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 7', SYSDATETIME())
/****************************************************************************/

--Agregado: 09-01-2024
-----------------------------------------------------------------------------------------------------------------------------------------
															--NUEVAS CORRECCIONES:
-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION DE BU Y CHANNEL
update #Tablero_Motor
set
	GRUPO_CHANNEL = CASE WHEN B.CANAL_ACTUAL IS NULL OR B.CANAL_ACTUAL = '' THEN A.GRUPO_CHANNEL ELSE B.CANAL_ACTUAL END,
	CHANNEL = CASE WHEN B.[PARTNER] IS NULL OR B.[PARTNER] = '' THEN A.CHANNEL ELSE B.[PARTNER] END
from #Tablero_Motor A
left join reportes.dbo.POLIZAS_MOVILIDAD_NUEVO B ON
A.NNUMDOCU = B.NNUMDOCU

--CORRECCION DE NOMBRES A BU Y CHANNEL
update #Tablero_Motor
set
	GRUPO_CHANNEL = CASE 
		WHEN GRUPO_CHANNEL LIKE '%Affinity%' OR GRUPO_CHANNEL = 'NEGOCIOS MASIVOS Y CLIENTES' THEN 'AFFINITY'
		WHEN GRUPO_CHANNEL IN ('CNC', 'NEGOCIOS COMERCIALES', 'NEGOCIOS EMPRESAS Y PERSONAS', 'E&P') THEN 'PYME'
		WHEN GRUPO_CHANNEL IN ('LBR', 'NEGOCIOS CORPORATIVOS') THEN 'CORPORATIVO'
		WHEN GRUPO_CHANNEL IN ('DIRECTO', 'NEGOCIOS DIRECTOS') THEN 'CANAL DIRECTO'
		WHEN GRUPO_CHANNEL = 'SUCURSALES' THEN 'CANAL ASESOR'
		WHEN GRUPO_CHANNEL = '' THEN NULL
		ELSE GRUPO_CHANNEL
	END,
	CHANNEL = CASE
		WHEN CHANNEL = 'DIRECTO' THEN 'CANAL DIRECTO'
		WHEN CHANNEL IN ('DEALER DIRECTO','DEALERS DIRECTOS') THEN 'DEALERS DIRECTO'
		WHEN CHANNEL = '' THEN NULL
		ELSE CHANNEL
	END

-----------------------------------------------------------------------------------------------------------------------------------------
--AGREGAR FLOTAS
--TSTGO
UPDATE #Tablero_Motor
SET
FLOTA = CASE 
	WHEN CONTRATANTE=77532011 THEN 'TSTGO - STU' 
	WHEN CONTRATANTE=77532114 THEN 'TSTGO - BUSES ALFA' 
	WHEN CONTRATANTE=77532117 THEN 'TSTGO - BUSES OMEGA' 
	WHEN CONTRATANTE=77532096 THEN 'TSTGO - RBU SANTIAGO'
	WHEN CONTRATANTE=99557440 THEN 'TSTGO - METBUS'
	WHEN CONTRATANTE=76071048 THEN 'TSTGO - BUSES VULE'
	WHEN CONTRATANTE=99577050 THEN 'TSTGO - RED BUS'
	ELSE FLOTA
END,
GRUPO_FLOTA = 'TSTGO'
WHERE CONTRATANTE IN (77532011, 77532114, 77532117, 77532096, 99557440, 76071048, 99577050)


UPDATE #Tablero_Motor
SET
GRUPO_FLOTA = 'TSTGO'
WHERE FLOTA LIKE 'TSTGO%'


--OTROS
UPDATE #Tablero_Motor
SET
FLOTA		= 'TRANSVIP',
GRUPO_FLOTA = 'TRANSVIP'
WHERE CONTRATANTE IN (76102176)

UPDATE #Tablero_Motor
SET
FLOTA		= 'Transportes MKN Spa',
GRUPO_FLOTA = 'Transportes MKN Spa'
WHERE CONTRATANTE IN (77171831)





-----------------------------------------------------------------------------------------------------------------------------------------
--ACTUALIZACION DE TIPPLAN PARA RCM Y RCA a RCI

--RCI
UPDATE #Tablero_Motor
SET
TIPPLAN = 'RCI'
where 
	(
	PLAN_TECNICO2 LIKE 'RCA%' OR 
	PLAN_TECNICO2 LIKE 'RCM%' or 
	PLAN_TECNICO2 LIKE 'RESP%MER%'
	OR PLAN_TECNICO2 LIKE 'RC%ARG%'
	OR PLAN_TECNICO2 LIKE 'RC%MER%'
	)
	AND PLAN_TECNICO2 NOT LIKE '%ROBO%'

--RCI+ROBO
UPDATE #Tablero_Motor
SET
TIPPLAN = 'RCI+ROBO'
where 
	PLAN_TECNICO2 LIKE 'RCA%ROBO%' OR 
	PLAN_TECNICO2 LIKE 'RCM%ROBO%' OR 
	PLAN_TECNICO2 LIKE 'RESP%ROBO%MER%' OR
	PLAN_TECNICO2 LIKE 'RC%ARG%ROBO%' OR
	PLAN_TECNICO2 LIKE 'RC%MER%ROBO%'

-----------------------------------------------------------------------------------------------------------------------------------------
--ACTUALIZACION DE TIPPLAN CRUZANDO CON LA TABLA DE CARLOS VICENCIO
update #Tablero_Motor
set
	TIPPLAN = CASE WHEN B.TIPO_PLAN IS NULL OR B.TIPO_PLAN = '' THEN A.TIPPLAN ELSE B.TIPO_PLAN END
from #Tablero_Motor A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	A.tipplan <> b.tipo_plan
	and A.tipplan not in ('RCI', 'RCI+ROBO')
	and B.TIPO_PLAN <> 'NO INDENT'
	and B.PLAN_TECNICO like '%MARCA%'
	and B.TIPO_PLAN <> 'RCA'

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion para Planes tecnicos con palabra 'Marca' y TIPPLAN 'RCA'
update #Tablero_Motor
set
	TIPPLAN = 'FULL'
from #Tablero_Motor A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	b.PLAN_TECNICO like '%MARCA%'
	and tipplan = 'RCA'

-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION CASOS ESPECIFICOS
update #Tablero_Motor
set
	TIPPLAN = replace(B.TIPO_PLAN,' ','')
from #Tablero_Motor A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	a.tipplan <> b.tipo_plan
	and a.tipplan not in ('RCI', 'RCI+ROBO')
	and b.TIPO_PLAN <> 'NO INDENT'
	and not (b.PLAN_TECNICO like '%MARCA%' and b.TIPO_PLAN = 'RCA')
	and replace(replace(B.PLAN_TECNICO, 'PT RC', 'PT+RC'),'PT + RC','PT+RC') not like '%' + replace(A.TIPPLAN,' ','') + '%'
	and B.PLAN_TECNICO NOT LIKE '%FORCENTER%'
	and NPLANTEC not in (6839,6803)

update #Tablero_Motor
set 
	TIPPLAN = 'RCI'
where 
	TIPPLAN = 'RCA'

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion RCA NORCAVAL
update #Tablero_Motor
set
	TIPPLAN = 'FULL'
from #Tablero_Motor A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	A.tipplan in ('RCA','RCI')
	and B.PLAN_TECNICO like '%NORCAVAL%'
	and NPLANTEC = 8331

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion PT + RC
update #Tablero_Motor
set
	TIPPLAN = 'PT + RC'
where 
	TIPPLAN = 'PT+RC'

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion vacios
update #Tablero_Motor
set
	TIPPLAN = NULL
where 
	TIPPLAN = ''

update #Tablero_Motor
set 
	MARCA = NULL
where 
	MARCA = ''

-----------------------------------------------------------------------------------------------------------------------------------------
--FIN NUEVAS CORRECCIONES


--MAS ROBADOS
alter table #Tablero_Motor
add MAS_ROBADOS NVARCHAR(20) NULL

/*UPDATE #Tablero_Motor
SET
MAS_ROBADOS = 
CASE WHEN
	   (rtrim(MARCA) = 'CHERY'		 and  rtrim(MODELO) IN ('GRAND TIGGO','NEW TIGGO','TIGGO','TIGGO 2','TIGGO 3','TIGGO 4','TIGGO 7','TIGGO 8','TIGGO 2 PRO','TIGGO 3 PRO','TIGGO 7 PRO','TIGGO 8 PRO'))
	or (rtrim(MARCA) = 'CHEVROLET'	 and  rtrim(MODELO) IN ('SAIL','SILVERADO','SILVERADO CK 3500'))
	or (rtrim(MARCA) = 'FORD'		 and  rtrim(MODELO) IN ('F - 150','F-150 LARIAT','F-150 PLATINUM','F-150 RAPTOR','F-150 XLT'))
	or (rtrim(MARCA) = 'HYUNDAI'	 and  rtrim(MODELO) IN ('ACCENT','ACCENT HATCHBACK','ACCENT PRIME','ACCENT RB','ACCENT SEDAN','ALL NEW TUCSON','GRAND SANTA FE','NEW SANTA FE','NEW TUCSON','SANTA FE','TUCSON'))
	or (rtrim(MARCA) = 'JEEP'		 and  rtrim(MODELO) IN ('GRAND CHEROKEE.','GRAND CHEROKEE LAREDO','GRAND CHEROKEE LIMITED','NEW GRAND CHEROKEE','NEW GRAND CHEROKEE LAREDO','NEW GRAND CHEROKEE LIMITED'))
	or (rtrim(MARCA) = 'KIA MOTORS'  and  rtrim(MODELO) IN ('FRONTIER','FRONTIER D/C','FRONTIER SUPER','RIO','RIO II','RIO JB','RIO 3','RIO 4','RIO 5','RIO 5 SPORT'))
	or (rtrim(MARCA) = 'MAZDA'		 and  rtrim(MODELO) IN ('ALL NEW 3','NEW 3 SPORT','NEW MAZDA 3 SKYACTIVE SPORT GT','NEW MAZDA 3 SKYACTIVE 1.6','NEW MAZDA 3 SKYACTIVE 2.0','3.','3 SPORT.','3 SPORT 1.6 AT'))
	or (rtrim(MARCA) = 'MITSUBISHI'  and  rtrim(MODELO) IN ('L-200','L-200 DAKAR','L-200 KATANA','L-200 WORK','MONTERO','NEW MONTERO','NEW MONTERO SPORT','MONTERO SPORT','MONTERO SPORT.','MONTERO SPORT G2'))
	or (rtrim(MARCA) = 'NISSAN'		 and  rtrim(MODELO) IN ('KICKS','VERSA'))
	or (rtrim(MARCA) = 'PEUGEOT'	 and  rtrim(MODELO) IN ('E-2008 (ELECTRICO)','PARTNER','PARTNER (ELECTRICO)','PARTNER FURGON 5P. T/A MOTOR ELECTRICO','PARTNER MAXI','PARTNER TEPEE','PARTNER TEPEE OUTDOOR'))
	or (rtrim(MARCA) = 'SAMSUNG'	 and  rtrim(MODELO) IN ('SM3'))
	or (rtrim(MARCA) = 'SUZUKI'		 and  rtrim(MODELO) IN ('BALENO'))
	or (rtrim(MARCA) = 'TOYOTA'		 and  rtrim(MODELO) IN ('ADVANTAGE RAV4','ALL NEW HILUX','HI-LUX 4X4','HI-LUX','HI-LUX 4X2','NEW HILUX','NEW RAV-4','NEW YARIS','NEW YARIS SPORT','RAV.','RAV-4','YARIS','YARIS SPORT'))
THEN 'MAS ROBADO' 
ELSE 'REGULAR'
END*/

--NUEVA MARCA MAS ROBADOS
UPDATE #Tablero_Motor
SET
MAS_ROBADOS = 
CASE WHEN
	--SIN SUSCRIPCION POR INDICES DE ROBO
		(rtrim(MARCA) = 'FORD'		 and  rtrim(MODELO) LIKE '%F%150%' OR rtrim(MODELO) LIKE '%TERRITORY%')
	or (rtrim(MARCA) = 'HYUNDAI'	 and  rtrim(MODELO) = 'H-1')
	or (rtrim(MARCA) = 'JEEP'		 and  rtrim(MODELO) LIKE '%GRAND CHEROKEE%')
	or (rtrim(MARCA) = 'KIA MOTORS'  and  rtrim(MODELO) LIKE '%FRONTIER%' OR rtrim(MODELO) LIKE '%SOUL%')
	or (rtrim(MARCA) = 'MITSUBISHI'  and  rtrim(MODELO) LIKE '%L-200%' OR rtrim(MODELO) LIKE '%MONTERO%')
	or (rtrim(MARCA) = 'TOYOTA'		 and  rtrim(MODELO) LIKE '%FORTUNER%' OR rtrim(MODELO) LIKE '%HI%LUX%' OR rtrim(MODELO) LIKE '%LAND CRUISER%')

	--SUSCRIPCION MONITOREADA
	or (rtrim(MARCA) = 'CHEVROLET'	 and  rtrim(MODELO) LIKE '%GROOVE%')
	or (rtrim(MARCA) = 'CITROEN'	 and  rtrim(MODELO) LIKE '%C%ELYS%')
	or (rtrim(MARCA) = 'FORD'		 and  rtrim(MODELO) LIKE '%EXPLORER%')
	or (rtrim(MARCA) = 'HYUNDAI'	 and  rtrim(MODELO) LIKE '%ACCENT%')
	or (rtrim(MARCA) = 'KIA MOTORS'  and  rtrim(MODELO) LIKE '%SOLUTO%')
	or (rtrim(MARCA) = 'MAHINDRA'	 and  rtrim(MODELO) LIKE '%XUV%500')
	or (rtrim(MARCA) = 'MAXUS'		 and  rtrim(MODELO) = 'T60')
	or (rtrim(MARCA) = 'MAZDA'		 and  ((rtrim(MODELO) LIKE '%3%' AND rtrim(MODELO) NOT LIKE '%[A-Z0-9-]3%' AND rtrim(MODELO) NOT LIKE '%.3%') OR rtrim(MODELO) LIKE '%CX%3'))
	or (rtrim(MARCA) = 'NISSAN'		 and  rtrim(MODELO) = 'VERSA')
	or (rtrim(MARCA) = 'PEUGEOT'	 and  rtrim(MODELO) LIKE '%301%' OR rtrim(MODELO) LIKE '%5008%')
	or (rtrim(MARCA) = 'VOLKSWAGEN'	 and  rtrim(MODELO) LIKE '%AMAROK%')
	THEN 'MAS ROBADO' 
	ELSE 'REGULAR'
END

--DEALERS BRUNO FRITSCH Y DIFOR
UPDATE #Tablero_Motor
SET
CHANNEL =
	CASE
		--WHEN nnumrut = 77350508 THEN 'DEALERS - DIFOR'
		WHEN nnumrut = 76620819 THEN 'DEALERS - BRUNO FRITSCH'
		WHEN nnumrut = 76133889 THEN 'DEALERS - TANNER'
		WHEN nnumrut = 76110334 THEN 'DEALERS - SERGIO ESCOBAR'
		WHEN nnumrut = 92909000 THEN 'DEALERS - CURIFOR'
		WHEN nnumrut = 76068841 THEN 'DEALERS - FORCENTER'
		WHEN nnumrut = 81198400 THEN 'DEALERS - INALCO'
		WHEN nnumrut = 76685737 THEN 'DEALERS - BLCARS'
		WHEN nnumrut = 77963303 THEN 'DEALERS - BIMOTORA / IBS'
		WHEN nnumrut = 77326117 THEN 'DEALERS - JESUS PONS'
		ELSE CHANNEL
	END
from #Tablero_Motor
where nnumrut in (76620819,76133889,76110334,92909000,76068841,81198400,76685737,77963303,77326117)


UPDATE #Tablero_Motor
SET
CHANNEL = 'DEALERS - DIFOR'
from #Tablero_Motor
where NPLANTEC in (4024,4025,4026,4027,4028,4029,5015,5016,5017,5018,5020,5022,5023,5024,5025,5673)

-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION A PRINCIPALES PARTNER_PYG
update #Tablero_Motor
set 
BU = 'AFFINITY',
CHANNEL = 
	CASE 
		WHEN nnumrut = 77191070 THEN 'BANCHILE'
		WHEN nnumrut = 77099010 THEN 'FALABELLA'
		WHEN nnumrut = 76215627 THEN 'MOK'
		WHEN nnumrut = 77472420 THEN 'RIPLEY'
		WHEN nnumrut = 96524260 THEN 'SANTANDER CORREDORA'
		ELSE CHANNEL
	END
WHERE 
	nnumrut IN (77191070,77099010,76215627,77472420,96524260)


-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION PARA AGREGAR "ACCESOS" A CANAL DIRECTO

update #Tablero_Motor
set 
CHANNEL = 'CANAL DIRECTO',
BU = 'CANAL DIRECTO'
WHERE  nnumrut = '99017000' AND SUCURSAL NOT IN ('CASA MATRIZ')




/*update #Tablero_Motor
set 
BU = 'AFFINITY',
CHANNEL = 
	CASE 
		WHEN NNURUPRO = 70016330 THEN 'LOS HEROES'
		ELSE CHANNEL
	END
WHERE 
	NNURUPRO IN (70016330)*/

-----------------------------------------------------------------------------------------------------------------------------------------
update #Tablero_Motor
set
tipo_veh = Case When 
	rtrim(MODELO) in ('RICH 6 EV', 'IONIQ','IONIQ ELECTRICO','KANGOO ZE','LEAF','FLUENCE ZE','IONIQ 5 (ELECTRICO)','NIRO', 'I3S 120AH', 'KONA', 'PRIUS', 'PRIUS C', 'M5 EV') 
	or rtrim(MODELO) like '%ELECTRIC%' 
	or rtrim(MODELO) like '%EL…CTR%' 
	or rtrim(MODELO) like '%ELETR%'
	or (rtrim(MARCA) IN ('BYD')  and  rtrim(MODELO) IN ('M3', 'T3', 'EV')) 
	or (rtrim(MARCA) IN ('FARIZON')  and  rtrim(MODELO) IN ('E200 3.5 T', 'E6')) 
	or (rtrim(MARCA) IN ('GEELY')  and  rtrim(MODELO) like '%EV%')
	or (rtrim(MARCA) IN ('MAPLE')  and  rtrim(MODELO) IN ('30 X', '60 S', '80 V')) 
	or (rtrim(MARCA) IN ('MG')  and  rtrim(MODELO) IN ('ZS EV', 'MARVEL R'))  
	then 'VEHICULO ELECTRICO' 
	when 
		rtrim(MODELO) like '%HIBR%'
		or rtrim(MODELO) like '%HEV' 
		or rtrim(MODELO) like '%HYBRID%' 
		OR rtrim(MODELO) like '%PHEV%' 
		or nnumdocu = 7870731 
	then 'VEHÕCULO HIBRIDO'
	WHEN 
		(NPLANTEC in (6482,6369,6837,6267,6816,7095,8470,8499,8681) 
		or nnumdocu in (7750297,7882583,7882585,7882586, 7294025,7745982,7806169,7870731, 7926736,7936057)
		or rtrim(MODELO) IN ('B12C01', 'K9KA', 'U10', 'XMQ', 'LCK', 'EBUS U12.-', 'ZK', 'LCK6900H', 'K9')) 
	THEN 'BUS ELECTRICO' 
	ELSE [TIPO_VEH] 
END

-----------------------------------------------------------------------------------------------------------------------------------------
update #Tablero_Motor
set DEDUCIBLE = NULL
where rtrim(ltrim(DEDUCIBLE)) = ''

-----------------------------------------------------------------------------------------------------------------------------------------


--CREAR TABLA TABLERO MOTOR
DROP TABLE IF EXISTS Transaccional.dbo.Tablero_Motor
SELECT * INTO Transaccional.dbo.Tablero_Motor FROM #Tablero_Motor
DROP TABLE #Tablero_Motor



/****** Checkpoint 4 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR - CHECKPOINT 8', SYSDATETIME())
/****************************************************************************/
--SE GENERA TABLERO MOTOR FINAL
--DROP TABLE Transaccional.dbo.Tablero_Motor_final
--
DROP TABLE IF EXISTS #Tablero_Motor_final

SELECT LINEA_NEGOCIO,CHANNEL,GRUPO_CHANNEL,BU,CORREDOR,NPLANTEC,TIPPLAN,PLAN_TECNICO,PLAN_TECNICO2,PRODUCTOS_NUEVOS,
--DEDUCIBLE,
CAST(IIF(DEDUCIBLE IN ('N/A', 'N/I'),'-1',DEDUCIBLE) AS float) AS DEDUCIBLE,
TIPO_VEH,GAMA_VEH,
MARCA,MODELO,MARCA_MODELO,TOP100,ZONA_SUCURSAL,SUCURSAL,REGION,REGION_URBE,PROVINCIA,nueva_renov NUEVA_RENOV,nueva_renov2,FLOTA,GRUPO_FLOTA,PERIODO,ANT_VEH,EDAD,EXTRANJERO,
PERFIL_UBER,VIGENCIA,A.CONTRATANTE,REGION_REAL,
CODRAMO,TAMA—O TAMA—O_FLOTA,(CASE WHEN GRUPO_FLOTA IN ('INVERSIONES INVERGAS','TSTGO','SALFA','SCANIA') THEN 'EXCLUIDO' ELSE 'INCLUIDO' END) INCLUSI”N,
sum(PRIMA_EMI) as PRIMA_EMI,sum(COMIS_EMI) as COMIS_EMI,sum(PRIMA_EMI_ENT) as PRIMA_EMI_ENT,
sum(case when prima_emi>0 then 1 else 0 end) as c_emisiones,sum(EXPOS) as EXPOS,sum(PRIMA_DEV) as PRIMA_DEV,
sum(COMIS_DEV) as COMIS_DEV,sum(Gtos_Adq) as Gtos_Adq,sum(PRDP_EMI) as PRDP_EMI,sum(PRPT_EMI) as PRPT_EMI,sum(PRRC_EMI) as PRRC_EMI,
sum(PRROBO_EMI) as PRROBO_EMI,sum(PRRIESGO_EMI) as PRRIESGO_EMI,sum(PRDP_DEV) as PRDP_DEV,sum(PRPT_DEV) as PRPT_DEV,sum(PRRC_DEV) as PRRC_DEV,
sum(PRROBO_DEV) as PRROBO_DEV,sum(PRRIESGO_DEV) as PRRIESGO_DEV,sum(FRECDP_DEV) as FRECDP_DEV,sum(FRECPT_DEV) as FRECPT_DEV,sum(FRECRC_DEV) as FRECRC_DEV,
sum(FRECROBO_DEV) as FRECROBO_DEV,sum(FRECTOT_DEV) as FRECTOT_DEV,sum(CANT_ULT_DP) as CANT_ULT_DP,sum(CANT_ULT_PT) as CANT_ULT_PT,sum(CANT_ULT_RC) as CANT_ULT_RC,
sum(CANT_ULT_ROBO) as CANT_ULT_ROBO,sum(CANT_ULT_ASIST) as CANT_ULT_ASIST,sum(CANT_ULT_TOTAL) as CANT_ULT_TOTAL,sum(ULT_DP) as ULT_DP,sum(ULT_PT) as ULT_PT,
sum(ULT_RC) as ULT_RC,sum(ULT_ROBO) as ULT_ROBO,sum(ULT_ASIST) as ULT_ASIST,sum(ULT_TOTAL) as ULT_TOTAL,sum(CANT_DP) as CANT_DP,sum(CANT_PT) as CANT_PT,sum(CANT_RC) as CANT_RC,
sum(CANT_ROBO) as CANT_ROBO,sum(CANT_ASIST) as CANT_ASIST,sum(CANT_ULT) as CANT_ULT,sum(PAGO_DP) as PAGO_DP,sum(PAGO_PT) as PAGO_PT,sum(PAGO_RC) as PAGO_RC,
sum(PAGO_ROBO) as PAGO_ROBO,sum(PAGO_ASIST) as PAGO_ASIST,sum(PAGO_TOTAL) as PAGO_TOTAL,sum(RESERVA_DP) as RESERVA_DP,sum(RESERVA_PT) as RESERVA_PT,sum(RESERVA_RC) as RESERVA_RC,
sum(RESERVA_ROBO) as RESERVA_ROBO,sum(RESERVA_ASIST) as RESERVA_ASIST,sum(RESERVA_TOTAL) as RESERVA_TOTAL
INTO #Tablero_Motor_final
FROM Transaccional.dbo.Tablero_Motor A
where year(PER)*100+month(per)<=@CIERRE
GROUP BY LINEA_NEGOCIO,CHANNEL,GRUPO_CHANNEL,BU,CORREDOR,NPLANTEC,TIPPLAN,PLAN_TECNICO,PLAN_TECNICO2,PRODUCTOS_NUEVOS,
--DEDUCIBLE
CAST(IIF(DEDUCIBLE IN ('N/A', 'N/I'),'-1',DEDUCIBLE) AS float),
TIPO_VEH,GAMA_VEH,
MARCA,MODELO,MARCA_MODELO,TOP100,SUCURSAL,REGION,REGION_URBE,PROVINCIA,NUEVA_RENOV,NUEVA_RENOV2,FLOTA,GRUPO_FLOTA,PERIODO,ANT_VEH,EDAD,EXTRANJERO,
PERFIL_UBER,VIGENCIA,ZONA_SUCURSAL,CODRAMO,TAMA—O,A.CONTRATANTE,REGION_REAL,
(CASE WHEN GRUPO_FLOTA IN ('INVERSIONES INVERGAS','TSTGO','SALFA','SCANIA') THEN 'EXCLUIDO' ELSE 'INCLUIDO' END)

--
drop table if exists #ant_empresa

select distinct contratante,ant_empresa,year(fecha_inicio) aÒo_inicio
into #ant_empresa
from [SGF1025].Reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR

alter table #Tablero_Motor_final
add ant_empresa INTEGER

update #Tablero_Motor_final
set ant_empresa=case when cast(left(periodo,4) as float) - aÒo_inicio < 0 then 0 else cast(left(periodo,4) as float) - aÒo_inicio end
from #Tablero_Motor_final a
left join #ant_empresa b on a.contratante=b.contratante
where b.contratante is not null;
----


update #Tablero_Motor_final
set ult_total=pago_total+reserva_total, ult_dp=pago_dp+reserva_dp,ult_pt=pago_pt+reserva_pt,ult_robo=pago_robo+reserva_robo,ult_rc=pago_rc+reserva_rc
where  grupo_flota in ('SCANIA','SALFA') or (ult_total=0 and pago_total+reserva_total>0);


update #Tablero_Motor_final
set ult_total = ult_dp+ult_pt+ult_robo+ult_rc,
CANT_ult_total = cant_ult_dp+cant_ult_pt+cant_ult_robo+cant_ult_rc 
FROM #Tablero_Motor_final;



--Agregado: 22-07-2024
-----------------------------------------------------------------------------------------------------------------------------------------
															--MAS ROBADOS
-----------------------------------------------------------------------------------------------------------------------------------------
alter table #Tablero_Motor_final
add MAS_ROBADOS NVARCHAR(20) NULL

/*UPDATE #Tablero_Motor_final
SET
MAS_ROBADOS = 
CASE WHEN
	   (rtrim(MARCA) = 'CHERY'		 and  rtrim(MODELO) IN ('GRAND TIGGO','NEW TIGGO','TIGGO','TIGGO 2','TIGGO 3','TIGGO 4','TIGGO 7','TIGGO 8','TIGGO 2 PRO','TIGGO 3 PRO','TIGGO 7 PRO','TIGGO 8 PRO'))
	or (rtrim(MARCA) = 'CHEVROLET'	 and  rtrim(MODELO) IN ('SAIL','SILVERADO','SILVERADO CK 3500'))
	or (rtrim(MARCA) = 'FORD'		 and  rtrim(MODELO) IN ('F - 150','F-150 LARIAT','F-150 PLATINUM','F-150 RAPTOR','F-150 XLT'))
	or (rtrim(MARCA) = 'HYUNDAI'	 and  rtrim(MODELO) IN ('ACCENT','ACCENT HATCHBACK','ACCENT PRIME','ACCENT RB','ACCENT SEDAN','ALL NEW TUCSON','GRAND SANTA FE','NEW SANTA FE','NEW TUCSON','SANTA FE','TUCSON'))
	or (rtrim(MARCA) = 'JEEP'		 and  rtrim(MODELO) IN ('GRAND CHEROKEE.','GRAND CHEROKEE LAREDO','GRAND CHEROKEE LIMITED','NEW GRAND CHEROKEE','NEW GRAND CHEROKEE LAREDO','NEW GRAND CHEROKEE LIMITED'))
	or (rtrim(MARCA) = 'KIA MOTORS'  and  rtrim(MODELO) IN ('FRONTIER','FRONTIER D/C','FRONTIER SUPER','RIO','RIO II','RIO JB','RIO 3','RIO 4','RIO 5','RIO 5 SPORT'))
	or (rtrim(MARCA) = 'MAZDA'		 and  rtrim(MODELO) IN ('ALL NEW 3','NEW 3 SPORT','NEW MAZDA 3 SKYACTIVE SPORT GT','NEW MAZDA 3 SKYACTIVE 1.6','NEW MAZDA 3 SKYACTIVE 2.0','3.','3 SPORT.','3 SPORT 1.6 AT'))
	or (rtrim(MARCA) = 'MITSUBISHI'  and  rtrim(MODELO) IN ('L-200','L-200 DAKAR','L-200 KATANA','L-200 WORK','MONTERO','NEW MONTERO','NEW MONTERO SPORT','MONTERO SPORT','MONTERO SPORT.','MONTERO SPORT G2'))
	or (rtrim(MARCA) = 'NISSAN'		 and  rtrim(MODELO) IN ('KICKS','VERSA'))
	or (rtrim(MARCA) = 'PEUGEOT'	 and  rtrim(MODELO) IN ('E-2008 (ELECTRICO)','PARTNER','PARTNER (ELECTRICO)','PARTNER FURGON 5P. T/A MOTOR ELECTRICO','PARTNER MAXI','PARTNER TEPEE','PARTNER TEPEE OUTDOOR'))
	or (rtrim(MARCA) = 'SAMSUNG'	 and  rtrim(MODELO) IN ('SM3'))
	or (rtrim(MARCA) = 'SUZUKI'		 and  rtrim(MODELO) IN ('BALENO'))
	or (rtrim(MARCA) = 'TOYOTA'		 and  rtrim(MODELO) IN ('ADVANTAGE RAV4','ALL NEW HILUX','HI-LUX 4X4','HI-LUX','HI-LUX 4X2','NEW HILUX','NEW RAV-4','NEW YARIS','NEW YARIS SPORT','RAV.','RAV-4','YARIS','YARIS SPORT'))
THEN 'MAS ROBADO' 
ELSE 'REGULAR'
END*/

--NUEVA MARCA MAS ROBADOS
UPDATE #Tablero_Motor_final
SET
MAS_ROBADOS = 
CASE WHEN
	--SIN SUSCRIPCION POR INDICES DE ROBO
		(rtrim(MARCA) = 'FORD'		 and  rtrim(MODELO) LIKE '%F%150%' OR rtrim(MODELO) LIKE '%TERRITORY%')
	or (rtrim(MARCA) = 'HYUNDAI'	 and  rtrim(MODELO) = 'H-1')
	or (rtrim(MARCA) = 'JEEP'		 and  rtrim(MODELO) LIKE '%GRAND CHEROKEE%')
	or (rtrim(MARCA) = 'KIA MOTORS'  and  rtrim(MODELO) LIKE '%FRONTIER%' OR rtrim(MODELO) LIKE '%SOUL%')
	or (rtrim(MARCA) = 'MITSUBISHI'  and  rtrim(MODELO) LIKE '%L-200%' OR rtrim(MODELO) LIKE '%MONTERO%')
	or (rtrim(MARCA) = 'TOYOTA'		 and  rtrim(MODELO) LIKE '%FORTUNER%' OR rtrim(MODELO) LIKE '%HI%LUX%' OR rtrim(MODELO) LIKE '%LAND CRUISER%')

	--SUSCRIPCION MONITOREADA
	or (rtrim(MARCA) = 'CHEVROLET'	 and  rtrim(MODELO) LIKE '%GROOVE%')
	or (rtrim(MARCA) = 'CITROEN'	 and  rtrim(MODELO) LIKE '%C%ELYS%')
	or (rtrim(MARCA) = 'FORD'		 and  rtrim(MODELO) LIKE '%EXPLORER%')
	or (rtrim(MARCA) = 'HYUNDAI'	 and  rtrim(MODELO) LIKE '%ACCENT%')
	or (rtrim(MARCA) = 'KIA MOTORS'  and  rtrim(MODELO) LIKE '%SOLUTO%')
	or (rtrim(MARCA) = 'MAHINDRA'	 and  rtrim(MODELO) LIKE '%XUV%500')
	or (rtrim(MARCA) = 'MAXUS'		 and  rtrim(MODELO) = 'T60')
	or (rtrim(MARCA) = 'MAZDA'		 and  ((rtrim(MODELO) LIKE '%3%' AND rtrim(MODELO) NOT LIKE '%[A-Z0-9-]3%' AND rtrim(MODELO) NOT LIKE '%.3%') OR rtrim(MODELO) LIKE '%CX%3'))
	or (rtrim(MARCA) = 'NISSAN'		 and  rtrim(MODELO) = 'VERSA')
	or (rtrim(MARCA) = 'PEUGEOT'	 and  rtrim(MODELO) LIKE '%301%' OR rtrim(MODELO) LIKE '%5008%')
	or (rtrim(MARCA) = 'VOLKSWAGEN'	 and  rtrim(MODELO) LIKE '%AMAROK%')
	THEN 'MAS ROBADO' 
	ELSE 'REGULAR'
END
-----------------------------------------------------------------------------------------------------------------------------------------



DROP TABLE IF EXISTS Transaccional.dbo.Tablero_Motor_final
SELECT * INTO Transaccional.dbo.Tablero_Motor_final from #Tablero_Motor_final
DROP TABLE #Tablero_Motor_final


--BORRAR TABLAS TEMPORALES PARA LIBERAR ESPACIO
DROP TABLE IF EXISTS #polizas_uber
DROP TABLE IF EXISTS #min_per
DROP TABLE IF EXISTS #SISGEN
DROP TABLE IF EXISTS #TAMA—O
DROP TABLE IF EXISTS #TAMA—O2
DROP TABLE IF EXISTS #TIPOS
DROP TABLE IF EXISTS #tipo2
DROP TABLE IF EXISTS #nuevas
DROP TABLE IF EXISTS #ant_empresa



/****** Checkpoint PROCESO TERMINADO ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR TERMINADO', SYSDATETIME())
/****************************************************************************/

-- Validacion
--select periodo,sum(expos),sum(prima_dev),sum(prriesgo_dev),sum(pago_total+reserva_total),sum(ult_total) 
--from Transaccional.dbo.Tablero_Motor
--where year(PER)*100+month(per)<=@CIERRE and ult_total=0 and pago_total+reserva_total>0
--group by periodo
--order by periodo
------------------ FIN

-- Traspaso de Transaccional a GestionPortafolio (Ejecutar en servidor sgf1034)
/*
USE GestionPortafolio

drop table Tablero_Motor
select * into Tablero_Motor from sgf1025.Transaccional.dbo.Tablero_Motor

drop table Tablero_Motor_final
select * into Tablero_Motor_final from sgf1025.Transaccional.dbo.Tablero_Motor_final
*/

END
