BEGIN {
	cgidir="/www/cgi-bin/webif"
	rootdir="/cgi-bin/webif"
	indexpage="index.sh"
}

function categories(n, i, sel, categories) {
	n = 0
	sel = 0
	FS = ":"
	
	while (("grep '##WEBIF:' "cgidir"/.categories "cgidir"/*.awx "cgidir"/*.sh 2>/dev/null" | getline) == 1) {
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

function subcategories() {
	FS = ":"
	print "<h3><strong>@TR<<Subcategories>>:</strong></h3>"
	print "<ul>"
	while (("grep -H '##WEBIF:name:"CATEGORY":' "cgidir"/*.awx "cgidir"/*.sh 2>/dev/null | sed -e 's,^.*/\\([a-zA-Z\\.\\-]*\\):\\(.*\\)$,\\2:\\1,' | sort -n" | getline) == 1) {
		if ($5 ~ "^"PAGENAME"$") print "	<li class=\"selected\"><a href=\"" rootdir "/" $6 "\">@TR<<" $5 ">></a></li>"
		else print "	<li><a href=\"" rootdir "/" $6 "\">@TR<<" $5 ">></a></li>"
	}
	print "</ul>"
	return ""
}

function status() {
	return ""
}

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
