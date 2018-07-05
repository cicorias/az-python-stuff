Azure PY stuff



date compares:

todate=$(date -d 2013-07-18 +%s)
cond=$(date -d 2014-08-19 +%s)

if [ $todate -ge $cond ];
then
    break
fi 


