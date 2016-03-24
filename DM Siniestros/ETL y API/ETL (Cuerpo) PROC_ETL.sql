CREATE OR REPLACE PACKAGE BODY SINIESTROS.proc_etl
IS
	PROCEDURE get_dias_perd_caso
   IS
      CURSOR c_dias_perd_caso
      IS
         SELECT     caso_id_caso, caso_id_reingreso, cssl_dias_perd_denuncia,
                    SUM (cssl_dias_perd_denuncia) OVER (PARTITION BY caso_id_caso ORDER BY caso_id_reingreso)
                                                         cssl_dias_perd_caso
               FROM casos_salud
         FOR UPDATE;
   BEGIN
      FOR i IN c_dias_perd_caso
      LOOP
         UPDATE casos_salud
            SET cssl_dias_perd_caso = i.cssl_dias_perd_caso
          WHERE caso_id_caso = i.caso_id_caso
            AND caso_id_reingreso = i.caso_id_reingreso;
      END LOOP;
   END get_dias_perd_caso;

   PROCEDURE intgr_salud_etl
   IS
      v_reg            casos_salud%ROWTYPE;
      v_proc           VARCHAR2 (15);
      v_pgm            VARCHAR2 (30);
      v_seq            NUMBER;
      v_cantidad       NUMBER;
      v_commit         NUMBER;
      v_flag           BOOLEAN;
      v_caso_id_caso   casos_salud.caso_id_caso%TYPE;

      CURSOR c_casos_salud
      IS
         SELECT a.atdn_id_unico, a.cssl_cantidad_diagnosticos,
                a.cssl_cod_diag_1_may_est, a.cssl_nom_diag_1_may_est,
                a.cssl_urg_prioridad,
                CASE
                   WHEN b.tipo_accidente = 'ACC'
                      THEN a.cssl_dias_diag_estandar_acc
                   WHEN b.tipo_accidente = 'EP'
                      THEN a.cssl_dias_diag_estandar_ep
                END cssl_dias_diag_estandar,
                a.cssl_dias_reposo_otrg, a.cssl_dias_reposo_cons,
                CASE
                   WHEN b.tipo_accidente = 'ACC'
                      THEN   a.cssl_dias_reposo_cons
                           / NULLIF (a.cssl_dias_diag_estandar_acc, 0)
                   WHEN b.tipo_accidente = 'EP'
                      THEN   a.cssl_dias_reposo_cons
                           / NULLIF (a.cssl_dias_diag_estandar_ep, 0)
                END cssl_porc_dias_cons_est,
                a.cssl_porc_dias_cons_otrg, a.cssl_fecha_alta_laboral,
                NULL cssl_fecha_cierre_denuncia_ssi, a.cssl_ind_acc_fatal,
                NULL cssl_dias_perd_periodo, c.cssl_dias_perd_denuncia,
                NULL cssl_dias_perd_caso, NULL cssl_denuncia_periodo,
                CASE
                   WHEN r.rslc_porcentaje_incapacidad >= 15
                      THEN 'P'
                   WHEN c.cssl_dias_perd_denuncia IS NOT NULL
                      THEN 'T'
                   ELSE NULL
                END cssl_incapacidad,
                a.caso_id_caso, a.caso_id_reingreso
           FROM dmsalud.vw_intgr_casos_salud a
                LEFT JOIN
                (SELECT atdn_id_unico,
                        CASE
                           WHEN atdn_tipo_sancion BETWEEN 1 AND 4
                              THEN 'ACC'
                           WHEN atdn_tipo_sancion IN (5, 6)
                              THEN 'EP'
                           WHEN atdn_desc_tipo_acc IN
                                      ('Trabajo', 'Trayecto')
                              THEN 'ACC'
                           ELSE 'EP'
                        END tipo_accidente
                   FROM siniestros.atenciones_denuncia) b
                ON a.atdn_id_unico = b.atdn_id_unico
                LEFT JOIN
                (SELECT   atdn_id_unico,
                          MAX
                             (rslc_porcentaje_incapacidad
                             ) rslc_porcentaje_incapacidad
                     FROM siniestros.resoluciones
                 GROUP BY atdn_id_unico) r ON a.atdn_id_unico =
                                                              r.atdn_id_unico
                LEFT JOIN
                (SELECT   atdn_id_unico, COUNT (*) cssl_dias_perd_denuncia
                     FROM siniestros.dias_perdidos
                 GROUP BY atdn_id_unico) c ON a.atdn_id_unico =
                                                              c.atdn_id_unico
                ;
   BEGIN
      v_cantidad := 0;
      v_commit := 0;
      v_flag := TRUE;
      v_proc := 'INTGR_SALUD_ETL';
      v_pgm := 'INTGR_SALUD_ETL';
      msg.inicio_proceso (v_proc,
                          v_seq,
                          TRUNC (SYSDATE, 'DD'),
                          'Inicio normal'
                         );
      msg.inicio_pgm (v_proc, v_seq, v_pgm, 'Inicio INTGR_SALUD_ETL');

      FOR i IN c_casos_salud
      LOOP
         v_caso_id_caso := i.caso_id_caso;
         v_cantidad := v_cantidad + 1;
         v_commit := v_commit + 1;
         v_reg.atdn_id_unico := i.atdn_id_unico;
         v_reg.cssl_cantidad_diagnosticos := i.cssl_cantidad_diagnosticos;
         v_reg.cssl_cod_diag_1_may_est := i.cssl_cod_diag_1_may_est;
         v_reg.cssl_nom_diag_1_may_est := i.cssl_nom_diag_1_may_est;
         v_reg.cssl_urg_prioridad := i.cssl_urg_prioridad;
         v_reg.cssl_dias_diag_estandar := i.cssl_dias_diag_estandar;
         v_reg.cssl_dias_reposo_otrg := i.cssl_dias_reposo_otrg;
         v_reg.cssl_dias_reposo_cons := i.cssl_dias_reposo_cons;
         v_reg.cssl_porc_dias_cons_est := i.cssl_porc_dias_cons_est;
         v_reg.cssl_porc_dias_cons_otrg := i.cssl_porc_dias_cons_otrg;
         v_reg.cssl_fecha_alta_laboral := i.cssl_fecha_alta_laboral;
         v_reg.cssl_fecha_cierre_denuncia_ssi :=
                                             i.cssl_fecha_cierre_denuncia_ssi;
         v_reg.cssl_ind_acc_fatal := i.cssl_ind_acc_fatal;
         v_reg.cssl_dias_perd_periodo := i.cssl_dias_perd_periodo;
         v_reg.cssl_dias_perd_denuncia := i.cssl_dias_perd_denuncia;
         v_reg.cssl_dias_perd_caso := i.cssl_dias_perd_caso;
         v_reg.cssl_denuncia_periodo := i.cssl_denuncia_periodo;
         v_reg.cssl_incapacidad := i.cssl_incapacidad;
         v_reg.caso_id_caso := i.caso_id_caso;
         v_reg.caso_id_reingreso := i.caso_id_reingreso;

         BEGIN
            casos_salud_tab.ins_upd (v_reg);
         EXCEPTION
            WHEN OTHERS
            THEN
               msg.error (v_proc, v_seq, v_pgm);
               v_flag := FALSE;
               msg.control (v_proc,
                            v_seq,
                            v_pgm,
                            'Registro erroneo: ' || v_caso_id_caso
                           );
         END;

         IF MOD (v_commit, k_times_to_commit) = 0
         THEN
            msg.info (v_proc, v_seq, v_pgm, 'commit:' || TO_CHAR (v_commit));
            COMMIT;
         END IF;
      END LOOP;
      msg.info (v_proc,
                v_seq,
                v_pgm,
                'Registros Leidos : ' || TO_CHAR (v_cantidad)
               );
      COMMIT;
      proc_etl.get_dias_perd_caso;
      msg.termino_pgm (v_proc, v_seq, v_pgm);
      msg.termino_proceso (v_proc, v_seq, v_flag);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         msg.error (v_proc, v_seq, v_pgm);
         msg.termino_pgm (v_proc,
                          v_seq,
                          v_pgm,
                          'INTGR_SALUD = ' || v_caso_id_caso
                         );
         msg.termino_proceso (v_proc, v_seq, FALSE);
   END intgr_salud_etl;
END proc_etl;
/