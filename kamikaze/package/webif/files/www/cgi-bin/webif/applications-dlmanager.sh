#!/usr/bin/webif-page
<?
#########################################
# Applications Download Manager
#
# Author(s) [in order of work date]:
#        Dmytro Dykhman <dmytro@iroot.ca>
#

. /usr/lib/webif/functions.sh
. /lib/config/uci.sh
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
	App_package_remove "Download Manager" "app.dlmanager" "ctorrent" "uclibcxx" "curl" "libcurl"
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

################### HTML PAGE ################################

echo "$HTMLHEAD<font color=red>GUI is not available yet ... comming soon.</font>"

fi
?>