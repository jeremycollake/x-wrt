# 
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=file
PKG_VERSION:=4.21
PKG_RELEASE:=1

PKG_SOURCE_URL:=ftp://ftp.astron.com/pub/file
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=9e3503116f4269a1be70220ee2234b0e

PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBMAGIC,libmagic,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,FILE,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

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
		--disable-rpath \
		--without-libiconv-prefix \
		--without-libintl-prefix \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR)/magic \
		magic
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_LIBMAGIC):
	install -d -m0755 $(IDIR_LIBMAGIC)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmagic.so.* $(IDIR_LIBMAGIC)/usr/lib/
	install -d -m0755 $(IDIR_LIBMAGIC)/usr/share/file
	$(CP) $(PKG_BUILD_DIR)/magic/magic $(IDIR_LIBMAGIC)/usr/share/file/
	$(CP) $(PKG_BUILD_DIR)/magic/magic.mime $(IDIR_LIBMAGIC)/usr/share/file/
	$(RSTRIP) $(IDIR_LIBMAGIC)
	$(IPKG_BUILD) $(IDIR_LIBMAGIC) $(PACKAGE_DIR)

$(IPKG_FILE):
	install -d -m0755 $(IDIR_FILE)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/file $(IDIR_FILE)/usr/bin/
	$(RSTRIP) $(IDIR_FILE)
	$(IPKG_BUILD) $(IDIR_FILE) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libmagic.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/magic.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmagic.{a,so*} $(STAGING_DIR)/usr/lib/
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/libmagic.so

uninstall-dev:
	rm -rf \
	  $(STAGING_DIR)/usr/include/magic.h \
	  $(STAGING_DIR)/usr/lib/libmagic.{a,so} \

compile: install-dev
clean: uninstall-dev
