#!/bin/bash
export patchDir="/home/ivsadmin/RFC0005385/Install1022";
export patchZip="/home/ivsadmin/RFC0005385/Install1022.zip";
export IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;

if [ ! -d $patchDir ]; then
	if [ -f $patchZip ]; then
		unzip $patchZip && ls
	else
		if [ -f ".\Install1022.zip" ]; then
			cp -fR ".\Install1022.zip" $patchZip
		else
			echo "Patch files are not present. Please download the patch to /home/ivsadmin ."
			exit 1
		fi
	fi
else
	echo "Backing up current configs..."

	###
	# Backups
	###
	if [ ! -d /home/ivsadmin ]; then 
		mkdir /home/ivsadmin/RFC0005385;
	fi

	if [ ! -d /home/ivsadmin/RFC0005385/apache ]; then
		mkdir /home/ivsadmin/RFC0005385/apache;
	fi
	
	if [ ! -d /home/ivsadmin/RFC0005385/wowza ]; then
		mkdir /home/ivsadmin/RFC0005385/wowza;
	fi

	cp -fR /var/www/tools /home/ivsadmin/RFC0005385/apache/tools;
	cp -fR /var/www/v3 /home/ivsadmin/RFC0005385/apache/tools/v3;
	cp -fR /usr/local/WowzaStreamingEngine/conf/* /home/ivsadmin/RFC0005385/wowza;
	crontab -l > /home/ivsadmin/RFC0005385/crontab.bak;

	###
	# Stop Services
	###
	export counter=0;
	echo "Stopping services..."

	if [ $(ps -ef | grep -v grep | grep "WowzaStreamingEngine" | wc -l) -gt 0 ]; then
		if [ $counter -eq 10 ]; then
			echo "Cannot stop WowzaStreamingEngine service. Exiting...";
			exit 1;
		fi
		service WowzaStreamingEngine stop;
		$counter=$counter+1;
		sleep 2;
	fi

	$counter=0;

	if [ $(ps -ef | grep -v grep | grep "apache2" | wc -l) -gt 0 ]; then
		if [ $counter -eq 10 ]; then
			echo "Cannot stop apache2 service. Exiting...";
			exit 1;
		fi
		service apache2 stop;
		$counter=$counter+1;
		sleep 2;
	fi

	###
	# Apply Patch
	###
	echo "Copying wowza files..."

	sudo cp -r ./Install1022/wowza/conf /usr/local/WowzaStreamingEngine

	sudo cp -r ./Install1022/Install1022/wowza/lib /usr/local/WowzaStreamingEngine

	echo "Copying php and apache files..."
	sudo cp -r ./Install1022/etc/php5 /etc
	sudo cp -r ./Install1022/etc/rc.local /etc
	sudo cp -r ./Install1022/v3 /var/www/
	sudo cp -r ./Install1022/tools /var/www/

	sudo ln -s /var/www/v3/vendor/h4cc/wkhtmltopdf-amd64/bin/wkhtmltopdf-amd64 /usr/bin/wkhtmltopdf
	chmod +x /usr/bin/wkhtmltopdf

	echo "Updating ffmpeg..."
	cd /var/www/tools/
	sudo tar -xvf ffmpeg-release-64bit-static.tar.xz
	cd ffmpeg-2.7.2-64bit-static
	sudo rm /usr/bin/ffmpeg
	sudo ln ffmpeg /usr/bin/ffmpeg

	echo "Updating base wowza conf..."
	sudo cp -r ./Install1022/wowza/conf /usr/local/WowzaStreamingEngine
	
	###
	# New Cron File
	###
	echo "Creating new crontab..."
	echo "*/5 * * * * sudo php /var/www/v3/app/console recorder:outdated:delete" >> newCron
	echo "*/5 * * * * sudo php /var/www/v3/app/console recorder:scheduled:run" >> newCron
	echo "*/2 * * * * sudo php /var/www/v3/app/console recorder:unrecord:stop" >> newCron
	crontab newCron
	rm newCron

	###
	# Replace protocol & IP in wowza settings
	###

####	sed -i 's/192.168.0.99/$IP/' /usr/local/WowzaStreamingEngine/conf/dustin/Application.xml
####	sed -i 's/192.168.0.99/$IP/' /var/www/dustin/web/wowza_conf/url
####	
####	#sed -i 's/http/https/' /usr/local/WowzaStreamingEngine/conf/dustin/Application.xml
####	
####	
####	sudo -s
####	cd /var/www/v3
####	sh assets.sh
####	service WowzaStreamingEngine restart
####
####	###
####	# Verify
####	###
####
####	while [ ! pgrep WowzaStreamingEngine -a $counter -le 3 ];
####	do
####		sudo service WowzaStreamingEngine stop
####		sudo service WowzaStreamingEngine start
####		counter++
####		sleep 10
####	done
####
####	### Failure
####	if [! pgrep WowzaStreamingEngine ];
####		then
####		echo "PATCH FAILED! ROLLBACK INITIATED";
####		sh Rollback_RFC0005385.sh & ;
####	else
####	### Success
####		echo "PATCH APPLIED SUCCESSFULLY";
####	fi
fi

