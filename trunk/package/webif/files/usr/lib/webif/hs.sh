
. /etc/hs/functions.sh
[ -e "/etc/chilli/functions" ] && . /etc/chilli/functions

HS_USING=$HS_PROVIDER
[ -n "$HS_PROVIDER_LINK" ] && \
HS_USING="<a href=\"$HS_PROVIDER_LINK\">$HS_USING</a>"
HS_USING=${HS_USING:+" (services by $HS_USING)"}

has_required_pkg() {
	# after load_settings "hotspot"
	pkg=${hs_type:-$(nvram get hs_type)}
	case "$pkg" in
	chillispot)
		has_pkgs chillispot && return 0;
		;;
	wifidog)
		has_pkgs wifidog && return 0;
		;;
	*)
		echo "<p>Select a HotSpot Type <a href=hs.sh>here</a> first.</p>"
		;;
	esac
	return 1;
}
