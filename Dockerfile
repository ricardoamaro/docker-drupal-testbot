FROM ubuntu:latest
MAINTAINER Nick Schuch <nick@previousnext.com.au>
RUN apt-get update # Fri Dec 13 12:24:34 EST 2013
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-pear git curl wget mysql-client mysql-server apache2 libapache2-mod-php5 php5-curl pwgen python-setuptools vim-tiny php5-mysql openssh-server sudo php5-gd
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin
RUN sudo ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
RUN pear channel-discover pear.phing.info
RUN pear install phing/phing
RUN easy_install supervisor
ADD ./vhost.conf /etc/apache2/sites-available/default
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
RUN echo %sudo	ALL=NOPASSWD: ALL >> /etc/sudoers
RUN rm -rf /var/www/
RUN chmod 755 /start.sh
RUN chmod 755 /etc/apache2/foreground.sh
RUN mkdir /var/log/supervisor/
RUN mkdir /var/run/sshd
CMD ["/bin/bash", "/start.sh"]
