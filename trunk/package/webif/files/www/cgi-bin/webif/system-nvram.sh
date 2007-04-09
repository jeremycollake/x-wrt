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
MAX_VALUE_LEN=248

header_inject_head=$(cat <<EOF
<style type="text/css">
<!--
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
	validate <<EOF
string|FORM_nvramvar|@TR<<system_nvram_New_Variable#New Variable Name>>|required nospaces|$FORM_nvramvar
EOF
	equal "$?" 0 && {
		FORM_action_add="$FORM_action_new"
		FORM_nvramvar="$FORM_new_nvramvar"
		unset FORM_action_new
	}
}
# delete variable
! equal "$FORM_action_delete" "" && ! equal "$FORM_confirm" "" && {
	SAVED=1
	#save_setting system "$FORM_nvramvar" ""
	nvram unset "$FORM_nvramvar" 2>/dev/null
	nvram commit
	unset FORM_action_delete
	unset FORM_confirm
}
# change value
! equal "$FORM_action_change" "" && ! equal "$(set | grep FORM_newvalue)" "" && {
	SAVED=1
	#sanitize - it needs more work and sync with save_settings!
	#temp_value=$(echo "$FORM_newvalue" | sed 's/"/\\"/;')
	save_setting system "$FORM_nvramvar" "$FORM_newvalue"
	unset temp_value
	unset FORM_action_change
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
helptext|system_nvram_Delete_Setting_helptext#The configuration system is not equipped with functions for deleting the NVRAM variable. Therefore the variable is deleted by this script immediately after pressing the button. Be sure you know what you are doing before pressing the button!
end_form
EOF
elif [ "$FORM_action_change" != "" ] || [ "$FORM_action_add" != "" ]; then
	FORM_newvalue=$(nvram get "$FORM_nvramvar" 2>/dev/null)
	if [ "$FORM_newvalue" == "" ]; then
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
end_form
EOF
else
	display_form <<EOF
start_form|@TR<<system_nvram_Add_System_Setting#Add System Setting>>
field|@TR<<system_nvram_New_Variable#New Variable Name>>
text|new_variable|$FORM_new_variable
field|&nbsp;
submit|add_variable|@TR<<system_nvram_Add_new_variable#Add new variable>>
helpitem|system_nvram_NVRAM#NVRAM
helptext|system_nvram_NVRAM_helptext#NVRAM stands for Non-Volatile RAM, in this case the last 64K of the flash chip used to store various configuration information in a name=value format.
end_form
EOF
	cat << EOF
<div class="settings">
<h3>@TR<<system_nvram_General_System_Settings#General System Settings>></h3>
<h4 class="warning">@TR<<Warning>>: @TR<<system_nvram_warn_nvram#Changing these settings may result in permanent damage to your device.>></h4>
<h4>@TR<<system_nvram_inform_apply#Changes will not take effect until you choose "Apply Changes".>></h4><br />

<div id="nvramtable">
<table>
<tbody>
<tr>
	<th class="var">@TR<<system_nvram_th_Change_Variable#Change Variable>></th>
	<th>&nbsp;</th>
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
			print tr_ind "<tr>"
			odd--
		} else {
			print tr_ind "<tr class=\"odd\">"
			odd++
		}
		value=$2
		for (i=3; i<=NF; i++) value=value "=" $i
		if (length(value) > max_val_len) value=substr(value, 1, max_val_len) "..."
		if ((length(value) == 0) || (value == " ")) value="&nbsp;"
		else {
			gsub(/&/, "&amp;", value)
			gsub(/</, "&lt;", value)
			gsub(/>/, "&gt;", value)
		}
		print "<td><a href=\"" url "?action_change=Change&amp;nvramvar=" $1 "\" title=\"@TR<<system_nvram_Change_the_value#Change the value>>\">" $1 "</a></td>"
		print "<td>=</td>"
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
	USED_NVRAM=$(echo "$nvram_totals" | sed 's/size: \([[:digit:]]\{1,5\}\).*/\1/')
	FREE_NVRAM=$(echo "$nvram_totals" | sed 's/.*(\([[:digit:]]\{1,5\}\) .*).*/\1/')
	[ "$USED_NVRAM" -ge 0 ] >/dev/null 2>&1 &&  [ "$FREE_NVRAM" -ge 0 ] >/dev/null 2>&1 && {
		TOTAL_NVRAM=$(($USED_NVRAM + $FREE_NVRAM))
		NVRAM_PERCENT_USED=$((100 -($FREE_NVRAM/($TOTAL_NVRAM/100))))

		display_form <<EOF
start_form|@TR<<system_nvram_NVRAM_Usage#NVRAM Usage>>
string|<tr><td>@TR<<system_nvram_Total#Total>>: $TOTAL_NVRAM B</td><td>
progressbar|nvramuse|@TR<<system_nvram_Used#Used>>: $USED_NVRAM B ($NVRAM_PERCENT_USED%)|200|$MEM_PERCENT_USED|$NVRAM_PERCENT_USED%||
helpitem|system_nvram_NVRAM_Usage#NVRAM Usage
helptext|system_nvram_NVRAM_Usage_helptext#This is the current NVRAM usage. The graph shows how much memory is available for other variables.
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
