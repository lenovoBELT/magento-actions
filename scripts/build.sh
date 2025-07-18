#!/usr/bin/env bash

echo "building ....."


chown -R root:root .
PROJECT_PATH="$(pwd)"

echo "currently in $PROJECT_PATH"
[ $INPUT_PWA_STUDIO_ONLY = 1 ] && rm -rf  $PROJECT_PATH/magento
[ $INPUT_MAGENTO_ONLY = 1 ] && rm -rf  $PROJECT_PATH/pwa-studio


echo "currently in $PROJECT_PATH"


#launch pwa-strudio build if the directory exists
if [ -d "$PROJECT_PATH/pwa-studio" ]
then
  set -e

  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install $INPUT_NODE_VERSION
  npm install -g yarn
  yarn install && yarn add compression

  cd pwa-studio
  yarn install --update-checksums --frozen-lockfile
  yarn run build
  set +e
  ls -talh
fi
cd $PROJECT_PATH


if [ -d "$PROJECT_PATH/magento" ]
then
   cd "$PROJECT_PATH/magento"

    chmod +x bin/magento

    #mysqladmin -h mysql -u root -pmagento status
    ## fix magento error: connection default is not defined
    cp /opt/config/env/env.php app/etc/env.php
    ## end fix ##

    echo ' ========= IMPORT DUMMY DATABASE  =========';
    mysql -h mysql -u root -pmagento magento < /opt/config/env/sample_dump.sql
    echo ' ========= END OF IMPORT =========';

    bash /opt/config/utils/common-magento-installer.sh
fi
