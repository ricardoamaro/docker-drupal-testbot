#!/bin/bash

#mysql has to be started this way as it doesn't work to call from /etc/init.d
/usr/bin/mysqld_safe & 
sleep 10s
mysqladmin -u root password drupal
mysql -uroot -pdrupal -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY 'drupal'; FLUSH PRIVILEGES;"
mysql -uroot -pdrupal -e "SET GLOBAL innodb_fast_shutdown=0;"

# Restart mysqld properly.
killall mysqld
/usr/sbin/mysqld &
sleep 10s

# Start apache.
a2enmod rewrite
apachectl start

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

# Install the site. Enable Simpletest.
cd /root/drupal-install && phing install -Dapp.installUrl='core/install.php?langcode=en&profile=testing'
cd /root/drupal-install && phing enable:simpletest

# Show the environment variables for debugging.
echo "##################################################"
echo ""
echo "These are environment variables we need to know "
echo "for debugging."
echo ""
echo "CONCURRENCY: $CONCURRENCY"
echo "GROUPS: $GROUPS"
echo ""
echo "##################################################"

# Run the test suite.
sudo -E -u www-data -H sh -c "export TERM=linux && cd /var/www && php ./core/scripts/run-tests.sh --php `which php` --url 'http://localhost' --color --concurrency $CONCURRENCY --xml '/var/www/results' '$GROUPS'"
