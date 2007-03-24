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

# Set the working directories
DOWNLOAD_ROOT="/mnt/bulky/Downloads"

QUEUE_NORMAL="$DOWNLOAD_ROOT/downloadnormal"
QUEUE_PRIO="$DOWNLOAD_ROOT/downloadprio"
QUEUE_DONE="$DOWNLOAD_ROOT/downloaddone"
QUEUE_ABORT="$DOWNLOAD_ROOT/downloadabort"
LOG_DIRECTORY="$DOWNLOAD_ROOT/downloadlog"
DOWNLOAD_TEMP="$DOWNLOAD_ROOT/downloadtemp"
DOWNLOAD_DESTINATION="$DOWNLOAD_ROOT"

# Set email settings
EMAIL_FROM="freeloader@zonnet.nl"
EMAIL_TO="janssenmaj@hotmail.com"
EMAIL_SMTP="smtp.versatel.nl"

#functions
mailstatus()
{
	echo $1 | mini_sendmail -f$EMAIL_FROM -s$EMAIL_SMTP $EMAIL_TO
}

logstatus()
{
	echo `date` -- $1 >> "$LOG_DIRECTORY/freeloader.log"
}

