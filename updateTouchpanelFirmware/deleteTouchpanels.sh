#!/bin/bash
i=1
while read p; do
	curl -XDELETE http://192.168.99.100:32781/devices/touchpanel/$i
	i=$((i+1))
done<touchpanels
