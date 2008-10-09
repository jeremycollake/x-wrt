#!/bin/ash
			/etc/init.d/network restart
			sleep 3
			killall dnsmasq
			if [ -f /etc/rc.d/S??dnsmasq ]; then
				/etc/init.d/dnsmasq start
			fi
      sleep 3
      wifi