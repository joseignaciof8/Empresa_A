CREATE OR REPLACE PACKAGE SINIESTROS.proc_etl
IS
	   k_times_to_commit   NUMBER := 10000;

	   PROCEDURE get_dias_perd_caso;

	   PROCEDURE intgr_salud_etl;
END proc_etl;
/