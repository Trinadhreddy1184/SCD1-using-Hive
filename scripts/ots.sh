#!/bin/bash/

#bringing parameter file
. /home/saif/project_1/env/sqp.prm

PASSWD=`sh password.sh`
LOG_DIR=/home/saif/project_1/logs/
DT=`date '+%Y-%m-%d %H:%M:%S'`
LOG_FILE=${LOG_DIR}/project_1_ots.log

mysql --local-infile=1 -uroot -p${PASSWD} < /home/saif/project_1/scripts/sql.txt

if [ $? -eq 0 ]
then echo "sql successfully executed at ${DT}" >> ${LOG_FILE}
else echo "sql commands failed  at ${DT} " >> ${LOG_FILE}
exit 1
fi


sqoop job --create pro_job_imp -- import \
--connect jdbc:mysql://${LOCALHOST}:${PORT_NO}/${DB_NAME}?useSSL=False \
--username ${USERNAME} --password-file ${PASSWORD_FILE} \
--query 'SELECT custid, username, quote_count, ip, entry_time, prp_1, prp_2, prp_3, ms, http_type, purchase_category, total_count, purchase_sub_category, http_info, status_code,year_col,month_col FROM day WHERE $CONDITIONS' -m 1 \
--delete-target-dir \
--target-dir ${OP_DIR} 

if [ $? -eq 0 ]
then echo "sqoop imp job successfully created at ${DT}" >> ${LOG_FILE}
else echo "sqoop imp job  failed  at ${DT} " >> ${LOG_FILE}
exit 1
fi


hive -f /home/saif/project_1/scripts/hive_ots.hql

if [ $? -eq 0 ]
then echo "hive ots successfully executed at ${DT}" >> ${LOG_FILE}
else echo "sqoop hive ots  failed  at ${DT} " >> ${LOG_FILE}
exit 1
fi


sqoop job --create pro_job_exp -- export \
--connect jdbc:mysql://${LOCALHOST}:${PORT_NO}/${DB_NAME}?useSSL=False \
--table ${EXP_TBL} \
--username ${USERNAME} --password-file ${PASSWORD_FILE} \
--direct \
--export-dir ${EXP_DIR} \
--m 1 \
-- driver com.mysql.jdbc.Driver --input-fields-terminated-by ','



if [ $? -eq 0 ]
then echo "sqoop exp job successfully created at ${DT}" >> ${LOG_FILE}
else echo "sqoop exp job  failed  at ${DT} " >> ${LOG_FILE}
exit 1
fi



 
