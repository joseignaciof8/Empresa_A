CREATE OR REPLACE VIEW VW_INTGR_CASOS_SALUD
(ATDN_ID_UNICO, CASO_ID_CASO, CASO_ID_REINGRESO, CSSL_CANTIDAD_DIAGNOSTICOS, CSSL_COD_DIAG_1_MAY_EST, 
 CSSL_NOM_DIAG_1_MAY_EST, CSSL_URG_PRIORIDAD, CSSL_DIAS_DIAG_ESTANDAR_ACC, CSSL_DIAS_DIAG_ESTANDAR_EP, CSSL_DIAS_REPOSO_OTRG, 
 CSSL_DIAS_REPOSO_CONS, CSSL_PORC_DIAS_CONS_EST_ACC, CSSL_PORC_DIAS_CONS_EST_EP, CSSL_PORC_DIAS_CONS_OTRG, CSSL_FECHA_ALTA_LABORAL, 
 CSSL_FECHA_CIERRE_DENUNCIA_SSI, CSSL_IND_ACC_FATAL, CSSL_DIAS_PERD_PERIODO, CSSL_DIAS_PERD_DENUNCIA, CSSL_DIAS_PERD_CASO, 
 CSSL_DENUNCIA_PERIODO, CSSL_INCAPACIDAD, CSSL_FECHA_APERTURA)
AS 
SELECT a.caso_num_siniestro, a.caso_id_caso, a.caso_id_reingreso, a.caso_cantidad_diagnosticos,
          a.caso_cod_diag_1_may_est, a.caso_nom_diag_1_may_est,
          a.caso_urg_prioridad, b.diag_estandar_acc, b.diag_estandar_ep,
          a.caso_dias_reposo_otorgados,
          a.caso_dias_reposo_consumidos,
            a.caso_dias_reposo_consumidos
          / NULLIF (b.diag_estandar_acc, 0) cssl_porc_dias_cons_est_acc,
            a.caso_dias_reposo_consumidos
          / NULLIF (b.diag_estandar_ep, 0) cssl_porc_dias_cons_est_ep,
            a.caso_dias_reposo_consumidos
          / NULLIF (a.caso_dias_reposo_otorgados, 0) cssl_porc_dias_cons_otrg,
          f.alla_fecha_alta_laboral, NULL cssl_fecha_cierre_denuncia_ssi,
          CASE
             WHEN a.caso_tipo_cierre IN
                            ('FALLEC', 'MFAENA', 'MTRAY')
                THEN 'S'
             ELSE 'N'
          END cssl_ind_acc_fatal,
          NULL cssl_dias_perd_periodo, NULL cssl_dias_perd_denuncia,
          NULL cssl_dias_perd_caso, NULL cssl_denuncia_periodo,
          NULL cssl_incapacidad, a.caso_fecha_ingreso
     FROM casos a LEFT JOIN diagnosticos b
          ON a.caso_cod_diag_1_may_est = b.diag_id_diagnostico
        AND a.empr_id_empresa = b.empr_id_empresa
          LEFT JOIN
          (SELECT alla_fecha_alta_laboral, caso_id_caso, empr_id_empresa,
                  caso_id_reingreso
             FROM altas_laborales d
            WHERE TO_NUMBER (   TO_CHAR (d.alla_fecha_alta_laboral,
                                         'yyyymmdd')
                             || LPAD (d.alla_id_alta_laboral, 10, '0')
                            ) =
                     (SELECT MAX
                                (TO_NUMBER
                                        (   TO_CHAR
                                                   (e.alla_fecha_alta_laboral,
                                                    'yyyymmdd'
                                                   )
                                         || LPAD (e.alla_id_alta_laboral,
                                                  10,
                                                  '0'
                                                 )
                                        )
                                )
                        FROM altas_laborales e
                       WHERE d.caso_id_caso = e.caso_id_caso
                         AND d.caso_id_reingreso = e.caso_id_reingreso
                         AND d.empr_id_empresa = e.empr_id_empresa)) f
          ON f.caso_id_caso = a.caso_id_caso
        AND f.empr_id_empresa = a.empr_id_empresa
        AND f.caso_id_reingreso = a.caso_id_reingreso
    WHERE a.caso_tipo_paciente = 'LEY' AND a.caso_num_siniestro IS NOT NULL
/

