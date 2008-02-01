# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=jpeg
PKG_VERSION:=6b
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)src.v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.ijg.org/files/ \
        ftp://ftp.uu.net/graphics/jpeg/
PKG_MD5SUM:=dbd5f3b47ed13132f04c685d608a7547
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBJPEG,lib$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,JPEG_TOOLS,$(PKG_NAME)-tools,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:  $(PKG_BUILD_DIR)/.prepared
	# replace the old upstream libtool stuff with our own
	ln -sf $(STAGING_DIR)/usr/bin/libtool $(PKG_BUILD_DIR)/
	ln -sf $(STAGING_DIR)/usr/share/libtool/config.sub $(PKG_BUILD_DIR)/
	ln -sf $(STAGING_DIR)/usr/share/libtool/config.guess $(PKG_BUILD_DIR)/
	ln -sf $(STAGING_DIR)/usr/share/libtool/ltmain.sh $(PKG_BUILD_DIR)/
	ln -sf /bin/true $(PKG_BUILD_DIR)/ltconfig
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
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --enable-shared \
		  --enable-static \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)/usr/{include,lib,bin,man/man1}
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LIBTOOL="./libtool --tag=CC" \
		prefix="$(PKG_INSTALL_DIR)/usr" \
		exec_prefix="$(PKG_INSTALL_DIR)/usr" \
		all install install-headers install-lib
	touch $@

$(IPKG_LIBJPEG): $(STAGING_DIR)/usr/lib/libdb.so
	install -m0755 -d $(IDIR_LIBJPEG)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.so.* $(IDIR_LIBJPEG)/usr/lib/
	$(RSTRIP) $(IDIR_LIBJPEG)
	$(IPKG_BUILD) $(IDIR_LIBJPEG) $(PACKAGE_DIR)

$(IPKG_JPEG_TOOLS): $(STAGING_DIR)/usr/lib/libdb.so
	install -m0755 -d $(IDIR_JPEG_TOOLS)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/*jpeg* $(IDIR_JPEG_TOOLS)/usr/bin/
	$(RSTRIP) $(IDIR_JPEG_TOOLS)
	$(IPKG_BUILD) $(IDIR_JPEG_TOOLS) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libjpeg.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/jpeglib.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/jpegint.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/j{config,error,morecfg}.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.{a,so*} $(STAGING_DIR)/usr/lib/
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/libjpeg.so

uninstall-dev:
	rm -rf $(STAGING_DIR)/usr/include/jpeglib.h
	rm -rf $(STAGING_DIR)/usr/include/jpegint.h
	rm -rf $(STAGING_DIR)/usr/include/j{config,error,morecfg}.h
	rm -rf $(STAGING_DIR)/usr/lib/libjpeg.{a,so*}

compile: install-dev
clean: uninstall-dev
