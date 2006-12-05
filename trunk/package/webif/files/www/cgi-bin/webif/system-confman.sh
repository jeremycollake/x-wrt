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

header "System" "Backup" "@TR<<Backup and Restore>>" ''

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
		echo "<p>Generated <a href=\"/config.tgz\">config.tgz</a></p>"
		echo "<script language=\"JavaScript\" type=\"text/javascript\">"
		echo "window.setTimeout('window.location=\"/config.tgz\"', 5000);"
		echo "</script>"
		;;
	instconfig)
		dir=$FORM_dir
		display_form <<EOF
start_form|Install Configuration
EOF
	if [ -n "$dir" ] && [ -d $dir ] && \
		[ -e "$dir/config.name" ] && [ -e "$dir/config.boardtype" ]; then
			echo "<tr><td colspan=2>installing configuration<br><pre>"
			cd $dir
			for file in $(find etc); do
				if [ -d $file ]; then
					[ -d /$file ] || mkdir /$file
				else
					[ -e /$file ] && rm /$file
					cp $file /$file
					echo "restoring $file"
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
					print "echo \"setting " $1 "=\\\"" $2 "\\\"\"" >> "nvram.sh"
					print "nvram set " $1 "=\"" v "\"" >> "nvram.sh"
				}
			' nvram.set
		sh nvram.sh
		echo "committing NVRAM settings"
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
		if [ -n "$FORM_configfile" ] && [ -e $FORM_configfile ]; then
			cat<<EOF
<form method="GET" name="install" action="$SCRIPT_NAME">
EOF
			display_form <<EOF
start_form|Install Configuration
EOF
			rm -rf /tmp/config.* 2>/dev/null
			tmp=/tmp/config.$$
			mkdir $tmp
			(cd $tmp; tar xzf $FORM_configfile)
			rm $FORM_configfile

			if [ ! -e "$tmp/config.name" ] || [ ! -e "$tmp/config.boardtype" ]; then
				echo "<tr><td colspan=2>Invalid config.tgz file!</td></tr>"
			else
				nm=$(cat $tmp/config.name)
				bd=$(cat $tmp/config.boardtype)
				dt=$(cat $tmp/config.date)
				if [ "$bd" != $(nvram get boardtype) ]; then
					echo "<tr><td colspan=2><font color=red>WARNING</font>: different board type (ours: $(nvram get boardtype), file: $bd)!</td></tr>"
				else
					echo "<tr><td colspan=2>configuration looks good!</td></tr>"
				fi
				display_form <<EOF
field|@TR<<Config Name>>
string|$nm
field|@TR<<Board Type>>
string|$bd
field|@TR<<Generated>>
string|$dt
field
string|@TR<<NVRAM settings to set (by prefix; be careful!)>><br>
$(for pfix in $NVRAM_PREFIX $NVRAM_VARS; do echo "checkbox|$pfix|$FORM_pfix|y|$pfix<br>"; done)
EOF
			fi
			display_form <<EOF
hidden|action|instconfig
hidden|dir|$tmp
submit|Install Config|Install Config
end_form
EOF
			cat<<EOF
</form>
EOF
		fi
		;;
	esac

display_form <<EOF
start_form|@TR<<Download Configuration>>
EOF

cat <<EOF
<form method="GET" name="download" action="$SCRIPT_NAME">
<input type="hidden" name="action" value="download">
	<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
	<tbody>
		<tr>
			<td>@TR<<Name this configuration>></td>
			<td>
				<input name="name" value="${FORM_name:-$(nvram get wan_hostname)}"/>
			</td>
		</tr>
		<tr>
			<td />
			<td>
			<input id="form_submit" type="submit" name="submit" value="@TR<<Download>>" />
			</td>
		</tr>
	</tbody>
	</table>
</form>
EOF

display_form <<EOF
end_form|
EOF

display_form <<EOF
start_form|@TR<<Upload Configuration>>
EOF

cat<<EOF
<form method="POST" name="instconfig" action="$SCRIPT_NAME" enctype="multipart/form-data">
<input type="hidden" name="action" value="chkconfig">
	<table style="width: 90%; text-align: left;" border="0" cellpadding="2" cellspacing="2" align="center">
	<tbody>
		<tr>
			<td>@TR<<Saved config.tgz file:>></td>
			<td>
				<input type="file" name="configfile" />
			</td>
		</tr>
		<tr>
			<td />
			<td>
			<input id="form_submit" type="submit" name="submit" value="@TR<<Submit>>" />
			</td>
		</tr>
	</tbody>
	</table>
</form>
EOF

display_form <<EOF
end_form|
EOF

footer
?>
<!--
##WEBIF:name:System:450:Backup
-->
