#!/bin/sh
ts=$(date +"%s")
for db in wikipedia_id wikipedia_title wikipedia_title_hash wikipedia_url
do	
	echo $db
	echo "db.articles_id.stats()" | mongo --host configsrv.local --port 27019 $db > /vagrant/$db$ts
done
