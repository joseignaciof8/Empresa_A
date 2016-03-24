CREATE OR REPLACE VIEW VW_INTGR_DIAGNOSTICOS_DETALLE
(CASO_ID_CASO, CASO_ID_REINGRESO, DGCS_LATERALIDAD, DGCS_IND_LEY, DGCS_IND_GES, 
 DGCS_FECHA_DIAGNOSTICO, DGCS_FECHA_MODIFICACION, DGCS_ESTADO_DIAGNOSTICO, DGCS_IND_PRINCIPAL, DGCS_EDAD_PACIENTE, 
 DIAG_DIAGNOSTICO, DIAG_COD_FAMILIA, DIAG_FAMILIA, DIAG_ESTANDAR_ACC, DIAG_ESTANDAR_EP, 
 DIAG_IND_LATERALIDAD, DIAG_IND_LEY, DIAG_IND_GRAVEDAD, DIAG_COD_PARTE_CUERPO, DIAG_PARTE_CUERPO_AFECTADA, 
 DIAG_DIAG_CIE10, DGNC_CODIGO_CIE10, DGNC_DESCRIPCION)
AS 
select a.caso_id_caso, a.caso_id_reingreso, a.dgcs_lateralidad, a.dgcs_ind_ley, a.dgcs_ind_ges
, a.dgcs_fecha_diagnostico, a.dgcs_fecha_modificacion, a.dgcs_estado_diagnostico, a.dgcs_ind_principal
, a.dgcs_edad_paciente, b.diag_diagnostico, b.diag_cod_familia, b.diag_familia, b.diag_estandar_acc
, b.diag_estandar_ep, b.diag_ind_lateralidad, b.diag_ind_ley, b.diag_ind_gravedad, b.diag_cod_parte_cuerpo
, b.diag_parte_cuerpo_afectada, b.diag_diag_cie10, c.DGNC_CODIGO_CIE10, c.dgnc_descripcion
from dmsalud.diag_casos a, dmsalud.diagnosticos b, dmsalud.diagnosticos_cie10 c
where a.empr_id_empresa = b.empr_id_empresa
and a.diag_id_diagnostico = b.diag_id_diagnostico
and b.diag_cod_cie10 = c.dgnc_codigo_cie10
/

