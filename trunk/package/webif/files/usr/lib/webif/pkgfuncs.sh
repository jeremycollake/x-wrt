#
# This file includes all functions applicable to
# package management.
#
# (c) 2006 Jeremy Collake - X-Wrt Project
#
#
is_package_installed() {
	# $1 = package name
	# returns 0 if package is installed.

	ipkg list_installed | grep "$1" >> /dev/null 2>&1
}

install_package() {
	# $1 = package name or URL
	# returns 0 if success.
	# if package is not found, and it isn't a URL, then it'll
	# try an 'ipkg update' to see if it can locate it. Does
	# emit output to std devices.
	ipkg install "$1" -force-overwrite -force-defaults | uniq
	! equal "$?" "0" &&
	{
		echo "$1" | grep "://" >> /dev/null
		! equal "$?" "0" && {
			# wasn't a URL, so update
			ipkg update
			ipkg install "$1" -force-overwrite -force-defaults | uniq
		}
	}
}

remove_package() {
	# $1 = package name
	# returns 0 if success.
	ipkg remove "$1"
}

update_package_list() {
	ipkg update >> /dev/null
}

add_package_source() {
	# $1 = new source
	# this will not check for duplicates.
	# for squashfs with symlink hack, rm first.

	local ipkgtmp=$(mktemp /tmp/.webif-XXXXXX)
	cp "/etc/ipkg.conf" "$ipkgtmp"
	cat "$1" >> "$ipkgtmp"
	rm "/etc/ipkg.conf"
	mv "$ipkgtmp" "/etc/ipkg.conf"
}

has_pkgs() {
	local pcnt=0
	local nothave=0
	local retval=0;
	for pkg in "$@"; do
		pcnt=$((pcnt + 1))
		empty $(ipkg list_installed | grep "^$pkg ") && {
			echo -n "<p>@TR<<Features on this page require the>> \"<b>$pkg</b>\" @TR<<package>>. &nbsp;<a href=\"/cgi-bin/webif/ipkg.sh?action=install&pkg=$pkg&prev=$SCRIPT_NAME\">@TR<<install now>></a>.</p>"
			retval=1;
			nothave=$((nothave + 1))
		}
	done	
	if [ "$pcnt" = "$nothave" ]; then
		_savebutton=""
	fi
	return $retval;
}