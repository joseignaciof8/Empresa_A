CREATE OR REPLACE package SINIESTROS.CASOS_SALUD_TAB is
/*
Proyecto: Integracion Salud - Seguro
Objetivo: Procedimientos API tabla CASOS_SALUD
Dependiencias:

Historia
========
20160310 JFO Creación
*/


subtype rec_CASOS_SALUD is CASOS_SALUD%rowtype;
type    tab_CASOS_SALUD is table of rec_CASOS_SALUD index by binary_integer;
type    cursor_CASOS_SALUD is ref cursor return CASOS_SALUD%rowtype;


/* Consulta el registro de CASOS_SALUD basado en la PK */
function qry( 
    p_caso_id_caso CASOS_SALUD.caso_id_caso%type
) return rec_CASOS_SALUD;


/* Inserta un registro de CASOS_SALUD */
procedure ins(
    p_reg rec_CASOS_SALUD
);


/* Actualiza un registro de CASOS_SALUD en función de la PK */
procedure upd( 
    p_caso_id_caso CASOS_SALUD.caso_id_caso%type
, p_reg rec_CASOS_SALUD
);


/* Inserta sino actualiza un registro de CASOS_SALUD en función de la PK */
procedure ins_upd(
    p_reg rec_CASOS_SALUD
);


/* Elimina un registro de CASOS_SALUD en función de la PK */
procedure del( 
    p_caso_id_caso CASOS_SALUD.caso_id_caso%type
);


end CASOS_SALUD_TAB;
/