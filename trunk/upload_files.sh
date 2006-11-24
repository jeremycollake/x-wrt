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
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/packages/
echo "Uploading webif version info ..."
scp \
	build_mipsel/webif-0.3/ipkg/webif/www/.version \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/
# for my personal shit
if [ -d "/mnt/whale/xwrt" ]; then
	cp /mnt/whale/xwrt/xwrt.htm ht_docs
	cp /mnt/whale/xwrt/xwrt.asp ht_docs
fi
echo "Uploading xwrt web pages ..."
scp \
	ht_docs/xwrt.htm \
	ht_docs/xwrt.asp \
	$SCP_USER@shell.berlios.de:/home/groups/xwrt/htdocs/
echo "Uploading package repository ..."
scp \
	bin/packages/* \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/packages/
echo "Uploading X-Wrt patches ..."
scp \
	patches/* \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/patches/

echo "Uploading firmware images ..."
date > /tmp/build-date.txt
scp \
	/tmp/build-date.txt \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/default/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/*.7z \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/default/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/*.bin \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/default/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/*.trx \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/default/
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/*.7z \
#	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/micro/
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/*.bin \
#	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/micro/
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/*.trx \
#	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/micro/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pppoe/*.7z \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/pppoe/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pppoe/*.bin \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/pppoe/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pppoe/*.trx \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/pppoe/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/*.7z \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/pptp/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/*.bin \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/pptp/
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/*.trx \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/pptp/
echo "Uploading SDk and image builder ..."
scp \
	bin/*.tar.bz2 \
	$SCP_USER@shell.berlios.de:/home/groups/ftp/pub/xwrt/images/white-russian-latest/


