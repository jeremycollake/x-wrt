BEGIN {
	print "<form method=\"post\" action=\"" url "\" enctype=\"multipart/form-data\">"
	start_form("@TR<<File>>: " path "/" file)
	print hidden("path", path)
	print hidden("edit", file)
	printf "<textarea name=\"filecontent\" cols=\"80\" rows=\"20\">"
}

{
	gsub("&", "\\&amp;", $0)
	gsub("<", "\\&lt;", $0)
	gsub(">", "\\&gt;", $0)
	print $0
}

END {
	print "</textarea><br />"
	print button("save", " Save Changes ") "&nbsp;" button("cancel", " Back ")
	print "<br /><div class=\"tip\">After you are done changing files and making other configuration adjustments, you must click the Apply link to make the changes permanent.</div>"
	end_form("&nbsp;")
	print "</form>"
}
