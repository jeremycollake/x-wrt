#!/usr/bin/webif-page "-U /tmp -u 4096"
<?

COPY_FILES="/etc/*"

COPY_DIRS="/etc"

. /usr/lib/webif/webif.sh
uci_load "system"

header "System" "Backup &amp; Restore" "<img src=\"/images/bkup.jpg\" alt=\"@TR<<Backup and Restore>>\" />&nbsp;@TR<<Backup and Restore>>" ''

DOWNLOAD()
{
cat <<EOF
&nbsp;&nbsp;&nbsp;@TR<<confman_noauto_click#If downloading does not start automatically, click here>> ... <a href="/$1">$1</a><br><br>
<script language="JavaScript" type="text/javascript">
setTimeout('top.location.href=\"/$1\"',"300")
</script>
EOF
}
if ! equal $FORM_download "" ; then
	
	if equal $FORM_rdflash "1" ; then

		tmp=/tmp/flash_$FORM_name.trx
		tgz=/www/flash_$FORM_name.trx
		mount -o remount,ro /dev/mtdblock/4 / 2>/dev/null
		dd if=/dev/mtdblock/1 > $tmp 2>/dev/null
		ln -s $tmp $tgz 2>/dev/null
		DOWNLOAD flash_$FORM_name.trx
		sleep 25 ; rm $tmp ; rm $tgz
	else

		tmp=/tmp/config.$$
		tgz=/www/config.tgz
		rm -rf $tmp 2>/dev/null
		mkdir -p $tmp 2>/dev/null
		date > $tmp/config.date
		echo "$FORM_name" > $tmp/config.name

	echo $(dmesg | grep "CPU revision is:" | sed -e s/'CPU revision is: '//g) > $tmp/config.boardtype

		for file in $COPY_FILES; do
			[ -e $file ] && [ ! -h $file ] && {
			d=`dirname $file`; [ -d $tmp$d ] || mkdir -p $tmp$d
			cp $file $tmp$file 2>/dev/null
			}
		done
		for dir in $COPY_DIRS; do
			[ -e $dir ] && {
			mkdir -p $tmp$dir
			cp -r $dir/* $tmp$dir/ 2>/dev/null
			}
		done
		(cd $tmp; tar czf $tgz *)
		rm -rf $tmp 2>/dev/null
		DOWNLOAD config.tgz
		sleep 25 ; rm $tgz
	fi

elif ! equal $FORM_instconfig "" ; then

if equal $FORM_rdflash "1" ; then
	echo "<br />@TR<<confman_Restoring_firmware#Restoring firmware, please wait ...>> <br />"
	mtd -r write $FORM_file linux
else

dir=$FORM_dir
display_form <<EOF
start_form|@TR<<Restore Configuration>>
EOF
	if [ -n "$dir" ] && [ -d "$dir" ] && [ -e "$dir/config.name" ] && [ -e "$dir/config.boardtype" ]; then
			echo "<tr><td colspan=\"2\">@TR<<confman_restoring_conf#Restoring configuration.>><br><pre>"
			cd $dir
			for file in $(find etc); do
				if [ -d $file ]; then
					[ -d /$file ] || mkdir /$file
				else
					[ -e /$file ] && rm /$file
					cp $file /$file
					echo "@TR<<confman_restoring_file#restoring>> $file"
				fi
			done

		echo "<br>@TR<<Rebooting now>>...<meta http-equiv=\"refresh\" content=\"4;url=reboot.sh?reboot=1\">"
		echo "</pre></td></tr>"
	else
		echo "<p>@TR<<confman_bad_dir#bad dir>>: $dir</p>"
	fi

display_form <<EOF
end_form
EOF
fi

elif ! equal $FORM_chkconfig "" ; then

		if [ -n "$FORM_configfile" ] && [ -e "$FORM_configfile" ]; then
			
		echo "<form method=\"get\" name=\"install\" action=\"$SCRIPT_NAME\">"
if equal $FORM_rdflash "1" ; then
	echo "<h2><font color=red>@TR<<confman_warn_erase#WARNING !!! This operation will erase current flash.>></font></h2>"
	echo "<input type='hidden' name='rdflash' value='1'><input type='hidden' name='file' value=\"$FORM_configfile\">"	
else
display_form <<EOF
start_form|@TR<<Restore Configuration>>
EOF
			rm -rf /tmp/config.* 2>/dev/null
			tmp=/tmp/config.$$
			mkdir $tmp
			(cd $tmp; tar xzf $FORM_configfile)
			rm $FORM_configfile

			if [ ! -e "$tmp/config.name" ] || [ ! -e "$tmp/config.boardtype" ]; then
				echo "<tr><td colspan=\"2\">@TR<<confman_invalid_file#Invalid file>>: config.tgz!</td></tr>"
			else
				nm=$(cat $tmp/config.name)
				bd=$(cat $tmp/config.boardtype)
				dt=$(cat $tmp/config.date)

			CFGGOOD="<tr><td colspan=\"2\">@TR<<confman_good_conf#The configuration looks good>>!<br><br></td></tr>"

			if [ "$bd" != $(dmesg | grep "CPU revision is:" | sed -e s/'CPU revision is: '//g) ]; then
				echo "<tr><td colspan=\"2\"><font color=\"red\">@TR<<big_warning#WARNING>></font>: @TR<<confman_other_board#different board type>> (@TR<<confman_board_ours#ours>>: $(dmesg | grep "CPU revision is:" | sed -e s/'CPU revision is: '//g), @TR<<confman_board_file#file>>: $bd)!</td></tr>"
			else
				echo $CFGGOOD
			fi
display_form <<EOF
field|@TR<<Config Name>>
string|$nm
field|@TR<<Board Type>>
string|$bd
field|@TR<<Generated>>
string|$dt
field
EOF
			fi
fi
		echo "<input type='hidden' name='dir' value=\"$tmp\">"
		echo "<input type=\"submit\" class=\"flatbtn\" name=\"instconfig\" value=\"@TR<<Restore>>\"><br><br></form>"
		fi
footer
exit
fi

cat <<EOF
<form method="post" name="download" action="$SCRIPT_NAME" enctype="multipart/form-data">
&nbsp;&nbsp;&nbsp;<img src="/images/app.2.jpg" width="24" height="24" alt />&nbsp;<input type="radio" name="rdflash" value="0" checked />&nbsp;@TR<<confman_Configuration#Configuration>>
<br/>
&nbsp;&nbsp;&nbsp;<img src="/images/app.12.jpg" width="25" height="25" alt />&nbsp;<input type="radio" name="rdflash" value="1" />&nbsp;@TR<<confman_Entire_Flash#Entire Flash>><br/><br/>
EOF

display_form <<EOF
start_form|@TR<<Backup Configuration>>
EOF

cat <<EOF
<tr><td width="70%">@TR<<Name this configuration>>:&nbsp;&nbsp;&nbsp;<input name="name" value="${FORM_name:-$CONFIG_system_hostname}"/></td>
<td><input class="flatbtn" type="submit" name="download" value="@TR<<Backup>>" /></td>
</tr>
EOF

display_form <<EOF
end_form
EOF

display_form <<EOF
start_form|@TR<<Restore Configuration>>
EOF

cat<<EOF
<tr>
<td width="70%">@TR<<Saved config.tgz file>>:&nbsp;&nbsp;&nbsp;<input type="file" class="flatbtn" name="configfile" /></td>
<td><input class="flatbtn" type="submit" name="chkconfig" value="@TR<<Restore>>" /></td>
</tr>
EOF

display_form <<EOF
end_form|
string|</form>
EOF

footer
?>
<!--
##WEBIF:name:System:450:Backup &amp; Restore
-->
