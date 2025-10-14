USE [Transaccional]
GO
/****** Object:  StoredProcedure [dbo].[SP_MI_TRANSACCIONAL_MOTOR_CORRECCIONES]    Script Date: 14-10-2025 10:27:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER  PROCEDURE [dbo].[SP_MI_TRANSACCIONAL_MOTOR_CORRECCIONES]
AS
   
--exec [dbo].[SP_MI_TRANSACCIONAL_MOTOR_CORRECCIONES]

BEGIN

DECLARE
	@CIERRE INT = YEAR(dateadd(month, -1, GETDATE()))*100+MONTH(dateadd(month, -1, GETDATE())),
	--@CIERRE INT = 202404, --USAR FECHA CIERRE DE FORMA MANUAL SI SE DESEA REPROCESAR
	@SQL NVARCHAR(MAX)
--SELECT @CIERRE

DROP TABLE IF EXISTS #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
SELECT *, 
--YEAR(dateadd(month, -1, GETDATE()))*100+MONTH(dateadd(month, -1, GETDATE())) AS CIERRE
@CIERRE AS CIERRE
INTO #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
FROM Transaccional.dbo.MI_PRIMA_SINIESTRO_MOTOR;

-------------------------------------------------------
/*SET @SQL = 'DROP TABLE IF EXISTS REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR_BKP_' + CAST(@CIERRE AS VARCHAR(6))

--SELECT @SQL
EXEC SP_EXECUTESQL @SQL*/

-------------------------------------------------------
--YA NO HACEMOS BACKUP (ESTA TABLA ES MUY PESADA Y OCUPA MUCHO ESPACIO)
/*
--SE CREA BKP CORRESPONDIENTE AL CIERRE ACTUAL
SET @SQL = 'SELECT * INTO REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR_BKP_' + CAST(@CIERRE AS VARCHAR(6)) + 
	' FROM #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR'

--SELECT @SQL
EXEC SP_EXECUTESQL @SQL
*/
-------------------------------------------------------
--TRUNCATE TABLE AUX_MOTOR_06_CHECKPOINTS
--SELECT * FROM AUX_MOTOR_06_CHECKPOINTS order by 2 desc

/****** Checkpoint Inicio ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('PROCESO CORRECCIONES INICIADO', SYSDATETIME())
/*********************************************************************************/
-------------------------------------------AJUSTES
--PERSONAL-- CALIBRACION MANUAL - FACTORES JOCHI
/*UPDATE #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
SET 
PRDP_DEV_UF     = CASE WHEN A.PRDP_DEV_UF     >0    THEN A.PRDP_DEV_UF     * 1.167 * 1.019    ELSE A.PRDP_DEV_UF        END,   
PRDP_DEV        = CASE WHEN A.PRDP_DEV        >0    THEN A.PRDP_DEV        * 1.167 * 1.019    ELSE A.PRDP_DEV           END,
PRPT_DEV_UF     = CASE WHEN A.PRPT_DEV_UF     >0    THEN A.PRPT_DEV_UF     * 1.108 * 0.952    ELSE A.PRPT_DEV_UF        END,    
PRPT_DEV        = CASE WHEN A.PRPT_DEV        >0    THEN A.PRPT_DEV        * 1.108 * 0.952    ELSE A.PRPT_DEV           END,
PRRC_DEV_UF     = CASE WHEN A.PRRC_DEV_UF     >0    THEN A.PRRC_DEV_UF     * 1.391 * 1.159    ELSE A.PRRC_DEV_UF        END,    
PRRC_DEV        = CASE WHEN A.PRRC_DEV        >0    THEN A.PRRC_DEV        * 1.391 * 1.159    ELSE A.PRRC_DEV           END,
PRROBO_DEV_UF   = CASE WHEN A.PRROBO_DEV_UF   >0    THEN A.PRROBO_DEV_UF   * 1.729 * 1.355    ELSE A.PRROBO_DEV_UF      END,    
PRROBO_DEV      = CASE WHEN A.PRROBO_DEV      >0    THEN A.PRROBO_DEV      * 1.729 * 1.355    ELSE A.PRROBO_DEV         END 
FROM #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR A LEFT JOIN ALMACEN_DE_DATOS.DBO.SURA_MOVILIDAD_FACTORES_DE_AJUSTES B 
ON A.LINEA_NEGOCIO=B.LINEA_NEGOCIO AND CASE WHEN A.DEDUCIBLE NOT IN ('0','3','5','10') THEN 'RESTO' ELSE A.DEDUCIBLE END=B.DEDUCIBLE
WHERE B.TIPO_AJUSTE='PR'  AND A.LINEA_NEGOCIO='PERSONAL'

/****** Checkpoint 0 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 0 - CALIBRACIONES', SYSDATETIME())
/****************************************************************************/


UPDATE #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
SET 
FRECDP          = CASE WHEN A.FRECDP          >0    THEN A.FRECDP            * 1.124 * 0.782689654    ELSE A.FRECDP            END,    
FRECDP_DEV      = CASE WHEN A.FRECDP_DEV      >0    THEN A.FRECDP_DEV        * 1.124 * 0.782689654    ELSE A.FRECDP_DEV        END,
FRECPT          = CASE WHEN A.FRECPT          >0    THEN A.FRECPT            * 0.945 * 1.058439754    ELSE A.FRECPT            END,    
FRECPT_DEV      = CASE WHEN A.FRECPT_DEV      >0    THEN A.FRECPT_DEV        * 0.945 * 1.058439754    ELSE A.FRECPT_DEV        END,
FRECRC          = CASE WHEN A.FRECRC          >0    THEN A.FRECRC            * 1.200 * 0.676040169    ELSE A.FRECRC            END,    
FRECRC_DEV      = CASE WHEN A.FRECRC_DEV      >0    THEN A.FRECRC_DEV        * 1.200 * 0.676040169    ELSE A.FRECRC_DEV        END,
FRECROBO        = CASE WHEN A.FRECROBO        >0    THEN A.FRECROBO          * 1.069 * 0.89539773     ELSE A.FRECROBO          END,    
FRECROBO_DEV    = CASE WHEN A.FRECROBO_DEV    >0    THEN A.FRECROBO_DEV      * 1.069 * 0.89539773     ELSE A.FRECROBO_DEV      END 
FROM #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR A LEFT JOIN ALMACEN_DE_DATOS.DBO.SURA_MOVILIDAD_FACTORES_DE_AJUSTES B 
ON A.LINEA_NEGOCIO=B.LINEA_NEGOCIO AND CASE WHEN A.DEDUCIBLE NOT IN ('0','3','5','10') THEN 'RESTO' ELSE A.DEDUCIBLE END=B.DEDUCIBLE
WHERE B.TIPO_AJUSTE='FREC'  AND A.LINEA_NEGOCIO='PERSONAL'


/****** Checkpoint 0-2 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 0-2 - CALIBRACIONES', SYSDATETIME())
/****************************************************************************/


--PARA ESTE MES NO APLICAR LA CALIBRACION A COMMERCIAL (2024-01-12)
--AGREGADA CALIBRACION MANUAL A COMMERCIAL PESADO (2024-01-22)

--COMMERCIAL PESADO- CALIBRACION MANUAL
UPDATE #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
SET 
PRDP_DEV_UF     = CASE WHEN A.PRDP_DEV_UF     >0    THEN A.PRDP_DEV_UF       * 1.4475839636    ELSE   A.PRDP_DEV_UF        END,    
PRDP_DEV        = CASE WHEN A.PRDP_DEV        >0    THEN A.PRDP_DEV          * 1.4475839636    ELSE   A.PRDP_DEV           END,
PRPT_DEV_UF     = CASE WHEN A.PRPT_DEV_UF     >0    THEN A.PRPT_DEV_UF       * 0.8336513656    ELSE   A.PRPT_DEV_UF        END,    
PRPT_DEV        = CASE WHEN A.PRPT_DEV        >0    THEN A.PRPT_DEV          * 0.8336513656    ELSE   A.PRPT_DEV           END,
PRRC_DEV_UF     = CASE WHEN A.PRRC_DEV_UF     >0    THEN A.PRRC_DEV_UF       * 1.0988083064    ELSE   A.PRRC_DEV_UF        END,    
PRRC_DEV        = CASE WHEN A.PRRC_DEV        >0    THEN A.PRRC_DEV          * 1.0988083064    ELSE   A.PRRC_DEV           END,
PRROBO_DEV_UF   = CASE WHEN A.PRROBO_DEV_UF   >0    THEN A.PRROBO_DEV_UF     * 1.7262621402    ELSE   A.PRROBO_DEV_UF      END,    
PRROBO_DEV      = CASE WHEN A.PRROBO_DEV      >0    THEN A.PRROBO_DEV        * 1.7262621402    ELSE   A.PRROBO_DEV         END 
FROM #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR A LEFT JOIN ALMACEN_DE_DATOS.DBO.SURA_MOVILIDAD_FACTORES_DE_AJUSTES B 
ON A.LINEA_NEGOCIO=B.LINEA_NEGOCIO/* and A.DEDUCIBLE=B.DEDUCIBLE*/
WHERE B.TIPO_AJUSTE='PR'  AND A.LINEA_NEGOCIO='COMMERCIAL' AND CCODRAMO = 'EP'

/****** Checkpoint 1 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 1 - CALIBRACIONES 2', SYSDATETIME())
/****************************************************************************/

--select * from  ALMACEN_DE_DATOS.DBO.SURA_MOVILIDAD_FACTORES_DE_AJUSTES 
UPDATE #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
SET 
FRECDP          = CASE WHEN A.FRECDP          >0    THEN A.FRECDP            * 1.44854     ELSE   A.FRECDP            END,    
FRECDP_DEV      = CASE WHEN A.FRECDP_DEV      >0    THEN A.FRECDP_DEV        * 1.44854     ELSE   A.FRECDP_DEV        END,
FRECPT          = CASE WHEN A.FRECPT          >0    THEN A.FRECPT            * 0.71206     ELSE   A.FRECPT            END,    
FRECPT_DEV      = CASE WHEN A.FRECPT_DEV      >0    THEN A.FRECPT_DEV        * 0.71206     ELSE   A.FRECPT_DEV        END,
FRECRC          = CASE WHEN A.FRECRC          >0    THEN A.FRECRC            * 0.95816     ELSE   A.FRECRC            END,    
FRECRC_DEV      = CASE WHEN A.FRECRC_DEV      >0    THEN A.FRECRC_DEV        * 0.95816     ELSE   A.FRECRC_DEV        END,
FRECROBO        = CASE WHEN A.FRECROBO        >0    THEN A.FRECROBO          * 1.66758     ELSE   A.FRECROBO          END,    
FRECROBO_DEV    = CASE WHEN A.FRECROBO_DEV    >0    THEN A.FRECROBO_DEV      * 1.66758     ELSE   A.FRECROBO_DEV      END 
FROM #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR A LEFT JOIN ALMACEN_DE_DATOS.DBO.SURA_MOVILIDAD_FACTORES_DE_AJUSTES B 
ON A.LINEA_NEGOCIO=B.LINEA_NEGOCIO
/*and A.DEDUCIBLE=B.DEDUCIBLE*/
WHERE B.TIPO_AJUSTE='FREC'  AND A.LINEA_NEGOCIO='COMMERCIAL' AND CCODRAMO = 'EP'
--
*/

UPDATE #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
SET 
PRRIESGO_UF_DEV = PRDP_DEV_UF    + PRPT_DEV_UF    + PRROBO_DEV_UF + PRRC_DEV_UF, 
PRRIESGO_DEV    = PRDP_DEV       + PRPT_DEV       + PRROBO_DEV    + PRRC_DEV
WHERE PRRIESGO_UF_DEV >0 AND PRRIESGO_UF_DEV IS NOT NULL



/****** Checkpoint 1-2 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 1-2 - CALIBRACIONES 2', SYSDATETIME())
/****************************************************************************/
ALTER TABLE #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
ADD TIPO_VIGENCIA varchar(25);

UPDATE #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR
SET 
TIPO_VIGENCIA = CASE 
	WHEN DATEDIFF(DAY, FECINVIG, FECTEVIG) BETWEEN -15 AND 20        THEN 'MENOR A MENSUAL'
	WHEN DATEDIFF(DAY, FECINVIG, FECTEVIG) BETWEEN  21 AND 45        THEN 'MENSUAL'
	WHEN DATEDIFF(DAY, FECINVIG, FECTEVIG) BETWEEN  46 AND 105       THEN 'TRIMESTRAL'
	WHEN DATEDIFF(DAY, FECINVIG, FECTEVIG) BETWEEN 106 AND 210       THEN 'SEMESTRAL'
	WHEN DATEDIFF(DAY, FECINVIG, FECTEVIG) BETWEEN 211 AND 385       THEN 'ANUAL'
	WHEN DATEDIFF(DAY, FECINVIG, FECTEVIG) BETWEEN 386 AND 750       THEN 'BIENAL'
	WHEN DATEDIFF(DAY, FECINVIG, FECTEVIG) BETWEEN 751 AND 1000000   THEN 'MAYOR A BIENAL'
	ELSE 'SIN VIGENCIA'
END

------------------------------------------------------------------------------ Marca Vehiculo Robado ----------------------------------------------------------------------------------------
--#AUX_1
DROP TABLE if exists #AUX_1
SELECT NNUMDOCU, NNUMITEM, MAX(RUT_ASEGURADO) AS RUT_ASEGURADO
INTO #AUX_1
FROM reportes.[dbo].[SURA_MOVILIDAD_TRANSACCIONAL] 
GROUP BY NNUMDOCU, NNUMITEM

--#AUX_2
--Actualizar base resumen clientes en query del proceso 6 al final.
DROP TABLE IF EXISTS #AUX_2
SELECT A.*, B.REGION,  
Region_Bloqueada = case 
	when b.region in (
		'METROPOLITANA DE SANTIAGO',
        'DE TARAPACA','DE ANTOFAGASTA',
		'DE COQUIMBO',
		'DE ARICA Y PARINACOTA',
		'DE VALPARAISO','DE ATACAMA',
		'DEL LIBERTADOR B. OHIGGINS') then 'Bloqueado' 
	when b.region is null then 'Ignorada' 
	else 'No Bloqueado' end
INTO #AUX_2
FROM #AUX_1 A
LEFT JOIN [Transaccional].[dbo].[Base_resumen_clientes] B
ON A.RUT_ASEGURADO=B.nnuruase

--#AUX_3
--Cargar base de vehiculos robados previamente en caso de cambiar algún criterio
drop table IF EXISTS #AUX_3
select 
	a.*, 
	Veh_Robado_Año = case when NANFAVEH >= 2017 THEN 'Bloqueado' else cast(NANFAVEH as varchar) end, 
	Veh_Robado_Zona = b.Region_Bloqueada, 
	Veh_Robado_MarcaModelo = c.[ROBADO BLOQUEAR],
	Listado_Veh_Robados = c.AGRUPACION
into #AUX_3
FROM #REPORTES_DBO_MI_PRIMA_SINIESTRO_MOTOR a
left join #AUX_2 b on 
	a.NNUMDOCU=b.NNUMDOCU and 
	a.NNUMITEM=b.NNUMITEM
left join [Transaccional].[dbo].[Vehiculos_Robados] c on  
	REPLACE(A.CCOMAVEH,' ','') = REPLACE(C.CCOMAVEH,' ','') AND 
	REPLACE(A.CDESCORT,' ',' ') = REPLACE(C.CDESCORT,' ',' ')

ALTER TABLE #AUX_3
ADD Region_Bloqueada varchar(255);

-- Se realiza un UPDATE con a #AUX_3, para los casos en que no contamos con la region del asegurado en la base de clientes, se tomará la que viene directo de SOL
UPDATE #AUX_3
SET Region_Bloqueada = case 
	when region in (
		'METROPOLITANA DE SANTIAGO',
        'DE TARAPACA','DE ANTOFAGASTA',
		'DE COQUIMBO',
		'DE ARICA Y PARINACOTA',
		'DE VALPARAISO','DE ATACAMA',
		'DEL LIBERTADOR B. OHIGGINS') then 'Bloqueado' 
	when region is null then 'Ignorada' 
	else 'No Bloqueado' end

--#MI_PRIMA_SINIESTRO_MOTOR
drop table IF EXISTS #MI_PRIMA_SINIESTRO_MOTOR
SELECT *, Marca_Robado = case when Veh_Robado_Año='Bloqueado' and Veh_Robado_Zona='Bloqueado' and Veh_Robado_MarcaModelo='Bloqueado' then 'Robado' else 'Resto' end
into #MI_PRIMA_SINIESTRO_MOTOR
from #AUX_3



/****** Checkpoint 2 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 2 - MARCA ROBADO', SYSDATETIME())
/****************************************************************************/
------------------------------------------------------------------------------ Marca Tamaño de Flotas ----------------------------------------------------------------------------------------
-- Cantidad de autos por flotas
--#TAMAÑO
drop table IF EXISTS #TAMAÑO
select CONTRATANTE,YEAR(FECTEVIG)*100+MONTH(FECTEVIG) MES, COUNT(*) CANTIDAD
INTO #TAMAÑO
from [SGF1025].Transaccional.dbo.MI_PRIMA_EMITIDA_ACCESS 
where linea_negocio like 'COM%'
group by CONTRATANTE,YEAR(FECTEVIG)*100+MONTH(FECTEVIG)

--#TAMAÑO2
drop table IF EXISTS #TAMAÑO2
select nnumdocu,nnumitem,min(ccodramo) CODRAMO,min(nnumrut) nnumrut,min(A.contratante) contratante,min(cantidad) CANTIDAD,MIN(CCODRAMO) CCODRAMO_FLOTA,
INCLUSION_FLOTA = MIN(CASE WHEN A.CONTRATANTE IN (76071048,76976580,79738350,91502000,97030000,97036000,99554700,99577050) THEN 'EXCLUIDO' ELSE 'INCLUIDO' END) ,
TAMAÑO_FLOTA = 
MIN(CASE WHEN C.CANTIDAD=1 THEN 'A.1_1' WHEN C.CANTIDAD=2 THEN 'B.2_2' WHEN C.CANTIDAD=3 THEN 'C.3_3' WHEN C.CANTIDAD=4 THEN 'D.4_4' WHEN C.CANTIDAD=5 THEN 'E.5_5' WHEN C.CANTIDAD<=10 THEN 'F.6_10' 
WHEN C.CANTIDAD<=20 THEN 'G.11_20' WHEN C.CANTIDAD<=50 THEN 'H.21_50' WHEN C.CANTIDAD<=100 THEN 'I.51_100' WHEN C.CANTIDAD<=300 THEN 'J.101_300' WHEN C.CANTIDAD<=1000 THEN 'K.301_1000'
WHEN C.CANTIDAD<=2000 THEN 'L.1001_2000' WHEN C.CANTIDAD<=3000 THEN 'M.2001_3000' WHEN C.CANTIDAD>3000 THEN 'N.>3000' ELSE NULL END) 
INTO #TAMAÑO2
FROM [SGF1025].Transaccional.dbo.MI_PRIMA_EMITIDA_ACCESS a
left join #TAMAÑO C on  A.CONTRATANTE=C.CONTRATANTE AND YEAR(FECTEVIG)*100+MONTH(FECTEVIG)=C.MES
where linea_negocio like 'COM%'
group by nnumdocu,nnumitem



/****** Checkpoint 3 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 3 - TAMANO', SYSDATETIME())
/****************************************************************************/
----- Agrego las variables a MI_PRIMA_SINIESTRO_MOTOR
--------------- Paso Final corro el AvE
--#MARCAS
drop table IF EXISTS #marcas
select distinct A.nnumdocu, A.nnumitem, B.CCODRAMO_FLOTA, B.INCLUSION_FLOTA, B.TAMAÑO_FLOTA, grupo_flota, tamaño
into #marcas
--from sgf1034.GestionPortafolio.[dbo].[Tablero_Motor] A
from Transaccional.[dbo].[Tablero_Motor] A
LEFT JOIN #TAMAÑO2 B
ON A.NNUMDOCU = B.NNUMDOCU AND A.NNUMITEM=B.NNUMITEM
Where tamaño IS NOT NULL

-----------------------------------------
--Se agrega información de flotas a MI_prima_siniestro_Calibrado
DROP TABLE IF EXISTS #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO
select A.*, B.CCODRAMO_FLOTA, B.INCLUSION_FLOTA, B.TAMAÑO_FLOTA, b.grupo_flota, b.tamaño as tamaño2
into #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO 
from #MI_PRIMA_SINIESTRO_MOTOR A LEFT JOIN #marcas B 
ON A.NNUMDOCU = B.NNUMDOCU AND A.NNUMITEM = B.NNUMITEM


--DROP TABLE REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR
DROP TABLE IF EXISTS #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
SELECT a.*, b.Tramo_Segun_ventas,	b.Fecha_inicio,	b.Rubro_economico,	b.Subrubro_economico,	b.Actividad_Economica,	b.[Numero de Trabajadores], b.ANT_EMPRESA
--into REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR
into #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
FROM #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO a
left join Transaccional.dbo.Base_Antiguedad_empresas b
on a.CONTRATANTE = b.RUT

-----------------------------------------------------------------------------------------------------------------------------------------
--NUEVA_RENOVADA
alter table #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
add NUEVA_RENOVADA VARCHAR(50) NULL

update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set NUEVA_RENOVADA = case when ind_renovacion=0 then 'NUEVA' ELSE 'RENOVACION' end

-----------------------------------------------------------------------------------------------------------------------------------------
/*
select *
into reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR_202312--------> Una vez creada reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR se genera bkp con el nombre del mes de cierre
from reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR
*/

/*SET @SQL = 'DROP TABLE IF EXISTS REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR_' + CAST(@CIERRE AS VARCHAR(6))

--SELECT @SQL
EXEC SP_EXECUTESQL @SQL*/

-------------------------------------------------------
/*
--SE CREA BKP CORRESPONDIENTE AL CIERRE ACTUAL
SET @SQL = 'SELECT * INTO REPORTES.DBO.MI_PRIMA_SINIESTRO_MOTOR_' + CAST(@CIERRE AS VARCHAR(6)) + 
	' FROM #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2'

--SELECT @SQL
EXEC SP_EXECUTESQL @SQL
*/
-------------------------------------------------------

/****** Checkpoint 4 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 4 - MPSM', SYSDATETIME())
/****************************************************************************/
-----------------------------------------------------------------------------------------------------------------------------------------
															--NUEVAS CORRECCIONES:
-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION DE BU Y CHANNEL
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	BU = CASE WHEN B.CANAL_ACTUAL IS NULL OR B.CANAL_ACTUAL = '' THEN A.BU ELSE B.CANAL_ACTUAL END,
	CHANNEL = CASE WHEN B.[PARTNER] IS NULL OR B.[PARTNER] = '' THEN A.CHANNEL ELSE B.[PARTNER] END
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
left join reportes.dbo.POLIZAS_MOVILIDAD_NUEVO B ON
A.NNUMDOCU = B.NNUMDOCU

--CORRECCION DE NOMBRES A BU Y CHANNEL
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	BU = CASE 
		WHEN BU LIKE '%Affinity%' OR BU = 'NEGOCIOS MASIVOS Y CLIENTES' THEN 'AFFINITY'
		WHEN BU IN ('CNC', 'NEGOCIOS COMERCIALES', 'NEGOCIOS EMPRESAS Y PERSONAS', 'E&P') THEN 'PYME'
		WHEN BU IN ('LBR', 'NEGOCIOS CORPORATIVOS') THEN 'CORPORATIVO'
		WHEN BU IN ('DIRECTO', 'NEGOCIOS DIRECTOS') THEN 'CANAL DIRECTO'
		WHEN BU = 'SUCURSALES' THEN 'CANAL ASESOR'
		WHEN BU = '' THEN NULL
		ELSE BU
	END,
	CHANNEL = CASE
		WHEN CHANNEL = 'DIRECTO' THEN 'CANAL DIRECTO'
		WHEN CHANNEL IN ('DEALER DIRECTO','DEALERS DIRECTOS') THEN 'DEALERS DIRECTO'
		WHEN CHANNEL = 'SUCURSALES' THEN 'CANAL ASESOR'
		WHEN CHANNEL = '' THEN NULL
		ELSE CHANNEL
	END

-----------------------------------------------------------------------------------------------------------------------------------------
--AGREGAR FLOTAS
UPDATE #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
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

--OTROS
UPDATE #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
SET
FLOTA		= CASE WHEN CONTRATANTE=76102176 THEN 'TRANSVIP' END,
GRUPO_FLOTA = CASE WHEN CONTRATANTE=76102176 THEN 'TRANSVIP' END
WHERE CONTRATANTE IN (76102176)

/****** Checkpoint 5 ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('CORRECCIONES - CHECKPOINT 5 - CANALES', SYSDATETIME())
/****************************************************************************/
-----------------------------------------------------------------------------------------------------------------------------------------
--ACTUALIZACION DE TIPPLAN PARA RCM Y RCA a RCI

--RCI
UPDATE #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
SET
TIPPLAN = 'RCI'
where NPLANTEC in (4958,6034,3708,3706,4731,3709,1067,3710,3712,6042,6042,3711)

--RCI+ROBO
UPDATE #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
SET
TIPPLAN = 'RCI+ROBO'
where NPLANTEC IN (6041,4730,4756)

-----------------------------------------------------------------------------------------------------------------------------------------
--ACTUALIZACION DE TIPPLAN CRUZANDO CON LA TABLA DE CARLOS VICENCIO
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = CASE WHEN B.TIPO_PLAN IS NULL OR B.TIPO_PLAN = '' THEN A.TIPPLAN ELSE B.TIPO_PLAN END
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	A.tipplan <> b.tipo_plan
	and A.tipplan not in ('RCI', 'RCI+ROBO')
	and B.TIPO_PLAN <> 'NO INDENT'
	and B.PLAN_TECNICO like '%MARCA%'
	and B.TIPO_PLAN <> 'RCA'

-----------------------------------------------------------------------------------------------------------------------------------------
--PARCHE CASOS AL AIRE
--RCI
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = 'RCI'
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	a.NPLANTEC = 1636

--RCI+ROBO
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = 'RCI+ROBO'
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	a.NPLANTEC = 6366

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion para Planes tecnicos con palabra 'Marca' y TIPPLAN 'RCA'
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = 'FULL'
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	b.PLAN_TECNICO like '%MARCA%'
	and tipplan = 'RCA'

-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION CASOS ESPECIFICOS
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = replace(B.TIPO_PLAN,' ','')
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
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

-----------------------------------------------------------------------------------------------------------------------------------------
--RCA sueltos
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = 'RCI'
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	A.tipplan = 'RCA'
	and (B.PLAN_TECNICO like 'RCA%' or B.PLAN_TECNICO like 'RC%ARG%')
	and B.PLAN_TECNICO not like '%+%ROBO%'
	and B.PLAN_TECNICO not like '%NORCAVAL%'

update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set 
	TIPPLAN = 'RCI'
where 
	TIPPLAN = 'RCA'

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion RCA NORCAVAL
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = 'FULL'
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2 A
left join (select CODIGO_PLAN_TECNICO, PLAN_TECNICO, TIPO_PLAN from reportes.dbo.PLANES_TECNICOS_MOVILIDAD) B ON
A.NPLANTEC = B.CODIGO_PLAN_TECNICO
where 
	A.tipplan IN ('RCA','RCI')
	and B.PLAN_TECNICO like '%NORCAVAL%'
	and NPLANTEC = 8331

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion PT + RC
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = 'PT + RC'
where 
	TIPPLAN = 'PT+RC'

-----------------------------------------------------------------------------------------------------------------------------------------
--Correccion vacios
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
	TIPPLAN = NULL
where 
	TIPPLAN = ''

-----------------------------------------------------------------------------------------------------------------------------------------
--DEALERS BRUNO FRITSCH Y DIFOR
UPDATE #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
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
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
where nnumrut in (76620819,76133889,76110334,92909000,76068841,81198400,76685737,77963303,77326117)


UPDATE #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
SET
CHANNEL = 'DEALERS - DIFOR'
from #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
where NPLANTEC in (4024,4025,4026,4027,4028,4029,5015,5016,5017,5018,5020,5022,5023,5024,5025,5673)

-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION A PRINCIPALES PARTNER_PYG
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set 
BU = 'AFFINITY',
CHANNEL = 
	CASE 
		WHEN NNUMRUT = 77191070 THEN 'BANCHILE'
		WHEN NNUMRUT = 77099010 THEN 'FALABELLA'
		WHEN NNUMRUT = 76215627 THEN 'MOK'
		WHEN NNUMRUT = 77472420 THEN 'RIPLEY'
		WHEN NNUMRUT = 96524260 THEN 'SANTANDER CORREDORA'
		WHEN NNUMRUT = 76449877 THEN 'M A C C CORREDORES DE SEGUROS S P A'
		WHEN NNUMRUT = 78745730 THEN 'SCOTIABANK'
		ELSE CHANNEL
	END
WHERE 
	(NNUMRUT = 77099010 and NNURUPRO in (10639058,14598475,18639355,76157159,77099010,77261280,90749000,96509660,96847200) ) OR
	NNUMRUT in (77191070,76215627,77472420,96524260,76449877,78745730)

-----------------------------------------------------------------------------------------------------------------------------------------
--CORRECCION PARA AGREGAR "ACCESOS" A CANAL DIRECTO

update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set 
CHANNEL = 'CANAL DIRECTO',
BU = 'CANAL DIRECTO'
WHERE  nnumrut = '99017000' AND NOMSUCU NOT IN ('CASA MATRIZ')



/*update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
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
update #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2
set
tipo = Case When 
	rtrim(CDESCORT) in ('RICH 6 EV', 'IONIQ','IONIQ ELECTRICO','KANGOO ZE','LEAF','FLUENCE ZE','IONIQ 5 (ELECTRICO)','NIRO', 'I3S 120AH', 'KONA', 'PRIUS', 'PRIUS C', 'M5 EV') 
	or rtrim(CDESCORT) like '%ELECTRIC%' 
	or rtrim(CDESCORT) like '%ELÉCTR%' 
	or rtrim(CDESCORT) like '%ELETR%'
	or (rtrim(CCOMAVEH) IN ('BYD')  and  rtrim(CDESCORT) IN ('M3', 'T3', 'EV')) 
	or (rtrim(CCOMAVEH) IN ('FARIZON')  and  rtrim(CDESCORT) IN ('E200 3.5 T', 'E6')) 
	or (rtrim(CCOMAVEH) IN ('GEELY')  and  rtrim(CDESCORT) like '%EV%')
	or (rtrim(CCOMAVEH) IN ('MAPLE')  and  rtrim(CDESCORT) IN ('30 X', '60 S', '80 V')) 
	or (rtrim(CCOMAVEH) IN ('MG')  and  rtrim(CDESCORT) IN ('ZS EV', 'MARVEL R'))  
	then 'VEHICULO ELECTRICO' 
	when 
		rtrim(CDESCORT) like '%HIBR%'
		or rtrim(CDESCORT) like '%HEV' 
		or rtrim(CDESCORT) like '%HYBRID%' 
		OR rtrim(CDESCORT) like '%PHEV%' 
		or nnumdocu = 7870731 
	then 'VEHÍCULO HIBRIDO'
	WHEN 
		(NPLANTEC in (6482,6369,6837,6267,6816,7095,8470,8499,8681) 
		or nnumdocu in (7750297,7882583,7882585,7882586, 7294025,7745982,7806169,7870731, 7926736,7936057)
		or rtrim(CDESCORT) IN ('B12C01', 'K9KA', 'U10', 'XMQ', 'LCK', 'EBUS U12.-', 'ZK', 'LCK6900H', 'K9')) 
	THEN 'BUS ELECTRICO' 
	ELSE [TIPO] 
END

-----------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR
SELECT *
INTO Reportes.dbo.MI_PRIMA_SINIESTRO_MOTOR
FROM #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2


-- HAGO UN TRUNCATE PARA LIBERAR ESPACIO EN EL SERVIDOR DE TRANSACCIONAL
TRUNCATE TABLE TRANSACCIONAL.DBO.MI_PRIMA_SINIESTRO_MOTOR   
 

-----------------------------------------------------------------------------------------------------------------------------------------
--FIN NUEVAS CORRECCIONES


--BORRAR TABLAS TEMPORALES PARA LIBERAR ESPACIO
drop table if exists #AUX_1
drop table if exists #AUX_2
drop table if exists #AUX_3
drop table if exists #TAMAÑO
drop table if exists #TAMAÑO2
drop table if exists #marcas
drop table if exists #MI_PRIMA_SINIESTRO_MOTOR
drop table if exists #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO
drop table if exists #MI_PRIMA_SINIESTRO_MOTOR_CALIBRADO_2


/****** Checkpoint PROCESO TERMINADO ********************************************************/
INSERT INTO AUX_MOTOR_06_CHECKPOINTS VALUES('PROCESO CORRECCIONES TERMINADO', SYSDATETIME())
/****************************************************************************/

END