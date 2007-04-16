#!/bin/sh
#
# Hotspot handler.

reload_hotspot() {
	echo '@TR<<Exporting>> @TR<<hotspot settings>> ...'
	[ -e "/bin/save_hotspot" ] && {
		/bin/save_hotspot >&- 2>&-
	}

	echo '@TR<<Reloading>> @TR<<hotspot settings>> ...'
	[ -e "/usr/sbin/chilli" ] && {
		/etc/init.d/chilli stop  >&- 2>&-
		/etc/init.d/chilli start >&- 2>&-
	}
}

HANDLERS_config="$HANDLERS_config
	hotspot) reload_hotspot;;
"
