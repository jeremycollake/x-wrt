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

load_settings() {
	config_load "$1"
	exists /tmp/.webif/config-$1 && . /tmp/.webif/config-$1
}

save_setting() {
	mkdir -p /tmp/.webif
	cat >> /tmp/.webif/config-$1 <<EOF
config update "$2"
	option "$3" "$4"
EOF
}

commit_settings() {(
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
