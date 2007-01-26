BEGIN {
	gsub(/^\/\//, "/", path)
	start_form("@TR<<Filesystem Browser>>: " path);
	print "<table>"
	print "<tr><td class=\"c1\">&nbsp;</td><td colspan=\"2\"><a href=\"" url "?path=/\">@TR<<Root>></a></td></tr>"
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
		line = "<tr><td class=\"c1\">&nbsp;</td><td colspan=\"2\"><a href=\"" url "?path=" path "/..\">@TR<<Parent Directory>></a></td></tr>"
	} else {
		line = "<tr><td class=\"c1\">@TR<<Directory>>:</td><td class=\"fname\">"
		if ((fname == "rom") || \
			(fname == "bin") || \
			(fname == "sbin") || \
			(fname == "lib") || \
			(fname == "proc") || \
			(fname == "dev")) line = line fname
		else line = line "<a href=\"" url "?path=" path "/" fname "\">" fname "</a>"
		line = line "</td></tr>\n"
	}
}

type == "-" {
	line = "<tr> <td class=\"c1\">@TR<<File>>:</td> <td class=\"fname\">" fname "</td> <td class=\"fsize\">" fsize "</td> <td class=\"c2\"><a href=\"" url "?path=" path "&edit=" fname "\">@TR<<Edit>></a></td> </tr>\n"
}

(fname != ".") && (fname != "") {
	line = line "</tr>"
	out[type] = out[type] line
}

END {
	print out["d"]
	print out["-"]
	print "</table>"
	end_form("&nbsp;");
}
