#!/usr/bin/webif-page
<?
#########################################
# Applications Download Manager
#
# Author(s) [in order of work date]:
#        Dmytro Dykhman <dmytro@iroot.ca>
#

. /usr/lib/webif/webif.sh
. /www/cgi-bin/webif/applications-shell.sh

echo "$HEADER"

if ! empty "$FORM_package"; then
	
	App_package_install "Download Manager" "" "ctorrent" "curl"

	if  is_package_installed "ctorrent"  &&  is_package_installed "curl"  ; then 
	##### Make config file

	if [ ! -s "/etc/config/app.dlmanager" ] ; then 
	echo "config dlmanager set
	option service	''" > /etc/config/app.dlmanager
	fi
	echo_install_complete
	Load_remote_libs
	fi
exit
fi

if ! empty "$FORM_remove"; then
	App_package_remove "Download Manager" "app.dlmanager" "ctorrent" "uclibcxx" "curl" "libcurl" "libopenssl"
	exit
fi

if  is_package_installed "ctorrent"  &&  is_package_installed "curl"  ; then 

	######## Read config

	uci_load "app.dlmanager"
	CFG_SRV="$CONFIG_set_service"


	######### Save DlManager
	if ! empty "$FORM_save_dlmanager"; then
	echo "<META http-equiv="refresh" content='2;URL=$SCRIPT_NAME'>"
	echo "<br>saving ..."

	exit
	fi

	cat <<EOF
	$HTMLHEAD</head><body bgcolor="#eceeec">
	<div id="mainmenu"><ul>
	<li><a href="$SCRIPT_NAME">Status</a></li>
	<li class="separator">-</li>
	<li><a href="$SCRIPT_NAME?page=http">HTTP</a></li>
	<li><a href="$SCRIPT_NAME?page=ftp">FTP</a></li>
	<li><a href="$SCRIPT_NAME?page=torrent">Torrents</a></li>
	<li class="separator">-</li>
	<li><a href="$SCRIPT_NAME?page=history">History</a></li>
	</ul></div><br/>
EOF
##################################################################

	if [ "$FORM_page" = "http" ]; then
		echo "in developemnt..."
	elif [ "$FORM_page" = "ftp" ]; then
		echo "in developemnt..."
	elif [ "$FORM_page" = "torrent" ]; then
		##################################################################
		# Downloader v0.6-alpha
		# Download from URL; Download torrent
		# Created by rll email: romanlenskij <at> gmail <dot> com
		#

		! empty "$FORM_download_urlbt" && {
		FORM_action="downloadbt"
		}

		! empty "$FORM_killbt" && {
		FORM_action="killbt"
		}

		display_form <<EOF

		start_form|@TR<<Download torrent>>
		field|@TR<<URL of torrent>>
		text|urlbt|$FORM_urlbt

		field|@TR<<Destination>>
		text|destbt|$FORM_destbt

		field|
		submit|download_url|@TR<<Download From URL>>|
		end_form

		start_form|@TR<<Kill ctorrent>>
		field|
		submit|killbt|Stop ctorrent|
		end_form
EOF
		# Block ends
		##################################################################

		echo "<pre>"
		if    [ "$FORM_action" = "downloadbt" ]; then
    			echo "@TR<<Please wait>> ...<br />"
    			echo "`echo $FORM_destbt` `echo $FORM_urlbt`" >> `cat /etc/config/app.dlmanager |awk 'NR>1'| awk 'NR>1{exit};1'`/url.list
   			echo "@TR<<Done>> ...<br />"
		elif    [ "$FORM_action" = "ctorrent" ]; then
    			echo "@TR<<Please wait>> ...<br />"
    			killall ctorrent
    			echo "@TR<<Done>> ...<br />"
		fi
		echo "</pre>"
		display_form <<EOF
		start_form||||nohelp
		end_form
EOF

	elif [ "$FORM_page" = "history" ]; then
		echo "in developemnt..."
	else
		echo "no status available"
	fi
fi
?>