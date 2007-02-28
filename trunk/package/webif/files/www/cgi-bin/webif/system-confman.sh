#!/usr/bin/webif-page "-U /tmp -u 4096"
<?

COPY_FILES="\
/etc/hosts \
/etc/ethers \
/etc/ppp/options.* \
/etc/ppp/users.* \
/etc/ppp/peers.* \
/etc/openvpn/ca.crt \
/etc/openvpn/client.crt \
/etc/openvpn/client.key \
/etc/openvpn/client.p12 \
/etc/openvpn/secret.key \
/etc/dyndns.org-ip*"

COPY_DIRS="\
/etc/ipkg \
/etc/chilli \
/etc/wifidog \
/etc/dropbear \
/etc/config"

NVRAM_PREFIX="\
wan_ \
lan_ \
wl0_ \
wl_ \
dhcp_ \
ipkg_ \
shape_ \
pptp_ \
ppp_ \
wifi_ \
openvpn_ \
hs_"

NVRAM_VARS="\
boot_wait"

. /usr/lib/webif/webif.sh

header "System" "Backup &amp; Restore" "@TR<<Backup and Restore>>" ''

DOWNLOAD()
{
cat <<EOF
&nbsp;&nbsp;&nbsp;@TR<<confman_noauto_click#If downloading does not start automatically, click here>> ... <a href="/$1">$1</a><br><br>
<script language="JavaScript" type="text/javascript">
setTimeout('top.location.href=\"/$1\"',"300")
</script>
EOF
}

case "$FORM_action" in
	download)

	tmp=/tmp/config.$$
	tgz=/www/config.tgz
	rm -rf $tmp 2>/dev/null
	mkdir -p $tmp 2>/dev/null
	date > $tmp/config.date
	echo "$FORM_name" > $tmp/config.name

	echo $(nvram get boardtype) > $tmp/config.boardtype
	for pfix in $NVRAM_PREFIX $NVRAM_VARS; do
		nvram show 2>/dev/null | grep "^$pfix" >> $tmp/nvram
	done

		for file in $COPY_FILES; do
			[ -e $file ] && [ ! -h $file ] && {
			d=`dirname $file`; [ -d $tmp$d ] || mkdir -p $tmp$d
			cp $file $tmp$file
			}
		done
		for dir in $COPY_DIRS; do
			[ -e $dir ] && {
			mkdir -p $tmp$dir
			cp -r $dir/* $tmp$dir/
			}
		done
	(cd $tmp; tar czf $tgz *)
	rm -rf $tmp 2>/dev/null
	DOWNLOAD config.tgz

	;;
	instconfig)

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

			rm -f nvram.set
			for pfix in $NVRAM_PREFIX $NVRAM_VARS; do
				[ "$(eval echo \$FORM_$pfix)" = "y" ] && grep "^$pfix" nvram >> nvram.set
			done
		[ -e nvram.set ] && {
			awk 'BEGIN {
				FS="="
				}
				{
					v=$2
					gsub(/[$]/,"\\$",v)
					print "echo \"@TR<<confman_setting#setting>> " $1 "=\\\"" $2 "\\\"\"" >> "nvram.sh"
					print "nvram set " $1 "=\"" v "\"" >> "nvram.sh"
				}
			' nvram.set
		sh nvram.sh
		echo "@TR<<confman_comitting_nvram#Committing NVRAM settings.>>"
		nvram commit

		}
		echo "</pre></td></tr>"
	else
		echo "<p>bad dir: $dir</p>"
	fi
	display_form <<EOF
end_form
EOF
	;;
	chkconfig)

		if [ -n "$FORM_configfile" ] && [ -e "$FORM_configfile" ]; then
			
		echo "<form method=\"get\" name=\"install\" action=\"$SCRIPT_NAME\">"

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

	if [ "$bd" != $(nvram get boardtype) ]; then
		echo "<tr><td colspan=\"2\"><font color=\"red\">@TR<<big_warning#WARNING>></font>: @TR<<confman_other_board#different board type>> (@TR<<confman_board_ours#ours>>: $(nvram get boardtype), @TR<<confman_board_file#file>>: $bd)!</td></tr>"
	else
		echo "<tr><td colspan=\"2\">@TR<<confman_good_conf#The configuration looks good>>!<br><br></td></tr>"
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

display_form <<EOF
string|@TR<<NVRAM settings to set (by prefix; be careful!)>><br>
$(for pfix in $NVRAM_PREFIX $NVRAM_VARS; do echo "checkbox|$pfix|$FORM_pfix|y|$pfix<br>"; done)
EOF

	fi
	echo "<br><input type=\"hidden\" name=\"action\" value=\"instconfig\">"
	echo "<input type=\"hidden\" name=\"dir\" value=\"$tmp\">"
	echo "<input type=\"submit\" class=\"flatbtn\"  value=\"@TR<<Restore>>\"><br><br></form>"
fi
		;;
esac
	echo "<form method=\"get\" name=\"download\" action=\"$SCRIPT_NAME\">"
display_form <<EOF
start_form|@TR<<Backup Configuration>>
EOF

cat <<EOF
<tr>
<td width="70%">@TR<<Name this configuration>>:&nbsp;&nbsp;&nbsp;<input name="name" class="flatbtn" value="${FORM_name:-$(nvram get wan_hostname)}"/></td>
<td><input type="hidden" name="action" value="download" /><input class="flatbtn" type="submit" name="submit" value="@TR<<Backup>>" /></td>
</tr>
EOF

display_form <<EOF
end_form|
string|</form>
EOF

echo "<form method=\"post\" name=\"instconfig\" action=\"$SCRIPT_NAME\" enctype=\"multipart/form-data\">"
display_form <<EOF
start_form|@TR<<Restore Configuration>>
EOF

cat<<EOF
<tr>
<td width="70%">@TR<<Saved config.tgz file>>:&nbsp;&nbsp;&nbsp;<input type="file" class="flatbtn" name="configfile" /></td>
<td><input type="hidden" name="action" value="chkconfig" /><input class="flatbtn" type="submit" name="submit" value="@TR<<Restore>>" /></td>
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
