#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header_inject_head=$(cat <<EOF
<script type="text/javascript">
<!--
function webif_entityDecode(s) {
    var e = document.createElement("div");
    e.innerHTML = s;
    return e.firstChild.nodeValue;
}

webif_printf = function() {
	var num = arguments.length;
	var output = arguments[0];
	for (var i = 1; i < num; i++) {
		var pattern = "\\\{" + (i-1) + "\\\}";
		var re = new RegExp(pattern, "g");
		output = output.replace(re, arguments[i]);
	}
	return output;
}

function confirm_delete(path,file) {
	if (window.confirm(webif_entityDecode(webif_printf("@TR<<big_warning#WARNING>>!\n\n@TR<<system_editor_ask_deletition#Do you really want to delete the '{0}' file>>?", file)))) {
		window.location=escape("$SCRIPT_NAME?path=" + path + "&delfile=" + file);
	}
}
-->
</script>

EOF
)

header "System" "File Editor" "@TR<<system_editor_File_Editor#File Editor>>" ''

if ! empty "$FORM_delfile"; then
	rm "$FORM_path/$FORM_delfile"
	cat <<EOF
@TR<<system_editor_info_deleted#File was deleted successfully>>:<br/>
<strong>$FORM_path/$FORM_delfile</strong><br/><br/>
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
	echo "<div id=\"filebrowser\" class=\"browse_table\">"
	(ls -halLe "$FORM_path" | grep "^[d]";
		ls -halLe "$FORM_path" | grep "^[^d]") | awk \
		-v url="$SCRIPT_NAME" \
		-v path="$FORM_path" \
		-f /usr/lib/webif/common.awk \
		-f /usr/lib/webif/browser.awk
	echo "</div>"
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

footer ?>
<!--
##WEBIF:name:System:200:File Editor
-->
