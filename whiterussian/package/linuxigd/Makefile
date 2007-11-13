# 
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2006 loswillios
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linuxigd
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/linux-igd
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=929f5c4878c91d534613b7c7070215d9

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_CAT:=zcat

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LINUXIGD,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR)  \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		BINDIR="/usr/sbin" \
		MANDIR="/usr/man" \
		HAVE_LIBIPTC=1 \
		LIBIPTC_PREFIX="$(STAGING_DIR)/usr" \
		LIBUPNP_PREFIX="$(STAGING_DIR)/usr" \
		all
	touch $@

$(IPKG_LINUXIGD):
	mkdir -p $(IDIR_LINUXIGD)/usr/sbin
	install -m 755 $(PKG_BUILD_DIR)/upnpd $(IDIR_LINUXIGD)/usr/sbin/
	mkdir -p $(IDIR_LINUXIGD)/etc/linuxigd
	install -m 640 $(PKG_BUILD_DIR)/etc/*.gif $(IDIR_LINUXIGD)/etc/linuxigd/
	install -m 640 $(PKG_BUILD_DIR)/etc/*.xml $(IDIR_LINUXIGD)/etc/linuxigd/
	mkdir -p $(IDIR_LINUXIGD)/etc/init.d
	install -m 755 ./files/upnpd.init $(IDIR_LINUXIGD)/etc/init.d/upnpd
	install -m 640 ./files/upnpd.conf $(IDIR_LINUXIGD)/etc/
	$(STRIP) $(IDIR_LINUXIGD)/usr/sbin/upnpd
	$(IPKG_BUILD) $(IDIR_LINUXIGD) $(PACKAGE_DIR)
