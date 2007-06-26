#!/bin/sh
subcategories() {
	(
	echo "#""#WEBIF:name:Graphs:1:graphs_cpu_subcategory#CPU:graphs-cpu.sh"
	cat /proc/net/dev | \
	egrep -v "No statistics available" | \
	sed -n '/:/{s/:.*//;s/^ *\(.*\)/##WEBIF:name:Graphs:2:graphs_if_Traffic#Traffic\>\> \1@TR\<\<:graphs-if.sh?if=\1/;p}'
	) | \
	awk -v "selected=$2" \
	-v "rootdir=$rootdir" \
	-f /usr/lib/webif/subcategories.awk -
}
