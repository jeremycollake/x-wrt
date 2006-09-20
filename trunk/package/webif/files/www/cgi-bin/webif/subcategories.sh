#!/bin/sh
subcategories() {
	(
	echo "#""#WEBIF:name:Graphs:1:CPU:cpu.sh"
	cat /proc/net/dev | \
	sed -n '/: *0/d;/:/{s/:.*//;s/^ *\(.*\)/##WEBIF:name:Graphs:2:Traffic \1:\/if.sh?if=\1/;p}'
	) | \

	awk -v "selected=$2" \
	-v "rootdir=$rootdir" \
	-f /usr/lib/webif/subcategories.awk -
}
