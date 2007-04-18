#!/bin/sh
#
# This file keeps our two branches of the webif in synchronization.
# All files confirmed to work in both branches get added here. Then
# we can simply update any one file to update both branches.
#
# We should endeavor for pages to be identical between branches
# wherever possible. This is extremely important for maintanence.
# As any programmer knows, maintainence is part of life.
#

if [ $# != 1 ]; then
	echo "USAGE: sync-webif.sh [-fromkami|-fromwr]"
	echo "  use -fromkami to copy files from Kamikaze to White Russian."
	echo "  use -fromwr to copy files from White Russian to Kamikaze."
	exit 1
fi

case "$1" in
	"-fromkami") 
		BRANCH_DEST="trunk/package/webif/files"
		BRANCH_SOURCE="kamikaze/package/webif/files";;
	"-fromwr") 
		BRANCH_SOURCE="trunk/package/webif/files"
		BRANCH_DEST="kamikaze/package/webif/files";;
	*) echo "Invalid parameter!"
	   exit 1;;
esac

synchronize_file () {
	# filename	
	for file in $(ls ${BRANCH_SOURCE}/$1); do
		sed_pre=$(echo $BRANCH_SOURCE | sed -e s/'\/'/'\\\/'/g )
		base_file=$(echo $file | sed -e s/$sed_pre//g )
		echo $base_file
		cp ${BRANCH_SOURCE}/${base_file} ${BRANCH_DEST}/${base_file}
	done
}

echo "Synchronizing branches ..."
svn up "$BRANCH_DEST"
synchronize_file "www/themes/xwrt/*"
synchronize_file "etc/config/webif"
synchronize_file "etc/functions-net.sh"
#NOT_synchronize_file "etc/init.d/S90webif_deviceid"  # not sync'd due to rc.common
#NOT_synchronize_file "etc/init.d/S90webif_firmwareid"# not sync'd due to rc.common
#NOT_synchronize_file "lib/config/uci-depends.*" #not needed in kamikaze
#NOT_synchronize_file "usr/lib/webif/apply.sh"
synchronize_file "usr/lib/webif/browser.awk"
synchronize_file "usr/lib/webif/editor.awk"
synchronize_file "usr/lib/webif/functions.sh"
#NOT_synchronize_file "usr/lib/webif/validate.awk" # kamikaze and white russian are different
#NOT_synchronize_file "usr/lib/webif/webif.sh"
synchronize_file "www/index.html"
synchronize_file "www/images/abt.jpg"
synchronize_file "www/images/action_edit.gif"
synchronize_file "www/images/action_edit_no.gif"
synchronize_file "www/images/action_x.gif"
synchronize_file "www/images/action_x_no.gif"
synchronize_file "www/images/arrwd.gif"
synchronize_file "www/images/arrwu.gif"
synchronize_file "www/images/blkbox.jpg"
synchronize_file "www/images/close.gif"
synchronize_file "www/images/dir.gif"
synchronize_file "www/images/down.gif"
synchronize_file "www/images/edit.gif"
synchronize_file "www/images/file.gif"
synchronize_file "www/images/loading.gif"
synchronize_file "www/images/overlay.png"
synchronize_file "www/images/up.gif"
synchronize_file "www/images/x.gif"
synchronize_file "www/cgi-bin/webif/data.sh"
synchronize_file "www/cgi-bin/webif/graph_cpu_svg.sh"
synchronize_file "www/cgi-bin/webif/graph_if_svg.sh"
synchronize_file "www/cgi-bin/webif/graphs-cpu.sh"
synchronize_file "www/cgi-bin/webif/graphs-if.sh"
#NOT_synchronize_file "www/cgi-bin/webif/graphs-subcategories.sh"
#NOT_synchronize_file "www/cgi-bin/webif/info.sh" # kamikaze uses awx
synchronize_file "www/cgi-bin/webif/info-credits.sh"
synchronize_file "www/cgi-bin/webif/log-dmesg.sh"
synchronize_file "www/cgi-bin/webif/log-dmesg_frame.sh"
synchronize_file "www/cgi-bin/webif/network-firewall.sh"
synchronize_file "www/cgi-bin/webif/network-qos.sh"
synchronize_file "www/cgi-bin/webif/network-services.sh"
synchronize_file "www/cgi-bin/webif/network-misc.sh"
#NOT_synchronize_file "www/cgi-bin/webif/network-wlan-advanced.sh" #not in kamikaze
synchronize_file "www/cgi-bin/webif/status-connection.sh"
synchronize_file "www/cgi-bin/webif/status-diag.sh"
synchronize_file "www/cgi-bin/webif/status-iptables.sh"
synchronize_file "www/cgi-bin/webif/status-leases.sh"
synchronize_file "www/cgi-bin/webif/status-processes.sh"
synchronize_file "www/cgi-bin/webif/status-qos.sh"
synchronize_file "www/cgi-bin/webif/status-usb.sh"
synchronize_file "www/cgi-bin/webif/status-wwaninfo.sh"
synchronize_file "www/cgi-bin/webif/system-editor.sh"
#NOT_synchronize_file "www/cgi-bin/webif/system-ipkg.sh"
synchronize_file "www/cgi-bin/webif/system-settings.sh"
synchronize_file "www/cgi-bin/webif/system-startup.sh"
synchronize_file "www/svggraph/graph_cpu.svg"
synchronize_file "www/svggraph/graph_if.svg"
svn ci "$BRANCH_DEST" -m "automated branch synchronize"
