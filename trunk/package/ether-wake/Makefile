#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=ether-wake
PKG_NAME_ORIG:=etherwake
PKG_VERSION:=1.09
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME_ORIG)_$(PKG_VERSION).orig.tar.gz
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/e/etherwake
PKG_MD5SUM:=628e8b2a28d47f262e4c26c989402a59
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME_ORIG)-$(PKG_VERSION).orig
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,ETHER_WAKE,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(TARGET_CC) \
		$(TARGET_CFLAGS) \
		-I$(STAGING_DIR)/include \
		-L$(STAGING_DIR)/lib \
		-D__UCLIBC__ \
		$(PKG_BUILD_DIR)/ether-wake.c -o $(PKG_BUILD_DIR)/ether-wake
	touch $@

$(IPKG_ETHER_WAKE):
	mkdir -p $(IDIR_ETHER_WAKE)/usr/sbin
	install -m 755 $(PKG_BUILD_DIR)/$(PKG_NAME) $(IDIR_ETHER_WAKE)/usr/sbin/
	ln -sf /usr/sbin/ether-wake $(IDIR_ETHER_WAKE)/usr/sbin/ether_wake
	ln -sf /usr/sbin/ether-wake $(IDIR_ETHER_WAKE)/usr/sbin/etherwake
	$(RSTRIP) $(IDIR_ETHER_WAKE)
	$(IPKG_BUILD) $(IDIR_ETHER_WAKE) $(PACKAGE_DIR)

