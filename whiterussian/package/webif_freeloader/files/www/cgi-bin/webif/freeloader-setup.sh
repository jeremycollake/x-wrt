#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# freeloader-setup.sh
# (c)2007 X-Wrt project (http://www.x-wrt.org)
# (c)2008-01-01 m4rc0
#
# version 1.0
#
# Description:
#	Sets up the variables for freeloader.
#
# Author(s) [in order of work date]:
#	m4rc0 <janssenmaj@gmail.com>
#
# Major revisions:
#	
#
#
# NVRAM variables referenced:
#   none
#
# Configuration files referenced:
#   /etc/config/freeloader
#
#

header "Freeloader" "freeloader-setup_subcategory#Setup" "@TR<<freeloader-log_Freeloader_log#Freeloader setup>>"
#Include settings
. /usr/lib/webif/freeloader-include.sh
#load_settings freeloader
freeloader_init_config


#Check the required packages
is_package_installed "curl"
pkg_curl=$?
is_package_installed "ctorrent"
pkg_ctorrent=$?
is_package_installed "nzbget"
pkg_nzbget=$?

if [ $pkg_nzbget -eq "0" ] || [ $pkg_ctorrent -eq "0" ] || [ $pkg_curl -eq "0" ]; then
	echo "Download root = $CONFIG_download_root <br />"
	echo "Download enable = $CONFIG_download_enable <br />"
	echo "<br />"
	echo "Ctorrent downloadrate = $CONIG_ctorrent_downloadrate <br />"
	echo "Ctorrent uploadrate = $CONFIG_ctorrent_uploadrate <br />"
	echo "<br />"
	echo "Email enable = $CONFIG_email_enable <br />"
	echo "Email email from = $CONFIG_email_emailfrom <br />"
	echo "Email email to = $CONFIG_email_emailto <br />"
	echo "Email email smtpserver = $CONFIG_email_smtpserver <br />"
	echo "<br />"
	echo "Curl ftplogin = $CONFIG_curl_ftplogin <br />"
	echo "Curl ftppassword = $CONFIG_curl_ftppasswd <br />"
else
	echo "<p>@TR<<freeloader-common_None_required_installed#None of the required packages are installed, check the <a href=\"freeloader-upload.sh\">upload-page</a> to install the packages.>></p>"
fi

#uci_load "freeloader"
#uci_set "freeloader" "email" "emailfrom" "uci@open.nl"
#uci_commit "freeloader"

footer ?>
<!--
##WEBIF:name:Freeloader:40:freeloader-setup_subcategory#Setup
-->
