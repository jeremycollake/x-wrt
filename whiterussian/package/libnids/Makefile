# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnids
PKG_VERSION:=1.18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.packetfactory.net/projects/libnids/dist/
PKG_MD5SUM:=9ee6dcdfac97bae6fe611aa27d2594a5
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBNIDS,libnids,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \
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
		--with-libnet="$(STAGING_DIR)/usr/lib/libnet-1.0.x" \
		--with-libpcap="$(STAGING_DIR)/usr" \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LNETLIB="-L$(STAGING_DIR)/usr/lib/libnet-1.0.x/lib -lnet" \
		install_prefix="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_LIBNIDS): $(STAGING_DIR)/usr/lib/libnids.so
	install -m0755 -d $(IDIR_LIBNIDS)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnids.so.* $(IDIR_LIBNIDS)/usr/lib/
	$(RSTRIP) $(IDIR_LIBNIDS)
	$(IPKG_BUILD) $(IDIR_LIBNIDS) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libnids.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/nids.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnids.{a,so*} $(STAGING_DIR)/usr/lib/
	touch $(STAGING_DIR)/usr/lib/libnids.so

install-dev: $(STAGING_DIR)/usr/lib/libnids.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/include/nids.h \
		$(STAGING_DIR)/usr/lib/libnids.{a,so*}

compile: install-dev
clean: uninstall-dev
