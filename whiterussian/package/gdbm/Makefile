# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=gdbm
PKG_VERSION:=1.8.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://ftp.gnu.org/gnu/gdbm/
PKG_MD5SUM:=1d1b1d5c0245b1c00aff92da751e9aa1
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBGDBM,lib$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
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
		--disable-rpath \
		--enable-shared \
		--enable-static \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		BINOWN=`id -u` \
		BINGRP=`id -g` \
		INSTALL_ROOT="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_LIBGDBM): $(STAGING_DIR)/usr/lib/libgdbm.so
	install -m0755 -d $(IDIR_LIBGDBM)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgdbm.so.* $(IDIR_LIBGDBM)/usr/lib/
	$(RSTRIP) $(IDIR_LIBGDBM)
	$(IPKG_BUILD) $(IDIR_LIBGDBM) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libgdbm.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gdbm.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgdbm.{a,so*} $(STAGING_DIR)/usr/lib/
	touch $(STAGING_DIR)/usr/lib/libgdbm.so

install-dev: $(STAGING_DIR)/usr/lib/libgdbm.so

uninstall-dev:
	rm -rf $(STAGING_DIR)/usr/include/gdbm.h \
	rm -rf $(STAGING_DIR)/usr/lib/libgdbm.{a,so*}

compile: install-dev
clean: uninstall-dev
