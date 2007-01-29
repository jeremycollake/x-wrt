#!/usr/bin/webif-page -p /bin/sh
. /usr/lib/webif/webif.sh

header "System" "Upgrade" "@TR<<Firmware Upgrade>>"

#####################################################################
do_upgrade() {
	! empty "$BOOT_WAIT" && {
		echo "<br />@TR<<Turning boot_wait on>> ..."
		nvram set boot_wait=on
		nvram commit
	}
	echo "<br />@TR<<Upgrading firmware, please wait>> ... <br />"	
	# free some memory :)
	ps | grep -vE 'Command|init|\[[kbmj]|httpd|haserl|bin/sh|awk|kill|ps|webif' | awk '{ print $1 }' | xargs kill -KILL
	MEMFREE="$(awk 'BEGIN{ mem = 0 } ($1 == "MemFree:") || ($1 == "Cached:") {mem += int($2)} END{print mem}' /proc/meminfo)"
	empty "$ERASE_FS" || MTD_OPT="-e linux"
	if [ $(($MEMFREE)) -ge 4096 ]; then
		bstrip "$BOUNDARY" > /tmp/firmware.bin
		mtd $MTD_OPT -q -r write /tmp/firmware.bin linux
	else
		# Not enough memory for storing the firmware on tmpfs
		bstrip "$BOUNDARY" | mtd $MTD_OPT -q -q -r write - linux
	fi
	echo "@TR<<done>>."
}

#####################################################################
read_var() {
	NAME=""
	while :; do
		read LINE
		LINE="${LINE%%[^0-9A-Za-z]}"
		equal "$LINE" "$BOUNDARY" && read LINE
		empty "$NAME$LINE" && exit
		case "${LINE%%:*}" in
			Content-Disposition)
				NAME="${LINE##*; name=\"}"
				NAME="${NAME%%\"*}"
			;;
		esac
		empty "$LINE" && return
	done
}

#####################################################################
NOINPUT=1

display_form <<EOF
start_form|
EOF

#####################################################################
equal "$REQUEST_METHOD" "GET" && {
	cat <<EOF
	<script type="text/javascript">

function statusupdate() {
	document.getElementById("form_submit").style.display = "none";
	document.getElementById("status_text").style.display = "inline";

	return true;
}
function printStatus() {
	document.write('<div style="display: none; font-size: 14pt; font-weight: bold;" id="status_text" />@TR<<Upgrading...>>&nbsp;</div>');
}
	</script>
	<form method="POST" name="upgrade" action="$SCRIPT_NAME" enctype="multipart/form-data" onSubmit="statusupdate()">
	<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
	<tbody>
		<tr>
			<td>@TR<<Boot_Wait_Force|Turn 'boot wait' ON>>:
			<td>
				<input type="checkbox" name="boot_wait" value="1" />
			</td>
		</tr>				
		<tr>
			<td>@TR<<Erase_JFFS2|Erase JFFS2 partition>>:
			<td>
				<input type="checkbox" name="erase_fs" value="1" />
			</td>
		</tr>
		<tr>
			<td>@TR<<Firmware_image|Firmware image:>></td>
			<td>
				<input type="file" name="firmware" />
			</td>
		</tr>
		<tr>
			<td />
			<td>
				<script type="text/javascript">printStatus()</script>
				<input id="form_submit" type="submit" name="submit" value="@TR<<Upgrade>>" onClick="statusupdate()" />
			</td>
		</tr>
	</tbody>
	</table>
	</form>
EOF
}
#####################################################################
equal "$REQUEST_METHOD" "POST" && {
	equal "${CONTENT_TYPE%%;*}" "multipart/form-data" || ERR=1
	BOUNDARY="${CONTENT_TYPE##*boundary=}"
	empty "$BOUNDARY" && ERR=1

	empty "$ERR" || {
		echo "Wrong data format"
		footer
		exit
	}
cat <<EOF
	<div style="margin: auto; text-align: left">
<pre>
EOF
	while :; do
		read_var
		empty "$NAME" && exit
		case "$NAME" in
			boot_wait)
				BOOT_WAIT=1;;
			erase_fs)
				ERASE_FS=1
				bstrip "$BOUNDARY" > /dev/null
			;;
			firmware) do_upgrade;;
		esac
	done
cat <<EOF
	</div>
EOF
}

display_form <<EOF
helpitem|Turn boot wait on
helptext|HelpText Turn_boot_wait_on#This option will cause boot_wait to be set prior to flashing the firmware image. When boot_wait is set most units will wait a few seconds at boot-up to see if anyone sends them a new firmware image via TFTP. This is useful in case the firmware upgrade flash corrupts your router's firmware.
helpitem|Erase JFFS2
helptext|HelpText Erase_JFFS2#This option is only useful when flashing a third-party firmware. Always select it when doing so. When upgrading to a new OpenWrt image, the JFFS2 partition is always erased.
helpitem|Firmware Image
helptext|HelpText Firmware_Image#You can choose any compatible BIN or TRX image.
end_form|
EOF

footer

##WEBIF:name:System:900:Upgrade
