#!/bin/sh
# compress all images into a single small archive.
# requires tar before compress so all data is in single stream.

CompressDir() {
odir=$(pwd)
cd "$1"
rm -f xwrt*.tar
rm -f xwrt*.rar.tar
tar -cvf xwrt-squashfs-images.tar *squashfs*.bin *squashfs*.trx
#tar -cvf xwrt-jffs-images.tar *jffs*.bin *jffs*.trx
7z a xwrt-firmware-images.7z xwrt-*-images.tar
cd "$odir"
}

CompressDir "imgbuild/bin/default"
CompressDir "imgbuild/bin/micro"
CompressDir "imgbuild/bin/pppoe"
CompressDir "imgbuild/bin/pptp"

