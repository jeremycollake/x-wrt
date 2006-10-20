#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh

FORM_path="${FORM_path:-/}"
cd "$FORM_path"
FORM_path="$(pwd)"

header "System" "File Editor" "@TR<<File Editor>>" ''

cat <<EOF
<style><!--

.c1 {
	width: 8em;
	font-weight: bold;
}

.fname {
	padding-right: 3em;
}

.c2 {
	width: 3em;
}

textarea {
	width: 100%;
	height: 100%;
}

--></style>
EOF

empty "$FORM_cancel" || FORM_edit=""

if empty "$FORM_edit"; then
	ls -halLe "$FORM_path" | awk \
		-v url="$SCRIPT_NAME" \
		-v path="$FORM_path" \
		-f /usr/lib/webif/common.awk \
		-f /usr/lib/webif/browser.awk
else
	cat "$FORM_edit" | awk \
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
