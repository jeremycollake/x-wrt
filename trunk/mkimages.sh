#!/bin/sh
# use the image builder to make X-Wrt images.
echo "Making firmware images ..."
rm -rf imgbuild
mkdir -p ./imgbuild
cd imgbuild
tar -xjf ../bin/OpenWrt-ImageBuilder-Linux-i686.tar.bz2 
cd OpenWrt-ImageBuilder-Linux-i686
make
cd ../..
