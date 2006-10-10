#!/bin/sh
echo " Uploading new X-Wrt Repository and Other Files ... "
scp \
	bin/packages/* \
	someuser@shell.berlios.de:/home/groups/ftp/pub/xwrt/packages/

scp \
	build_mipsel/webif-0.3/ipkg/webif/www/.version \
	../../whale/xwrt/xwrt.htm \
	../../whale/xwrt/xwrt.asp \
	someuser@shell.berlios.de:/home/groups/ftp/pub/xwrt/

scp patches/* \
	someuser@shell.berlios.de:/home/groups/ftp/pub/xwrt/patches/

