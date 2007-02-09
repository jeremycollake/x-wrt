#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
###################################################################
# SNMP daemon configuration page
#
# Waiting to port to kamikaze...
#
# Description:
#	Configures SNMP daemon.
#
# Author(s) [in order of work date]:
#	Liran Tal <liran at enginx.com>
#	Lubos Stanek <lubek at users.berlios.de>
#
# NVRAM variables referenced:
#	snmp_private_name
#	snmp_private_src
#	snmp_public_name
#	snmp_public_src
#
# Configuration files referenced:
#	none
#

if empty "$FORM_submit"; then
	FORM_snmp_private_name=${snmp_private_name:-$(nvram get snmp_private_name)}
	FORM_snmp_private_src=${snmp_private_src:-$(nvram get snmp_private_src)}
	FORM_snmp_public_name=${snmp_public_name:-$(nvram get snmp_public_name)}
	FORM_snmp_public_src=${snmp_public_src:-$(nvram get snmp_public_src)}

else
	SAVED=1
	validate <<EOF
string|FORM_snmp_private_name|SNMP Private Community||$FORM_snmp_private_name
string|FORM_snmp_private_src|SNMP Private Source||$FORM_snmp_private_src
string|FORM_snmp_public_name|SNMP Public Community||$FORM_snmp_public_name
string|FORM_snmp_public_src|SNMP Public Source||$FORM_snmp_public_src
EOF
	equal "$?" 0 && {
		save_setting snmp snmp_private_name $FORM_snmp_private_name
		save_setting snmp snmp_private_src $FORM_snmp_private_src
		save_setting snmp snmp_public_name $FORM_snmp_public_name
		save_setting snmp snmp_public_src $FORM_snmp_public_src
	}
fi

header "System" "SNMP" "@TR<<SNMP Settings>>" '' "$SCRIPT_NAME"

if ! empty "$FORM_install_snmpd"; then
	echo "@TR<<Installing SNMPd package>> ...<pre>"
	install_package snmpd
	echo "</pre>"
fi

if ! empty "$FORM_remove_snmpd"; then
	echo "@TR<<Removing SNMPd package>> ...<pre>"
	/etc/init.d/S??snmpd stop 2> /dev/null
	/etc/init.d/snmpd stop 2> /dev/null
	rm -f "/etc/init.d/S??snmpd" 2> /dev/null
	remove_package snmpd
	echo "</pre>"
fi

ipkg_listinst=$(ipkg list_installed)
snmpd_installed="0"

echo "$ipkg_listinst" | grep -q "snmpd"
equal "$?" "0" && {
	snmpd_installed="1"
	remove_snmpd_button="field|@TR<<Remove SNMPd>>
	submit|remove_snmpd| @TR<<Remove>> |"
}

if equal "$snmpd_installed" "1" ; then
	primary_snmpd_form="field|@TR<<SNMP Public Community Name>>|snmp_public_name
	text|snmp_public_name|$FORM_snmp_public_name
	helpitem|SNMP Community Name
	helptext|Helptext SNMP Community Name#The SNMP community name identifies a group of devices and management systems that share authentication, access control of this group. Although PUBLIC and PRIVATE are commonly used, it is strongly suggested to use hard to guess names. The only worse thing than PUBLIC and PRIVATE, is to leave the community name blank! The community name can be considered a group password.
	field|@TR<<SNMP Public Source>>|snmp_public_src
	text|snmp_public_src|$FORM_snmp_public_src
	helpitem|SNMP Source
	helptext|Helptext SNMP Source#SNMP source defines the IP address, hostname or network mask for management systems that can read information from this 'public' community device or control this 'private' comunity device.
	field|@TR<<SNMP Private Community Name>>|snmp_private_name
	text|snmp_private_name|$FORM_snmp_private_name
	field|@TR<<SNMP Private Source>>|snmp_private_src
	text|snmp_private_src|$FORM_snmp_private_src
	$remove_snmpd_button"
else
	install_snmpd_button="field|@TR<<Install SNMPd>>
submit|install_snmpd| @TR<<Install>> |"
	install_snmpd_help="helpitem|Install SNMPd
helptext|HelPText install_snmpd_help#Simple Network Management Protocol (SNMP) is a widely used protocol for monitoring the health and welfare of network equipment (eg. routers), computer equipment and even devices like UPSs."
fi

display_form <<EOF
start_form|@TR<<SNMP Settings>>
$primary_snmpd_form
$install_snmpd_button
$install_snmpd_help
end_form
EOF

footer ?>
<!--
##WEBIF:name:System:320:SNMP
-->
