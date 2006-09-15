#!/usr/bin/webif-page
<html>
<head>
  <meta http-equiv="refresh" content="5; URL=logread_frame.sh">
</head>
<body><? 
prefix=$(nvram get log_prefix)
?><pre><? logread | sort -r | sed -e "s| $prefix| |" ?></pre></body>
</html>
