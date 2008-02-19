#!/bin/sh
#
# Hotspot apply handler.

reload_hotspot() {
	echo '@TR<<Exporting>> @TR<<hotspot settings>> ...'
	[ -e /bin/save_hotspot ] && {
		/bin/save_hotspot >&- 2>&-
	}
	(
	config_cb() {
		config_get TYPE "$CONFIG_SECTION" TYPE
		case "$TYPE" in
			chillispot)
				service_cfg="$CONFIG_SECTION"
			;;
		esac
	}
	config_load "hotspot"
	config_get_bool test "$service_cfg" enable 0
	chilli_init="/etc/init.d/chilli"
	[ -e $chilli_init ] && {
		if [ "1" = "$test" ]; then
			echo '@TR<<Reloading>> @TR<<hotspot settings>> ...'
			$chilli_init enable >&- 2>&-
			$chilli_init stop  >&- 2>&-
			$chilli_init start >&- 2>&-
		else
			echo '@TR<<Stopping>> @TR<<hotspot>> ...'
			$chilli_init stop  >&- 2>&-
			$chilli_init disable >&- 2>&-
		fi
	}
	)
}

[ -f /tmp/.uci/hotspot ] && {
	# save settings
	echo "@TR<<Committing>> $package ..."
	uci_commit "hotspot"
	reload_hotspot
	# and do not save it twice
	rm -f /tmp/.uci/hotspot 2>/dev/null
}
