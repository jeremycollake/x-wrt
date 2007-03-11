#!/bin/sh
subcategories_extra() {
	egrep -v "No statistics available" /proc/net/dev | \
	sed -n '/:/{s/:.*//;s/^ *\(.*\)/##WEBIF:name:Graphs:2:Traffic \1:\graphs-if.sh?if=\1/;p}'
}
SUBCATEGORIES_EXTRA="$(subcategories_extra)"
