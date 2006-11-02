#############################################################################
# Configuration update functions
#
# Copyright (C) 2006 by Felix Fietkau <nbd@openwrt.org>
# Lame comments and hacks by Jeremy Collake.
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
. /etc/functions_ex.sh

#############################################################################
# UCI config functions
# 
#  These work with UCI compatibile configuration files. These files are 
#  stored in /etc/config.
#
#############################################################################

#
# load_settings_ex loads all settings from a UCI config file to shell
# variables. Use 'env' after loading to get a feel for how they are named.
#
load_settings_ex() {
	# $1 = file
	config_load "$1"	
	exists /tmp/.webif-uci/config-$1 && . /tmp/.webif-uci/config-$1
}

#
# save_settings_ex saves a setting to an intermediate (temporary)
# UCI config file. To persist changes to the final UCI config file, 
# call commit_settings_ex.
#
save_setting_ex() {
	# $1 = file
	# $2 = group
	# $3 = name
	# $4 = value
	mkdir -p /tmp/.webif-uci
	cat >> /tmp/.webif-uci/config-$1 <<EOF
config update "$2"
	option "$3" "$4"
EOF
}

#
# commit_settings_ex applies all pending config changes from save_setting_ex.
#
commit_settings_ex() {(	
	reset_cb
	option_cb() {
		# FIXME: ';' cannot be used in any config values
		updatestr="${updatestr:+$updatestr;}$CONFIG_SECTION.$1=$2"
	}

	for cfg in /tmp/.webif-uci/config-*; do
		exists $cfg || continue
		export cfgfile="${cfg##*config-}"
		export updatestr=
		. $cfg
		
		lock /tmp/.webif-uci/update-$cfgfile
		awk \
			-v cfgfile="/etc/config/$cfgfile" \
			-v updatestr="$updatestr" \
			-f /lib/config/uci-update.awk \
			-f - > /etc/config/$cfgfile.new <<EOF
BEGIN {
	cfg = read_file(cfgfile)
	print update_config(cfg, updatestr)
}
EOF
		equal "$?" 0 && {
			mv /etc/config/$cfgfile.new /etc/config/$cfgfile
			rm -f /tmp/.webif-uci/config-$cfgfile
		}
		lock -u /tmp/.webif-uci/update-$cfgfile
	done
)}


#############################################################################
# Original config functions
#
#  These work with as a tuple based configuration system. apply.sh applies
#  the changes.
#
#############################################################################

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
	# $1 = group
	# $2 = name
	# $3 = value
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


#############################################################################
# Misc. functions
#
# - todo: move elsewhere?? they are not used by above.
#
#############################################################################
remove_lines_from_file() {
	# $1=filename
	# $2=substring match indicating lines to remove (case sensitive)
	cat "$1" | grep -q "$2"
	[ "$?" = "0" ] && {
		local _substr_sed=$(echo "$2" | sed s/'\/'/'\\\/'/g)							
		cat "$1" |  sed /$_substr_sed/d > "$1"
	}
}
