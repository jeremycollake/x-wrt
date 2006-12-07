. /etc/functions_ex.sh

#############################################################################
# Misc. functions
#
#############################################################################
# workarounds for stupid busybox slowness on [ ]
empty() {
	case "$1" in
		"") return 0 ;;
		*) return 255 ;;
	esac
}

equal() {
	case "$1" in
		"$2") return 0 ;;
		*) return 255 ;;
	esac
}

neq() {
	case "$1" in
		"$2") return 255 ;;
		*) return 0 ;;
	esac
}

# very crazy, but also very fast :-)
exists() {
	( < $1 ) 2>&-
}

is_bcm947xx() {
	read _systype < /proc/cpuinfo
	equal "${_systype##* }" "BCM947XX"
}

is_kamikaze() {
	# todo: switch to a more reliable check of kamikaze
	grep -iq "KAMIKAZE" "/etc/banner"	
}

fix_symlink_hack() {
	touch "$1" >&- 2>&-
	! equal "$?" "0" && {
		local atmpfile
		atmpfile=$(mktemp "/tmp/webif-XXXXXX")
		cp "$1" "$atmpfile"
		equal "$?" "0" && {
			rm "$1"
			mv "$atmpfile" "$1"
		}
	}
}

remove_lines_from_file() {
	# $1=filename
	# $2=substring match indicating lines to remove (case sensitive)
	cat "$1" | grep -q "$2"
	[ "$?" = "0" ] && {
		fix_symlink_hack "$1"
		local _substr_sed
		_substr_sed=$(echo "$2" |  sed s/'\/'/'\\\/'/g)
		cat "$1" |  sed /"$_substr_sed"/d > "$1"
	}
}

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


