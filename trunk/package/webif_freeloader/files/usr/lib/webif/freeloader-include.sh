# freeloader-include.sh created by m4rc0 02-03-2007
# version 1.3
###################################################################
# freeloader-include.sh
# (c)2007 X-Wrt project (http://www.x-wrt.org)
# (c)2007-03-02 m4rc0
#
#	version 1.3
#
# Description:
#	Holds the major setting for freeloader.
#
# Author(s) [in order of work date]:
#	m4rc0 <janssenmaj@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#   none
#
# Configuration files referenced:
#
#
#

uci_add_section_if_not_exists() {
	local PACKAGE="$1"
	local SECTION="$2"
	local _val
	eval "_val=\$CONFIG_${SECTION}_TYPE" 2>/dev/null
	! equal "$_val" "$PACKAGE" && {
		uci_add "$PACKAGE" "$PACKAGE" "$SECTION"
	}
	[ "$_val" = "$PACKAGE" ]
}

uci_add_option_if_not_exists() {
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	local VALUE="$4"
	local _val
	eval "_val=\$CONFIG_${CONFIG}_${OPTION}" 2>/dev/null
	equal "$_val" "" && {
		uci_set "$PACKAGE" "$CONFIG" "$OPTION" "$VALUE"
	}
	[ "$_val" != "" ]
}

freeloader_commit=0
uci_load "freeloader"
uci_add_section_if_not_exists "freeloader" "download"
[ "$?" != "0" ] && {
	uci_set "freeloader" "download" "root" "/mnt/disc0_1/freeloader"
	freeloader_commit=1
} || {
	uci_add_option_if_not_exists "freeloader" "download" "root" "/mnt/disc0_1/freeloader"
	[ "$?" != "0" ] && freeloader_commit=1
}
uci_add_section_if_not_exists "freeloader" "email"
[ "$?" != "0" ] && {
	uci_set "freeloader" "email" "enable" "0"
	uci_set "freeloader" "email" "emailfrom" "root@localhost"
	uci_set "freeloader" "email" "emailto" "root@localhost"
	uci_set "freeloader" "email" "smtpserver" "127.0.0.1"
	freeloader_commit=1
} || {
	uci_add_option_if_not_exists "freeloader" "email" "enable" "0"
	[ "$?" != "0" ] && freeloader_commit=1
	uci_add_option_if_not_exists "freeloader" "email" "emailfrom" "root@localhost"
	[ "$?" != "0" ] && freeloader_commit=1
	uci_add_option_if_not_exists "freeloader" "email" "emailto" "root@localhost"
	[ "$?" != "0" ] && freeloader_commit=1
	uci_add_option_if_not_exists "freeloader" "email" "smtpserver" "127.0.0.1"
	[ "$?" != "0" ] && freeloader_commit=1
}
[ "$freeloader_commit" -gt 0 ] && {
	uci_commit "freeloader"
	uci_load "freeloader"
}
unset freeloader_commit

# Set the working directories
DOWNLOAD_ROOT="$CONFIG_download_root"
QUEUE_NORMAL="$DOWNLOAD_ROOT/downloadnormal"
QUEUE_PRIO="$DOWNLOAD_ROOT/downloadprio"
QUEUE_DONE="$DOWNLOAD_ROOT/downloaddone"
QUEUE_ABORT="$DOWNLOAD_ROOT/downloadabort"
LOG_DIRECTORY="$DOWNLOAD_ROOT/downloadlog"
DOWNLOAD_TEMP="$DOWNLOAD_ROOT/downloadtemp"
DOWNLOAD_DESTINATION="$DOWNLOAD_ROOT"

# Initialize the directory structure
[ -d "$DOWNLOAD_ROOT" ] && {
	[ ! -d "$QUEUE_NORMAL" ] && mkdir -p "$QUEUE_NORMAL" > /dev/null 2>&1
	[ ! -d "$QUEUE_PRIO" ] && mkdir -p "$QUEUE_PRIO" > /dev/null 2>&1
	[ ! -d "$QUEUE_DONE" ] && mkdir -p "$QUEUE_DONE" > /dev/null 2>&1
	[ ! -d "$QUEUE_ABORT" ] && mkdir -p "$QUEUE_ABORT" > /dev/null 2>&1
	[ ! -d "$LOG_DIRECTORY" ] && mkdir -p "$LOG_DIRECTORY" > /dev/null 2>&1
	[ ! -d "$DOWNLOAD_TEMP" ] && mkdir -p "$DOWNLOAD_TEMP" > /dev/null 2>&1
}

# Set email settings
EMAIL_FROM="$CONFIG_email_emailfrom"
EMAIL_TO="$CONFIG_email_emailto"
EMAIL_SMTP="$CONFIG_email_smtpserver"

# functions
mailstatus()
{
	[ "$CONFIG_email_enable" -gt 0 ] >/dev/null 2>&1 && {
		echo $1 | mini_sendmail -f$EMAIL_FROM -s$EMAIL_SMTP $EMAIL_TO
	}
}

logstatus()
{
	[ -d "$LOG_DIRECTORY" ] && {
		echo "`date` -- $1" >> "$LOG_DIRECTORY/freeloader.log"
	}
}

