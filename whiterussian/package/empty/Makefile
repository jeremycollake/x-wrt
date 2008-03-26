#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 9029 2007-09-25 23:32:13Z nico $

include $(TOPDIR)/rules.mk

PKG_NAME:=empty
PKG_VERSION:=0.6.15b
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=@SF/empty
PKG_MD5SUM:=#e56d0d81e5e40b1c41c4b9ed74a1edd8
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,EMPTY,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		all
	touch $@

$(IPKG_EMPTY):
	install -m0755 -d $(IDIR_EMPTY)/bin
	install -m0755  $(PKG_BUILD_DIR)/empty $(IDIR_EMPTY)/bin/
	$(RSTRIP) $(IDIR_EMPTY)
	$(IPKG_BUILD) $(IDIR_EMPTY) $(PACKAGE_DIR)
