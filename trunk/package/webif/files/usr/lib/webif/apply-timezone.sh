#!/bin/sh
#
# This file is designed only for White Russian.
#
# Handler for timezone setting.

reload_ntp() {
	# create symlink to /tmp/TZ if /etc/TZ doesn't exist
	# todo: -e | -f | -d didn't seem to work here, so I used find
	if [ -z $(find "/etc/TZ") ]; then 
		ln -s /tmp/TZ /etc/TZ
	fi
	# eJunky: set timezone
	TZ=$(nvram get time_zone | cut -f 2)
	[ "$TZ" ] && echo $TZ > /etc/TZ
}

HANDLERS_config="$HANDLERS_config
	timezone) reload_ntp;;
"
