#
# This file includes all functions applicable to
# package management.
#
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
	ipkg install "$1" -force-overwrite
	! equal "$?" "0" &&
	{		
		echo "$1" | grep "://" >> /dev/null
		! equal "$?" "0" && {
			# wasn't a URL, so update
			ipkg update
			ipkg install "$1" -force-overwrite
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