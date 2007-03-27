# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_SRC_NAME:=matrixssl
PKG_NAME:=libmatrixssl
PKG_VERSION:=1.2.4
PKG_RELEASE:=1
PKG_MD5SUM:=771c1489488e62668d673478311d63ca

PKG_SOURCE:=$(PKG_SRC_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://nbd.vd-s.ath.cx/openwrt
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SRC_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install


include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBMATRIXSSL,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.built: 
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS)  \
		DFLAGS="$(TARGET_CFLAGS) -Wall"
	touch $@

$(IPKG_LIBMATRIXSSL):
	mkdir -p $(IDIR_LIBMATRIXSSL)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libmatrixssl.so.* $(IDIR_LIBMATRIXSSL)/usr/lib/
	$(RSTRIP) $(IDIR_LIBMATRIXSSL)
	$(IPKG_BUILD) $(IDIR_LIBMATRIXSSL) $(PACKAGE_DIR)

$(STAGING_DIR)/src/libmatrixssl.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/matrixSsl.h $(STAGING_DIR)/usr/include/matrixSsl/
	ln -sf matrixSsl/matrixSsl.h $(STAGING_DIR)/usr/include/matrixSsl.h
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libmatrixssl.so.* $(STAGING_DIR)/usr/lib/
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/libmatrixssl.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/include/matrixSsl* \
		$(STAGING_DIR)/usr/lib/libmatrixssl.so*

compile-targets: install-dev
clean-targets: uninstall-dev
	
mostlyclean:
	-$(MAKE) -C $(PKG_BUILD_DIR) clean
	rm -f $(PKG_BUILD_DIR)/.built
