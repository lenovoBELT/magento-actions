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

  echo "Removing trash"
  composer dump-autoload -o
  echo " ========= SET ENVIRONMENT AS PRODUCTION  =========";
  bin/magento deploy:mode:set production
  echo " ========= SETUP:UPGRADE ========="
  bin/magento setup:upgrade
  echo " ========= END OF UPGRADE ========="
  echo " ========= DI:COMPILE ========="
  bin/magento setup:di:compile
  echo " ========= END OF DI ========="
  echo " ========= STATIC-CONTENT DEPLOYMENT ========="
  bin/magento setup:static-content:deploy pt_BR -f
  echo " ========= END OF STATIC-CONTENT DEPLOYMENT ========="
 ## bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation --search-engine="opensearch" --opensearch-host="$SEARCHENGINE" --opensearch-port=9200 --disable-modules="$INPUT_DISABLE_MODULES"
