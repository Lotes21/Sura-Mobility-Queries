USE [Transaccional]
GO
/****** Object:  StoredProcedure [dbo].[SP_MI_TABLERO_MOTOR_MENSUAL]    Script Date: 14-10-2025 10:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EJECUTAR ESTE PROCESO DESPUES DE TRANSACCIONAL.DBO.SP_MI_TABLERO_MOTOR

ALTER  PROCEDURE [dbo].[SP_MI_TABLERO_MOTOR_MENSUAL] (
	@CIERRE AS INT
)
AS
   
--exec [dbo].[SP_MI_TABLERO_MOTOR_MENSUAL] 202506

BEGIN

-------------------------------------------------------
--TRUNCATE TABLE AUX_MOTOR_06_CHECKPOINTS
--SELECT * FROM AUX_MOTOR_06_CHECKPOINTS
-------------------------------------------------------

--DROP TABLE IF EXISTS #Tablero_Motor
DROP TABLE IF EXISTS #Tablero_Motor_final

/****** Checkpoint Inicio ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR MENSUAL INICIADO', SYSDATETIME())
/*********************************************************************************/

--SE GENERA TABLERO MOTOR FINAL
--DROP TABLE Transaccional.dbo.Tablero_Motor_final_mensual
--
DROP TABLE IF EXISTS #Tablero_Motor_final

SELECT LINEA_NEGOCIO,CHANNEL,GRUPO_CHANNEL,BU,CORREDOR,NPLANTEC,TIPPLAN,PLAN_TECNICO,PLAN_TECNICO2,PRODUCTOS_NUEVOS,
--DEDUCIBLE,
CAST(IIF(DEDUCIBLE IN ('N/A', 'N/I'),'-1',DEDUCIBLE) AS float) AS DEDUCIBLE,
TIPO_VEH,GAMA_VEH,
MARCA,MODELO,MARCA_MODELO,TOP100,ZONA_SUCURSAL,SUCURSAL,REGION,REGION_URBE,PROVINCIA,nueva_renov NUEVA_RENOV,nueva_renov2,FLOTA,GRUPO_FLOTA,PER as PERIODO,ANT_VEH,EDAD,EXTRANJERO,
PERFIL_UBER,VIGENCIA,A.CONTRATANTE,REGION_REAL,
CODRAMO,TAMAÑO TAMAÑO_FLOTA,(CASE WHEN GRUPO_FLOTA IN ('INVERSIONES INVERGAS','TSTGO','SALFA','SCANIA') THEN 'EXCLUIDO' ELSE 'INCLUIDO' END) INCLUSIÓN,
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
MARCA,MODELO,MARCA_MODELO,TOP100,SUCURSAL,REGION,REGION_URBE,PROVINCIA,NUEVA_RENOV,NUEVA_RENOV2,FLOTA,GRUPO_FLOTA,PER,ANT_VEH,EDAD,EXTRANJERO,
PERFIL_UBER,VIGENCIA,ZONA_SUCURSAL,CODRAMO,TAMAÑO,A.CONTRATANTE,REGION_REAL,
(CASE WHEN GRUPO_FLOTA IN ('INVERSIONES INVERGAS','TSTGO','SALFA','SCANIA') THEN 'EXCLUIDO' ELSE 'INCLUIDO' END)

--
drop table if exists #ant_empresa

select distinct contratante,ant_empresa,year(fecha_inicio) año_inicio
into #ant_empresa
from [SGF1025].Reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR

alter table #Tablero_Motor_final
add ant_empresa INTEGER

update #Tablero_Motor_final
set ant_empresa=case when cast(left(periodo,4) as float) - año_inicio < 0 then 0 else cast(left(periodo,4) as float) - año_inicio end
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
	   (rtrim(MARCA) = 'CHERY'		 and  rtrim(MODELO) LIKE '%TIGGO%')
	or (rtrim(MARCA) = 'CHEVROLET'	 and  rtrim(MODELO) LIKE '%GROOVE%')
	or (rtrim(MARCA) = 'FORD'		 and  rtrim(MODELO) LIKE '%F%150%' OR rtrim(MODELO) LIKE '%TERRITORY%')
	or (rtrim(MARCA) = 'HYUNDAI'	 and  rtrim(MODELO) LIKE '%ACCENT%')
	or (rtrim(MARCA) = 'JEEP'		 and  rtrim(MODELO) LIKE '%GRAND CHEROKEE%')
	or (rtrim(MARCA) = 'KIA MOTORS'  and  rtrim(MODELO) LIKE '%FRONTIER%' OR rtrim(MODELO) LIKE 'RIO%' OR rtrim(MODELO) LIKE '%SOLUTO%')
	or (rtrim(MARCA) = 'MAZDA'		 and  rtrim(MODELO) LIKE '%3%' AND rtrim(MODELO) NOT LIKE '%[A-Z0-9-]3%' AND rtrim(MODELO) NOT LIKE '%.3%')
	or (rtrim(MARCA) = 'MITSUBISHI'  and  rtrim(MODELO) LIKE '%L-200%' OR rtrim(MODELO) LIKE '%MONTERO%')
	or (rtrim(MARCA) = 'NISSAN'		 and  rtrim(MODELO) IN ('KICKS','VERSA'))
	or (rtrim(MARCA) = 'SUZUKI'		 and  rtrim(MODELO) = 'BALENO')
	or (rtrim(MARCA) = 'TOYOTA'		 and  rtrim(MODELO) LIKE '%RAV%4%' OR rtrim(MODELO) LIKE '%FORTUNER%' OR rtrim(MODELO) LIKE '%HI%LUX%' OR rtrim(MODELO) LIKE '%LAND CRUISER%' OR rtrim(MODELO) LIKE '%YARIS%')
	THEN 'MAS ROBADO' 
	ELSE 'REGULAR'
END
-----------------------------------------------------------------------------------------------------------------------------------------



DROP TABLE IF EXISTS Transaccional.dbo.Tablero_Motor_final_mensual
SELECT * INTO Transaccional.dbo.Tablero_Motor_final_mensual from #Tablero_Motor_final
DROP TABLE #Tablero_Motor_final


--BORRAR TABLAS TEMPORALES PARA LIBERAR ESPACIO
DROP TABLE IF EXISTS #ant_empresa



/****** Checkpoint PROCESO TERMINADO ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('TABLERO MOTOR MENSUAL TERMINADO', SYSDATETIME())
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