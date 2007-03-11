# parameters: 1
function config_load(package, var) {
	while (("/bin/ash -c '. /etc/functions.sh; unset NO_EXPORT; config_load \""package"\"; env | grep \"^CONFIG_\"'" | getline) == 1) {
		sub("^CONFIG_", "")
		if (match($0, "=") == 0) {
			if (var != "") CONFIG[var] = CONFIG[var] "\n" $0
			next
		}
		var=substr($0, 1, RSTART-1)
		CONFIG[var] = substr($0, RSTART+1, length($0) - RSTART)
	}
}

# parameters: 2
function config_get(package, option) {
	return CONFIG[package "_" option]
}

# parameters: 3
function config_get_bool(package, option, default, var) {
	var = config_get(package, option);
	if ((var == "enabled") || (var == "1") || (var == "on")) return 1
	if ((var == "disabled") || (var == "0") || (var == "off")) return 1
	return (var && var != "0" ? 1 : 0)
}

# parameters: 0
function categories(n, i, sel, categories, f, c) {
	n = 0
	sel = 0
	FS = ":"
	
	while (("grep '^##WEBIF:' "cgidir"/.categories "cgidir"/*.awx "cgidir"/*.sh 2>/dev/null" | getline) == 1) {
		if (($3 == "category") && (categories !~ /:$4:/)) {
			categories = categories ":" $4 ":";
			n++
			if ($4 ~ "^" CATEGORY "$") sel = n
			c[n] = $4
			if (f[$4] == "") f[$4] = rootdir "/" indexpage "?cat=" $4
		}
		if (($3 == "name") && ((p[$4] == 0) || (p[$4] > int($5)))) {
			gsub(/^.*\//, "", $1)
			p[$4] = int($5) + 1
			f[$4] = rootdir "/" $1
		}
	}
	print "<ul>"
	for (i = 1; i <= n; i++) {
		if (sel == i) print "   <li class=\"selected\"><a href=\"" f[c[i]] "\">@TR<<" c[i] ">></a></li>"
		else {
			if (c[i] == "-") print " <li class=\"separator\">-</li>" 
			else print " <li><a href=\"" f[c[i]] "\">@TR<<" c[i] ">></a></li>";
		}
	}
	print "</ul>"
	return ""
}

function print_subcategory() {
	if ($5 ~ "^"PAGENAME"$") print "	<li class=\"selected\"><a href=\"" rootdir "/" ($7 ? $7"?action="$6 : $6) "\">@TR<<" $5 ">></a></li>"
	else print "	<li><a href=\"" rootdir "/" ($7 ? $7"?action="$6 : $6) "\">@TR<<" $5 ">></a></li>"
}

# parameters: 0-1
function subcategories(extra, a, n, i) {
	FS = ":"
	print "<h3><strong>@TR<<Subcategories>>:</strong></h3>"
	print "<ul>"
	while (("grep -H '^##WEBIF:name:"CATEGORY":' "cgidir"/*.awx "cgidir"/*.sh 2>/dev/null | sed -e 's,^.*/\\([a-zA-Z\\.\\-]*\\):\\(.*\\)$,\\2:\\1,' | sort -n" | getline) == 1) {
		print_subcategory()
	}
	if (extra) {
		n = split(extra, a, "\n")
		for (i = 1; i <= n; i++) {
			$0 = a[i]
			print_subcategory()
		}
	}
	print "</ul>"
	return ""
}

# parameters: 0
function status(hostname, uptime, loadavg, i) {
	if (config_get("general", "use_short_status_frame") == "1") {
		return "<iframe src=\"/cgi-bin/webif/iframe.mini-info.sh\" width=\"200\" height=\"80\" scrolling=\"no\" frameborder=\"0\"></iframe>"
	}
	
	getline < "/proc/sys/kernel/hostname"
	hostname=$0
	
	"uptime" | getline
	uptime=$0

	if (match(uptime, "load average: ") != 0) loadavg = substr($0, RSTART+RLENGTH, length($0) - RSTART - RLENGTH + 1)
	if (match(uptime, "up ") != 0) uptime = substr($0, RSTART + RLENGTH, length($0) - RSTART - RLENGTH - 1)
	else uptime=""
	if (match(uptime, ",") != 0) uptime = substr(uptime, 1, RSTART - 1)
	return "<div id=\"short-status\">\
		<h3><strong>@TR<<Status>>:</strong></h3>\
		<ul>\
			<li><strong>"config_get("general", "firmware_name")" "config_get("general", "firmware_version")"</strong></li>\
			<li><strong>@TR<<Host>>:</strong> "hostname"</li>\
			<li><strong>@TR<<Uptime>>:</strong> "uptime"</li>\
			<li><strong>@TR<<Load>>:</strong> "loadavg"</li>\
		</ul>\
	</div>"
}

# parameters: 0
function num_changes(counter) {
	counter=0
	while (("(cat /tmp/.webif/config-* ; ls /tmp/.webif/file-*; find '/tmp/.webif/edited-files' -type f) 2>&-" | getline) == 1) {
		counter++
	}
	while (("grep -E '(CONFIG_SECTION|uci_)' /tmp/.uci/* 2>&-" | getline) == 1) {
		counter++
	}
	return counter
}


function start_form(title, field_opts, field_opts2) {
	print "<div class=\"settings\"" field_opts ">"
	if (title != "") print "<h3><strong>" title "</strong></h3>"
	print "<div class=\"settings-content\"" field_opts2 ">"
}

function end_form(form_help, form_help_link) {
	print "</div>"
	if (form_help != "" || form_help_link != "") {
		print "<blockquote class=\"settings-help\">"
		print "<h3><strong>@TR<<Short help>>:</strong></h3>"
		print form_help form_help_link
		print "</blockquote>"
	}
	print "<div class=\"clearfix\">&nbsp;</div></div>"
}

function textinput(name, value) {
	return "<input type=\"text\" name=\"" name "\" value=\"" value "\" />"
}

function textinput2(name, value, width) {
        return "<input type=\"text\" name=\"" name "\" value=\"" value "\" style=\"width:" width "em;\" />"
}
function hidden(name, value) {
	return "<input type=\"hidden\" name=\"" name "\" value=\"" value "\" />"
}

function button(name, caption) {
	return "<input type=\"submit\" name=\"" name "\" value=\"@TR<<" caption ">>\" />"
}

function helpitem(name) { 
	return "<dt>@TR<<" name ">>: </dt>"
}

function helptext(short, name) { 
	return "<dd>@TR<<" short "|" name ">>: </dd>"
}
function sel_option(name, caption, default, sel) {
	if (default == name) sel = " selected=\"selected\""
	else sel = ""
	return "<option value=\"" name "\"" sel ">@TR<<" caption ">></option>"
}


BEGIN {
	cgidir="/www/cgi-bin/webif"
	rootdir="/cgi-bin/webif"
	indexpage="index.sh"
}


