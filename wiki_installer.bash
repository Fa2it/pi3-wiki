#!/bin/bash

#upgrade
apt update; 

apt -y upgrade;
 
mkdir /tmp/installer-report/;
 
wget https://www.imagemagick.org/download/ImageMagick.tar.gz;

wget https://releases.wikimedia.org/mediawiki/1.31/mediawiki-1.31.1.tar.gz;

wget https://extdist.wmflabs.org/dist/extensions/Elastica-REL1_31-7019d96.tar.gz;

wget https://extdist.wmflabs.org/dist/extensions/CirrusSearch-REL1_31-ad9a0d9.tar.gz;



apt install -y mysql-server apache2 curl wget make nodejs composer vim vsftpd default-jre; 

apt install -y php7.2 libapache2-mod-php7.2 php7.2-mysql php-apcu php7.2-curl php7.2-xml php7.2-mbstring php7.2-xmlrpc php7.2-intl php7.2-gd php7.2-zip php7.2-dev php-pear;

php -v > /tmp/installer-report/result.log;
mysql -V &>> /tmp/installer-report/result.log;
apache2 -v &>> /tmp/installer-report/result.log; 
node -v &>> /tmp/installer-report/result.log;  
java -version &>> /tmp/installer-report/result.log;
# cread db user
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'wiki'@'localhost' IDENTIFIED BY 'wiki'";
  

#must reatart apache2
service apache2 restart;

#Installing imagemagic;
find /etc/apt/sources.list -type f -exec sed -i "s/deb-src http:\/\/archive.ubuntu.com\/ubuntu bionic main restricted/\#deb-src http:\/\/archive.ubuntu.com\/ubuntu bionic main restricted/g" {} \;
#sed -i "s/deb-src http:\/\/archive.ubuntu.com\/ubuntu bionic main restricted/\#deb-src http:\/\/archive.ubuntu.com\/ubuntu bionic main restricted/g" /etc/apt/sources.list

#deb-src http://archive.ubuntu.com/ubuntu bionic main restricted
apt update;
apt build-dep imagemagick;

tar xf ImageMagick.tar.gz;
cd ImageMagick-7*;

./configure;

#make;

make install;

ldconfig /usr/local/lib;

identify -version &>> /tmp/installer-report/imagemagic.log;

#make check | tee /tmp/installer-report/imagemagic.log;
 
# install wiki 
cd /tmp/pi3-wiki;
tar xvzf mediawiki-*.tar.gz;
rm -R /var/www/html/*;
mv mediawiki-1.31.1/* /var/www/html/;

#Elastica 
tar -xzf Elastica-REL1_31-7019d96.tar.gz -C /var/www/html/extensions/;

chgrp -R www-data /var/www/html/extensions/Elastica/;
chmod -R 775 /var/www/html/extensions/Elastica/;

#CirrusSearch extension for MediaWiki REL1_31 
tar -xzf CirrusSearch-REL1_31-ad9a0d9.tar.gz -C /var/www/html/extensions/;
chgrp -R www-data /var/www/html/extensions/CirrusSearch/;
chmod -R 775 /var/www/html/extensions/CirrusSearch/;

######## install elastic search from APT repository#######################################################################

dpkg -i elasticsearch-oss-6.5.4.deb;

#configure Elasticsearch to start automatically when the system boots up
systemctl daemon-reload;
systemctl enable elasticsearch.service;
systemctl start elasticsearch.service;
systemctl status elasticsearch.service;

#test elasticsearch
#curl  localhost:9200;

############################################################################################################################ 