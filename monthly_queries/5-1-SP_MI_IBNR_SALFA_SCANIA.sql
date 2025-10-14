USE [Transaccional]
GO
/****** Object:  StoredProcedure [dbo].[SP_MI_IBNR_SALFA_SCANIA]    Script Date: 14-10-2025 10:27:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER  PROCEDURE [dbo].[SP_MI_IBNR_SALFA_SCANIA](
	@mes_cierre_fecha AS DATE
)
AS
-- En caso de ejecutar manualmente:
-- Ejecutar SP con fecha de ultimo mes de cierre, Ej: Durante el cierre de septiembre corrido los primeros dias de octubre, se ejecuta con fecha '2023-09-30'

-- exec [dbo].[SP_MI_IBNR_SALFA_SCANIA] @mes_cierre_fecha
-- EJEMPLO: exec [dbo].[SP_MI_IBNR_SALFA_SCANIA] '2023-09-30'

--declare 
--	@mes_cierre_fecha date = '2023-09-30';
BEGIN

	declare 
		@mes_cierre int = YEAR(@mes_cierre_fecha)*100+MONTH(@mes_cierre_fecha),
		@mes_cierre_1 int = YEAR(DATEADD(month, -1, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -1, @mes_cierre_fecha)),
		@mes_cierre_2 int = YEAR(DATEADD(month, -2, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -2, @mes_cierre_fecha)),
		@mes_cierre_3 int = YEAR(DATEADD(month, -3, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -3, @mes_cierre_fecha)),
		@mes_cierre_4 int = YEAR(DATEADD(month, -4, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -4, @mes_cierre_fecha)),
		@mes_cierre_5 int = YEAR(DATEADD(month, -5, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -5, @mes_cierre_fecha)),
		@mes_cierre_6 int = YEAR(DATEADD(month, -6, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -6, @mes_cierre_fecha)),
		@mes_cierre_7 int = YEAR(DATEADD(month, -7, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -7, @mes_cierre_fecha)),
		@mes_cierre_8 int = YEAR(DATEADD(month, -8, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -8, @mes_cierre_fecha)),
		@mes_cierre_9 int = YEAR(DATEADD(month, -9, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -9, @mes_cierre_fecha)),
		@mes_cierre_10 int = YEAR(DATEADD(month, -10, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -10, @mes_cierre_fecha)),
		@mes_cierre_11 int = YEAR(DATEADD(month, -11, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -11, @mes_cierre_fecha)),
		@mes_cierre_12 int = YEAR(DATEADD(month, -12, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -12, @mes_cierre_fecha)),
		@mes_cierre_13 int = YEAR(DATEADD(month, -13, @mes_cierre_fecha))*100+MONTH(DATEADD(month, -13, @mes_cierre_fecha))

	update [SGF1025].REPORTES.dbo.MI_PRIMA_SINIESTRO_MOTOR
	SET 
	ULT_DP=(PAGO_DP+reserva_dp) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	ULT_PT=(PAGO_PT+reserva_PT) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	ULT_ROBO=(PAGO_ROBO+reserva_robo) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	ULT_rc=(PAGO_rc+reserva_rc) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	ULT_DP_P=(PAGO_DP_P+reserva_dp_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	ULT_PT_P=(PAGO_PT_P+reserva_PT_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	ULT_ROBO_P=(PAGO_ROBO_P+reserva_robo_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	ULT_rc_P=(PAGO_rc_P+reserva_rc_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 1.07
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.33
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.63
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 1.79
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 1.41
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 1.50
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 2.47
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.61
		else 1 end,

	CANT_ULT_DP=(CANT_DP) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.993
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.008
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.063
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.992
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.831
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.838
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.881
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.208
		else 1 end,

	CANT_ULT_PT=(CANT_pt) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.993
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.008
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.063
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.992
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.831
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.838
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.881
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.208
		else 1 end,

	CANT_ULT_ROBO=(CANT_ROBO) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.993
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.008
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.063
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.992
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.831
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.838
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.881
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.208
		else 1 end,

	CANT_ULT_RC=(CANT_RC) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.993
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 1.008
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 1.063
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.992
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.831
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.838
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.881
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 1.208
		else 1 end
	WHERE contratante=76574810 and corredor like 'Arth%'
	--


	update [SGF1025].REPORTES.dbo.MI_PRIMA_SINIESTRO_MOTOR
	SET 
		CANTIDAD_ULT = CANT_ULT_DP + CANT_ULT_PT + CANT_ULT_ROBO + CANT_ULT_RC,
		ULT_TOTAL = ULT_DP + ULT_PT + ULT_ROBO + ULT_rc,
		ULT_TOTAL_P = ULT_DP_P + ULT_PT_P + ULT_ROBO_P + ULT_rc_P
	WHERE contratante=76574810 and corredor like 'Arth%'
	--

	update [SGF1025].REPORTES.dbo.MI_PRIMA_SINIESTRO_MOTOR
	SET
		CANT_IBNR_DP = CANT_ULT_DP - CANT_DP,
		CANT_IBNR_PT = CANT_ULT_PT- CANT_PT,
		CANT_IBNR_ROBO = CANT_ULT_ROBO- CANT_ROBO,
		CANT_IBNR_RC = CANT_ULT_RC - CANT_RC,
	
		IBNR_DP = ULT_DP-(PAGO_DP+reserva_dp),
		IBNR_PT =ULT_PT-(PAGO_PT+reserva_PT),
		IBNR_ROBO =ULT_ROBO-(PAGO_ROBO+reserva_robo),
		IBNR_RC = ULT_rc-(PAGO_rc+reserva_rc),

		IBNR_DP_P = ULT_DP_P-(PAGO_DP_P+reserva_dp_P),
		IBNR_PT_P =ULT_PT_P-(PAGO_PT_P+reserva_PT_P),
		IBNR_ROBO_P =ULT_ROBO_P-(PAGO_ROBO_P+reserva_robo_P),
		IBNR_RC_P = ULT_rc_P-(PAGO_rc_P+reserva_rc_P)
	WHERE contratante=76574810 and corredor like 'Arth%'
	--

	------------------------------------------ hasta aca actualizo el IBNR SALFA  ---------------------------------------------------------------


	update [SGF1025].REPORTES.dbo.MI_PRIMA_SINIESTRO_MOTOR
	SET 
	ULT_DP=(PAGO_DP+reserva_dp) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end,

	ULT_PT=(PAGO_PT+reserva_PT) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end,

	ULT_ROBO=(PAGO_ROBO+reserva_ROBO) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end,

	ULT_RC=(PAGO_RC+reserva_RC) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end,

	ULT_DP_P=(PAGO_DP_P+reserva_dp_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end,

	ULT_PT_P=(PAGO_PT_P+reserva_PT_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end,

	ULT_ROBO_P=(PAGO_ROBO_P+reserva_ROBO_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end,

	ULT_RC_P=(PAGO_RC_P+reserva_RC_P) * case 
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_13 THEN 0.9813
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_12 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_11 THEN 0.9948
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_10 THEN 0.9972
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_9 THEN 0.9975
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_8 THEN 0.9936
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_7 THEN 0.9737
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_6 THEN 0.9680
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_5 THEN 0.9588
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_4 THEN 0.9556
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_3 THEN 0.9412
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_2 THEN 0.9166
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre_1 THEN 0.8890
		when YEAR(PER)*100+MONTH(PER) = @mes_cierre THEN 0.8541
		else 1 end
	WHERE contratante=91502000
	--

	update [SGF1025].REPORTES.dbo.MI_PRIMA_SINIESTRO_MOTOR
	SET 
		CANTIDAD_ULT = CANT_ULT_DP + CANT_ULT_PT + CANT_ULT_ROBO + CANT_ULT_RC,
		ULT_TOTAL = ULT_DP + ULT_PT + ULT_ROBO + ULT_rc,
		ULT_TOTAL_P = ULT_DP_P + ULT_PT_P + ULT_ROBO_P + ULT_rc_P
	WHERE contratante=91502000
	--

	update [SGF1025].REPORTES.dbo.MI_PRIMA_SINIESTRO_MOTOR
	SET
		CANT_IBNR_DP = CANT_ULT_DP - CANT_DP,
		CANT_IBNR_PT = CANT_ULT_PT- CANT_PT,
		CANT_IBNR_ROBO = CANT_ULT_ROBO- CANT_ROBO,
		CANT_IBNR_RC = CANT_ULT_RC - CANT_RC,

		IBNR_DP = ULT_DP-(PAGO_DP+reserva_dp),
		IBNR_PT = ULT_PT-(PAGO_PT+reserva_PT),
		IBNR_ROBO = ULT_ROBO-(PAGO_ROBO+reserva_robo),
		IBNR_RC = ULT_rc-(PAGO_rc+reserva_rc),

		IBNR_DP_P = ULT_DP_P-(PAGO_DP_P+reserva_dp_P),
		IBNR_PT_P = ULT_PT_P-(PAGO_PT_P+reserva_PT_P),
		IBNR_ROBO_P = ULT_ROBO_P-(PAGO_ROBO_P+reserva_robo_P),
		IBNR_RC_P = ULT_rc_P-(PAGO_rc_P+reserva_rc_P)
	WHERE contratante=91502000
	--

END
