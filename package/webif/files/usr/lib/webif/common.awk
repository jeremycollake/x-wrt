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

# parameters: 1
function config_load_state(package, var) {
	while (("/bin/ash -c '. /etc/functions.sh; unset NO_EXPORT; . \"/var/state/"package"\" 2>/dev/null; env | grep \"^CONFIG_\"'" | getline) == 1) {
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
	if ((var == "disabled") || (var == "0") || (var == "off")) return 0
	return (default == "1" ? 1 : 0)
}

# parameters: 1
function uci_load(package, var) {
	while (("/bin/ash -c '. /etc/functions.sh; . /lib/config/uci.sh; unset NO_EXPORT; uci_load \""package"\"; env | grep \"^CONFIG_\"'" | getline) == 1) {
		sub("^CONFIG_", "")
		if (match($0, "=") == 0) {
			if (var != "") CONFIG[var] = CONFIG[var] "\n" $0
			next
		}
		var=substr($0, 1, RSTART-1)
		CONFIG[var] = substr($0, RSTART+1, length($0) - RSTART)
	}
}

# parameters: 4
function uci_set(package, config, option, value) {
	system("/bin/ash -c '. /etc/functions.sh; . /lib/config/uci.sh; uci_set \""package"\" \""config"\" \""option"\" \""value"\"'")
}

# WARNING: this function is a test and it may not be supported later!
# parameters: 2
# the second parameter is a two-dimensional array confoptval[config, option]
function uci_set_ar(package, confoptval, \
			cmd, var, nr, confopt) {
	cmd = "/bin/ash -c '\$0'"
	for (var in confoptval) {
		nr = split(var, confopt, SUBSEP)
		if (nr == 2)
			print ". /etc/functions.sh; . /lib/config/uci.sh; uci_set \""package"\" \""confopt[1]"\" \""confopt[2]"\" \""confoptval[var]"\"" | cmd
	}
	close(cmd)
}

# parameters: 3
function uci_add(package, type, config) {
	system("/bin/ash -c '. /etc/functions.sh; . /lib/config/uci.sh; uci_add \""package"\" \""type"\" \""config"\"'")
}

# parameters: 3
function uci_rename(package, config, value) {
	system("/bin/ash -c '. /etc/functions.sh; . /lib/config/uci.sh; uci_rename \""package"\" \""config"\" \""value"\"'")
}

# parameters: 3
function uci_remove(package, config, option) {
	system("/bin/ash -c '. /etc/functions.sh; . /lib/config/uci.sh; uci_remove \""package"\" \""config"\" \""option"\"'")
}

# parameters: 1
function uci_commit(package) {
	system("/bin/ash -c '. /etc/functions.sh; . /lib/config/uci.sh; uci_commit \""package"\"'")
}

# parameters: 1
function indent_level(level, i) {
	if (level > 0) {
		for (i = 1; i <= level; i++) printf "\t"
	}
}

# parameters: 0
function cssmenu(mainmenu, submenu, menuind, ofs, osubsep, n, i) {
	ofs = FS
	FS = ":"
	osubsep = SUBSEP
	SUBSEP = ":"

	delete mainmenu
	n = 0
	# parse categories
	while (("grep '^##WEBIF:' "cgidir"/.categories 2>/dev/null | sed 's/^[^:]*:[^:]*://'" | getline) == 1) {
		if ($1 != "") {
			n++
			mainmenu[n SUBSEP "title"] = $1
			if ($1 == CATEGORY) mainmenu[n SUBSEP "sel"] = 1
		}
	}
	mainmenu["count"] = n
	delete submenu
	# parse all ##WEBIF...
	n = 0
	while (("grep '^##WEBIF:' "cgidir"/*.awx "cgidir"/*.sh 2>/dev/null | sed 's,^[^:]*\/,,; s/##WEBIF:name://; s/^\\([^:]*\\):\\(.*\\)/\\2:\\1/' | sort" | getline) == 1) {
		if ((mainmenu[$1 SUBSEP "url"] == "")  && ($4 != "")) mainmenu[$1 SUBSEP "url"] = rootdir "/" $4
		if (mainmenu[$1 SUBSEP "pages"] !~ /:$2:/) {
			mainmenu[$1 SUBSEP "pages"] = mainmenu[$1 SUBSEP "pages"] ":" $2 ":"
			mainmenu[$1 SUBSEP "count"]++
			submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "title"] = $3
			if ($3 == PAGENAME) submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "sel"] = 1
			if ($5 != "") {
				if ($4 != "") submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "url"] = rootdir "/" $5 "?action=" $4
			} else {
				if ($4 != "") submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "url"] = rootdir "/" $4
			}
		}
	}
	# parse extra subcategories
	while (("/bin/ash -c '. "cgidir"/graphs-subcategories.sh; subcategories_extra' | sed 's/##WEBIF:name://' | sort" | getline) == 1) {
		if ((mainmenu[$1 SUBSEP "url"] == "")  && ($4 != "")) mainmenu[$1 SUBSEP "url"] = rootdir "/" $4
		mainmenu[$1 SUBSEP "count"]++
		submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "title"] = $3
		if ($3 == PAGENAME) submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "sel"] = 1
		if ($5 != "") {
			if ($4 != "") submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "url"] = rootdir "/" $5 "?action=" $4
		} else {
			if ($4 != "") submenu[$1 SUBSEP mainmenu[$1 SUBSEP "count"] SUBSEP "url"] = rootdir "/" $4
		}
	}
	# flush it
	menuind = 1
	indent_level(menuind); print "<ul class=\"mainmenu\">"
	for (n = 1; n <= mainmenu["count"]; n++) {
		indent_level(menuind + 1)
		if (mainmenu[n SUBSEP "title"] == "-") print "<li class=\"separator\">" mainmenu[n SUBSEP "title"] "</li>"
		else {
			if (mainmenu[n SUBSEP "sel"] == 1) printf "<li class=\"selected\">"
			else printf "<li>"
			if (mainmenu[mainmenu[n SUBSEP "title"] SUBSEP "url"] != "")
				printf "<a href=\"" mainmenu[mainmenu[n SUBSEP "title"] SUBSEP "url"] "\">"
			printf "@TR<<" mainmenu[n SUBSEP "title"] ">>"
			if (mainmenu[mainmenu[n SUBSEP "title"] SUBSEP "url"] != "")
				printf "</a>"
			print "<ul class=\"submenu\">"
			for (i = 1; i <= mainmenu[mainmenu[n SUBSEP "title"] SUBSEP "count"]; i++) {
				indent_level(menuind + 2)
				if (submenu[mainmenu[n SUBSEP "title"] SUBSEP i SUBSEP "sel"] == 1) printf "<li class=\"selected\">"
				else printf "<li>"
				if (submenu[mainmenu[n SUBSEP "title"] SUBSEP i SUBSEP "url"] != "")
					printf "<a href=\"" submenu[mainmenu[n SUBSEP "title"] SUBSEP i SUBSEP "url"] "\">"
				printf "@TR<<" submenu[mainmenu[n SUBSEP "title"] SUBSEP i SUBSEP "title"] ">>"
				if (submenu[mainmenu[n SUBSEP "title"] SUBSEP i SUBSEP "url"] != "")
					printf "</a>"
				print "</li>"
			}
			indent_level(menuind + 1)
			print "</ul></li>"
		}
	}
	indent_level(menuind); print "</ul>"

	delete submenu
	delete mainmenu

	SUBSEP = osubsep
	FS = ofs
}

# parameters: 0
function categories(n, i, sel, categories, f, c, ofs) {
	n = 0
	sel = 0
	ofs = FS
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
	FS = ofs
	return ""
}

function print_subcategory() {
	if ($5 ~ "^"PAGENAME"$") print "	<li class=\"selected\"><a href=\"" rootdir "/" ($7 ? $7"?action="$6 : $6) "\">@TR<<" $5 ">></a></li>"
	else print "	<li><a href=\"" rootdir "/" ($7 ? $7"?action="$6 : $6) "\">@TR<<" $5 ">></a></li>"
}

# parameters: 0-1
function subcategories(extra, a, n, i, ofs) {
	ofs = FS
	FS = ":"
	print "<h3><strong>@TR<<Subcategories>>:</strong></h3>"
	print "<ul>"
	while (("grep -H '^##WEBIF:name:"CATEGORY":' "cgidir"/*.awx "cgidir"/*.sh 2>/dev/null | sed -e 's,^.*/\\([a-zA-Z0-9\\.\\-]*\\):\\(.*\\)$,\\2:\\1,' | sort -n" | getline) == 1) {
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
	FS = ofs
	return ""
}

# parameters: 0
function status(hostname, uptime, loadavg, i) {
	getline < "/proc/sys/kernel/hostname"
	hostname=$0
	
	"uptime" | getline
	uptime=$0

	if (match(uptime, "load average: ") != 0) loadavg = substr($0, RSTART+RLENGTH, length($0) - RSTART - RLENGTH + 1)
	if (match(uptime, "up ") != 0) uptime = substr($0, RSTART + RLENGTH, length($0) - RSTART - RLENGTH - 1)
	else uptime=""
	if (match(uptime, ", load ") != 0) uptime = substr(uptime, 1, RSTART - 1)
	return "<div id=\"short-status\">\
		<h3>@TR<<Status>>:</h3>\
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
	while (("/bin/ash -c 'for config in \$(ls /tmp/.uci/* 2>&- | grep -v \"\\.lock\$\"); do cat \"\$config\" 2>&-; done'" | getline) == 1) {
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
	return "<h4>@TR<<" name ">>:</h4>"
}

function helptext(text) { 
	return "<p>@TR<<" text ">></p>"
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

