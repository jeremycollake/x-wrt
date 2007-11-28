#
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unrar
PKG_VERSION:=3.7.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.rarlab.com/rar
PKG_MD5SUM:=b783f1932bc0c73902c6399f7c2c6f43
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,UNRAR,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) -f makefile.unix \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		LIBS="-nodefaultlibs -luClibc++" \
		STRIP=:
	touch $@

$(IPKG_UNRAR):
	install -d -m0755 $(IDIR_UNRAR)/usr/bin
	install -m0755 $(PKG_BUILD_DIR)/unrar $(IDIR_UNRAR)/usr/bin/
	$(RSTRIP) $(IDIR_UNRAR)
	$(IPKG_BUILD) $(IDIR_UNRAR) $(PACKAGE_DIR)
