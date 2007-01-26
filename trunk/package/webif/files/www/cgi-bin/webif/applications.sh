#!/usr/bin/webif-page "-U /tmp -u 4096"
<?
# add haserl args in double quotes it has very ugly
# command line parsing code!

. /usr/lib/webif/webif.sh

header "Applications" "List" "@TR<<List of Applications>>"


if ! empty "$FORM_install_package"; then
        echo "Installing openvpn package ...<pre>"
        install_package "openvpn"
        echo "</pre>"
fi

install_package_button=""
! is_package_installed "openvpn" &&
        install_package_button="string|<div class=warning>VPN will not work until you install OpenVPN: </div>
                submit|install_package| Install OpenVPN Package |"

 
cat <<EOF
<font color="#FF0000">This page is currently in development process. Some features 
may not function. </font> 
<br>
<img src="/images/coming_soon2.jpg" border="0" >


<table width="90%" border="0" cellspacing="1">
  <tr>
    <td width="15%">&nbsp;</td>
    <td width="85%">&nbsp;</td>
  </tr>
  <tr>
    <td><DIV>
<IFRAME SRC="app-list.sh" STYLE="width:240px; height:300px; border:1px dotted #888888;" FRAMEBORDER="0" SCROLLING="NO" name="AppList"></IFRAME>
</DIV>
</td>
    <td><DIV>
<IFRAME SRC="app-index.sh" STYLE="width:500px; height:300px; border:1px dotted #888888;" FRAMEBORDER="0" SCROLLING="NO" name="AppIndex"></IFRAME>
</DIV>
</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
EOF

#display_form <<EOF
#start_form|@TR<<Installed>>
#end_form
#start_form|@TR<<Available>>
#end_form

#EOF

footer
?>
<!--
##WEBIF:name:Applications:1:<List>
-->
