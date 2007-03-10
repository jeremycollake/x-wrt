#!/usr/bin/webif-page
<?
###################################################################
# startup
#
# Description:
#	Custom startup configuration.
#
# Author(s) [in order of work date]:
#       Jeremy Collake
#
# Major revisions:
#
# NVRAM variables referenced:
#
#
# Configuration files referenced:
#   none
#
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
	if (window.confirm(webif_entityDecode(webif_printf("@TR<<big_warning#WARNING>>!\n\n@TR<<system_startup_ask_deletition#Do you really want to delete the '{0}' file>>?", file)))) {
		window.location=escape("$SCRIPT_NAME?path=" + path + "&delfile=" + file);
	}
}
-->
</script>

EOF
)


header "System" "Startup" "@TR<<Startup>>" ''

# defaults
custom_script_name="/etc/init.d/S95custom-user-startup"
startup_script_template="/etc/init.d/.x95custom-user-startup-default"
FORM_edit="S95custom-user-startup"
FORM_path="/etc/init.d"
cd "$FORM_path" # editor awk code expects this
edit_pathname="$FORM_path/$FORM_edit"
saved_filename="/tmp/.webif/edited-files/$edit_pathname"

! empty "$FORM_save" && {
	SAVED=1
	mkdir -p "/tmp/.webif/edited-files/$FORM_path"
	echo "$FORM_filecontent" > "$saved_filename"
	chmod 755 "$saved_filename"
}

empty "$FORM_cancel" || FORM_edit=""

! exists "$custom_script_name" && ! exists "$saved_filename" && {
	cp "$startup_script_template" "$custom_script_name"
	chmod 755 "$custom_script_name"
}

if empty "$FORM_edit"; then
	(ls -halLe "$FORM_path" 2>/dev/null | grep "^[d]";
		ls -halLe "$FORM_path" 2>/dev/null | grep "^[^d]") | awk \
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
##WEBIF:name:System:125:Startup
-->
