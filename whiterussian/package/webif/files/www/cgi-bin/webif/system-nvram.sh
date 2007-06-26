#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# NVRAM settings page
#
# Description:
#	Allows modification of the NVRAM settings.
#
# Author(s) [in order of work date]:
#   OpenWrt developers (??)
#   luke-jr+openwrt@utopios.org
#   Lubos Stanek <lubek@users.berlios.de>
#
# Sorry, no credit, the page was awful:
#   credit goes to luke-jr+openwrt@utopios.org
#

# max length of the displayed value
MAX_VALUE_LEN=64

header_inject_head=$(cat <<EOF
<style type="text/css">
<!--
#nvramtable a:link {
	text-decoration: none;
}
#nvramtable a:active {
	text-decoration: none;
}
#nvramtable a:visited {
	text-decoration: none;
}
#nvramtable a:hover {
	text-decoration: underline;
}
#nvramtable table {
	width: 96%;
	margin-left: auto;
	margin-right: auto;
	font-size: 0.9em;
}
#nvramtable td {
	padding: 0;
}
#nvramtable .nr {
	text-align: right;
	font-size: 0.7em;
	padding-left: 2px;
}
-->
</style>

EOF
)

# add new variable name
! empty "$FORM_action_new" && {
	# validate
	equal "$(echo "$FORM_new_nvramvar" 2>/dev/null | grep "['\" ]")" "" && {
		FORM_action_add="$FORM_action_new"
		FORM_nvramvar="$FORM_new_nvramvar"
		unset FORM_action_new
	} || {
		ERROR="@TR<<system_nvram_Error_in#Error in>> @TR<<system_nvram_New_Variable#New Variable Name>>: @TR<<system_nvram_Invalid_characters#Invalid characters>><br />"
		unset FORM_action_new
	}
}
# delete variable
! equal "$FORM_action_delete" "" && ! equal "$FORM_confirm" "" && {
	SAVED=1
	#save_setting system "$FORM_nvramvar" ""
	nvram unset "$FORM_nvramvar"
	nvram commit
	unset FORM_action_delete
	unset FORM_confirm
}
# change value
! equal "$FORM_action_change" "" && ! equal "$(set | grep FORM_newvalue)" "" && {
	# validate
	equal "$(echo "$FORM_newvalue" 2>/dev/null | grep "['\"]")" "" && {
		SAVED=1
		save_setting system "$FORM_nvramvar" "$FORM_newvalue"
		unset FORM_action_change
	} || {
		ERROR="@TR<<system_nvram_Error_in#Error in>> @TR<<system_nvram_Variable_Value#Variable Value>>: @TR<<system_nvram_Invalid_characters#Invalid characters>><br />"
	}
}

header "System" "system_nvram_NVRAM#NVRAM" "@TR<<system_nvram_NVRAM#NVRAM>>"

echo "<form enctype=\"multipart/form-data\" action=\"$SCRIPT_NAME\" method=\"post\">"

if [ "$FORM_action_delete" != "" ]; then
	FORM_nvramvalue=$(nvram get "$FORM_nvramvar" 2>/dev/null)
	display_form <<EOF
start_form|@TR<<system_nvram_Delete_Setting#Delete NVRAM Setting>>
field|@TR<<system_nvram_Variable_Name#Variable Name>>
text|nvramvar|$FORM_nvramvar||readonly="readonly"
field|@TR<<system_nvram_Variable_Value#Variable Value>>
text|nvramvalue|$FORM_nvramvalue||readonly="readonly"
string|<input type="hidden" name="confirm" value="yes" />
field|@TR<<system_nvram_Are_you_sure#Are you sure you wish to delete the variable&#63;>>
submit|action_delete|@TR<<system_nvram_action_Delete#Delete>>
submit|action_cancel|@TR<<system_nvram_action_Cancel#Cancel>>
helpitem|system_nvram_Delete_Setting#Delete NVRAM Setting
helptext|system_nvram_Delete_Setting_helptext#The variable will be deleted by this page immediately after pressing the Delete button. Be sure you know what you are doing before pressing it!<br />If you only want to remove the value, return back and modify the variable's value by clearing it.
end_form
EOF
elif [ "$FORM_action_change" != "" ] || [ "$FORM_action_add" != "" ]; then
	# error occured in the changed value
	[ -z "$FORM_newvalue" ] && {
		FORM_newvalue=$(nvram get "$FORM_nvramvar" 2>/dev/null)
	}
	# sanitize for editing
	FORM_newvalue=$(echo "$FORM_newvalue" 2>/dev/null | sed 's/&/\&amp;/; s/"/\&#34;/; s/'\''/\&#39;/; s/\$/\&#36;/; s/</\&lt;/; s/>/\&gt;/; s/\\/\&#92;/; s/|/\&#124;/;')
	if [ -z "$FORM_newvalue" ]; then
		form_heading="@TR<<system_nvram_Add_New_NVRAM_Setting#Add New NVRAM Setting>>"
	else
		form_heading="@TR<<system_nvram_Change_NVRAM_Setting#Change NVRAM Setting>>"
	fi
	display_form <<EOF
start_form|$form_heading
field|@TR<<system_nvram_Variable_Name#Variable Name>>
text|nvramvar|$FORM_nvramvar||readonly="readonly"
field|<strong>@TR<<system_nvram_Variable_Value#Variable Value>></strong>
text|newvalue|$FORM_newvalue||style="width: 100%"
field|&nbsp;
submit|action_change|@TR<<system_nvram_action_Change#Change>>
submit|action_cancel|@TR<<system_nvram_action_Cancel#Cancel>>
helpitem|system_nvram_Variable_Value#Variable Value
helptext|system_nvram_Variable_Value_helptext#Enter the desired value into the input box. The value cannot contain the single quote <b>&#39;</b> (apostrophe) and quotes <b>&quot;</b> symbols.
end_form
EOF
else
	display_form <<EOF
start_form|@TR<<system_nvram_Add_System_Setting#Add System Setting>>
field|@TR<<system_nvram_New_Variable#New Variable Name>>
text|new_nvramvar|$FORM_new_nvramvar
field|&nbsp;
submit|action_new|@TR<<system_nvram_Add_new_variable#Add new variable>>
helpitem|system_nvram_Add_System_Setting#Add System Setting
helptext|system_nvram_Add_System_Setting_helptext#Enter the name of the new variable into the input box. The value cannot contain spaces, the single quote <b>&#39;</b> (apostrophe) and quotes <b>&quot;</b> symbols.
helpitem|system_nvram_General_System_Settings#General System Settings
helptext|system_nvram_General_System_Settings_helptext#General System Settings are stored in the NVRAM. NVRAM stands for Non-Volatile RAM, in this case the last 64K of the flash chip used to store various configuration information in a name=value format.
end_form
EOF
	cat << EOF
<div class="settings">
<h3>@TR<<system_nvram_General_System_Settings#General System Settings>></h3>
<h4 class="warning">@TR<<Warning>>: @TR<<system_nvram_warn_nvram#Changing these settings may result in permanent damage to your device.>></h4>
<h4>@TR<<system_nvram_inform_apply#Changes will not take effect until you choose>>: "@TR<<Apply Changes>>".</h4><br />

<div id="nvramtable">
<table>
<tbody>
<tr>
	<th class="var">@TR<<system_nvram_th_Change_Variable#Change Variable>></th>
	<th>@TR<<system_nvram_th_Current_Value#Current Value>></th>
	<th>@TR<<system_nvram_th_Action#Action>></th>
	<th class="nr">@TR<<system_nvram_th_Nr#Nr.>></th>
</tr>
EOF
	nvram show 2>/dev/null | sort | awk -F "=" \
		-v max_val_len="$MAX_VALUE_LEN" -v url="$SCRIPT_NAME" '
	BEGIN {
		odd = 1
	}
	{
		if (odd == 1) {
			print "<tr>"
			odd--
		} else {
			print "<tr class=\"odd\">"
			odd++
		}
		value=$2
		for (i=3; i<=NF; i++) value=value "=" $i
		if (length(value) > max_val_len) value=substr(value, 1, max_val_len) "..."
		if ((length(value) == 0) || (value == " ")) value="&nbsp;"
		else {
			gsub(/&/, "\\&amp;", value)
			gsub(/</, "\\&lt;", value)
			gsub(/>/, "\\&gt;", value)
		}
		print "<td><a href=\"" url "?action_change=Change&amp;nvramvar=" $1 "\" title=\"@TR<<system_nvram_Change_the_value#Change the value>>\">" $1 "</a></td>"
		print "<td>" value "</td>"
		print "<td><a href=\"" url "?action_delete=Delete&amp;nvramvar=" $1 "\" title=\"@TR<<system_nvram_Delete_the_variable#Delete the variable>>\">@TR<<system_nvram_action_Delete#Delete>></a></td>"
		print "<td class=\"nr\">" NR "</td>"
		print "</tr>"
	}
	END {
		if (NR < 1) print "<td colspan=\"4\">&nbsp;</td>"
	}
'
	cat << EOF
</tbody>
</table>
</div>
</div>
<br />
EOF

	nvram_totals=$(nvram show 2>&1 | sed '/^size: /!d')
	USED_NVRAM=$(echo "$nvram_totals" | cut -d' ' -f2)
	FREE_NVRAM=$(echo "$nvram_totals" | cut -d' ' -f4 | sed 's/(//g')
	! empty "$USED_NVRAM" && ! empty "$FREE_NVRAM" && \
	[ "$USED_NVRAM" -ge 0 ] 2>/dev/null && [ "$FREE_NVRAM" -ge 0 ] 2>/dev/null && {
		TOTAL_NVRAM=$(($USED_NVRAM + $FREE_NVRAM))
		NVRAM_PERCENT_USED=$((100 - ($FREE_NVRAM/($TOTAL_NVRAM/100))))

		display_form <<EOF
start_form|@TR<<system_nvram_NVRAM_Usage#NVRAM Usage>>
string|<tr><td>@TR<<system_nvram_Total#Total>>: $TOTAL_NVRAM @TR<<system_nvram_B#B>></td><td>
progressbar|nvramuse|@TR<<system_nvram_Used#Used>>: $USED_NVRAM @TR<<system_nvram_B#B>> ($NVRAM_PERCENT_USED%)|200|$MEM_PERCENT_USED|$NVRAM_PERCENT_USED%||
helpitem|system_nvram_NVRAM_Usage#NVRAM Usage
helptext|system_nvram_NVRAM_Usage_helptext#This is the current NVRAM usage. The graph shows how much memory is used and how much memory is available for other variables.
end_form
EOF
	}
fi
?>
</form>
<? footer ?>
<!--
##WEBIF:name:System:190:system_nvram_NVRAM#NVRAM
-->
