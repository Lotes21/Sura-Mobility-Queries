-- DIFERENCIA PORCENTUAL DE LAS TASACIONES DESVIADAS CON RESPECTO A LAS TASACIONES "CORRECTAS" (DISMINUYEN O SE MANTIENEN)
-- De aquí nos dimos cuenta que las tasaciones tienen un error al inputarse, hay tasaciones para las mismas marcas-modelo-año que en cuanto más reciente es la póliza
-- la tasación es mayor, lo cual, no tiene sentido.
-- En adelante, se omite la variable tiempo tratando de buscar el mix de vehículos con un average. 
-- Es decir, modelos que recién entren tendrán la tasación promedio catalogada hasta el último momento, por lo que si bien su valor sube debido a pólizas más viejas
-- nos permite asociar marcas-modelo-año que estén relativamente en el mismo espectro de precio.
SELECT 
    SUM(CASE WHEN SUB_JOIN.PREV_DIFF_TASACION > 0 THEN SUB_JOIN.TASACION_NUEVO END) AS SUMA_TASACIONES_POSITIVAS,
    SUM(CASE WHEN SUB_JOIN.PREV_DIFF_TASACION <= 0 THEN SUB_JOIN.TASACION_NUEVO END) AS SUMA_TASACIONES_TOTAL,
    CAST(CAST(SUM(CASE WHEN SUB_JOIN.PREV_DIFF_TASACION > 0 THEN SUB_JOIN.TASACION_NUEVO END) AS NUMERIC)/CAST(SUM(CASE WHEN SUB_JOIN.PREV_DIFF_TASACION <= 0 THEN SUB_JOIN.TASACION_NUEVO END) AS NUMERIC) AS NUMERIC(17,2)) AS RELACION_PORCENTUAL
FROM 
(
SELECT
    LTRIM(RTRIM(SMT.MARCA)) AS MARCA_NUEVO,
    LTRIM(RTRIM(SMT.MODELO)) AS MODELO_NUEVO,
    SMT.AÑO AS YEAR_NUEVO,
    LTRIM(RTRIM(SMT.SEGMENTACION)) AS SEGMENTACION_NUEVO,
    SMT.FECHA_FIRMA_POLIZA,
    SMT.IND_RENOVACION_LLAVE_1,
    MAX(NVP.TASACION) AS TASACION_NUEVO,
    SMT.IND_RENOVACION_LLAVE_1 - LAG(SMT.IND_RENOVACION_LLAVE_1, 1, 0) OVER (PARTITION BY SMT.MARCA, SMT.MODELO, SMT.AÑO ORDER BY SMT.MARCA ASC, SMT.MODELO ASC, SMT.AÑO ASC, SMT.FECHA_FIRMA_POLIZA ASC, SMT.IND_RENOVACION_LLAVE_1 ASC) AS PREV_DIFF_IND_RENOVACION_LLAVE_1,
    MAX(NVP.TASACION) - LAG(MAX(NVP.TASACION), 1, MAX(NVP.TASACION)) OVER (PARTITION BY SMT.MARCA, SMT.MODELO, SMT.AÑO ORDER BY SMT.MARCA ASC, SMT.MODELO ASC, SMT.AÑO ASC, SMT.FECHA_FIRMA_POLIZA ASC, SMT.IND_RENOVACION_LLAVE_1 ASC) AS PREV_DIFF_TASACION
FROM REPORTES.DBO.SURA_MOVILIDAD_TRANSACCIONAL AS SMT
INNER JOIN ALMACEN_DE_DATOS.DBO.NEW_VARIABLES_MODELO_PERSONAL_2024 AS NVP
    ON SMT.NNUMDOCU = NVP.NNUMDOCU AND SMT.NNUMITEM = NVP.NNUMITEM AND SMT.FECHA_FIRMA_POLIZA = NVP.FECHA_FIRMA_POLIZA
WHERE 
    SMT.LINEA_NEGOCIO = 'PERSONAL'
    --AND VIGENTE = 1
    AND YEAR(SMT.INICIO_VIGENCIA) >= 2024
    AND (NVP.TASACION > 0)
GROUP BY SMT.MARCA, SMT.MODELO, SMT.SEGMENTACION, SMT.AÑO, SMT.FECHA_FIRMA_POLIZA, SMT.IND_RENOVACION_LLAVE_1
) AS SUB_JOIN
WHERE
    SUB_JOIN.PREV_DIFF_IND_RENOVACION_LLAVE_1 IN (0, 1)
--ORDER BY SUB_JOIN.MARCA_NUEVO ASC, SUB_JOIN.MODELO_NUEVO ASC, SUB_JOIN.YEAR_NUEVO ASC, SUB_JOIN.FECHA_FIRMA_POLIZA ASC, SUB_JOIN.IND_RENOVACION_LLAVE_2 ASC

-- TASACION Y TOTAL PRIMA POR POLIZA, SOLO ANUAL Y PERSONAL
WITH tasaciones_promedio_marca_modelo_ano AS (
SELECT
    marca,
    modelo,
    año,
    AVG(tasacion) AS tasacion_avg
FROM almacen_de_datos.dbo.new_variables_modelo_personal_2024
WHERE
    tasacion > 0
GROUP BY marca, modelo, año
)
SELECT 
    tas.tasacion_avg,
    SUM(tm.prima_emi) AS valor_prima,
    tm.nnumdocu,
    tm.nnumitem,
    tm.linea_negocio,
    tm.channel,
    tm.bu,
    tm.corredor,
    tm.tipplan,
    tm.deducible,
    tm.tipo_veh,
    tm.marca,
    tm.modelo,
    tm.nanfaveh,
    tm.region,
    tm.provincia,
    MIN(tm.per) AS primera_fecha_poliza,
    tm.nueva_renov,
    tm.region_real
FROM TRANSACCIONAL.DBO.Tablero_Motor AS tm
INNER JOIN tasaciones_promedio_marca_modelo_ano AS tas
    ON tm.marca = tas.marca AND tm.modelo = tas.modelo AND tm.nanfaveh = tas.año
WHERE
    tm.nanfaveh <> 0
GROUP BY
    tas.tasacion_avg,
    tm.nnumdocu,
    tm.nnumitem,
    tm.linea_negocio,
    tm.channel,
    tm.bu,
    tm.corredor,
    tm.tipplan,
    tm.deducible,
    tm.tipo_veh,
    tm.marca,
    tm.modelo,
    tm.nanfaveh,
    tm.region,
    tm.provincia,
    tm.nueva_renov,
    tm.region_real
HAVING
    YEAR(MIN(tm.per)) >= 2024