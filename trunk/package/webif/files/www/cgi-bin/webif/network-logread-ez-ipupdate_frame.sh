#!/usr/bin/webif-page
<?
colorize_script=""
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
   	<title>@TR<<EZ-IP-Update Messages>></title>
	<link rel="stylesheet" type="text/css" href="/webif.css" />		
	<!--[if lt IE 7]>
		<link rel="stylesheet" type="text/css" href="/ie_lt7.css" />
	<![endif]-->						
	<meta http-equiv="Content-Type" content="text/html; charset=@TR<<Encoding|ISO-8859-1>>" />
	<meta http-equiv="expires" content="-1" />
	<script type="text/javascript" src="/colorize.js"></script>
		<script type="text/javascript"> colorize(); </script>
</head>
<body $4>	
<div class="logread"><pre>
<?
logread | grep 'ez-ipupdate\[' | sort -r | sed 's/[a-zA-Z]*\..*ez-ipupdate\[[0-9]*\]//' 
?>
</pre></div>
</body>
</html>
