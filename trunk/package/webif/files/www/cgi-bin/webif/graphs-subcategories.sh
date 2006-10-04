#!/bin/sh
subcategories() {
	(
	echo "#""#WEBIF:name:Graphs:1:CPU:graphs-cpu.sh"
	cat /proc/net/dev | grep wds -v | \
	sed -n '/: *0/d;/:/{s/:.*//;s/^ *\(.*\)/##WEBIF:name:Graphs:2:Traffic \1:\graphs-if.sh?if=\1/;p}'
	) | \

	awk -v "selected=$2" \
	-v "rootdir=$rootdir" \
	-f /usr/lib/webif/subcategories.awk -
}
