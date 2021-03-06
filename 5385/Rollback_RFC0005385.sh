#!/bin/bash

#!/bin/bash
#############
# Author: Dan Clegg
# Date: 4 Nov 2015
#############

export patchDir="/home/ivsadmin/RFC0005385/Install1022";
export patchZip="/home/ivsadmin/RFC0005385/Install1022.zip";
#export IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;

if [ ! -d $patchDir ]; then
	if [ -f $patchZip ]; then
		unzip $patchZip && ls && echo "Restart script..."
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
		$counter+=1;
		sleep 2;
	fi

	$counter=0;

	if [ $(ps -ef | grep -v grep | grep "apache2" | wc -l) -gt 0 ]; then
		if [ $counter -eq 10 ]; then
			echo "Cannot stop apache2 service. Exiting...";
			exit 1;
		fi
		service apache2 stop;
		$counter+=1;
		sleep 2;
	fi

#	###
#	# Rollback Patch
#	###
#	echo "Restoring wowza files..."
#
#	sudo cp -fr cp -fR /home/ivsadmin/RFC0005385/wowza/ /home/ivsadmin/RFC0005385/wowza /usr/local/WowzaStreamingEngine
#
#	sudo cp -fr Install1022/wowza/lib /usr/local/WowzaStreamingEngine
#
#	echo "Restoring php and apache files..."
#	sudo cp -fr Install1022/etc/php5 /etc
#	sudo cp -fr Install1022/etc/rc.local /etc
#	sudo cp -fr Install1022/v3 /var/www/
#	sudo cp -fr Install1022/tools /var/www/
#
#	sudo ln -s /var/www/v3/vendor/h4cc/wkhtmltopdf-amd64/bin/wkhtmltopdf-amd64 /usr/bin/wkhtmltopdf
#	chmod +x /usr/bin/wkhtmltopdf
#
#	echo "Restoring base wowza conf..."
#	sudo cp -r ./Install1022/wowza/conf /usr/local/WowzaStreamingEngine
#	
#	###
#	# New Cron File
#	###
#	echo "Restoring crontab..."
#	echo "*/5 * * * * sudo php /var/www/v3/app/console recorder:outdated:delete" >> newCron
#	echo "*/5 * * * * sudo php /var/www/v3/app/console recorder:scheduled:run" >> newCron
#	echo "*/2 * * * * sudo php /var/www/v3/app/console recorder:unrecord:stop" >> newCron
#	crontab newCron
#	rm newCron
#
#	####	
#
#	#while [ ! pgrep apache2 ];
#	#do
#	#	sudo service apache2 stop
#		sudo service apache2 start
#	#	sleep 5
#	#done
#
#	cd /var/www/v3
#	sudo sh assets.sh
#	sudo service WowzaStreamingEngine restart
#
#	###
#	# Verify
#	###
#
#	#while [ ! pgrep WowzaStreamingEngine];
#	#do
#		sudo service WowzaStreamingEngine stop
#		sudo service WowzaStreamingEngine start
#	#	sleep 10
#	#done
#
#	### Failure
#	#if [ ! pgrep WowzaStreamingEngine ];
#	#	then
#	#	echo "PATCH FAILED! ROLLBACK INITIATED";
#	#	##sh Rollback_RFC0005385.sh & ;
#	#else
#	#### Success
#	#	echo "PATCH APPLIED SUCCESSFULLY";
#	#fi
fi

