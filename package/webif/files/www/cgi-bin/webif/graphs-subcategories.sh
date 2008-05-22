#!/bin/sh
subcategories_extra() {
	egrep -v "No statistics available" /proc/net/dev | \
	sed -n '/:/{s/:.*//;s/^ *\(.*\)/##WEBIF:name:Graphs:2:graphs_if_Traffic#Traffic\>\> \1@TR\<\<:graphs-if.sh?if=\1/;p}'
}
SUBCATEGORIES_EXTRA="$(subcategories_extra)"
