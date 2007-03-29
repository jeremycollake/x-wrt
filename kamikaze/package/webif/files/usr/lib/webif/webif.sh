######################################################
# Webif base
#
# Description:
#        Holds primary functions. Header, footer, etc..
#
# Author(s) [in order of work date]:
#        A variety of people. Several X-Wrt developers.
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced:
#

libdir=/usr/lib/webif
wwwdir=/www
cgidir=/www/cgi-bin/webif
rootdir=/cgi-bin/webif
indexpage=index.sh
. /usr/lib/webif/functions.sh
. /lib/config/uci.sh

awk_call() {
	local cmd="$1"; shift
	/usr/bin/awk "$@" -f /usr/lib/webif/common.awk -f - <<EOF
BEGIN {
	$cmd
}
EOF
}

awx_call() {
	local cmd="$1"; shift
	/usr/bin/awk "$@" -f /usr/lib/webif/common.awx -f - <<EOF
BEGIN {
	$cmd
}
EOF
}

categories() {
	awk_call 'categories()' -v CATEGORY="$1" 
}

subcategories() {
	awk_call 'subcategories()' -v CATEGORY="$1" -v PAGENAME="$2" 
}

ShowWIPWarning() {
	echo "<div class=\"warning\">@TR<<big_warning#WARNING>>: @TR<<page_incomplete#This page is incomplete and may not work correctly, or at all.>></div>"
}

ShowUntestedWarning() {
	echo "<div class=\"warning\">@TR<<big_warning#WARNING>>: @TR<<page_untested#This page is untested and may or may not work correctly.>></div>"
}

ShowNotUpdatedWarning() {
       echo "<div class=\"warning\">@TR<<big_warning#WARNING>>: @TR<<page_untested_kamikaze#This page has not been updated or checked for correct functionality under Kamikaze.>></div>"
}

update_changes() {
	CHANGES="$(awk_call 'print num_changes()')"
}

pcnt=0
nothave=0
_savebutton_bk=""

has_pkgs() {
	retval=0;
	for pkg in "$@"; do
		pcnt=$((pcnt + 1))
		empty $(ipkg list_installed | grep "^$pkg ") && {
			echo -n "<p>@TR<<features_require_package#Features on this page require the package>>: \"<b>$pkg</b>\". &nbsp;<a href=\"/cgi-bin/webif/ipkg.sh?action=install&pkg=$pkg&prev=$SCRIPT_NAME\">@TR<<features_install#install now>></a>.</p>"
			retval=1;
			nothave=$((nothave + 1))
		}
	done
	[ -z "$_savebutton_bk" ] && _savebutton_bk=$_savebutton
	if [ "$pcnt" = "$nothave" ]; then
		_savebutton=""
	else
		_savebutton=$_savebutton_bk
	fi
	return $retval;
}

mini_header() {

cat <<EOF
Content-Type: text/html
Pragma: no-cache

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<?xml version="1.0" encoding="@TR<<Encoding|ISO-8859-1>>"?>
<head>
	<link rel="stylesheet" type="text/css" href="/themes/active/webif.css" />        
	<title></title>
	<style type="text/css">
		html, body { background-color: transparent; }
	</style>
</head>
EOF
}

header() {
	empty "$ERROR" && {
		_show_info="${SAVED:+@TR<<Settings saved>>}"
	} || {
		_show_info="@TR<<Settings not saved>>"
	}

	_use_form="$5"
	empty "$REMOTE_USER" && neq "${SCRIPT_NAME#/cgi-bin/}" "webif.sh" && grep 'root:!' /etc/passwd >&- 2>&- && {
		_nopasswd=1
		_use_form=""
		_show_info=""
		ERROR=""
	}

	awx_call "render(\"views/header.ahtml\")" \
		-v CATEGORY="$1" \
		-v PAGENAME="$2" \
		-v page_title="$3" \
		-v html_body_args="$4" \
		-v show_info="$_show_info" \
		-v show_error="$ERROR" \
		-v use_form="$_use_form" \
		-v subcategories_extra="$SUBCATEGORIES_EXTRA" \
		-v html_head="$header_inject_head" \
		-v html_body="$header_inject_body"

	empty "$REMOTE_USER" && neq "${SCRIPT_NAME#/cgi-bin/}" "webif.sh" && {
		empty "$FORM_passwd1" || {
			echo '<pre>'
			(
				echo "$FORM_passwd1"
				sleep 1
				echo "$FORM_passwd2"
			) | passwd root 2>&1 && apply_passwd
			echo '</pre>'
			footer
			exit
		}
		equal "$_nopasswd" 1 && {
			cat <<EOF
<br />
<br />
<br />
<h3>@TR<<Warning>>: @TR<<Password_warning|you haven't set a password for the Web interface and SSH access<br />Please enter one now (the user name in your browser will be 'root').>></h3>
<br />
<br />
EOF
			empty "$NOINPUT" && cat <<EOF
<form enctype="multipart/form-data" action="$SCRIPT_NAME" method="POST">
<table>
	<tr>
		<td>@TR<<New Password>>:</td>
		<td><input type="password" name="passwd1" /></td>
	</tr>
	<tr>
		<td>@TR<<Confirm Password>>:</td>
		<td><input type="password" name="passwd2" /></td>
	</tr>
	<tr>
		<td colspan="2"><input type="submit" name="action" value="@TR<<Set>>" /></td>
	</tr>
</table>
</form>
EOF
			footer
			exit
		} || {
			apply_passwd
		}
	}
}

#######################################################
# footer
#
footer() {
	awx_call "render(\"views/footer.ahtml\")" \
		-v use_form="$_use_form"
}

#######################################################
apply_passwd() {
	case ${SERVER_SOFTWARE%% *} in
		mini_httpd/*)
			grep '^root:' /etc/passwd | cut -d: -f1,2 > $cgidir/.htpasswd
			killall -HUP mini_httpd
			;;
	esac
}

display_form() {
	if empty "$1"; then
		awk -F'|' -f /usr/lib/webif/common.awk -f /usr/lib/webif/form.awk
	else
		echo "$1" | awk -F'|' -f /usr/lib/webif/common.awk -f /usr/lib/webif/form.awk
	fi
}

list_remove() {
	echo "$1 " | awk '
BEGIN {
	RS=" "
	FS=":"
}
($0 !~ /^'"$2"'/) && ($0 != "") {
	printf " " $0
	first = 0
}'
}

handle_list() {
	# $1 - remove
	# $2 - add
	# $3 - submit
	# $4 - validate

	empty "$1" || {
		LISTVAL="$(list_remove "$LISTVAL" "$1") "
		LISTVAL="${LISTVAL# }"
		LISTVAL="${LISTVAL%% }"
		_changed=1
	}

	empty "$3" || {
		validate "${4:-none}|$2" && {
			LISTVAL="$LISTVAL $2"
			_changed=1
		}
	}

	LISTVAL="${LISTVAL# }"
	LISTVAL="${LISTVAL%% }"
	LISTVAL="${LISTVAL:- }"

	if empty "$_changed"; then
		return 255
	else
		return 0
	fi
}

