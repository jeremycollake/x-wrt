#!/bin/sh
if [ $# -lt 1 ]; then
        echo "Usage: $0 USERNAME"
        exit 1
fi
export SCP_USER="$1"
kamikaze_version="snapshots"
chmod -R 775 bin/*

#Broadcom 2.4
ls bin/openwrt-brcm-2.4* >/dev/null 2>&-
[ $? = "0" ] && {
version="brcm-2.4"
chmod 775 build_mipsel/webif-0.3/ipkg/webif/www/.version
version_file="build_mipsel/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#Broadcom 2.6
ls bin/openwrt-brcm47xx-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="brcm47xx-2.6"
chmod 775 build_mipsel/webif-0.3/ipkg/webif/www/.version
version_file="build_mipsel/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#x86 2.6
ls bin/openwrt-x86-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="x86-2.6"
chmod 775 build_i386/webif-0.3/ipkg/webif/www/.version
version_file="build_i386/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#Atheros 2.6
ls bin/openwrt-atheros-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="atheros-2.6"
chmod 775 build_mips/webif-0.3/ipkg/webif/www/.version
version_file="build_mips/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#rb532 2.6
ls bin/openwrt-rb532-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="rb532-2.6"
chmod 775 build_mips/webif-0.3/ipkg/webif/www/.version
version_file="build_mips/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#ixp4xx 2.6
ls bin/openwrt-ixp4xx-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="ixp4xx-2.6"
chmod 775 build_armeb/webif-0.3/ipkg/webif/www/.version
version_file="build_armeb/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#magicbox 2.6
ls bin/openwrt-magicbox-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="magicbox-2.6"
chmod 775 build_powerpc/webif-0.3/ipkg/webif/www/.version
version_file="build_powerpc/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#au1000 2.6
ls bin/openwrt-au1000-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="au1000-2.6"
chmod 775 build_mipsel/webif-0.3/ipkg/webif/www/.version
version_file="build_mipsel/webif-0.3/ipkg/webif/www/.version"
echo $version
}


echo "Uploading webif version info ..."
scp \
	$version_file \
        $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$kamikaze_version/$version/
echo "Uploading package repository ..."
scp \
        bin/packages/* \
        $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$kamikaze_version/$version/packages/
echo "Uploading X-Wrt patches ..."
scp \
        patches/* \
        $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$kamikaze_version/$version/patches/
echo "Uploading firmware images ..."
cd bin
md5sum openwrt* > /tmp/md5sums.txt
md5sum OpenWrt* >> /tmp/md5sums.txt
cd ..
scp \
	/tmp/md5sums.txt \
	$SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$kamikaze_version/$version/
date > /tmp/build-date.txt
scp \
       /tmp/build-date.txt \
       $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$kamikaze_version/$version/
scp \
       bin/openwrt* \
       $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$kamikaze_version/$version/
