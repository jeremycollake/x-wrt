# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libpam
PKG_VERSION:=0.99.6.3
PKG_RELEASE:=2

PKG_SOURCE:=Linux-PAM-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.kernel.org/pub/linux/libs/pam/pre/library/
PKG_MD5SUM:=0f17f7105faa82a51dfbeb6b08a1ca29
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/Linux-PAM-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBPAM,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

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
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-shared \
		--enable-static \
		--enable-pamlocking \
		--disable-prelude \
		--disable-lckpwdf \
		--disable-selinux \
		--disable-rpath \
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

$(IPKG_LIBPAM): $(PKG_BUILD_DIR)/.built
	install -m0755 -d $(IDIR_LIBPAM)/etc
	install -m0755 -d $(IDIR_LIBPAM)/lib/security/pam_filter
	install -m0755 -d $(IDIR_LIBPAM)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/etc/* $(IDIR_LIBPAM)/etc/
	$(CP) $(PKG_INSTALL_DIR)/lib/libpa{m,mc,m_misc}.so.* $(IDIR_LIBPAM)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/security/*.so $(IDIR_LIBPAM)/lib/security/
	$(CP) $(PKG_INSTALL_DIR)/lib/security/pam_filter/* $(IDIR_LIBPAM)/lib/security/pam_filter/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/* $(IDIR_LIBPAM)/usr/sbin/
	$(RSTRIP) $(IDIR_LIBPAM)
	$(IPKG_BUILD) $(IDIR_LIBPAM) $(PACKAGE_DIR)

install-dev: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/lib/security/pam_filter $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/lib/libpa{m,mc,m_misc}.so* $(STAGING_DIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/security/* $(STAGING_DIR)/lib/security/

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/include/security \
		$(STAGING_DIR)/usr/include/_pam_* \
		$(STAGING_DIR)/usr/include/pam_* \
		$(STAGING_DIR)/lib/libpa{m,mc,m_misc}.so* \
		$(STAGING_DIR)/lib/security

compile: install-dev
clean: uninstall-dev

