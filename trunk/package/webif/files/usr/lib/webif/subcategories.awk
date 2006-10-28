BEGIN {
	FS=":"
	print "<ul class=\"mainmenu\"><li><div><strong>@TR<<Subcategories>>:</strong></div></li>"
}
{
	if ($5 ~ "^" selected "$") print "<li><a class=\"selected\" href=\"" rootdir "/" $6 "\">@TR<<" $5 ">></a>&nbsp;</li>"
	else print "<li><a href=\"" rootdir "/" $6 "\">&nbsp;@TR<<" $5 ">>&nbsp;</a></li>"
}
END {
	print "</ul>"
}

