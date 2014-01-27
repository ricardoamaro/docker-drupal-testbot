#!/bin/bash

#mysql has to be started this way as it doesn't work to call from /etc/init.d
/usr/bin/mysqld_safe & 
sleep 10s
mysqladmin -u root password drupal
mysql -uroot -pdrupal -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY 'drupal'; FLUSH PRIVILEGES;"

# Start apache.
a2enmod rewrite
apachectl start

#supervisord -n &
#sleep 10s

# Setup Drupal.
cd /var/www
scp sites/default/default.settings.php sites/default/settings.php
chmod 777 sites/default/settings.php

# Directories and permissions.
rm -fR /var/www/sites/default/files
rm -fR /var/www/sites/default/private
mkdir /var/www/sites/default/files
mkdir /var/www/sites/default/private
chmod -R 777 /var/www/sites/default/files
chmod -R 777 /var/www/sites/default/private

# Setup a directory to output the build results.
rm -fR /var/www/results
mkdir /var/www/results
chmod -R 777 /var/www/results

# Setup the installer.
cd ~
git clone https://github.com/nickschuch/phing-drupal-install.git drupal-install
cd drupal-install
composer install
# We skip a few steps in the install process.
# @todo, don't use the URL.
phing install -Dapp.installUrl='core/install.php?langcode=en&profile=testing'

# We now want to ensure the "Testing" moudle is enabled.
phing enable:simpletest

# Run the test suite.
sudo -u www-data -H sh -c "export TERM=linux && cd /var/www && php ./core/scripts/run-tests.sh --php `which php` --url 'http://localhost' --color --all --concurrency $CONCURRENCY --xml '/var/www/results'"
 
