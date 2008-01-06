# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=p910nd
PKG_VERSION:=0.91
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://etherboot.sourceforge.net/p910nd
PKG_MD5SUM:=e9000417318756cf8887882e66504dee
PKG_CAT:=bzcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,P910ND,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC=$(TARGET_CC) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -DLOCKFILE_DIR=\"\\\"/tmp\\\"\""
	touch $@

$(IPKG_P910ND): $(PKG_BUILD_DIR)/.built
	install -d -m0755 $(IDIR_P910ND)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/$(PKG_NAME) $(IDIR_P910ND)/usr/sbin/
	install -d -m0755 $(IDIR_P910ND)/etc/default/
	install -m0644 ./files/p910nd.default $(IDIR_P910ND)/etc/default/p910nd
	install -d -m0755 $(IDIR_P910ND)/etc/init.d/
	install -m0755 ./files/p910nd.init $(IDIR_P910ND)/etc/init.d/S90p910nd
	$(STRIP) $(IDIR_P910ND)/usr/sbin/*
	$(IPKG_BUILD) $(IDIR_P910ND) $(PACKAGE_DIR)

