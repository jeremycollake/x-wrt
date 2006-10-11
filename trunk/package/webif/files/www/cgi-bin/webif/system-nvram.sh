#!/usr/bin/webif-page
<? 
#
# credit goes to luke-jr+openwrt@utopios.org
#
# TODO: this page violates our CSS standards by having style defined in it.
#
#
. /usr/lib/webif/webif.sh
header "System" "NVRAM" "@TR<<NVRAM>>" '' '' ?>

<style type="text/css">
	td {
		vertical-align: top;
		padding-left: 1em;
	}
</style>

<div class="half noBorderOnLeft">
<?
myself=$(basename "$SCRIPT_NAME")
live=false

echo '<form method="POST" action="'"$myself"'">'

cancel="<a href=\"$myself\" style=\"border: 1px solid; background-color: grey; padding: 0.4ex 1em; margin: 0; color: black;\">Cancel</a>"
if [ "$FORM_action" = 'Delete' ]; then
	echo '<h3>@TR<<Delete NVRAM Setting>></h3>'
	echo '<p style="margin-top: 1em; margin-bottom: 1em;">'
	if [ "$FORM_confirm" = 'yes' ]; then
		if $live; then
			if nvram unset $FORM_var; then
				echo "<strong>$FORM_var</strong> has been deleted."
			else
				echo "<br /><br />ERROR: Unable to delete <strong>$FORM_var</strong>!"
			fi
		else
			save_setting system "$FORM_var" ""
			echo "When changes are applied, <strong>$FORM_var</strong> will be deleted."
		fi
		echo '</p>'
		echo "<p><a href=\"$myself\">Return to setting list</a></p>"
	else
		echo "Are you sure you wish to delete <strong>$FORM_var</strong>?"
		echo '</p>'
		echo "$cancel"
		echo '<input type="hidden" name="var" value="'"$FORM_var"'" />'
		echo '<input type="hidden" name="confirm" value="yes" />'
		echo '<input type="submit" name="action" value="Delete" />'
	fi
elif [ "$FORM_action" = 'Change' ] || [ "$FORM_action" = 'Add' ]; then
	value=$(nvram get "$FORM_var")
	if [ "$value" = '' ]; then
		echo '<h3>@TR<<Add New NVRAM Setting>></h3>'
	else
		echo '<h3>@TR<<Change NVRAM Setting>></h3>'
	fi
	if [ "$FORM_newvalue" = '' ]; then
		echo "<div>Set <strong>$FORM_var</strong> to:<br />"
		echo '<input type="hidden" name="var" value="'"$FORM_var"'" />'
		echo "<textarea style=\"width: 90%; height: 10em;\" name=\"newvalue\">$value</textarea><br />"
		echo '<div style="width: 90%; text-align: right;">'
		echo "$cancel"
		echo '<input type="submit" name="action" value="Change" />'
		echo '</div>'
	else
		if $live; then
			if nvram set "$FORM_var"="$FORM_newvalue"; then
				echo "<strong>$FORM_var</strong> set to:<pre>$FORM_newvalue</pre>"
			else
				echo "<br /><br />ERROR: Unable to set <strong>$FORM_var</strong>!"
			fi
		else
			save_setting system "$FORM_var" "$FORM_newvalue"
			echo "When changes are applied, <strong>$FORM_var</strong> will be set to:<pre>$FORM_newvalue</pre>"
		fi
		echo '</p>'
		echo "<p><a href=\"$myself\">Return to setting list</a></p>"
	fi
else
	echo '<h3>@TR<<General System Settings>></h3>'
	echo '<br><font color="red" size=-1>Warning: Changing these settings may result in permenant damage to your router.</font><br><br>'
	if $live; then
		echo '<h4>Changes take effect immediately.</h4><br>'
	else
		echo '<h4>Changes will not take effect until you choose "Apply Changes"</h4><br>'
	fi
	echo '<table style="width: 90%; margin: auto;">'
	echo '<tr><th>Setting Variable</th><th>Current Value</th></tr>'
	actions='Change Delete'
	echo '<tr><td><input style="width: 100%;" name="var"></td><td style="vertical-align: middle;"><em style="font-size: 75%;">New Variable</em></td>'
	echo '<td colspan="2"><input type="submit" name="action" value="Add" style="width: 100%;" /></td>'
	echo '</tr>'
	
	nvram show 2>/dev/null | sed 's,^\([^=]\+\)=.*$,\1,;t;d' | sed '/eou_private_key/d' | sed '/eou_public_key/d' | sed '/sdram_/d' | sort |
	while IFS='=' read name; do
		value=$(nvram get "$name")
		empty "$value" && continue;
		echo '<tr>'
		echo "<td>$name</td>"
		echo "<td><code>$value</code></td>"
		for action in $actions; do
			echo "<td><a href=\"$myself?action=$action&var=$name\">$action</a></td>"
		done
		echo "</tr>"
	done
	echo '	</table>'
fi
?>
</form>
</div>

<? footer ?>
<!--
##WEBIF:name:System:190:NVRAM
-->
