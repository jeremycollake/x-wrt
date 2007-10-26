# 
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xrelayd
PKG_VERSION:=0.2
PKG_RELEASE:=1
PKG_MD5SUM:=7bf10a509292d8c6a43662e958a9aba7

PKG_SOURCE_URL:=http://znerol.ch/files
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,XRELAYD,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CC=$(TARGET_CC) \
		LD=$(TARGET_CC) \
		CFLAGS="$(strip $(TARGET_CFLAGS))" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
		prefix="$(PKG_INSTALL_DIR)/usr"
	mkdir -p $(PKG_INSTALL_DIR)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/xrelayd $(PKG_INSTALL_DIR)/usr/bin
	touch $@

$(IPKG_XRELAYD):
	install -d -m0755 $(IDIR_XRELAYD)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/xrelayd $(IDIR_XRELAYD)/usr/bin
	$(RSTRIP) $(IDIR_XRELAYD)
	$(IPKG_BUILD) $(IDIR_XRELAYD) $(PACKAGE_DIR)

mostlyclean:
	make -C $(PKG_BUILD_DIR) clean
	rm $(PKG_BUILD_DIR)/.built
