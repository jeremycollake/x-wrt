# 
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xyssl
PKG_VERSION:=0.7
PKG_RELEASE:=1
PKG_MD5SUM:=f6422c393a4ca72577331f373c6c4248

PKG_SOURCE_URL:=http://www.xyssl.org/code/download
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBXYSSL,lib$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,XYSSLPROGS,$(PKG_NAME)-progs,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		OFLAGS="$(TARGET_CFLAGS)" \
		all
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)/usr" \
		install
	touch $@

$(IPKG_LIBXYSSL):
	install -d -m0755 $(IDIR_LIBXYSSL)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libxyssl.so $(IDIR_LIBXYSSL)/usr/lib
	$(RSTRIP) $(IDIR_LIBXYSSL)
	$(IPKG_BUILD) $(IDIR_LIBXYSSL) $(PACKAGE_DIR)

$(IPKG_XYSSLPROGS):
	install -d -m0755 $(IDIR_XYSSLPROGS)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/xyssl_* $(IDIR_XYSSLPROGS)/usr/bin
	$(RSTRIP) $(IDIR_XYSSLPROGS)
	$(IPKG_BUILD) $(IDIR_XYSSLPROGS) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libxyssl.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/xyssl $(STAGING_DIR)/usr/include
	mkdir -p $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libxyssl.{a,so} $(STAGING_DIR)/usr/lib/
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/libxyssl.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/include/xyssl \
		$(STAGING_DIR)/usr/lib/libxyssl.{a,so}

compile: install-dev
clean: uninstall-dev

mostlyclean:
	make -C $(PKG_BUILD_DIR) clean
	rm $(PKG_BUILD_DIR)/.built
