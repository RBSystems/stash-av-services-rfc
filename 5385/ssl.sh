#!/bin/bash
#############
# Author: Dan Clegg
# Date: 4 Nov 2015
#############

export IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;
export InstallPath=$1

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

