#!/bin/sh

TSTAMP=`date "+%Y.%m%d.%H%M%S"`
LOGFILE=r.${TSTAMP}.log

(
date

source activate webscraper
export ORAENV_ASK=NO
export ORACLE_SID=DB12C
. oraenv

ls
which python3

python3 <<ENDPY
exec(open("main.py").read())
ENDPY
date
) 1>>$LOGFILE 2>&1 


