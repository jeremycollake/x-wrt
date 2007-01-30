BEGIN {
	n = 0
	sel = 0
	FS=":"
}
($3 == "category") && (categories !~ /:$4:/) {
	categories = categories ":" $4 ":";
 	n++
	if ($4 ~ "^" selected "$") sel = n
	c[n] = $4
	if (f[$4] == "") f[$4] = rootdir "/" indexpage "?cat=" $4
}
($3 == "name") && ((p[$4] == 0) || (p[$4] > int($5))) {
	gsub(/^.*\//, "", $1);
	p[$4] = int($5) + 1
	f[$4] = rootdir "/" $1
}
END {
	print "<div id=\"mainmenu\"><ul>"
	
	for (i = 1; i <= n; i++) {
		if (sel == i) print "<li class=\"selected\"><a href=\"" f[c[i]] "\">@TR<<" c[i] ">></a></li>"
		else {
			if (c[i] == "-") {
				print "<li class=\"separator\">-</li>"	
			}
			else {		
				print "<li><a href=\"" f[c[i]] "\">@TR<<" c[i] ">></a></li>";	
			}
		}
	}
  
	print "</ul></div>"
}
