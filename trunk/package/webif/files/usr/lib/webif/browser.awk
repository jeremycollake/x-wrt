# WARNING! the input list must be sorted with directories first
BEGIN {
	gsub(/^\/\//, "/", path)
	print "<div class=\"settings\">"
	print "<h3><strong>@TR<<browser_Filesystem_Browser#Filesystem Browser>>: " path "</strong></h3>"
	print "<table style=\"margin-left: 2.5em; text-align: left; font-size: 0.8em;\" border=\"0\" cellpadding=\"3\" cellspacing=\"3\" summary=\"@TR<<browser_Filesystem_Browser#Filesystem Browser>>\">"
	print "<tbody>"
	print "	<tr>"
	print "		<td><img src=\"/images/dir.gif\" alt=\"\" /></td>"
	print "		<td><a href=\"" url "?path=/\">@TR<<browser_Root#Root>></a></td>"
	print "		<td colspan=\"6\">&nbsp;</td>"
	print "	</tr>"
	odd=0
}

{
	type = substr($1, 1, 1);
	fsize = $5
	fname = $11
	for (i = 12; i <= NF; i++)
		fname = fname " " $i
	line = ""
}

type == "d" {
	if (fname == "..") {
		line = "		<td><img src=\"/images/dir.gif\" alt=\"@TR<<browser_Directory#Directory>>\" /></td>\n"
		line = line "		<td colspan=\"6\"><a href=\"" url "?path=" path "/..\">@TR<<browser_Parent_Directory#Parent Directory>></a></td>"
	} else {
		line = "	<td><img src=\"/images/dir.gif\" alt=\"@TR<<browser_Directory#Directory>>\" /></td>\n"
		line = line "	<td colspan=\"6\">"
		if ((fname == "rom") || \
			(fname == "bin") || \
			(fname == "sbin") || \
			(fname == "lib") || \
			(fname == "proc") || \
			(fname == "dev")) line = line fname
		else line = line "<a href=\"" url "?path=" path "/" fname "\">" fname "</a>"
		line = line "</td>\n"
	}
}

type == "-" {
	line = "		<td><img src=\"/images/file.gif\" alt=\"@TR<<browser_File#File>>\" /></td>\n"
	line = line "		<td>" fname "</td>\n"
	line = line "		<td align=\"right\">" fsize "</td>\n"
	line = line "		<td><a href=\"" url "?path=" path "&amp;edit=" fname "\"><img src=\"/images/action_edit.gif\" alt=\"@TR<<browser_Edit#Edit>>\" /></a></td>\n"
	line = line "		<td><a href=\"" url "?path=" path "&amp;savefile=" fname "\"><img src=\"/images/action_sv.gif\" alt=\"@TR<<browser_Download#Download>>\" /></a></td>\n"
	line = line "		<td><a href=\"javascript:confirmT('" path  "','" fname "')\"><img src=\"/images/action_x.gif\" alt=\"@TR<<browser_Delete#Delete>>\" /></a></td>"
}

(fname != ".") && (fname != "") {
	if (odd == 1) {
		print "	<tr>"
		odd--
	} else {
		print "	<tr class=\"odd\">"
		odd++
	}
	print line
	print "	</tr>\n"
}

END {
	print "</tbody>"
	print "</table>"
	print "</div>"
}
