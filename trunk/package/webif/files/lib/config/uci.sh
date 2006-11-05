7#!/bin/sh
# Shell script defining macros for manipulating config files
#
# Copyright (C) 2006 by Fokus Fraunhofer <carsten.tittel@fokus.fraumhofer.de>
# Copyright (C) 2006 by Felix Fietkau <nbd@openwrt.org>
# Docs and minor hacks by Jeremy Collake <jeremy@bitsum.com>
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
# How the UCI system works:
#
#  Each package has a configuration file in standard uci format stored in
#  /etc/config/. The configuration files are named after the base name of 
#  their owner packages, i.e. for 'qos' package the configuration file is
#  /etc/config/qos.
#
#  Changes to UCI config files are done by first saving changes to a 
#  temporary file in /tmp/.uci/ that is named the same as the configuration 
#  file it pertains to, i.e. /tmp/.uci/qos. The uci_add and other functions
#  will save changes to this intermediate area. 
# 
#  The uci_load function will load config files and then any uncommitted
#  changes found in /tmp/.uci. Therefore, when working with config files
#  uncomitted changes are visible as long as you use this function.
# 
#  One commits pending changes by calling uci_commit. This function will
#  write changes found in /tmp/.uci to the pertainent package configuration 
#  file, then delete the temporary file in /tmp/.uci if successful.
#
#

###########################################################################
# uci_load(package)
#
#  This function loads config given as $1 into shell variables named 
#   CONFIG_group_variable=value
#  This function DOES load pending changes that haven't been committed.
###########################################################################
uci_load() {
	local PACKAGE="$1"
	config_load "$PACKAGE"
	local PACKAGE_BASE="$(basename "$PACKAGE")"
	[ -f "/tmp/.uci/${PACKAGE_BASE}" ] && {
		. "/tmp/.uci/${PACKAGE_BASE}"
		config_cb
	}
}


###########################################################################
# uci_do_update(filename, update)
#
#  
###########################################################################
uci_do_update() {
	local FILENAME="$1"
	local UPDATE="$2"
	awk -f /lib/config/uci-update.awk -f - <<EOF
BEGIN {
	config = read_file("$FILENAME")
	$UPDATE
	print config
}
EOF
}

###########################################################################
# uci_add_update(filename, update)
#
#
###########################################################################
uci_add_update() {
	local PACKAGE="$1"
	local UPDATE="$2"
	local PACKAGE_BASE="$(basename "$PACKAGE")"
	
	# FIXME: add locking?
	mkdir -p "/tmp/.uci"
	echo "$UPDATE" >> "/tmp/.uci/${PACKAGE_BASE}"
}

###########################################################################
# uci_set(package, config_group, option, value)
#
#  Set a particular option value.
###########################################################################
uci_set() {
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	local VALUE="$4"

	( # spawn a subshell so you don't mess up the current environment
		uci_load "$PACKAGE"
		config_get type "$CONFIG" TYPE
		[ -z "$type" ]
	) || uci_add_update "$PACKAGE" "CONFIG_SECTION='$CONFIG'${N}option '$OPTION' '$VALUE'"
}

###########################################################################
# uci_add(package, type, config_group)
#
#  Add a new config group.
###########################################################################
uci_add() {
	local PACKAGE="$1"
	local TYPE="$2"
	local CONFIG="$3"

	uci_add_update "$PACKAGE" "config '$TYPE' '$CONFIG'"
}

###########################################################################
# uci_rename(package, config_group, new_config_group)
#
#
###########################################################################
uci_rename() {
	local PACKAGE="$1"
	local CONFIG="$2"
	local VALUE="$3"

	uci_add_update "$PACKAGE" "config_rename '$CONFIG' '$VALUE'"
}

###########################################################################
# uci_remove(package, config_group, option)
#
#
###########################################################################
uci_remove() {
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"

	if [ -z "$OPTION" ]; then
		uci_add_update "$PACKAGE" "config_clear '$CONFIG'"
	else
		uci_add_update "$PACKAGE" "config_unset '$CONFIG' '$OPTION'"
	fi
}

###########################################################################
# uci_commit(package)
#
#
###########################################################################
uci_commit() {
	local PACKAGE="$1"
	local PACKAGE_BASE="$(basename "$PACKAGE")"
	
	mkdir -p /tmp/.uci
	lock "/tmp/.uci/$PACKAGE_BASE.lock"
	[ -f "/tmp/.uci/$PACKAGE_BASE" ] && (
		updatestr=""
		
		# replace handlers
		config() {
			append updatestr "config = update_config(config, \"@$2=$1\")" "$N"
		}
		option() {
			append updatestr "config = update_config(config, \"$CONFIG_SECTION.$1=$2\")" "$N"
		}
		config_rename() {
			append updatestr "config = update_config(config, \"&$1=$2\")" "$N"
		}
		config_unset() {
			append updatestr "config = update_config(config, \"-$1.$2\")" "$N"
		}
		config_clear() {
			append updatestr "config = update_config(config, \"-$1\")" "$N"
		}
		
		. "/tmp/.uci/$PACKAGE_BASE"

		# completely disable handlers so that they don't get in the way
		config() {
			return 0
		}
		option() {
			return 0
		}
		
		config_load "$PACKAGE" || CONFIG_FILENAME="$ROOT/etc/config/$PACKAGE_BASE"
		uci_do_update "$CONFIG_FILENAME" "$updatestr" > "/tmp/.uci/$PACKAGE_BASE.new" && {
			mv -f "/tmp/.uci/$PACKAGE_BASE.new" "$CONFIG_FILENAME" && \
			rm -f "/tmp/.uci/$PACKAGE_BASE"
		} 
	)
	lock -u "/tmp/.uci/$PACKAGE_BASE.lock"
}
