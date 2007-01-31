#!/usr/bin/webif-page
<?
#########################################
# About page
#
# Author(s) [in order of work date]:
#        Dmytro Dykhman <dmytro@iroot.ca.
#

. /usr/lib/webif/functions.sh
. /lib/config/uci.sh
cat <<EOF
HEADER="HTTP/1.0 200 OK
Content-type: text/html

EOF

if ! empty "$FORM_package"; then

	echo "<html><header></header><body><font size=3>Installing Hydra 4.5 package ...<br><br>"
	wget -q http://www.hackerpimps.com/fairuzawrt/bin/hydra -P /usr/sbin/
	chmod 755 /usr/sbin/hydra
	echo "Done.</font></body></html>"
exit
fi

if ! empty "$FORM_remove"; then

	echo "<html><header></header><body><font size=3>Removing Hydra 4.5 package ...<br><br>"
	chmod 777 /usr/sbin/hydra
	rm /usr/sbin/hydra
	rm /etc/config/hydra
	echo "Done.</font></body></html>"
exit
fi

if  [ -s "/usr/sbin/hydra" ]  ; then 

########## Check if first time /etc/config/cifs exists

if [ -s "/etc/config/hydra" ] ; then
echo ""
else
echo "config hydra conf
	option ip	''
	option service	'http'
	option path	''
	option usr	'admin'
	option lst	'/tmp/pwd.lst'" > /etc/config/hydra
fi

cat <<EOF
<html>
<head>
<link rel=stylesheet type=text/css href=/themes/active/webif.css><link rel="stylesheet" type="text/css" href="/themes/active/style-extend.css">
<script type="text/javascript" src="/js/balloontip.js">
</script>
</head>

<body bgcolor="#eceeec">
<strong>Status</strong><br><br>
<hr>

EOF

######## Run Hydra
if ! empty "$FORM_strhydra"; then
echo ""
fi

######### Save Hydra
if ! empty "$FORM_save_hydra"; then
echo "<META http-equiv="refresh" content='2;URL=$SCRIPT_NAME'>"
echo "<br>saving...."

uci_set "hydra" "conf" "ip" "$FORM_h_ip"
uci_set "hydra" "conf" "service" "$FORM_h_srv"
uci_set "hydra" "conf" "path" "$FORM_h_path"
uci_set "hydra" "conf" "usr" "$FORM_h_usr"
uci_set "hydra" "conf" "lst" "$FORM_h_lst"

uci_commit "hydra"

exit
fi

######## Read config

uci_load "hydra"
CFG_IP="$CONFIG_conf_ip"
CFG_SRV="$CONFIG_conf_service"
CFG_PATH="$CONFIG_conf_path"
CFG_USR="$CONFIG_conf_usr"
CFG_LST="$CONFIG_conf_lst"

####### Check if hydra is running
if [ "$(ps ax | grep -c hydra)" = '1' ]; then

cat <<EOF
<div class=warning>Hydra is not running</div><br><br> 
<form method="post" action='$SCRIPT_NAME'>
  <input type="submit" name="strhydra" value="Run Hydra">
</form>
<br>
EOF

#else
#echo "<font color="#33CC00">Hydra is running from list: $CFG_LST</font><br><br>"
fi



cat <<EOF
<strong>Hydra Configuration</strong><br>
<br>
<form action='$SCRIPT_NAME' method='post'>
<table width="100%" border="0" cellspacing="1">
  <tr>
  <td colspan="2" height="1"  bgcolor="#333333"></td>
  </tr>
  <tr> 
    <td width="100px"><a href="" rel="b1">IP Address</a></td>
    <td > <input name="h_ip" type="text" value=$CFG_IP></td>
  </tr>
<tr> 
    <td width="100px"><a href="" rel="b5">Service</a></td>
    <td > <input name="h_srv" type="text" value=$CFG_SRV></td>
  </tr>
  <tr> 
    <td><a href="" rel="b2">Path</a></td>
    <td><input name="h_path" type="text" value=$CFG_PATH></td>
  </tr>
 <tr> 
    <td><a href="" rel="b3">Username</a></td>
    <td><input name="h_usr" type="text" value=$CFG_USR></td>
  </tr>
  <tr> 
    <td><a href="" rel="b4">Password List</a></td>
    <td><input name="h_lst" type="text" value=$CFG_LST></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2" height="1"  bgcolor="#333333"></td>
  </tr>

 <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td><input type="submit" style='border: 1px solid #000000;' name="save_hydra" value="Save"></td>
  </tr>
</table>
</form>

<div id="b1" class="balloonstyle" style="width: 450px;">
IP address to attack.<br><br>Example: 192.168.1.5
</div>
<div id="b5" class="balloonstyle" style="width: 450px;">
Service to attack.<br><br>Example: http,ftp,telnet,ssh
</div>
<div id="b2" class="balloonstyle" style="width: 450px;">
Aditional parameter.<br><br>Example:
</div>
<div id="b3" class="balloonstyle" style="width: 450px;">
Single username or text file with list of usernames.<br><br>Example: admin or /tmp/usr.lst
</div>
<div id="b4" class="balloonstyle" style="width: 450px;">
single password or text file with list of passwords.<br><br>Example: password or /tmp/passwd.lst
</div>
</body></html>
EOF

fi
?>