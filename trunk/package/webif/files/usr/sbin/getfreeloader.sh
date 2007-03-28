#!/bin/sh

###################################################################
# getfreeloader.sh
# (c)2007 X-Wrt project (http://www.x-wrt.org)
# (c)2007-02-15 m4rc0
#
#	version 1.22
#
# Description:
#	Checks for files in the queues and downloads them.
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
#   /etc/freeloader-include.sh
#
#

#Include settings
. /etc/freeloader-include.sh

#Get the WAN IP address
WAN=$(nvram get wan_ifname)
WAN_IP=`/sbin/ifconfig | grep -A 4 $WAN | awk '/inet/ { print $2 } ' | sed -e s/addr://` 


#this LS command is needed because otherwise the abort.lock and suspend.lock will not be found, some kind of caching problem on CIFS shares
ls "$DOWNLOAD_DESTINATION"  > /dev/null 2>&1

if ! [ -f $DOWNLOAD_DESTINATION/suspend.lock ]; then

	#check if ctorrent is running
	if ! [ -f /tmp/freeloader.lock ]; then

		#Get the PID of this running script
		touch /tmp/freeloader.lock

		#check if there are .torrent or .link files in the PRIO queue
		if [ "`ls $QUEUE_PRIO/*.link $QUEUE_PRIO/*.torrent $QUEUE_PRIO/*.nzb`" != '' ]; then
			#Set the current working queue as the PRIO queue
			QUEUE_DIR="$QUEUE_PRIO"
	
			#create a prio.lock file
			touch /tmp/prio.lock
		else
			#Set the current working queue as the normal queue
			QUEUE_DIR="$QUEUE_NORMAL"
		fi	
	
		#for all the .torrent, .nzb and .link files in the queueu do the following
		#Used the while read loop to handle spaces in the filename.
		ls $QUEUE_DIR/*.torrent $QUEUE_DIR/*.link $QUEUE_DIR/*.nzb | while read DOWNLOADFILE
		do
			#Get only the filename from the path
			DOWNLOADFILE=`echo "$DOWNLOADFILE" | awk '{n=split($0,fn,"/"); print fn[n]}'`

			#replace [ & ] with _ in the filenames
			DOWNLOADFILE_ORG=$DOWNLOADFILE
			DOWNLOADFILE_TEMP=`echo "$DOWNLOADFILE" | awk 'gsub(/\[/,"_");'`
			if [ -z "$DOWNLOADFILE_TEMP" ]; then
				DOWNLOADFILE_TEMP=`echo "$DOWNLOADFILE" | awk 'gsub(/\]/,"_");'`
				if [ -n "$DOWNLOADFILE_TEMP" ]; then
					DOWNLOADFILE=$DOWNLOADFILE_TEMP
				fi
			else
				DOWNLOADFILE=$DOWNLOADFILE_TEMP
				DOWNLOADFILE_TEMP=`echo "$DOWNLOADFILE" | awk 'gsub(/\]/,"_");'`
				if [ -n "$DOWNLOADFILE_TEMP" ]; then
					DOWNLOADFILE=$DOWNLOADFILE_TEMP
				fi
			fi	

			mv "$QUEUE_DIR/$DOWNLOADFILE_ORG" "$QUEUE_DIR/$DOWNLOADFILE"

			#Get only the extension from the filename
			EXT_DOWNLOADFILE=`echo "$DOWNLOADFILE" | awk '{n=split($0,ext,"."); print ext[n]}'`
	
			#set the download directory
			mkdir "$DOWNLOAD_DESTINATION/$DOWNLOADFILE"
			cd "$DOWNLOAD_DESTINATION/$DOWNLOADFILE"

			#mail the currently downloading filename 
			mailstatus "The download $DOWNLOADFILE is started."

			#log status
			logstatus "The download $DOWNLOADFILE is started."

			
			#set the 'current' files for further processing by other scripts 
			echo "$DOWNLOADFILE.log" > /tmp/currentlogfile
			echo "$DOWNLOADFILE" > /tmp/currentdownloadfile
			echo "$EXT_DOWNLOADFILE" > /tmp/currentdownloadextension
			
			#check if the downfile still exists in the queue
			if [ -f "$QUEUE_DIR/$DOWNLOADFILE" ]; then
				if [ "$EXT_DOWNLOADFILE" = "torrent" ]; then
					#download the desired file with ctorrent and log the output to the logfile
					ctorrent -C 0 -e 0 -i $WAN_IP -M 20 "$QUEUE_DIR/$DOWNLOADFILE" > "$LOG_DIRECTORY/$DOWNLOADFILE.log" 2>&1
		
					#Get this exitcode 
					EXITCODE=$?
				elif [ "$EXT_DOWNLOADFILE" = "link" ]; then

					#remove the \r (^M) from the .link file for dos-text uploads via FTP.
					tr -d '\r' < "$QUEUE_DIR/$DOWNLOADFILE" > "$QUEUE_DIR/$DOWNLOADFILE.tmp" 
					mv "$QUEUE_DIR/$DOWNLOADFILE.tmp" "$QUEUE_DIR/$DOWNLOADFILE"

					#this LS command is needed because otherwise the .fci will not be found, some kind of caching problem on CIFS shares
					ls "$QUEUE_DIR"  > /dev/null 2>&1

					if [ -f "$QUEUE_DIR/$DOWNLOADFILE.fci" ]; then
						#remove the \r (^M) from the .fci file for dos-text uploads via FTP.
						tr -d '\r' < "$QUEUE_DIR/$DOWNLOADFILE.fci" > "$QUEUE_DIR/$DOWNLOADFILE.tmp" 
						mv "$QUEUE_DIR/$DOWNLOADFILE.tmp" "$QUEUE_DIR/$DOWNLOADFILE.fci"
					fi

					#get the username password from resp. line 1 and line2
					URL_USERNAME=`sed -n 1p "$QUEUE_DIR/$DOWNLOADFILE.fci"|awk '{n=split($0,fn,"="); print fn[n]}'`
					URL_PASSWORD=`sed -n 2p "$QUEUE_DIR/$DOWNLOADFILE.fci"|awk '{n=split($0,fn,"="); print fn[n]}'`
					
					#if both (username/pasword) are filled then set the URL_OPTIONS
					if [ -n "$URL_USERNAME" ] && [ -n "$URL_PASSWORD" ]; then
						URL_OPTIONS="-u $URL_USERNAME:$URL_PASSWORD"
					fi
					
					#get the link from line 3.
					#URL=`sed -n 1p "$QUEUE_DIR/$DOWNLOADFILE"`
					#download the desired file with curl and log the output to the logfile
					#curl -C - -O $URL_OPTIONS $URL --stderr "$LOG_DIRECTORY/$DOWNLOADFILE.log"

					while read URL
					do
						#download the desired file with curl and log the output to the logfile
						curl -C - -O $URL_OPTIONS $URL --stderr "$LOG_DIRECTORY/$DOWNLOADFILE.log"
					done < "$QUEUE_DIR/$DOWNLOADFILE"
			
					#Get this exitcode 
					EXITCODE=$?
				elif [ "$EXT_DOWNLOADFILE" = "nzb" ]; then
					nzbget -n -c /etc/nzbget.cfg -d "$DOWNLOAD_DESTINATION/$DOWNLOADFILE" -t "$DOWNLOAD_TEMP" -m colored "$QUEUE_DIR/$DOWNLOADFILE" > $LOG_DIRECTORY/$DOWNLOADFILE.log 2>&1

					#Get this exitcode 
					EXITCODE=$?

					#Clean up the TEMP directory
					rm "$DOWNLOAD_TEMP"/*
				fi
		
				#log status
				logstatus "The download $DOWNLOADFILE exited with exitcode $EXITCODE"


				#if terminated normal mail this status and moce the .torrent file the done directory
				if [ "$EXITCODE" -eq '0' ]; then 
					mv "$QUEUE_DIR/$DOWNLOADFILE" "$QUEUE_DONE/$DOWNLOADFILE"
					if [ -f "$QUEUE_DIR/$DOWNLOADFILE.fci" ]; then
						mv "$QUEUE_DIR/$DOWNLOADFILE.fci" "$QUEUE_DONE/$DOWNLOADFILE.fci"
					fi
					mailstatus "$DOWNLOADFILE is succesfully finished."
	
				#if termimanted by a "KILL" move the .torrent/.link file to the abort directory and this status
				elif [ "$EXITCODE" -eq '137' ]; then
					mv "$QUEUE_DIR/$DOWNLOADFILE" "$QUEUE_ABORT/$DOWNLOADFILE"
					if [ -f "$QUEUE_DIR/$DOWNLOADFILE.fci" ]; then
						mv "$QUEUE_DIR/$DOWNLOADFILE.fci" "$QUEUE_ABORT/$DOWNLOADFILE.fci"
					fi
					mailstatus "$DOWNLOADFILE is aborted." 	
				else
					mv "$QUEUE_DIR/$DOWNLOADFILE" "$QUEUE_ABORT/$DOWNLOADFILE"
					if [ -f "$QUEUE_DIR/$DOWNLOADFILE.fci" ]; then
						mv "$QUEUE_DIR/$DOWNLOADFILE.fci" "$QUEUE_ABORT/$DOWNLOADFILE.fci"
					fi
					mailstatus "An error has been reported for $DOWNLOADFILE (errorcode=$EXITCODE)." 	
				fi 
			else
				#log status
				logstatus "The download $DOWNLOADFILE was not found in the queue."

				mailstatus "An error has been reported. $DOWNLOADFILE was been removed from the queue and can not be found by getdownload."
			fi

			#remove the control files
			rm /tmp/currentlogfile
			rm /tmp/currentdownloadfile
			rm /tmp/currentdownloadextension

			sleep 5

		done
		
		#remove the PID file of getdownload
		rm /tmp/freeloader.lock

		#if the prio.lock file exists remove it.
		if [ -f /tmp/prio.lock ]; then
			rm /tmp/prio.lock
		fi
	fi
fi