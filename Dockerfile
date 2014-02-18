FROM ubuntu
MAINTAINER Nick Schuch <nick@previousnext.com.au>

# APT.
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y upgrade

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Packages.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 curl drush git libapache2-mod-php5 mc memcached mysql-client mysql-server openssh-server php5-curl php5-gd php5-memcache php5-mysql php-apc php-pear pwgen python-setuptools sudo vim-tiny wget
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean

# Composer.
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin
RUN sudo ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Pear packages.
RUN pear channel-discover pear.phing.info
RUN pear install phing/phing

# Apache / PHP.
ADD ./conf/apache2/vhost.conf /etc/apache2/sites-available/default
ADD ./conf/php5/apache2.ini /etc/php5/apache2/php.ini
ADD ./conf/php5/cli.ini /etc/php5/cli/php.ini
ADD ./conf/php5/apc.ini /etc/php5/conf.d/apc.ini

# Mysql.
ADD ./conf/mysql/my.cnf /etc/mysql/my.cnf

# Retrieve latest drupal 
RUN rm -rf /var/www/ ; cd /var ; drush dl drupal ; mv /var/drupal*/ /var/www/
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R www-data:www-data /var/www/

# Scripts.
ADD ./conf/scripts/start.sh /start.sh
ADD ./conf/scripts/foreground.sh /etc/apache2/foreground.sh

# Supervisord.
RUN easy_install supervisor
ADD ./conf/supervisor/supervisord.conf /etc/supervisord.conf
RUN mkdir /var/log/supervisor/

# Sudo.
RUN echo %sudo	ALL=NOPASSWD: ALL >> /etc/sudoers
RUN mkdir /var/run/sshd

# Apache.
RUN rm -rf /var/www/
RUN chmod 755 /etc/apache2/foreground.sh

# Setup Drupal install library.
RUN git clone https://github.com/nickschuch/phing-drupal-install.git /root/drupal-install
RUN cd /root/drupal-install && composer install

# Run test script.
RUN chmod 755 /start.sh
CMD ["/bin/bash", "/start.sh"]
