#
# Nbd QoS scripts config
#	
uci_load qos	

! empty "$FORM_submit" && {
	uci_set "qos" "wan" "download" "$FORM_wan_download"
	uci_set "qos" "wan" "upload" "$FORM_wan_upload"
}

uci_load "qos"
FORM_wan_download="$CONFIG_wan_download"
FORM_wan_upload="$CONFIG_wan_upload"

display_form <<EOF
start_form|@TR<<WAN Connection Speeds>>
field|@TR<<Maximum Upload>>|field_n_wan_upload
text|wan_upload|$FORM_wan_upload| @TR<<kilobits>>
helpitem|Maximum Upload
helptext|HelpText Maximum Upload#This should be about 90% of your maximum sustained WAN upload throughput, in kilobits.
helpitem|Maximum Download
helptext|HelpText Maximum Download#This should be about 95% of your maximum sustained WAN download throughput, in kilobits.
field|@TR<<Maximum Download>>|field_n_wan_download
text|wan_download|$FORM_wan_download| @TR<<kilobits>>
tip|@TR<<nbd_qos_cfg_tip#The rest of the configuration is stored in /etc/config/qos. Its default state suffices for most users.>>|n_cfg_tip
end_form
EOF


	

