BEGIN {
	gsub(/^\/\//, "/", path)
	start_form("@TR<<Filesystem Browser>>: " path);
	print "<table width=\"100%\" border=\"0\" cellspacing=\"0\">"
	print "<tr><td style=\"width:3em\">&nbsp;</td><td><a href=\"" url "?path=/\">@TR<<Root>></a></td><td style=\"width:8em\" colspan="2"></td></tr>\n"
}

{
	type = substr($1, 1, 1);
	fname = $11
	fsize = $5
	for (i = 12; $i != ""; i++) fname = fname " " $i
	line = ""
}

type == "d" {
	if (fname == "..") {
		line = "<td>&nbsp;</td><td colspan=\"3\"><a href=\"" url "?path=" path "/..\">@TR<<Parent Directory>></a></td>"
	} else {
		line = "<td><img src='/images/dir.gif' alt /></td><td colspan=\"3\" style=\"padding-right:3em\">"
		if ((fname == "rom") || \
			(fname == "bin") || \
			(fname == "sbin") || \
			(fname == "lib") || \
			(fname == "proc") || \
			(fname == "dev")) line = line fname
		else line = line "<a href=\"" url "?path=" path "/" fname "\">" fname "</a>"
		line = line "</td>"
	}
}

type == "-" {
	line = "<td><img src='/images/file.gif' alt /></td><td style=\"padding-right:3em\">" fname "</td><td>" fsize "</td><td><a href=\"" url "?path=" path "&amp;edit=" fname "\"><img src='/images/action_edit.gif' alt /></a>&nbsp;<a href=\"" url "?path=" path "&amp;savefile=" fname "\"><img src='/images/action_sv.gif' alt /></a>&nbsp;<a href=javascript:confirmT(\"" path  "\",\"" fname "\")><img src='/images/action_x.gif' alt /></a></td>"
}

(fname != ".") && (fname != "") {
	if ( color == "1" ) { color="2" } else { color="1" }
 	line = "<tr class=\"CommonRow" color "\">" line "</tr>\n"
 	out[type] = out[type] line
}

END {
	print out["d"]
	print out["-"]
	print "</table>"
	end_form("&nbsp;");
}
