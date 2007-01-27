#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# Logout
#
# Description:
#       Logs user out.
#
# Author(s) [in order of work date]:
#	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#
# Configuration files referenced:
#   none
#
header "Logout" "Logout" "@TR<<logout_close_window#You must close the web browser to log out!>>" '' ''
cat <<EOF
@TR<<logout_explanation#Since basic httpd authentication is cached by your web browser, it is not possible to log a user out. You must close the web browser to force it to forget the credentials you have supplied. We will probably switch to cookie based authentication due to this problem.>>
<br /><br />
<div class="smalltext">
@TR<<logout_reference#For a reference, see http://httpd.apache.org/docs/1.3/howto/auth.html>>
</div>
EOF
#logout_user
show_validated_logo
footer ?>
<!--
##WEBIF:name:Logout:1:Logout
-->