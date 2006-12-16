#!/bin/sh
if [ $# -lt 1 ]; then
        echo "Usage: $0 USERNAME"
        exit 1
fi
export SCP_USER="$1"
rm bin/packages/w?bf??e*
chmod -R 775 bin/*
chmod 775 build_mipsel/webif-0.3/ipkg/webif/www/.version
echo "Uploading webif ..."
scp \
        bin/packages/web* \
        $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/packages/
echo "Uploading webif version info ..."
scp \
        build_mipsel/webif-0.3/ipkg/webif/www/.version \
        $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/
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

ls bin/openwrt-x86-2.6*
[ $? = "0" ] && {
echo "Uploading package repository ..."
scp \
        bin/packages/* \
        $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/x86-2.6/packages/
echo "Uploading X-Wrt patches ..."
scp \
        patches/* \
        $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/x86-2.6/patches/
#echo "Uploading firmware images ..."
#date > /tmp/build-date.txt
#scp \
#       /tmp/build-date.txt \
#       $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/x86-2.6/images/
#scp \
#       bin/openwrt-x86-2.6* \
#       $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/x86-2.6/images/
}
ls bin/openwrt-brcm-2.4*
[ $? = "0" ] && {
echo "Uploading package repository ..."
scp \
        bin/packages/* \
        $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/broadcom-2.4/packages/
echo "Uploading X-Wrt patches ..."
scp \
        patches/* \
        $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/broadcom-2.4/patches/
#echo "Uploading firmware images ..."
#date > /tmp/build-date.txt
#scp \
#       /tmp/build-date.txt \
#       $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/broadcom-2.4/images/
#scp \
#       bin/openwrt-x86-2.6* \
#       $SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/kamikaze/broadcom-2.4/images/
}