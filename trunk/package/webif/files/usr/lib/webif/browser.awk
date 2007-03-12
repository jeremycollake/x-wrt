# WARNING! the input list must be sorted with directories first
BEGIN {
	gsub(/^\/\//, "/", path)
	print "<div class=\"settings\">"
	print "<h3><strong>@TR<<browser_Filesystem_Browser#Filesystem Browser>>: " path "</strong></h3>"
	print "<div id=\"filebrowser\">"
	print "<table summary=\"@TR<<browser_Filesystem_Browser#Filesystem Browser>>\">"
	print "<tbody>"
	print "	<tr>"
	print "		<td class=\"leftimage\"><img src=\"/images/dir.gif\" alt=\"\" /></td>"
	print "		<td><a href=\"" url "?path=/\">@TR<<browser_Root#Root>></a></td>"
	print "		<td>&nbsp;</td>"
	print "		<td>&nbsp;</td>"
	print "		<td>&nbsp;</td>"
	print "	</tr>"
	odd=0
	# do not let the user to make wrong things (hm, at least some of them)
	xdirectory="^(\/bin$|\/bin\/$|\/dev$|\/dev\/.*$|\/etc$|\/jffs$|\/lib$|\/lib\/modules$|\/lib\/modules\/.*$|\/mnt$|\/proc$|\/proc\/.*|\/rom$|\/rom\/.*|\/sbin$|\/usr$|\/usr\/bin$|\/usr\/lib$|\/usr\/lib\/webif$|\/usr\/sbin$|\/usr\/share$|\/www$|\/www\/.*$|\/www\/themes\/.*$|\/www\/cgi-bin\/webif$)"
	xdownload="^(\/dev$|\/dev\/.*$|\/proc$|\/proc\/.*$)"
	xedit="^(\/dev$|\/dev\/.*$|\/lib$|\/lib\/modules\/.*$|\/proc$|\/proc\/.*$)"
	xdelete="^(\/dev$|\/dev\/.*$|\/lib$|\/lib\/modules\/.*$|\/proc$|\/proc\/.*$)"
}

{
	type = substr($1, 1, 1);
	fsize = $5
	if (fsize >= 2 ** 30) {
		hsize = fsize / (2 ** 30)
		hsize = int(hsize * 10)/10
		hsize = hsize " GB"
	} else if (fsize >= 2 ** 20) {
		hsize = fsize / (2 ** 20)
		hsize = int(hsize * 10) / 10
		hsize = hsize " MB"
	} else if (fsize >= 2 ** 15) {
		hsize = fsize / (2 ** 10)
		hsize = int(hsize * 10) / 10
		hsize = hsize " kB"
	} else {
		hsize = fsize
	}
	fname = $11
	for (i = 12; i <= NF; i++)
		fname = fname " " $i
	line = ""
	fullpath = path "/" fname
	gsub(/^\/\//, "/", fullpath)
}

type == "d" {
	if (fname == "..") {
		fullpath = path "/.."
		gsub(/^\/\//, "/", fullpath)
		line = "		<td class=\"leftimage\"><img src=\"/images/dir.gif\" alt=\"@TR<<browser_Directory#Directory>>\" /></td>\n"
		line = line "		<td><a href=\"" url "?path=" fullpath "\">@TR<<browser_Parent_Directory#Parent Directory>></a>\n"
		line = line "		<td>&nbsp;</td>\n"
		line = line "		<td>&nbsp;</td>\n"
		line = line "		<td>&nbsp;</td>"
	} else {
		line = "		<td class=\"leftimage\"><img src=\"/images/dir.gif\" alt=\"@TR<<browser_Directory#Directory>>\" /></td>\n"
		if (fullpath ~ xdirectory) {
			line = line "		<td><a href=\"" url "?path=" fullpath "\">" fname "</a></td>\n"
			line = line "		<td>&nbsp;</td>\n"
			line = line "		<td>&nbsp;</td>\n"
			line = line "		<td class=\"rightimage\"><img src=\"/images/action_x_no.gif\" alt=\"@TR<<browser_Delete#Delete>>\" />"
		} else {
			line = line "		<td><a href=\"" url "?path=" fullpath "\">" fname "</a></td>\n"
			line = line "		<td>&nbsp;</td>\n"
			line = line "		<td>&nbsp;</td>\n"
			line = line "		<td class=\"rightimage\"><a href=\"javascript:confirm_deldir('" path  "','" fullpath "')\"><img src=\"/images/action_x.gif\" alt=\"@TR<<browser_Delete#Delete>>\" /></a>"
		}
		line = line "</td>"
	}
}

type == "-" {
	line = "		<td class=\"leftimage\"><img src=\"/images/file.gif\" alt=\"@TR<<browser_File#File>>\" /></td>\n"
	if (path ~ xdownload) {
		line = line "		<td>" fname "</td>\n"
	} else {
		line = line "		<td><a href=\"/cgi-bin/webif/download.sh?script=" url "&amp;path=" path "&amp;savefile=" fname "\">" fname "</a></td>\n"
	}
	line = line "		<td class=\"number\">" hsize "</td>\n"
	if ((path ~ xedit) || fsize >= 2 ** 15) {
		line = line "		<td class=\"image\"><img src=\"/images/action_edit_no.gif\" alt=\"@TR<<browser_Edit#Edit>>\" /></td>\n"
	} else {
		line = line "		<td class=\"image\"><a href=\"" url "?path=" path "&amp;edit=" fname "\"><img src=\"/images/action_edit.gif\" alt=\"@TR<<browser_Edit#Edit>>\" /></a></td>\n"
	}
	if (path ~ xdelete) {
		line = line "		<td class=\"image\"><img src=\"/images/action_x_no.gif\" alt=\"@TR<<browser_Delete#Delete>>\" /></td>\n"
	} else {
		line = line "		<td class=\"rightimage\"><a href=\"javascript:confirm_delfile('" path  "','" fname "')\"><img src=\"/images/action_x.gif\" alt=\"@TR<<browser_Delete#Delete>>\" /></a></td>\n"
	}
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
	print "	</tr>"
}

END {
	print "</tbody>"
	print "</table>"
	print "</div>"
	print "</div>"
}
