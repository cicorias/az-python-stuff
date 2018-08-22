# Azure PY stuff

## Getting list of users
>NOTE: need to identify how to track back the SP creators
```
az role assignment list --subscription 3fee811e-11bf-4b5c-9c62-a2f28b517724 > ./data/out.json
```

## date compares:
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

## Check on each from a file
```
cat should_be_deleted.txt | xargs -L 1 az group show -o tsv -n
```

> FYI: the list was created using the following az cli command
```
az group list -o tsv --query "[?tags.keep == 'no']" | cut -d$'\t' -f 4
```

## The final command will be:
```
az group list -o tsv --query "[?tags.keep == 'no']" | cut -d$'\t' -f 4 | xargs -L 1 az group delete --no-wait -n
```

>Update:
```
az group list -o tsv --query "[?tags.keep != 'yes']" | cut -d$'\t' -f 4 | xargs -L 1 az group delete --no-wait -y -n
```


## Remove from a list  file

```
cat goodbye.txt | xargs -L 1 az group delete --no-wait -n
```



### Notes

```
az group list -o tsv --query "[?tags.keep != 'no' && tags.keep != 'yes']"
az group list -o tsv --query "[?tags.keep == 'no' || tags.keep == 'yes']"|wc

```

```
 az group list -o tsv --query "[?tags.keep != 'no' && tags.keep != 'yes']"|cut -d$'\t' -f 4| xargs -L 1 az group update --set tags.keep=no -n
 ```