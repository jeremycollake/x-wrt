#
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gmediaserver
PKG_VERSION:=0.13.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://savannah.nongnu.org/download/gmediaserver/
PKG_MD5SUM:=c422de386331e2a1a859d45f6fa270a3
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,GMEDIASERVER,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		LIBS="-lz" \
		PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig" \
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
		--disable-rpath \
		--disable-static \
		--enable-shared \
		--enable-threads=posix \
		--without-libintl-prefix \
		--with-libiconv-prefix="$(STAGING_DIR)/usr/lib/libiconv" \
		--with-id3lib="$(STAGING_DIR)/usr" \
		--with-libupnp="$(STAGING_DIR)/usr" \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		LIBMAGIC="-lmagic -lz" \
		UPNP_CFLAGS="-pthread -I$(STAGING_DIR)/usr/include/upnp" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_GMEDIASERVER): $(PKG_BUILD_DIR)/.built
	install -m0755 -d $(IDIR_GMEDIASERVER)/usr/sbin
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(IDIR_GMEDIASERVER)/usr/sbin/
	install -m0755 -d $(IDIR_GMEDIASERVER)/etc/config
	install -m0755 ./files/$(PKG_NAME).config $(IDIR_GMEDIASERVER)/etc/config/$(PKG_NAME)
	install -m0755 -d $(IDIR_GMEDIASERVER)/etc/init.d
	install -m0755 ./files/$(PKG_NAME).init $(IDIR_GMEDIASERVER)/etc/init.d/$(PKG_NAME)
	$(RSTRIP) $(IDIR_GMEDIASERVER)
	$(IPKG_BUILD) $(IDIR_GMEDIASERVER) $(PACKAGE_DIR)
