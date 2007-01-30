BEGIN {
	gsub(/^\/\//, "/", path)
	start_form("@TR<<Filesystem Browser>>: " path);
	print "<table>"
	print "<tr><td style=\"width:8em\">&nbsp;</td><td><a href=\"" url "?path=/\">@TR<<Root>></a></td><td style=\"width:8em\" colspan="2"></td></tr>\n"
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
		line = "<td><b>@TR<<Directory>>:</b></td><td colspan=\"3\" style=\"padding-right:3em\">"
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
	line = "<td><b>@TR<<File>>:</b></td><td style=\"padding-right:3em\">" fname "</td><td>" fsize "</td><td><a href=\"" url "?path=" path "&amp;edit=" fname "\">@TR<<Edit>></a></td>"
}

(fname != ".") && (fname != "") {
 	line = "<tr>" line "</tr>\n"
 	out[type] = out[type] line
}

END {
	print out["d"]
	print out["-"]
	print "</table>"
	end_form("&nbsp;");
}
