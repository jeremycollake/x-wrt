#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "System" "File Editor" "@TR<<File Editor>>" ''

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
	ls -halLe "$FORM_path" | awk \
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
