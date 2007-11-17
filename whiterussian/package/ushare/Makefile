# 
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ushare
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://ushare.geexbox.org/releases
PKG_MD5SUM:=a6dad95e61ded6f37fc158d9a81358dc
PKG_CAT:=bzcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,USHARE,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/upnp -I$(STAGING_DIR)/usr/lib/libiconv/include" \
		CPPFLAGS="-I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/upnp -I$(STAGING_DIR)/usr/lib/libiconv/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib/libiconv/lib" \
		LIBS=" -liconv" \
		PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
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
		--with-libiconv-prefix="$(STAGING_DIR)/usr/lib/libiconv" \
		--without-libintl-prefix \
		--with-libupnp="$(STAGING_DIR)/usr" \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_USHARE):
	install -m0755 -d $(IDIR_USHARE)/usr/sbin
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(IDIR_USHARE)/usr/sbin/
	install -m0755 -d $(IDIR_USHARE)/etc/config
	install -m0644 ./files/$(PKG_NAME).config $(IDIR_USHARE)/etc/config/$(PKG_NAME)
	install -m0755 -d $(IDIR_USHARE)/etc/init.d
	install -m0755 ./files/$(PKG_NAME).init $(IDIR_USHARE)/etc/init.d/$(PKG_NAME)
	$(RSTRIP) $(IDIR_USHARE)
	$(IPKG_BUILD) $(IDIR_USHARE) $(PACKAGE_DIR)
