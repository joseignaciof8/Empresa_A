SET DEFINE OFF;
DROP MATERIALIZED VIEW SINIESTROS.VW_INTGR_SALUD_SEGURO;

CREATE MATERIALIZED VIEW SINIESTROS.VW_INTGR_SALUD_SEGURO 
TABLESPACE SINIESTROS_DATA
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH TO_DATE('25-mar-2016 08:00:00','dd-mon-yyyy hh24:mi:ss')
NEXT trunc( sysdate + 1 ) + 8/24       
WITH PRIMARY KEY
AS 
SELECT nvl( b.atdn_id_unico, a.atdn_id_unico ) atdn_id_unico, a.caso_id_caso, a.caso_id_reingreso,
          a.cssl_cantidad_diagnosticos, a.cssl_cod_diag_1_may_est,
          a.cssl_nom_diag_1_may_est, a.cssl_urg_prioridad,
          a.cssl_dias_diag_estandar, a.cssl_dias_reposo_otrg,
          a.cssl_dias_reposo_cons, a.cssl_porc_dias_cons_est,
          a.cssl_porc_dias_cons_otrg, b.atdn_fecha_admision,
          NVL (a.cssl_fecha_alta_laboral,
               TRUNC (SYSDATE)
              ) cssl_fecha_alta_laboral,
          a.cssl_fecha_cierre_denuncia_ssi, a.cssl_ind_acc_fatal,
          NVL (e.periodo, TRUNC (b.atdn_fecha_admision, 'mm')) cssl_periodo,
          e.cssl_dias_perd_periodo, a.cssl_dias_perd_denuncia,
          a.cssl_dias_perd_caso,
          CASE
             WHEN TRUNC (b.atdn_fecha_admision, 'mm') =
                    NVL (e.periodo,
                         TRUNC (b.atdn_fecha_admision, 'mm')
                        )
                THEN '1'
             ELSE '2'
          END cssl_denuncia_periodo,
          a.cssl_incapacidad
     FROM atenciones_denuncia b left join casos_salud a
          ON a.atdn_id_unico = b.atdn_id_unico
          LEFT JOIN
          (select *
            from
            (select atdn_id_unico, periodo, sum(cssl_dias_perd_periodo) cssl_dias_perd_periodo
                from
                (SELECT   d.atdn_id_unico, c.periodo,
                                COUNT (*) cssl_dias_perd_periodo
                           FROM dias_perdidos d, dim_periodos c
                          WHERE d.dspr_fecha BETWEEN TRUNC (c.periodo, 'mm')
                                                 AND LAST_DAY (c.periodo)
                       GROUP BY d.atdn_id_unico, c.periodo
                       union all
                       select atdn_id_unico, trunc(atdn_fecha_admision, 'mm'), 0
                       from atenciones_denuncia)
                       group by atdn_id_unico, periodo)) e
          ON b.atdn_id_unico = e.atdn_id_unico;

COMMENT ON MATERIALIZED VIEW SINIESTROS.VW_INTGR_SALUD_SEGURO IS 'snapshot table for snapshot SINIESTROS.VW_INTGR_SALUD_SEGURO';

CREATE INDEX SINIESTROS.MV_CSSL_CASO_IDX ON SINIESTROS.VW_INTGR_SALUD_SEGURO
(CASO_ID_CASO)
LOGGING
TABLESPACE SINIESTROS_DATA
NOPARALLEL;

CREATE INDEX SINIESTROS.MV_CSSL_PERIODO_IDX ON SINIESTROS.VW_INTGR_SALUD_SEGURO
(CSSL_PERIODO)
LOGGING
TABLESPACE SINIESTROS_DATA
NOPARALLEL;

CREATE INDEX SINIESTROS.MV_CSSL_ATDN_ID_IDX ON SINIESTROS.VW_INTGR_SALUD_SEGURO
(ATDN_ID_UNICO)
LOGGING
TABLESPACE SINIESTROS_DATA
NOPARALLEL;
