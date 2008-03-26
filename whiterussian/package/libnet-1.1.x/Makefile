# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnet
PKG_VERSION:=1.1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_SOURCE_URL:=http://www.packetfactory.net/libnet/dist/
PKG_MD5SUM:=be845c41170d72c7db524f3411b50256
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/libnet
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBNET1,$(PKG_NAME)1,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		touch configure.in \
			include.m4 \
			aclocal.m4 \
			Makefile.in \
			configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
		ac_cv_libnet_endianess=lil \
		ac_libnet_have_pf_packet=yes \
		ac_cv_lbl_unaligned_fail=no \
		LL_INT_TYPE=linux \
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
		--with-pf_packet=yes \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	# pass CFLAGS again to override -O2 set by configure
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_LIBNET1):
	install -m0755 -d $(IDIR_LIBNET1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnet.so.* $(IDIR_LIBNET1)/usr/lib/
	$(RSTRIP) $(IDIR_LIBNET1)
	$(IPKG_BUILD) $(IDIR_LIBNET1) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libnet-1.1.x/lib/libnet.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/lib/libnet-1.1.x/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/libnet-config $(STAGING_DIR)/usr/lib/libnet-1.1.x/bin/
	mkdir -p $(STAGING_DIR)/usr/lib/libnet-1.1.x/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libnet* $(STAGING_DIR)/usr/lib/libnet-1.1.x/include/
	mkdir -p $(STAGING_DIR)/usr/lib/libnet-1.1.x/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnet.{a,so*} $(STAGING_DIR)/usr/lib/libnet-1.1.x/lib/
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/libnet-1.1.x/lib/libnet.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/lib/libnet-1.1.x

compile: install-dev
clean: uninstall-dev
