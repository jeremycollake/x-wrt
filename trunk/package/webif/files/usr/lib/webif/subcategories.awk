BEGIN {
	FS=":"
	print "<div id=\"submenu\"><h3><strong>@TR<<Subcategories>>:</strong></h3><ul>"
}
{
	if ($5 ~ "^" selected "$") print "<li class=\"selected-subcat\"><a href=\"" rootdir "/" $6 "\">&nbsp;@TR<<" $5 ">>&nbsp;</a></li>"
	else print "<li class=\"unselected-subcat\"><a href=\"" rootdir "/" $6 "\">&nbsp;@TR<<" $5 ">>&nbsp;</a></li>"
}
END {
	print "</ul></div>"
}

