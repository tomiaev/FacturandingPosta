#!/bin/sh

#consultar datos necesarios
echo 'Introducir BA a facturar:'
read BA

if [ -d /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMOutputDir ];
then
echo "Existe /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMOutputDir"
else
mkdir /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMOutputDir
chmod 777 /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMOutputDir
echo "Creado /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMOutputDir"
fi

if [ -d /u02/netcracker/rbm/infinys_root/RBM_int/RFU/RFUInputDir ];
then
echo "Existe /u02/netcracker/rbm/infinys_root/RBM_int/RFU/RFUInputDir"
else
mkdir /u02/netcracker/rbm/infinys_root/RBM_int/RFU/RFUInputDir
chmod 777 /u02/netcracker/rbm/infinys_root/RBM_int/RFU/RFUInputDir
echo "Creado /u02/netcracker/rbm/infinys_root/RBM_int/RFU/RFUInputDir"
fi

if [ -d /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMWorkDir ];
then
echo "Existe /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMWorkDir"
else
mkdir /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMWorkDir
chmod 777 /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMWorkDir
echo "Creado /u02/netcracker/rbm/infinys_root/RBM_custom/BFM/BFMWorkDir"
fi

if [ -d /u02/netcracker/rbm/infinys_root/RBM_custom/PDI/PDIOutputDir ];
then
echo "Existe /u02/netcracker/rbm/infinys_root/RBM_custom/PDI/PDIOutputDir"
else
mkdir /u02/netcracker/rbm/infinys_root/RBM_custom/PDI/PDIOutputDir
chmod 777 /u02/netcracker/rbm/infinys_root/RBM_custom/PDI/PDIOutputDir
echo "Creado /u02/netcracker/rbm/infinys_root/RBM_custom/PDI/PDIOutputDir"
fi

chmod -R ugo+rwx /u02/netcracker/rbm/infinys_root/RBM_custom/PDI
chmod -R ugo+rwx /u02/netcracker/rbm/infinys_root/RBM_custom/BPP


fechaa=$(sqlplus -s $DATABASE <<END
       set pagesize 0 feedback off verify off heading off echo off;
       select next_bill_dtm from account where account_num = '$BA';
       exit;
END
)

date=`date -d "${fechaa}" '+%Y%m%d'`

echo
echo "BA" $BA 
echo "fecha" $date
#unset fixeddate
echo
unset GENEVA_FIXEDDATE 
echo
#BajarProcesos
echo "                                                         ***Matando DCONFIG***"
dconfigadmin -H $HOSTNAME
#killall TM
echo "                                                         ***Matando TM***"
killall TM
#Descomentar la SYSdateOverride
sqlplus $DATABASE << END
	update gparams set name='SYSdateOverride' where name = '#SYSdateOverride';
	update gparams set name='#SYSdateValue' where name = 'SYSdateValue'; 	
	quit
    exit
END

#FECHAAA
export GENEVA_FIXEDDATE=''$date' 10000000' 
echo $GENEVA_FIXEDDATE 
#LevantarProcesos
echo "                                                         ***Levantando DCONFIG***"
nohup DConfigAgent &
sleep 0.5
echo "                                                         ***Levantando los SITTER*** "
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
echo "                                                         ***Levantando TM***"
TM -u geneva_admin -p M3ch4_A_4su@$ORACLE_SID &
echo
sleep 0.5
#BG
echo "                                                         ***Ejecutando BG*** "

BG -a "-a "$BA""
echo
#sleep 0.5
#BDW y consulta para conseguir el bill_style_id 
echo "                                                         ***Ejecutando BDW*** "

formatter=$(sqlplus -s $DATABASE <<END
       set pagesize 0 feedback off verify off heading off echo off;
       select bill_style_id from AccountDetails where account_num = '$BA' and end_dat is null;
       exit;
END
)
#sleep 0.5
#BDW  consulta para conseguir el bill_style_id 

billcycle=$(sqlplus -s $DATABASE <<END
       set pagesize 0 feedback off verify off heading off echo off;
       select BILL_CYCLE from accountattributes where account_num IN ('$BA');
       exit;
END
)
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
#sleep 1

#BDW -a "-formatterID 1 -bill -aattr BILL_CYCLE=04" > BDW_23547306_1.LOG & Version que dio Kiriti, aparentemente debe ser así la llamada. con el cycle

#Provisto por Kiriti, para actualizar la tabla de job antes del MFM. 
sqlplus $DATABASE << END
	update job set job_status=2 where job_status=1 and job_type_id=28;      
	quit
  	exit
END
#sleep 2

#MFM 
echo "                                                         ***Ejecutando MFM*** "
MFM -a "-plugInPath $INFINYS_ROOT/RB/lib/libGnvJIBP.so" &
echo

#BILL CYCLE 
billcyle=$(echo $billcycle | tr -d ' ')

#BFM
echo "                                                         ***Corriendo BFM***"
BFM -a "-billCycle $billcycle"

#VARIABLE FECHA y crear archivo
len=${#date}
echo "Length" $len
dat=${date:6:8}
echo "date" $date
yr=${date:0:4}
echo "year" $yr
mon=${date:4:6}
mon=${mon:0:2}
var01="JAN"
var02="FEB"
var03="MAR"
var04="APR"
var05="MAY"
var06="JUN"
var07="JUL"
var08="AUG"
var09="SEP"
var10="OCT"
var11="NOV"
var12="DEC"
val=$( eval eval echo \$var$mon )
fechames="$dat-$val-$yr"
mesanio="$mon$yr"

#testigos
echo "fechames "$fechames
echo "mesanio "$mesanio

findearchivo=000000.txt
nombrearchivo=$(sqlplus -s $DATABASE << END
set pagesize 0 feedback off verify off heading off echo off;
select distinct 'DGI'||substr(fa.DGI_INPUT_FILE_NAME,1,16)||'_$mesanio$findearchivo' as nombreArchivoRespDGI
from billsummary bs, TFNU_DGIRBMINVOICEVALUE iv,TFNU_DGIRBMINVOICEKEY ik,TFNU_DGIFILEAUDIT fa
where bs.bill_status=1
and bs.bill_dtm='$fechames'
and bs.account_num=iv.account_num
and bs.bill_seq=iv.rbm_bill_seq
and bs.bill_version=iv.rbm_bill_version
and bs.account_num=ik.account_num
and bs.bill_seq=ik.rbm_bill_seq
and bs.bill_version=ik.rbm_bill_version
and ik.dgi_file_seq=fa.dgi_file_seq
and iv.account_num like '%$BA%'
order by nombreArchivoRespDGI;
exit;
END
)

sqlplus -s $DATABASE << EOF
SPOOL /u02/netcracker/rbm/infinys_root/RBM_int/RFU/RFUInputDir/$nombrearchivo
set heading off;
set echo off;
SET LINESIZE 192
select ik.RBM_INVOICE_NUM||'-'||ik.RBM_INV_SPLIT_SEQ  --nro interno RBM
       ||'||'||
       ik.DGI_INVOICE_TYPE                            --id comprobante DGI
       ||'||'||
       'A'                                            --serie
       ||'||'||
       '123456'                                       --numLegal
       ||'||'||
       '90160161350'                                  --CAE
       ||'||'||
       '20180916'                                     --fecha
       ||'||'||
       'A'                                            --rangoSerie
       ||'||'||
       '5000001'                                      --inicioRango
       ||'||'||
       '9000000'                                      --finRango
       ||'||'||
       '1'                                            --Estado (Aceptado=1 , Rechazado=2)
       ||'||'||
       'https://www.efactura.dgi.gub.uy/consultaQR/cfe?211406340011'  --urlQR
       ||'||'||
       'AbC123'                                       --hash
       ||'||'||
       'Res. 3763/2013'                               --Res
       ||'||'||
       'www.movistar.com.uy'                          --url
       ||'||'||
       ''      as registrosArchResp                   --errorRechazo
from billsummary bs, TFNU_DGIRBMINVOICEVALUE iv,TFNU_DGIRBMINVOICEKEY  ik,TFNU_DGIFILEAUDIT fa
where bs.bill_status=1
and bs.bill_dtm='$fechames'
and bs.account_num=iv.account_num
and bs.bill_seq=iv.rbm_bill_seq
and bs.bill_version=iv.rbm_bill_version
and bs.account_num=ik.account_num
and bs.bill_seq=ik.rbm_bill_seq
and bs.bill_version=ik.rbm_bill_version
and ik.dgi_file_seq=fa.dgi_file_seq
and iv.account_num = '$BA';
SPOOL OFF
EXIT;
EOF
sleep 0.5
#RFU
echo "                                                         ***Corriendo RFU***"
echo
RFU
sleep 0.5

#PDI
echo "                                                         ***Corriendo PDI***"
PDI -a "-mode NORMAL -billCycle $billcyle"

echo "                                                         ***Comentariando Fechas***"
unset GENEVA_FIXEDDATE 

echo "                                                         ***Matando DCONFIG***"
dconfigadmin -H $HOSTNAME
sleep 0.5
#killall TM
echo "                                                         ***Matando TM***"
killall TM

sqlplus $DATABASE << END
	update gparams set name='#SYSdateOverride' where name = 'SYSdateOverride';      
	quit
    	exit
END
sleep 0.5
#LevantarProcesos
echo "                                                         ***Levantando DCONFIG***"
nohup DConfigAgent &
sleep 0.5
echo "                                                         ***Levantando los SITTER***"
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
echo "                                                         ***Levantando TM***"
TM -u geneva_admin -p M3ch4_A_4su@$ORACLE_SID &
echo

echo "                                                         ***PROCESO FINALIZADO!***"
