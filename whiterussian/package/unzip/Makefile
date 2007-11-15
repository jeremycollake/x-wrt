# 
# Copyright (C) 2007 X-Wrt.org 
# 
# This is free software, licensed under the GNU General Public License v2. 
# See /LICENSE for more information. 
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=unzip
SRC_VERSION:=552
PKG_VERSION:=5.52
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)$(SRC_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/infozip
PKG_MD5SUM:=9d23919999d6eac9217d1f41472034a9
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,UNZIP,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,UNZIP_TOOLS,$(PKG_NAME)-tools,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) -f unix/Makefile generic \
		$(TARGET_CONFIGURE_OPTS) \
		prefix="$(PKG_INSTALL_DIR)/usr" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CF="$(TARGET_CFLAGS) -O -I$(STAGING_DIR)/usr/include -I. -DUNIX" \
		LD="$(TARGET_CC) -L$(STAGING_DIR)/usr/lib" \
		install
	touch $@

$(IPKG_UNZIP):
	install -d -m0755 $(IDIR_UNZIP)/usr/bin
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/unzip $(IDIR_UNZIP)/usr/bin/
	$(RSTRIP) $(IDIR_UNZIP)
	$(IPKG_BUILD) $(IDIR_UNZIP) $(PACKAGE_DIR)

$(IPKG_UNZIP_TOOLS):
	install -d -m0755 $(IDIR_UNZIP_TOOLS)/usr/bin
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/funzip $(IDIR_UNZIP_TOOLS)/usr/bin/
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/unzipsfx $(IDIR_UNZIP_TOOLS)/usr/bin/
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/zipinfo $(IDIR_UNZIP_TOOLS)/usr/bin/
	$(RSTRIP) $(IDIR_UNZIP_TOOLS)
	$(IPKG_BUILD) $(IDIR_UNZIP_TOOLS) $(PACKAGE_DIR)
