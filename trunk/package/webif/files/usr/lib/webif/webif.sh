###################################################################
# Webif base
#
# Description:
#	Holds primary functions. Header, footer, etc..
#
# Author(s) [in order of work date]:
#	A variety of people. Several X-Wrt developers.
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced:
#
#

libdir=/usr/lib/webif
wwwdir=/www
cgidir=/www/cgi-bin/webif
rootdir=/cgi-bin/webif
indexpage=index.sh
. /usr/lib/webif/functions.sh
. /lib/config/uci.sh

categories() {
	grep '##WEBIF:' $cgidir/.categories $cgidir/*.sh 2>/dev/null | \
		awk -v "selected=$1" \
			-v "rootdir=$rootdir" \
			-v "indexpage=$indexpage" \
			-f /usr/lib/webif/categories.awk -
}

subcategories() {
	grep -H "##WEBIF:name:$1:" $cgidir/*.sh 2>/dev/null | \
		sed -e 's,^.*/\([a-zA-Z\.\-]*\):\(.*\)$,\2:\1,' | \
		sort -n | \
		awk -v "selected=$2" \
			-v "rootdir=$rootdir" \
			-f /usr/lib/webif/subcategories.awk -
}

show_validated_logo() {
	echo "<br /><br />
		<p id=\"validated-text\">This page passed W3C XHTML validation tests.</p>"
}

ShowWIPWarning() {
	echo "<div class=\"warning\">WARNING: This page is incomplete and may not work correctly, or at all.</div>"
}

ShowUntestedWarning() {
	echo "<div class=\"warning\">WARNING: This page is untested and may or may not work correctly.</div>"
}

ShowNotUpdatedWarning() {
       echo "<div class=\"warning\">WARNING: This page has not been updated or checked for correct functionality under Kamikaze.</div>"
}

update_changes() {
	CHANGES=$(($( (cat /tmp/.webif/config-* ; ls /tmp/.webif/file-*) 2>&- | wc -l)))
	EDITED_FILES=$(find "/tmp/.webif/edited-files" -type f 2>&- | wc -l)
	CHANGES=$(($CHANGES + $EDITED_FILES))
	# calculate and add number of pending uci changes
	for uci_tmp_file in $(ls /tmp/.uci/* 2>&-); do
		CHANGES_CUR=$(cat "$uci_tmp_file" | grep CONFIG_SECTION | wc -l)
		CHANGES=$(($CHANGES + $CHANGES_CUR))
		# force CHANGES to be non-zero since with this count method some 
		# pending changes won't be counted.
		equal "$CHANGES" "0" && CHANGES=1
	done
}

pcnt=0
nothave=0
_savebutton_bk=""

has_pkgs() {
	retval=0;
	for pkg in "$@"; do
		pcnt=$((pcnt + 1))
		empty $(ipkg list_installed | grep "^$pkg ") && {
			echo -n "<p>Features on this page require the \"<b>$pkg</b>\" package. &nbsp;<a href=\"/cgi-bin/webif/ipkg.sh?action=install&pkg=$pkg&prev=$SCRIPT_NAME\">install now</a>.</p>"
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
	<link rel="stylesheet" type="text/css" href="/themes/active/style-extend.css" />
	<title></title>
</head>
<style type="text/css">
	html, body {
		background-color: transparent;
	}
</style>
<script type="text/javascript" src="/colorize.js"></script>
<script type="text/javascript"> colorize(); </script>
EOF
}

header() {
	empty "$ERROR" && {
		_saved_title="${SAVED:+: @TR<<Settings saved>>}"
	} || {
		FORM_submit="";
		ERROR="<h3>$ERROR</h3><br /><br />"
		_saved_title=": @TR<<Settings not saved>>"
	}

	_category="$1"
	uci_load "webif"
	_firmware_version="$CONFIG_general_firmware_version"
	_firmware_name="$CONFIG_general_firmware_name"
	_firmware_subtitle="$CONFIG_general_firmware_subtitle"
	_uptime="$(uptime)"
	_loadavg="${_uptime#*load average: }"
	_uptime="${_uptime#*up }"
	_uptime="${_uptime%%,*}"
	_hostname=$(cat /proc/sys/kernel/hostname)
	_webif_rev=$(cat /www/.version)
	_head="${3:+<div class=\"settings-block-title\"><h2>$3$_saved_title</h2></div>}"
	_form="${5:+<form enctype=\"multipart/form-data\" action=\"$5\" method=\"post\"><input type=\"hidden\" name=\"submit\" value=\"1\" />}"
	_savebutton="${5:+<div class=\"page-save\"><input type=\"submit\" name=\"action\" value=\"@TR<<Save Changes>>\" /></div>}"	
	_categories=$(categories $1)
	_subcategories=${2:+$(subcategories "$1" "$2")}

	if equal $CONFIG_general_use_short_status_frame "1"; then
		short_status_frame='<iframe src="/cgi-bin/webif/iframe.mini-info.sh"
				width="200" height="80"  scrolling="no" frameborder="0"></iframe>'
	else
		short_status_frame="<div id=\"short-status\">
						<h3><strong>Status:</strong></h3>
						<ul>
							<li><strong>$_firmware_name $_firmware_version</strong></li>
							<li><strong>@TR<<Host>>:</strong> $_hostname</li>
							<li><strong>@TR<<Uptime>>:</strong> $_uptime</li>
							<li><strong>@TR<<Load>>:</strong> $_loadavg</li>
						</ul>
					</div>"
	fi

	empty "$REMOTE_USER" && neq "${SCRIPT_NAME#/cgi-bin/}" "webif.sh" && grep 'root:!' /etc/passwd >&- 2>&- && {
		_nopasswd=1
		_form=""
		_savebutton=""
	}

	cat <<EOF
Content-Type: text/html
Pragma: no-cache

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
	<title>$_firmware_name @TR<<Administrative Console>></title>
		<link rel="stylesheet" type="text/css" href="/themes/active/webif.css" />
		<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_brown.css" title="brown" />
		<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_green.css" title="green" />
		<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_navyblue.css" title="navyblue" />
		<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_black.css" title="black" />
		<link rel="stylesheet" type="text/css" href="/themes/active/style-extend.css" />
		<link rel="stylesheet" type="text/css" href="/themes/active/waitbox.css" />
		<!--[if lt IE 7]>
			<link rel="stylesheet" type="text/css" href="/themes/active/ie_lt7.css" />
		<![endif]-->		
		<meta http-equiv="Content-Type" content="text/html; charset=@TR<<Encoding|ISO-8859-1>>" />
		<meta http-equiv="expires" content="-1" />
		<script type="text/javascript" src="/js/waitbox.js"></script>
		<script type="text/javascript" src="/js/styleswitcher.js"></script>
	</head>
	<body $4>

	<script type="text/javascript" src="/colorize.js"></script>
		<script type="text/javascript"> colorize(); </script>

	<div id="container">
		<div id="header">
			<div class="openwrt-title"></div>
			$short_status_frame
		</div>

		<div id="mainmenu">$_categories</div>
		<div id="submenu">$_subcategories</div>
		$_form
		<div id="colorswitcher">
			<div style="background: #000000" title="black" onclick="setActiveStyleSheet('black'); return false;"></div>
			<div style="background: #192a65" title="navyblue" onclick="setActiveStyleSheet('navyblue'); return false;"></div>
			<div style="background: #114488" title="blue" onclick="setActiveStyleSheet('default'); return false;"></div>
			<div style="background: #2b6d21" title="green" onclick="setActiveStyleSheet('green'); return false;"></div>
			<div style="background: #e8ca9e" title="brown" onclick="setActiveStyleSheet('brown'); return false;"></div>
		</div>

		<script type="text/javascript"> swatch(); </script>

		<div id="content">
			<div class="settings-block">
				$_head
				$ERROR
EOF

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
		<td>@TR<<Confirm Password>>: &nbsp; </td>
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

footer() {
	update_changes
	_changes=${CHANGES#0}
	_changes=${_changes:+(${_changes})}
	_endform=${_savebutton:+</form>}
	cat <<EOF
			</div>
		</div>
		<br />
		<fieldset id="save">
		<legend><strong>Proceed Changes</strong></legend>
			$_savebutton
			<ul class="apply">
				<li><a href="config.sh?mode=save&amp;cat=$_category&amp;prev=$SCRIPT_NAME">@TR<<Apply Changes>> &laquo;</a></li>
				<li><a href="config.sh?mode=clear&amp;cat=$_category&amp;prev=$SCRIPT_NAME">@TR<<Clear Changes>> &laquo;</a></li>
				<li><a href="config.sh?mode=review&amp;cat=$_category&amp;prev=$SCRIPT_NAME">@TR<<Review Changes>> $_changes &laquo;</a></li>
			</ul>
		</fieldset>	
		$_endform
		<hr />
		<div id="footer">
			<h3>X-Wrt</h3>
			<em>@TR<<making_usable#End user extensions for OpenWrt>></em>
		</div>
    </div>
</body>
</html>
EOF
}

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

