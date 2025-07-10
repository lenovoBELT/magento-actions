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

    mysql -h localhost -u root -pmagento magento < /opt/config/env/sample_dump.sql

    if [ -n "$INPUT_DISABLE_MODULES"  ]
    then
      echo "These modules will be discarded during install process $INPUT_DISABLE_MODULES"
      [ -f app/etc/config.php ] && cp app/etc/config.php app/etc/config.php.orig
    fi

    bash /opt/config/utils/pagebuilder-compatibility-checker.sh
    bash /opt/config/utils/common-magento-installer.sh

    ## Build static contents
    ##bash /opt/config/utils/custom-theme-builder.sh

    if [ -z "$INPUT_LANGS"  ] && [ -z "$INPUT_THEMES"  ]
    then
      ## the switch to production will build static content for all languages declared in config.php
      bin/magento deploy:mode:set production
      composer dump-autoload -o
    else
      bin/magento setup:di:compile
      bin/magento deploy:mode:set --skip-compilation production
      # deploy static build for different locales
      export IFS=","
      magento_themes=${INPUT_THEMES:+${INPUT_THEMES//' '/,}",Magento/backend"}
      magento_themes_array=($magento_themes)
      languages="$INPUT_LANGS"
      if [ -n "$languages"  ]
      then
        for locale in $languages; do
          for theme in "${magento_themes_array[@]}" 
          do
          echo "bin/magento setup:static-content:deploy -t $theme $locale"
          ###  bin/magento setup:static-content:deploy -t $theme en_US pt_BR
	  done
        done
      else
          for theme in "${magento_themes_array[@]}" 
          do
            echo "bin/magento setup:static-content:deploy $theme"
           ### bin/magento setup:static-content:deploy $theme
	  done
      fi
      composer dump-autoload -o
    fi

    if [ -n "$INPUT_DISABLE_MODULES"  ]
    then
      [ -f app/etc/config.php.orig ] && cat app/etc/config.php.orig > app/etc/config.php
    fi

    rm app/etc/env.php
fi
