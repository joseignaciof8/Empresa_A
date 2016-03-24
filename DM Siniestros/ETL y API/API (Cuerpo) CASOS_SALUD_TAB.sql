CREATE OR REPLACE package body SINIESTROS.CASOS_SALUD_TAB is
/*
Proyecto: Integracion Salud - Seguro
Objetivo: Procedimientos API tabla CASOS_SALUD
Dependiencias:

Historia
========
20160310 JFO Creación
*/




/* Proceso de inserción. CASOS_SALUD */
procedure inserta(
    p_reg rec_CASOS_SALUD
) is
begin
    insert into CASOS_SALUD(
        atdn_id_unico
    , cssl_cantidad_diagnosticos
    , cssl_cod_diag_1_may_est
    , cssl_nom_diag_1_may_est
    , cssl_urg_prioridad
    , cssl_dias_diag_estandar
    , cssl_dias_reposo_otrg
    , cssl_dias_reposo_cons
    , cssl_porc_dias_cons_est
    , cssl_porc_dias_cons_otrg
    , cssl_fecha_alta_laboral
    , cssl_fecha_cierre_denuncia_ssi
    , cssl_ind_acc_fatal
    , cssl_dias_perd_periodo
    , cssl_dias_perd_denuncia
    , cssl_dias_perd_caso
    , cssl_denuncia_periodo
    , cssl_incapacidad
    , caso_id_caso
    , caso_id_reingreso
    ) 
    values(
        p_reg.atdn_id_unico
    , p_reg.cssl_cantidad_diagnosticos
    , p_reg.cssl_cod_diag_1_may_est
    , p_reg.cssl_nom_diag_1_may_est
    , p_reg.cssl_urg_prioridad
    , p_reg.cssl_dias_diag_estandar
    , p_reg.cssl_dias_reposo_otrg
    , p_reg.cssl_dias_reposo_cons
    , p_reg.cssl_porc_dias_cons_est
    , p_reg.cssl_porc_dias_cons_otrg
    , p_reg.cssl_fecha_alta_laboral
    , p_reg.cssl_fecha_cierre_denuncia_ssi
    , p_reg.cssl_ind_acc_fatal
    , p_reg.cssl_dias_perd_periodo
    , p_reg.cssl_dias_perd_denuncia
    , p_reg.cssl_dias_perd_caso
    , p_reg.cssl_denuncia_periodo
    , p_reg.cssl_incapacidad
    , p_reg.caso_id_caso
    , p_reg.caso_id_reingreso
    );
    

end;


/* Consulta el registro de CASOS_SALUD basado en la PK */
function qry( 
p_caso_id_caso CASOS_SALUD.caso_id_caso%type
) return rec_CASOS_SALUD is
v_CASOS_SALUD rec_CASOS_SALUD;
begin
select * into v_CASOS_SALUD from CASOS_SALUD
where  caso_id_caso =  p_caso_id_caso;


return v_CASOS_SALUD;


exception
when no_data_found then
    raise_application_error( -20100, 'registro CASOS_SALUD no encontrado!' );
end;


/* Inserta un registro de CASOS_SALUD */
procedure ins(
p_reg rec_CASOS_SALUD
) is
begin
/* Insertar registro de CASOS_SALUD */
inserta( p_reg );


exception
when others then
    raise;
end;


/* Actualiza un registro de CASOS_SALUD en función de la PK */
procedure upd( 
p_caso_id_caso CASOS_SALUD.caso_id_caso%type
, p_reg rec_CASOS_SALUD
) is 
begin
update CASOS_SALUD
set    atdn_id_unico = p_reg.atdn_id_unico
       , cssl_cantidad_diagnosticos = p_reg.cssl_cantidad_diagnosticos
       , cssl_cod_diag_1_may_est = p_reg.cssl_cod_diag_1_may_est
       , cssl_nom_diag_1_may_est = p_reg.cssl_nom_diag_1_may_est
       , cssl_urg_prioridad = p_reg.cssl_urg_prioridad
       , cssl_dias_diag_estandar = p_reg.cssl_dias_diag_estandar
       , cssl_dias_reposo_otrg = p_reg.cssl_dias_reposo_otrg
       , cssl_dias_reposo_cons = p_reg.cssl_dias_reposo_cons
       , cssl_porc_dias_cons_est = p_reg.cssl_porc_dias_cons_est
       , cssl_porc_dias_cons_otrg = p_reg.cssl_porc_dias_cons_otrg
       , cssl_fecha_alta_laboral = p_reg.cssl_fecha_alta_laboral
       , cssl_fecha_cierre_denuncia_ssi = p_reg.cssl_fecha_cierre_denuncia_ssi
       , cssl_ind_acc_fatal = p_reg.cssl_ind_acc_fatal
       , cssl_dias_perd_periodo = p_reg.cssl_dias_perd_periodo
       , cssl_dias_perd_denuncia = p_reg.cssl_dias_perd_denuncia
       , cssl_dias_perd_caso = p_reg.cssl_dias_perd_caso
       , cssl_denuncia_periodo = p_reg.cssl_denuncia_periodo
       , cssl_incapacidad = p_reg.cssl_incapacidad
       , caso_id_reingreso = p_reg.caso_id_reingreso
where  caso_id_caso = p_reg.caso_id_caso;


exception
when others then
    raise;
end;


/* Inserta sino actualiza un registro de CASOS_SALUD en función de la PK */
procedure ins_upd(
p_reg rec_CASOS_SALUD
) is
begin
/* Insertar registro de CASOS_SALUD */
inserta( p_reg );


exception
when dup_val_on_index then
    /* Actualizar registro de CASOS_SALUD en función de la PK */
    upd( 
        p_reg.caso_id_caso
    , p_reg
    );
    

when others then
    raise;
end;


/* Elimina un registro de CASOS_SALUD en función de la PK */
procedure del( 
p_caso_id_caso CASOS_SALUD.caso_id_caso%type
) is
begin
delete from CASOS_SALUD
where  caso_id_caso =  p_caso_id_caso;


exception
when others then
    RAISE_APPLICATION_ERROR( -20110, 'Imposible eliminar el registro' );
end;




end CASOS_SALUD_TAB;
/