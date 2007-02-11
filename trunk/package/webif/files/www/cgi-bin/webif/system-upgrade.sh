#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "System" "Upgrade" "@TR<<Firmware Upgrade>>" "" "$SCRIPT_NAME"

#####################################################################
do_upgrade() {
   firmware_file=$1
	! empty "$FORM_boot_wait" && {
		echo "<br />@TR<<Turning boot_wait on>> ..."
		nvram set boot_wait=on
		nvram commit
	}
	echo "<br />@TR<<Upgrading firmware, please wait>> ... <br />"	
	# free some memory :)
	ps | grep -vE 'Command|init|\[[kbmj]|httpd|haserl|bin/sh|awk|kill|ps|webif' | awk '{ print $1 }' | xargs kill -KILL
	MEMFREE="$(awk 'BEGIN{ mem = 0 } ($1 == "MemFree:") || ($1 == "Cached:") {mem += int($2)} END{print mem}' /proc/meminfo)"
	empty "$FORM_erase_jffs" || MTD_OPT="-e linux"
	if [ $(($MEMFREE)) -ge 4096 ]; then		
		echo "@TR<<Flashing firmware ...>><br />"
		mtd $MTD_OPT -q -r write "$firmware_file" linux
		echo "<a href=\"\\\">@TR<<Done>>. @TR<<Click here to continue>>."
	else
		echo "@TR<<ERROR: Out of memory.>>"
	fi
	echo "@TR<<done>>."
}

if ! empty $FORM_do_flash; then
	if empty $FORM_firmware_url; then
		echo "@TR<<You must supply a firmware URL to flash!>> <a href=\"$SCRIPT_NAME\">@TR<<Ok>></a>"		
	else
	  firmware_temp=$(mktemp /tmp/firmware-XXXXXX)
	  rm -f $firmware_temp # mktemp created, wget needs non-existant
		if ! wget $FORM_firmware_url -O $firmware_temp; then
			echo "@TR<<Error downloading firmware! Make sure the URL is valid.>> <a href=\"$SCRIPT_NAME\">@TR<<Ok>></a>"
		else
			do_upgrade "$firmware_temp"
		fi		
	fi
else  
  FORM_erase_jffs=${FORM_erase_jffs:-0}
  FORM_boot_wait=${FORM_boot_wait:-0}
	display_form <<EOF
	start_form
	field|@TR<<URL of New Firmware>>
	text|firmware_url|$FORM_firmware_url||40%
	field|@TR<<Turn boot wait on>>
	radio|boot_wait|$FORM_boot_wait|1|@TR<<Yes>>
	radio|boot_wait|$FORM_boot_wait|0|@TR<<No>>
	field|@TR<<Erase JFFS2>>
	radio|erase_jffs|$FORM_erase_jffs|1|@TR<<Yes>>
	radio|erase_jffs|$FORM_erase_jffs|0|@TR<<No>>
	field|&nbsp;|do_flash_field
	submit|do_flash|@TR<<Upgrade Firmware>>
	helpitem|Firmware URL
	helptext|HelpText firmware_url#This is the URL of the firmware you want to flash. It is not a path on your local computer.
	helpitem|Turn boot wait on
	helptext|HelpText Turn_boot_wait_on#This option will cause boot_wait to be set prior to flashing the firmware image. When boot_wait is set most units will wait a few seconds at boot-up to see if anyone sends them a new firmware image via TFTP. This is useful in case the firmware upgrade flash corrupts your router's firmware.
	helpitem|Erase JFFS2
	helptext|HelpText Erase_JFFS2#This option is only useful when flashing a third-party firmware. Always select it when doing so. When upgrading to a new OpenWrt image, the JFFS2 partition is always erased.
	helpitem|Firmware Image
	helptext|HelpText Firmware_Image#You can choose any compatible BIN or TRX image.
	end_form|
EOF
fi

_savebutton=""

footer
?>
<!--
##WEBIF:name:System:900:Upgrade
-->
