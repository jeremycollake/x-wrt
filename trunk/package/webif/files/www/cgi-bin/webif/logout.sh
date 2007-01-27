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
header "Logout" "Logout" "@TR<<You must close the web browser to log out>>!" '' ''
cat <<EOF
@TR<<Since authentication is handled by the httpd on a per-session basis and cached by your web browser, it is not possible to log a user out. You must close the web browser (completely) to force your web browser to forget the credentials for this session.>>
<br /><br />
<div class="smalltext">
@TR<<For a reference, see http://httpd.apache.org/docs/1.3/howto/auth.html>>
</div>
EOF
#logout_user
show_validated_logo
footer ?>
<!--
##WEBIF:name:Logout:1:Logout
-->