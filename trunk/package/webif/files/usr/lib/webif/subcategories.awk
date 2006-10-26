BEGIN {
	FS=":"
	print "<ul id=\"mainmenu\"><li><strong>@TR<<Subcategories>>:</strong></li>"
}
{
	if ($5 ~ "^" selected "$") print "<li><a id=\"selected\" href=\"" rootdir "/" $6 "\">@TR<<" $5 ">></a>&nbsp;</li>"
	else print "<li><a href=\"" rootdir "/" $6 "\">&nbsp;@TR<<" $5 ">>&nbsp;</a></li>"
}
END {
	print "</ul>"
}

