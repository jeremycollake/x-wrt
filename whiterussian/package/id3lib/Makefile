# 
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=id3lib
PKG_VERSION:=3.8.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/id3lib
PKG_MD5SUM:=19f27ddd2dda4b2d26a559a4f0f402a7
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,ID3LIB,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		CXXFLAGS="$(TARGET_CFLAGS) -fno-builtin -fno-rtti"  \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		LIBS="-nodefaultlibs -Wl,-Bdynamic,-luClibc++,-Bstatic,-lstdc++,-Bdynamic,-lz,-lm,-lc" \
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
		--with-gnu-ld \
	);
	find $(PKG_BUILD_DIR) -name 'libtool' | xargs -r \
		$(SED) 's,^hardcode_libdir_flag_spec=.*,hardcode_libdir_flag_spec=" -D__DIE_RPATH_DIE__ ",g'
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) all
	find $(PKG_BUILD_DIR) -name '*.la' | xargs -r \
		$(SED) "s,^libdir='/usr/lib',libdir='$(strip $(PKG_INSTALL_DIR))/usr/lib',g"
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR="$(PKG_INSTALL_DIR)" install
	touch $@

$(STAGING_DIR)/usr/lib/libid3.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) -a $(PKG_INSTALL_DIR)/usr/include/id3 $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/id3.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libid3.{a,so} $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libid3-*.so.* $(STAGING_DIR)/usr/lib/
	touch $@

$(IPKG_ID3LIB): $(STAGING_DIR)/usr/lib/libid3.so
	install -m0755 -d $(IDIR_ID3LIB)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libid3-*.so.* $(IDIR_ID3LIB)/usr/lib/
	$(RSTRIP) $(IDIR_ID3LIB)
	$(IPKG_BUILD) $(IDIR_ID3LIB) $(PACKAGE_DIR)

install-dev: $(STAGING_DIR)/usr/lib/libid3.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/include/id3/ \
		$(STAGING_DIR)/usr/include/id3.h \
		$(STAGING_DIR)/usr/lib/libid3.{a,so} \
		$(STAGING_DIR)/usr/lib/libid3-*.so.*

compile: install-dev
clean: uninstall-dev
