#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "System" "File Editor" "@TR<<File Editor>>" ''

cat <<EOF
<script type="text/javascript">
function confirmT(path,file) {
	if (window.confirm("Please Confirm!\n\nDo you want to delete \"" + file + "\" file?")) {
		window.location="$SCRIPT_NAME?path=" + path + "&delfile=" + file
	}
}
</script>
EOF


if ! empty "$FORM_savefile"; then
(mkdir -p /tmp 2>/dev/null; cd /tmp; tar czf $FORM_savefile.tgz $FORM_path/$FORM_savefile 2>/dev/null)
ln -s /tmp/$FORM_savefile.tgz /www/$FORM_savefile.tgz

cat <<EOF
<IFRAME STYLE="width:0px; height:0px;" FRAMEBORDER='0' SCROLLING='no' name='DLFILE'></IFRAME>
&nbsp;&nbsp;&nbsp;@TR<<confman_noauto_click#If downloading does not start automatically, click here>> ... <a href="/$FORM_savefile.tgz">$FORM_savefile</a><br><br>
<script language="JavaScript" type="text/javascript">
setTimeout('DLFILE.location.href=\"/$FORM_savefile.tgz\"',"300")
</script>
EOF
fi

if ! empty "$FORM_delfile"; then
rm "$FORM_path/$FORM_delfile"
cat <<EOF
File: "$FORM_path/$FORM_delfile" was deleted.<br/><br/>
EOF

fi

FORM_path="${FORM_path:-/}"
cd "$FORM_path"
FORM_path="$(pwd)"
edit_pathname="$FORM_path/$FORM_edit"
saved_filename="/tmp/.webif/edited-files/$edit_pathname"

! empty "$FORM_save" && {
	SAVED=1
	mkdir -p "/tmp/.webif/edited-files/$FORM_path"
	echo "$FORM_filecontent" > "$saved_filename"
}

empty "$FORM_cancel" || FORM_edit=""

if empty "$FORM_edit"; then
	(ls -halLe "$FORM_path" | grep "^[d]";
		ls -halLe "$FORM_path" | grep "^[^d]") | awk \
		-v url="$SCRIPT_NAME" \
		-v path="$FORM_path" \
		-f /usr/lib/webif/common.awk \
		-f /usr/lib/webif/browser.awk
else
	edit_filename="$FORM_edit"
	exists "$saved_filename" && {
		edit_filename="$saved_filename"
	}
	cat "$edit_filename" | awk \
		-v url="$SCRIPT_NAME" \
		-v path="$FORM_path" \
		-v file="$FORM_edit" \
		-f /usr/lib/webif/common.awk \
		-f /usr/lib/webif/editor.awk
fi

footer 
(sleep 20; rm "/www/$FORM_savefile.tgz" 2>/dev/null; rm "/tmp/$FORM_savefile.tgz" 2>/dev/null) >/dev/null 2>&1 &
?>
<!--
##WEBIF:name:System:200:File Editor
-->
