# 
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=libupnp
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/pupnp
PKG_MD5SUM:=3185b3fd9d7e8f5a3d29314e8d369c66
PKG_CAT:=bzcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBUPNP,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-shared \
		--enable-static \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		DESTDIR="$(PKG_INSTALL_DIR)" install
	touch $@

$(STAGING_DIR)/usr/lib/libupnp.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include/upnp
	$(CP) $(PKG_INSTALL_DIR)/usr/include/upnp/*.h $(STAGING_DIR)/usr/include/upnp/
	mkdir -p $(STAGING_DIR)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libupnp.pc $(STAGING_DIR)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{ixml,threadutil,upnp}.{a,so*} $(STAGING_DIR)/usr/lib/
	touch $@

$(IPKG_LIBUPNP): $(STAGING_DIR)/usr/lib/libupnp.so
	install -m0755 -d $(IDIR_LIBUPNP)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{ixml,threadutil,upnp}.so.* $(IDIR_LIBUPNP)/usr/lib/
	$(RSTRIP) $(IDIR_LIBUPNP)
	$(IPKG_BUILD) $(IDIR_LIBUPNP) $(PACKAGE_DIR)

install-dev: $(STAGING_DIR)/usr/lib/libupnp.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/include/upnp/ \
		$(STAGING_DIR)/usr/lib/pkgconfig/libupnp.pc \
		$(STAGING_DIR)/usr/lib/lib{ixml,threadutil,upnp}.{a,so*}

compile: install-dev
clean: uninstall-dev
