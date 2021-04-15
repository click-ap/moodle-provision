#!/bin/bash

set -ex

# PHP module
export PHP_VERSION=$(php -nr "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
 # eg. 7.x
export MODULESDIR=$(php -ni | grep -P '(^|\s)extension_dir' |  awk '{print $3}')
 # eg. /usr/lib64/php/modules
# from: https://gist.github.com/JohnClickAP/07382221048117f3f88108549df6943d
cd ~/
wget -qnv http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O ioncube_loaders_lin_x86-64.tar.gz
tar xfz ioncube_loaders_lin_x86-64.tar.gz
sudo cp "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" $MODULESDIR
sudo cp "ioncube/loader-wizard.php" /var/www/html/
sudo chown apache:apache /var/www/html/loader-wizard.php

# Clean
export SOPATH="/zend_extension.*ioncube_loader_lin_.*so.*"
sudo sed -i "$SOPATH/d" /etc/php.ini

#sudo sed -i 's|\[PHP\]|&\nzend_extension="/usr/lib64/php/modules/ioncube_loader_lin_7.x.so"|' /etc/php.ini
export SOPATH="${MODULESDIR}/ioncube_loader_lin_${PHP_VERSION}.so"
export SEDSTRING="s|\[PHP\]|&\nzend_extension=\"$SOPATH\""
sudo sed -i "$SEDSTRING |" /etc/php.ini

php -v
sudo systemctl restart httpd
echo "ionCube installed done. and Apache restart OK."
