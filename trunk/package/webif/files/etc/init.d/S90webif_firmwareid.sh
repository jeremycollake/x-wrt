#!/bin/sh

# we'll se these only if they aren't already, so that
# they can be pre-empted
firmware_name=$(nvram get firmware_name)
if [ -z "$firmware_name" ]; then
	nvram set firmware_name="OpenWrt White Russian"
	nvram set firmware_subtitle="With X-Wrt Extensions"
	nvram set firmware_version="RC5"
fi


