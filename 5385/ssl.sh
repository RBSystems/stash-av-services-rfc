#!/bin/bash
#############
# Author: Dan Clegg
# Date: 4 Nov 2015
#############

export IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;
export InstallPath=$1
export host=$(hostname -f)

if [ ! $1 ]; then
	echo "Provide a path to the install directory. Example: sh ssl.sh /tmp/Install1022";
	exit 1
fi

###
# Verify Cert Exists
###

if [ ! -f /etc/apache2/ssl/star_byu_edu.crt ]; then
	echo "ERROR: Missing star_byu_edu.crt certificate!"
	exit 1
fi

if [ ! -f /etc/apache2/ssl/IVS-510626065001.key ]; then
	echo "ERROR: Missing IVS-510626065001.key keyfile!"
	exit 1
fi
if [ ! -f /etc/apache2/ssl/DigiCertCA.crt ]; then
	echo "ERROR: Missing DigiCertCA.crt intermediate certificate!"
	exit 1
fi

cd $InstallPath

###
# Copy new config files to their directories
###
sudo cp default-ssl.conf /etc/apache2/sites-enabled/
sudo cp v3.conf.ssl /etc/apache2/sites-enabled/
sudo cp v3/nodejs/serverSSL.js /var/www/v3/nodejs/

###
# Rename the old config files
###
sudo mv /etc/apache2/sites-enabled/v3.conf /etc/apache2/sites-enabled/v3.conf.nossl
sudo mv /etc/apache2/sites-enabled/v3.conf.ssl /etc/apache2/sites-enabled/v3.conf
sudo mv /var/www/v3/nodejs/server.js /var/www/v3/nodejs/server.js.nossl
sudo mv /var/www/v3/nodejs/serverSSL.js /var/www/v3/nodejs/server.js
sudo cp /var/www/dustin/web/wowza_conf/url /var/www/dustin/web/wowza_conf/url.nossl

###
# Replace nodejs certs
###
sudo sed -i 's/<key>.key/IVS-510626065001.key/' /var/www/v3/nodejs/server.js
sudo sed -i 's/<cert>.cer/star_byu_edu.crt/' /var/www/v3/nodejs/server.js
sudo sed -i 's/<ca>.cer/DigiCertCA.crt/' /var/www/v3/nodejs/server.js
sudo sed -i 's/etc\/ssl\/crt/etc\/apache2\/ssl/' /var/www/v3/nodejs/server.js

###
# Enter proper ip address into wowza config
###
sudo sed -i "s/http:\/\/localhost/https:\/\/$IP/" /var/www/dustin/web/wowza_conf/url

###
# Enter https version of url in Wowza config
###
sudo -s
export IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;
export host=$(hostname -f)
sudo sed -i 's/http:\/\//https:\/\//' /usr/local/WowzaStreamingEngine/conf/dustin/Application.xml
sudo sed -i "s/192.168.0.99/$IP/" /usr/local/WowzaStreamingEngine/conf/dustin/Application.xml
sudo sed -i 's/valt_recordings/dustin_recordings/' /usr/local/WowzaStreamingEngine/conf/dustin/Application.xml

###
# Modify the v3.conf file
###
sudo sed -i "s/192.*:443/$IP:443/" /etc/apache2/sites-enabled/v3.conf
sudo sed -i "s/ServerName.*/ServerName $host/1" /etc/apache2/sites-enabled/v3.conf
#!!! ServerAlias not going in
##sudo sed -i "s/ServerName.*/ServerName $host $(printf '\r\t\t')/ ServerAlias *.byu.edu/2" /etc/apache2/sites-enabled/v3.conf
sudo sed -i 's/apache.crt/star_byu_edu.crt/' /etc/apache2/sites-enabled/v3.conf
sudo sed -i 's/apache.key/IVS-510626065001.key/' /etc/apache2/sites-enabled/v3.conf

###
# Modify the default-ssl.conf file
###
sudo sed -i "s/192.*:443/$IP:443/" /etc/apache2/sites-enabled/default-ssl.conf
sudo sed -i 's/apache.crt/star_byu_edu.crt/' /etc/apache2/sites-enabled/default-ssl.conf
sudo sed -i 's/apache.key/IVS-510626065001.key/' /etc/apache2/sites-enabled/default-ssl.conf

###
# Import the SSL cert into the Wowza Trust Store
###
sudo keytool -import -noprompt -trustcacerts -alias apache -file /etc/apache2/ssl/star_byu_edu.crt -keystore /usr/lib/jvm/default-java/jre/lib/security/cacerts -storepass changeit


###
# Enable SSL in Apache
###
sudo a2enmod ssl
sudo service apache2 restart
