#!/bin/sh
#this file contains any needed fixes to old functions that may have changed in newer versions.
#helps keep the webif compatable with older versions.

config_load() {
	local cfg
	local uci
	local PACKAGE="$1"

	case "$PACKAGE" in
		/*)	cfg="$PACKAGE"
			uci=""
		;;
		*)	cfg="$UCI_ROOT/etc/config/$PACKAGE"
			uci="/tmp/.uci/${PACKAGE}"
		;;
	esac

	[ -e "$cfg" ] || cfg=""
	[ -e "$uci" ] || uci=""

	# no config
	[ -z "$cfg" -a -z "$uci" ] && return 1

	_C=0
	export ${NO_EXPORT:+-n} CONFIG_SECTIONS=
	export ${NO_EXPORT:+-n} CONFIG_NUM_SECTIONS=0
	export ${NO_EXPORT:+-n} CONFIG_SECTION=

	${cfg:+. "$cfg"}
	${uci:+. "$uci"}
	
	${CONFIG_SECTION:+config_cb}
}


