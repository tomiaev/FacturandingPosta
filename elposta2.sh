#!/bin/sh

#consultar datos necesarios
echo 'Introducir BA a facturar:'
read BA
echo 'Introducir fecha AAAAMMDD:' 
read fecha
echo
echo "BA" $BA 
echo "fecha" $fecha
#unset fixeddate
echo
unset GENEVA_FIXEDDATE 
echo
#BajarProcesos
echo "                              Matando DCONFIG. . ."
dconfigadmin -H $HOSTNAME

#killall TM
echo "                              Matando TM. . ."
killall TM

#Descomentar la SYSdateOverride
sqlplus $DATABASE << END
	update gparams set name='SYSdateOverride' where name = '#SYSdateOverride';
	update gparams set name='#SYSdateValue' where name = 'SYSdateValue'; 	
	quit
    exit
END


#FECHAAA
export GENEVA_FIXEDDATE=''$fecha' 10000000' 
echo $GENEVA_FIXEDDATE 
#LevantarProcesos
echo "                              Levantando DCONFIG. . ."
nohup DConfigAgent &
sleep 1
echo "                              Levantando los SITTER. . . "
sitter -N RBMPROD -s BG_1
sitter -N RBMPROD -s BG_2
sitter -N RBMPROD -s BG_3 
sitter -N RBMPROD -s BC 
sitter -N RBMPROD -s FID 
sitter -N RBMPROD -s FID.GSM 
sitter -N RBMPROD -s FID.SMSC 
sitter -N RBMPROD -s FID.GRE 
sitter -N RBMPROD -s RMFP_1 
sitter -N RBMPROD -s RMFP_2 
sitter -N RBMPROD -s RMFP_3 
sitter -N RBMPROD -s RMFP_4 
sitter -N RBMPROD -s RMFP_5 
sitter -N RBMPROD -s RMFP_6 
sitter -N RBMPROD -s RMFP_7 
sitter -N RBMPROD -s RMFP_8 
sitter -N RBMPROD -s RMFP_9 
sitter -N RBMPROD -s RMFP_10 
sitter -N RBMPROD -s RMFP_11 
sitter -N RBMPROD -s RMFP_12 
sitter -N RBMPROD -s RMFP_13 
sitter -N RBMPROD -s RMFP_14 
sitter -N RBMPROD -s RMFP_15 
sitter -N RBMPROD -s CEU_01 
sitter -N RBMPROD -s CEU_02 
sitter -N RBMPROD -s CEU_03 
sitter -N RBMPROD -s CEU_04 
sitter -N RBMPROD -s CEU_05 
sitter -N RBMPROD -s RRR_1 
sitter -N RBMPROD -s RRR_2 
sitter -N RBMPROD -s RRR_3 
sitter -N RBMPROD -s RRR_4 
sitter -N RBMPROD -s RRR_5 
sitter -N RBMPROD -s RJR_1 
sitter -N RBMPROD -s RJR_2 
sitter -N RBMPROD -s DUM 
sitter -N RBMPROD -s COA0 
sitter -N RBMPROD -s ODD 
sitter -N RBMPROD -s GOMP 
sitter -N RBMPROD -s EXP 
sitter -N RBMPROD -s CCELoader 
sitter -N RBMPROD -s CASP 
echo
#sleep 2
echo "                              Levantando TM"
TM -u geneva_admin -p M3ch4_A_4su@$ORACLE_SID &
echo
sleep 0.5
#BG
echo "                              Ejecutando BG. . . "
BG -a "-a "$BA""
echo
sleep 0.5
#BDW y consulta para conseguir el bill_style_id 
echo "                              Ejecutando BDW. . . "

formatter=$(sqlplus -s $DATABASE <<END
       set pagesize 0 feedback off verify off heading off echo off;
       select bill_style_id from AccountDetails where account_num = '$BA' and end_dat is null;
       exit;
END
)
sleep 0.5
#BDW  consulta para conseguir el bill_style_id 

#billcycle=$(sqlplus -s $DATABASE <<END
#       set pagesize 0 feedback off verify off heading off echo off;
#       select BILL_CYCLE from accountattributes where account_num IN ('$BA');
#       exit;
#END
#)
#sleep 0.5
#BDW y consulta para conseguir el bill_style_id 


#echo
#echo "El billcyle es: $billcycle"
#echo

#Borra los espacios
formatter=$(echo $formatter | tr -d ' ')
#billcyle=$(echo $billcycle | tr -d ' ')

BDW -a " -formatterID $formatter -bill "
#BDW -a " -formatterID $formatter -bill -aattr BILL_CYCLE=$billcyle" & 
#echo El valor de formater es $formatter
echo
sleep 1

#BDW -a "-formatterID 1 -bill -aattr BILL_CYCLE=04" > BDW_23547306_1.LOG & Version que dio Kiriti, aparentemente debe ser así la llamada. con el cycle


#Provisto por Kiriti, para actualizar la tabla de job antes del MFM. 
sqlplus $DATABASE << END
	update job set job_status=2 where job_status=1 and job_type_id=28;      
	quit
  	exit
END
#sleep 2
#BFM 
echo "                              Ejecutando BFM. . . "
MFM -a "-plugInPath $INFINYS_ROOT/RB/lib/libGnvJIBP.so" &
echo


echo "                              Comentariando Fechas. . ."
unset GENEVA_FIXEDDATE 

echo "                              Matando DCONFIG. . ."
dconfigadmin -H $HOSTNAME
sleep 0.5
#killall TM
echo "                              Matando TM. . ."
killall TM


sqlplus $DATABASE << END
	update gparams set name='#SYSdateOverride' where name = 'SYSdateOverride';      
	quit
    	exit
END
sleep 0.5
#LevantarProcesos
echo "                              Levantando DCONFIG. . ."
nohup DConfigAgent &
sleep 0.5
echo "                              Levantando los SITTER. . . "
sitter -N RBMPROD -s BG_1
sitter -N RBMPROD -s BG_2
sitter -N RBMPROD -s BG_3 
sitter -N RBMPROD -s BC 
sitter -N RBMPROD -s FID 
sitter -N RBMPROD -s FID.GSM 
sitter -N RBMPROD -s FID.SMSC 
sitter -N RBMPROD -s FID.GRE 
sitter -N RBMPROD -s RMFP_1 
sitter -N RBMPROD -s RMFP_2 
sitter -N RBMPROD -s RMFP_3 
sitter -N RBMPROD -s RMFP_4 
sitter -N RBMPROD -s RMFP_5 
sitter -N RBMPROD -s RMFP_6 
sitter -N RBMPROD -s RMFP_7 
sitter -N RBMPROD -s RMFP_8 
sitter -N RBMPROD -s RMFP_9 
sitter -N RBMPROD -s RMFP_10 
sitter -N RBMPROD -s RMFP_11 
sitter -N RBMPROD -s RMFP_12 
sitter -N RBMPROD -s RMFP_13 
sitter -N RBMPROD -s RMFP_14 
sitter -N RBMPROD -s RMFP_15 
sitter -N RBMPROD -s CEU_01 
sitter -N RBMPROD -s CEU_02 
sitter -N RBMPROD -s CEU_03 
sitter -N RBMPROD -s CEU_04 
sitter -N RBMPROD -s CEU_05 
sitter -N RBMPROD -s RRR_1 
sitter -N RBMPROD -s RRR_2 
sitter -N RBMPROD -s RRR_3 
sitter -N RBMPROD -s RRR_4 
sitter -N RBMPROD -s RRR_5 
sitter -N RBMPROD -s RJR_1 
sitter -N RBMPROD -s RJR_2 
sitter -N RBMPROD -s DUM 
sitter -N RBMPROD -s COA0 
sitter -N RBMPROD -s ODD 
sitter -N RBMPROD -s GOMP 
sitter -N RBMPROD -s EXP 
sitter -N RBMPROD -s CCELoader 
sitter -N RBMPROD -s CASP 
echo
sleep 0.5
echo "                              Levantando TM"
TM -u geneva_admin -p M3ch4_A_4su@$ORACLE_SID &
echo


echo "                              PROCESO FINALIZADO!"



