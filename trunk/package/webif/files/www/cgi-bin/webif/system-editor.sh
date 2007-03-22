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

function confirm_deldir(path,file) {
	if (window.confirm(webif_entityDecode(webif_printf("@TR<<big_warning#WARNING>>!\n\n@TR<<system_editor_ask_dir_deletition#Do you really want to delete the '{0}' directory>>?", file)))) {
		window.location=escape("$SCRIPT_NAME?path=" + path + "&delpath=" + file);
	}
}
function confirm_delfile(path,file) {
	if (window.confirm(webif_entityDecode(webif_printf("@TR<<big_warning#WARNING>>!\n\n@TR<<system_editor_ask_file_deletition#Do you really want to delete the '{0}/{1}' file>>?", path, file)))) {
		window.location=escape("$SCRIPT_NAME?path=" + path + "&delfile=" + file);
	}
}
-->
</script>

<style type="text/css">
<!--
#filebrowser table {
	margin-left: 1em;
	margin-right: 1em;
	margin-bottom: 2.2em;
	text-align: left;
	font-size: 0.8em;
	border-style: none;
	border-spacing: 0;
}
#filebrowser td {
	padding-left: 0.1em;
	padding-right: 0.1em;
}
#filebrowser td.number {
	text-align: right;
}
#filebrowser td.leftimage {
	padding-left: 0em;
}
#filebrowser td.image {
	text-align: center;
}
#filebrowser td.rightimage {
	padding-right: 0em;
}
#filebrowser a.tooltip {
	z-index: 3;
}
#filebrowser span.tooltip {
	display: none;
}
#filebrowser a:hover.tooltip {
	position: relative;
}
#filebrowser a:hover.tooltip span.tooltip {
	z-index: 5;
	display: block;
	position: absolute;
	top: 1.1em;
	left: 1.8em;
	width: 20em;
	text-decoration: none;
	padding: 3px;
	border: 1px solid;
	color: Black;
	background-color: White;
}
-->
</style>

EOF
)

! empty "$FORM_delpath" && {
	cd / 2>/dev/null
	ERROR=$(rmdir "$FORM_delpath" 2>&1)
	equal "$?" "0" && {
		SUCCESS=$(cat <<EOF
@TR<<system_editor_info_dir_deleted#Directory was deleted successfully>>:<br/>
<strong>$FORM_delpath</strong><br/><br/>
EOF
)
	}
}
! empty "$FORM_delfile" && {
	ERROR=$(rm "$FORM_path/$FORM_delfile" 2>&1)
	equal "$?" "0" && {
		SUCCESS=$(cat <<EOF
@TR<<system_editor_info_file_deleted#File was deleted successfully>>:<br/>
<strong>$FORM_path/$FORM_delfile</strong><br/><br/>
EOF
)
	}
}

! equal "$ERROR" "" && ERROR="$ERROR<br />"

FORM_path="${FORM_path:-/}"
ERROR="$ERROR$(cd "$FORM_path" 2>&1)"
cd "$FORM_path" 2>/dev/null
while [ "$?" != "0" ]; do
	FORM_path="${FORM_path%/*}"
	FORM_path="${FORM_path:-/}"
	cd "$FORM_path" 2>/dev/null
done
FORM_path="$(pwd)"

header "System" "File Editor" "@TR<<system_editor_File_Editor#File Editor>>" ''

! empty "$SUCCESS" && echo "$SUCCESS"

edit_pathname="$FORM_path/$FORM_edit"
saved_filename="/tmp/.webif/edited-files/$edit_pathname"

! empty "$FORM_save" && {
	SAVED=1
	mkdir -p "/tmp/.webif/edited-files/$FORM_path"
	echo "$FORM_filecontent" > "$saved_filename"
}

empty "$FORM_cancel" || FORM_edit=""

if empty "$FORM_edit"; then
	(ls -alLe "$FORM_path" | grep "^[d]";
		ls -alLe "$FORM_path" | grep "^[^d]") 2>/dev/null | awk \
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

footer ?>
<!--
##WEBIF:name:System:200:File Editor
-->
