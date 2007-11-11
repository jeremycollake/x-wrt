#
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libiconv
PKG_VERSION:=1.9.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/libiconv
PKG_MD5SUM:=0c99a05e0c3c153bac1c960f78711155
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBICONV,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,ICONV,iconv,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -DUSE_DOS" \
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
		CFLAGS="$(TARGET_CFLAGS) -DUSE_DOS" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(STAGING_DIR)/usr/lib/libiconv/lib/libiconv.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/lib/libiconv/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(STAGING_DIR)/usr/lib/libiconv/include/
	mkdir -p $(STAGING_DIR)/usr/lib/libiconv/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcharset.{a,so*} $(STAGING_DIR)/usr/lib/libiconv/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiconv.{a,so*} $(STAGING_DIR)/usr/lib/libiconv/lib/
	touch $@

$(IPKG_LIBICONV): $(STAGING_DIR)/usr/lib/libiconv/lib/libiconv.so
	install -m0755 -d $(IDIR_LIBICONV)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcharset.so.* $(IDIR_LIBICONV)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiconv.so.* $(IDIR_LIBICONV)/usr/lib/
	$(RSTRIP) $(IDIR_LIBICONV)
	$(IPKG_BUILD) $(IDIR_LIBICONV) $(PACKAGE_DIR)

$(IPKG_ICONV): $(STAGING_DIR)/usr/lib/libiconv/lib/libiconv.so
	install -m0755 -d $(IDIR_ICONV)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/iconv $(IDIR_ICONV)/usr/bin/
	$(RSTRIP) $(IDIR_ICONV)
	$(IPKG_BUILD) $(IDIR_ICONV) $(PACKAGE_DIR)

install-dev: $(STAGING_DIR)/usr/lib/libiconv/lib/libiconv.so

uninstall-dev:
	rm -rf	$(STAGING_DIR)/usr/lib/libiconv

compile: install-dev
clean: uninstall-dev
