HANDLERS_config=$HANDLERS_config'
        pptp) reload_pptp;;
'

reload_pptp() {
    echo '@TR<<Reloading>> @TR<<PPTP settings>> ...'
    grep '_cli' config-pptp >&- 2>&- && [ -e /etc/init.d/S??pptp ] && {
	/etc/init.d/S??pptp stop >&- 2>&-
	/etc/init.d/S??pptp start >&- 2>&-
    }
    grep '_srv' config-pptp >&- 2>&- && [ -e /etc/init.d/S??pptpd ] && {
	/etc/init.d/S??pptpd stop  >&- 2>&-
	/etc/init.d/S??pptpd start >&- 2>&-
    }
}

