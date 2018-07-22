#Azure PY stuff



##date compares:
```
todate=$(date -d 2013-07-18 +%s)
cond=$(date -d 2014-08-19 +%s)

if [ $todate -ge $cond ];
then
    break
fi 
```

## Initially set the tags:
```
az group list -o tsv | cut -d$'\t' -f 4 | xargs -L 1 az group update --set tags.keep=no -n
```

> FYI: the list was created using the following az cli command
```
az group list -o tsv --query "[?tags.keep == 'no']" | cut -d$'\t' -f 4
```

## The final command will be:
```
az group list -o tsv --query "[?tags.keep == 'no']" | cut -d$'\t' -f 4 | xargs -L 1 az group delete --no-wait -n
```
