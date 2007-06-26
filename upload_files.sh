#!/bin/sh
if [ $# -lt 1 ]; then
        echo "Usage: $0 USERNAME"
        exit 1
fi
export SCP_USER="$1"
rm bin/packages/w?bf??e*
chmod -R 775 bin/*
# for my personal shit
if [ -d "/mnt/whale/xwrt" ]; then
        cp /mnt/whale/xwrt/xwrt.htm ht_docs
        cp /mnt/whale/xwrt/xwrt.asp ht_docs
fi
#echo "Uploading xwrt web pages ..."
#scp \
#       ht_docs/xwrt.htm \
#       ht_docs/xwrt.asp \
#       $SCP_USER@shell.berlios.de:/home/groups/xwrt/htdocs/

#Broadcom 2.4
ls bin/openwrt-brcm-2.4* >/dev/null 2>&-
[ $? = "0" ] && {
version="brcm-2.4"
chmod 775 build_mipsel/webif-0.3/ipkg/webif/www/.version
version_file="build_mipsel/webif-0.3/ipkg/webif/www/.version"
echo $version
}

#Broadcom 2.6
ls bin/openwrt-brcm-2.6* >/dev/null 2>&-
[ $? = "0" ] && {
version="brcm-2.6"
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

echo "Uploading webif version info ..."
scp \
	$version_file \
        $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$version/
echo "Uploading package repository ..."
scp \
        bin/packages/* \
        $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$version/packages/
echo "Uploading X-Wrt patches ..."
scp \
        patches/* \
        $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$version/patches/
#echo "Uploading firmware images ..."
#date > /tmp/build-date.txt
#scp \
#       /tmp/build-date.txt \
#       $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$version/images/
#scp \
#       bin/openwrt* \
#       $SCP_USER@downloads.x-wrt.org:/www/xwrt/kamikaze/$version/images/
