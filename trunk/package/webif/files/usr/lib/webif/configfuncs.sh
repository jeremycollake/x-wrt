# Configuration update functions
#
# Copyright (C) 2006 by Felix Fietkau <nbd@openwrt.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# to be used in webif.sh
#

######
# New settings functions that work with ng style config files.
# These have an "_ex" appended.
#

load_settings_ex() {
	config_load "$1"
	exists /tmp/.webif/config-$1 && . /tmp/.webif/config-$1
}

save_setting_ex() {
	mkdir -p /tmp/.webif
	cat >> /tmp/.webif/config-$1 <<EOF
config update "$2"
	option "$3" "$4"
EOF
}

commit_settings_ex() {(
	reset_cb
	option_cb() {
		# FIXME: ';' cannot be used in any config values
		updatestr="${updatestr:+$updatestr;}$CONFIG_SECTION.$1=$2"
	}

	for cfg in /tmp/.webif/config-*; do
		exists $cfg || continue
		export cfgfile="${cfg##*config-}"
		export updatestr=
		. $cfg
		
		lock /tmp/.webif/update-$cfgfile
		awk \
			-v cfgfile="/etc/config/$cfgfile" \
			-v updatestr="$updatestr" \
			-f /usr/lib/webif/uci-update.awk \
			-f - > /etc/config/$cfgfile.new <<EOF
BEGIN {
	cfg = read_file(cfgfile)
	print update_config(cfg, updatestr)
}
EOF
		equal "$?" 0 && {
			mv /etc/config/$cfgfile.new /etc/config/$cfgfile
			rm -f /tmp/.webif/config-$cfgfile
		}
		lock -u /tmp/.webif/update-$cfgfile
	done
)}


######
# Original settings functions that work with nvram.
# 

load_settings() {
	equal "$1" "nvram" || {
		exists /etc/config/$1 && . /etc/config/$1
	}
	exists /tmp/.webif/config-$1 && . /tmp/.webif/config-$1	
}

validate() {
	if empty "$1"; then
		eval "$(awk -f /usr/lib/webif/validate.awk)"
	else
		eval "$(echo "$1" | awk -f /usr/lib/webif/validate.awk)"
	fi
}


save_setting() {
	exists /tmp/.webif/* || mkdir -p /tmp/.webif
	oldval=$(eval "echo \${$2}")
	oldval=${oldval:-$(nvram get "$2")}
	grep "^$2=" /tmp/.webif/config-$1 >&- 2>&- && {
		grep -v "^$2=" /tmp/.webif/config-$1 > /tmp/.webif/config-$1-new 2>&- 
		mv /tmp/.webif/config-$1-new /tmp/.webif/config-$1 2>&- >&-
		oldval=""
	}
	equal "$oldval" "$3" || echo "$2=\"$3\"" >> /tmp/.webif/config-$1
}
