#!/bin/bash

$patchDir = "/home/ivsadmin/Install1022";
$patchZip = "/home/ivsadmin/Install1022.zip";

if [ ! -d $patchDir]
	then
	if [ -f $patchZip] then
		tar -xvf $patchZip
	else
		echo "Patch files are not present. Please download the patch to /home/ivsadmin ."
		exit 1
	fi
else
	
	###
	# Backups
	###

	mkdir /home/ivsadmin/RFC0005385
	mkdir /home/ivsadmin/RFC0005385/apache
	mkdir /home/ivsadmin/RFC0005385/wowza

	cp -fR /var/www/tools /home/ivsadmin/RFC0005385/apache/tools
	cp -fR /var/www/tools /home/ivsadmin/RFC0005385/apache/tools/v3
	cp -fR /usr/local/WowzaStreamingEngine/conf/* /home/ivsadmin/RFC0005385/wowza

	###
	# Apply Patch
	###

	sudo cp -r wowza/conf /usr/local/WowzaStreamingEngine

	sudo cp -r wowza/lib /usr/local/WowzaStreamingEngine
	sudo cp -r etc/php5 /etc
	sudo cp -r etc/rc.local /etc
	sudo cp -r v3 /var/www/
	sudo cp -r tools /var/www/

	sudo ln -s /var/www/v3/vendor/h4cc/wkhtmltopdf-amd64/bin/wkhtmltopdf-amd64 /usr/bin/wkhtmltopdf
	chmod +x /usr/bin/wkhtmltopdf
	cd /var/www/tools/
	sudo tar -xvf ffmpeg-release-64bit-static.tar.xz
	cd ffmpeg-2.7.2-64bit-static/
	sudo rm /usr/bin/ffmpeg
	sudo ln ffmpeg /usr/bin/ffmpeg
	sudo cp -r wowza/conf /usr/local/WowzaStreamingEngine
	 
	 
	crontab -e

	replace contents with:
	*/5 * * * * sudo php /var/www/v3/app/console recorder:outdated:delete
	*/5 * * * * sudo php /var/www/v3/app/console recorder:scheduled:run
	*/2 * * * * sudo php /var/www/v3/app/console recorder:unrecord:stop


	sudo nano /usr/local/WowzaStreamingEngine/conf/dustin/Application.xml
	#Replace protocol & IP

	sudo -s
	cd /var/www/v3
	sh assets.sh
	service WowzaStreamingEngine restart

	###
	# Verify
	###


fi
