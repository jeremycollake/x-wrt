#!/bin/sh
scp \
	bin/packages/* \
	jcollake@shell.berlios.de:/home/groups/ftp/pub/xwrt/packages/

scp \
	build_mipsel/webif-0.3/ipkg/webif/www/.version \
	../../whale/xwrt/xwrt.htm \
	../../whale/xwrt/xwrt.asp \
	jcollake@shell.berlios.de:/home/groups/ftp/pub/xwrt/packages/

scp patches/* \
	jcollake@shell.berlios.de:/home/groups/ftp/pub/xwrt/patches/

