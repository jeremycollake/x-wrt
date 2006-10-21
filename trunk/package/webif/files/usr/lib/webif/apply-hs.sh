
HANDLERS_config=$HANDLERS_config'
        hotspot) reload_hotspot;;
	shape) reload_shape;;
'

reload_hotspot() {
    echo '@TR<<Reloading>> @TR<<hotspot settings>> ...'
    grep -v '^hs_cframe' config-hotspot | grep '^hs_' >&- 2>&- && {
	[ -e "/usr/sbin/chilli" ] && {
	    /etc/init.d/S??chilli stop  >&- 2>&-
	    /etc/init.d/S??chilli start >&- 2>&-
	}
	[ -e "/usr/bin/wdctl" ] && {
	    wdctl stop >&- 2>&-
	    /etc/init.d/S??wifidog start >&- 2>&-
	}
    }
    grep '^hs_cframe' config-hotspot >&- 2>&- && {
	[ -e /etc/init.d/S??cframe ] && {
	    /etc/init.d/S??cframe stop  >&- 2>&-
	    /etc/init.d/S??cframe start >&- 2>&-
	}
    }
}

reload_shape() {
    echo '@TR<<Reloading>> @TR<<traffic shaping settings>> ...'
    grep '^shape_' config-shape >&- 2>&- && {
	/etc/init.d/S90shape start >&- 2>&-
    }
}

