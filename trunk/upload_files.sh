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
rm bin/packages/webf??e* -rf
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
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/
scp \
	../../ht_docs/howtoflash-7z.txt \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/
md5sum imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/* > imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/md5sums.txt
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/md5sums.txt \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/default
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/*.7z \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/default
rm imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/*v5*.bin
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/*.bin \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/default
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/default/*.trx \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/default

md5sum imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/* > imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/md5sums.txt
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/md5sums.txt \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/micro
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/*.7z \
#	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/micro
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/*.bin \
#	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/micro
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/micro/*.trx \
#	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/micro
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pppoe/*.7z \
#	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/pppoe
rm imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pppoe/*v5*.bin
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pppoe/*.bin \
#	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/pppoe
#scp \
#	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pppoe/*.trx \
#	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/pppoe

md5sum imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/* > imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/md5sums.txt
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/md5sums.txt \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/pptp
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/*.7z \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/pptp
rm imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/*v5*.bin
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/*.bin \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/pptp
scp \
	imgbuild/OpenWrt-ImageBuilder-Linux-i686/bin/pptp/*.trx \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/pptp
echo "Uploading SDk and image builder ..."
scp \
	bin/*.tar.bz2 \
	xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/imagebuilder

xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/milestone_2-5/default/
xwrt@xwrt.kicks-ass.org:/www/xwrt/firmware_images/whiterussian/pre-0.9/latest-daily-build/



