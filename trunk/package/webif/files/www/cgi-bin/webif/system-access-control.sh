#!/usr/bin/webif-page
<?
. "/usr/lib/webif/webif.sh"

###################################################################
# system configuration page
#
# Description:
#	Configures access control for the webif
#
# Author(s) [in order of work date]:
#	Travis Kemen <kemen04@gmail.com>
#
# Major revisions:
#
# Configuration files referenced:
#   /etc/config/webif_access_control
#
REMOTE_USER=root
mkdir /tmp/.webif/

if [ "$FORM_user_add" != "" ]; then
	validate <<EOF
string|FORM_password_add|@TR<<Password>>|required min=5|$FORM_password_add
EOF
	equal "$FORM_password_add" "$FORM_password2_add" || {
		[ -n "$ERROR" ] && ERROR="${ERROR}<br />"
		ERROR="${ERROR}@TR<<Passwords do not match>><br />"
	}
	if [ "${FORM_user_add}" = "root" -o "${FORM_user_add}" = "admin" ]; then
		[ -n "$ERROR" ] && ERROR="${ERROR}<br />"
		ERROR="${ERROR}@TR<<root and admin are already users.>><br />"
	fi
	empty "$ERROR" && {
		password=$(httpd -m $FORM_password_add)
		[ -e /tmp/.webif/file-httpd.conf ] || cp /etc/httpd.conf /tmp/.webif/file-httpd.conf
		echo "/cgi-bin/webif/:${FORM_user_add}:${password}" >> /tmp/.webif/file-httpd.conf
		uci_add "webif_access_control" "accesscontrol" "${FORM_user_add}"
	}
fi
header "System" "Access Control" "@TR<<Access Control>>" ' onload="modechange()" ' "$SCRIPT_NAME"
exists /tmp/.webif/file-httpd.conf && HTTPD_CONFIG_FILE=/tmp/.webif/file-httpd.conf || HTTPD_CONFIG_FILE=/etc/httpd.conf
cat $HTTPD_CONFIG_FILE | awk '
BEGIN {
	FS=":"
	include("/usr/lib/webif/common.awk")
	start_form("Users")
	if ((ENVIRON["FORM_submit"] != "") && ((ENVIRON["FORM_change_password_"$2] != "") || (ENVIRON["FORM_remove_user_"$2] == ""))) system("/bin/rm /tmp/.webif/file-httpd.conf; touch/tmp/.webif/file-httpd.conf")
}
(($1 == "/cgi-bin/webif/") && (($2 != "root") && ($2 != "admin"))) {
	if (ENVIRON["FORM_remove_user_" $2] == "") {
		field($2)
		password("user_"$2, ENVIRON["FORM_user_" $2])
		submit("change_password_"$2, "Change Password")
		submit("remove_user_"$2, "Remove "$2)
	}
}
((ENVIRON["FORM_submit"] != "") && ($1 != "")) {
	if (($1 == "/cgi-bin/webif/") && (ENVIRON["FORM_remove_user_"$2] == "") && (ENVIRON["FORM_change_password_"$2] == "")) {
		print $1":"$2":"$3 >> "/tmp/.webif/file-httpd.conf"
	}
	if ($1 != "/cgi-bin/webif/") {
		print $1":"$2 >> "/tmp/.webif/file-httpd.conf"
	}
	if (ENVIRON["FORM_change_password_"$2] != "") {
		("httpd -m " ENVIRON["FORM_user_"$2]) | getline password
		print $1":"$2":"password >> "/tmp/.webif/file-httpd.conf"
	}
}
END {
	end_form()
	start_form("Add User")
	field("Username")
	textinput3("user_add", ENVIRON["FORM_user_add"])
	field("Password")
	password("password_add")
	field("Confirm Password")
	password("password2_add")
	submit("add_user", "Add User")
	end_form()
}'
exists /tmp/.webif/file-httpd.conf && HTTPD_CONFIG_FILE=/tmp/.webif/file-httpd.conf || HTTPD_CONFIG_FILE=/etc/httpd.conf
users=`cat $HTTPD_CONFIG_FILE | awk '
BEGIN {
	FS=":"
}
($1 == "/cgi-bin/webif/") {
	if (($2 != "root") && ($2 != "admin")) print $2
}`

for user in $users; do
	export user
	grep -H "##[W]EBIF:name:" /www/cgi-bin/webif/*.sh |sed -e 's,^.*/\([a-zA-Z0-9\.\-]*\):\(.*\)$,\2:\1,' |sort -n |awk '
BEGIN {
	FS=":"
	include("/usr/lib/webif/common.awk")
	config_load("webif_access_control")
	start_form("User:" ENVIRON["user"])
}
($2 == "name") {
	if (ENVIRON["FORM_submit"] == "") {
		if ($3 != "Graphs") {
			var = config_get_bool(ENVIRON["user"], $3"_"$4, "0")
		}
		else {
			var = config_get_bool(ENVIRON["user"], "Graphs", "0")
		}
	}
	else {
		if ($3 != "Graphs") {
			varorig = config_get_bool(ENVIRON["user"], $3"_"$4, "0")
			var2 = "FORM_" ENVIRON["user"] "_" $3 "_" $4
			var = ENVIRON[var2]
			if (varorig != var) {
				uci_set("webif_access_control", ENVIRON["user"], $3 "_" $4, var)
			}
		}
		else {
			varorig = config_get_bool(ENVIRON["user"], "Graphs", "0")
			var2 = "FORM_" ENVIRON["user"] "_Graphs"
			var = ENVIRON[var2]
			if (varorig != var) {
				uci_set("webif_access_control", ENVIRON["user"], "Graphs", var)
			}
		}
	}
	if ((category != $3) && ($3 != GRAPHS)) {
		field("<h2>@TR<<"$3">></h2>")
	}
	category = $3
	if ($3 != GRAPHS) {
		if ($3 == "Graphs") {
			GRAPHS = $3
			field("@TR<<Graphs>>")
			select(ENVIRON["user"]"_Graphs", var)
		}
		else {
			field("@TR<<"$5">>")
			select(ENVIRON["user"]"_"$3"_"$4, var)
		}
		option("1", "@TR<<Enabled>>")
		option("0", "@TR<<Disabled>>")
	}
}
END {
	end_form()
}'
done

footer ?>

<!--
##WEBIF:name:System:150:Access Control
-->
