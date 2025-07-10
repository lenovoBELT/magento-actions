#!/usr/bin/env bash

set -e

source /etc/environment


#auto-detect search engine
opensearch_status=$(curl --write-out %{http_code} --silent --output /dev/null opensearch:9200) || true;
SEARCHENGINE=""
if [ "$opensearch_status" = "200" ]
then
  SEARCHENGINE="opensearch"
else
  SEARCHENGINE="elasticsearch"
fi

if [ "$INPUT_ELASTICSEARCH" = "1" ]
then
  echo 'teste1';
  ##bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation --elasticsearch-host="$SEARCHENGINE" --elasticsearch-port=9200 --disable-modules="$INPUT_DISABLE_MODULES"
else
  if [ "$INPUT_OPENSEARCH" = "1" ]
  then
    echo 'teste2';
   ## bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation --search-engine="opensearch" --opensearch-host="$SEARCHENGINE" --opensearch-port=9200 --disable-modules="$INPUT_DISABLE_MODULES"
  fi
fi

