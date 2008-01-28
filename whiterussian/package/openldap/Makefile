# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openldap
PKG_VERSION:=2.2.29
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/ \
	ftp://sunsite.cnlab-switch.ch/mirror/OpenLDAP/openldap-release/ \
	ftp://ftp.nl.uu.net/pub/unix/db/openldap/openldap-release/ \
	ftp://ftp.plig.org/pub/OpenLDAP/openldap-release/
PKG_MD5SUM:=6c4c72a1336aa45b463e738034c078d6
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBOPENLDAP,libopenldap,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,OPENLDAP_UTILS,openldap-utils,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
		ac_cv_func_memcmp_clean="yes" \
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
		  --disable-debug \
		  --enable-dynamic \
		  --enable-syslog \
		  --disable-local \
		  --disable-slapd \
		  --disable-slurpd \
		  --without-fetch \
		  --with-yielding_select="yes" \
		  --without-cyrus-sasl \
		  --without-threads \
		  --without-tls  \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		HOSTCC="$(HOSTCC)" \
		depend all install
	touch $@

$(IPKG_LIBOPENLDAP):
	mkdir -p $(IDIR_LIBOPENLDAP)/etc/openldap
	$(CP) $(PKG_INSTALL_DIR)/etc/openldap/ldap.conf $(IDIR_LIBOPENLDAP)/etc/openldap/
	mkdir -p $(IDIR_LIBOPENLDAP)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{lber,ldap}*.so.* $(IDIR_LIBOPENLDAP)/usr/lib/
	mkdir -p $(IDIR_LIBOPENLDAP)/usr/share/openldap
	$(CP) $(PKG_INSTALL_DIR)/usr/share/openldap/* $(IDIR_LIBOPENLDAP)/usr/share/openldap/
	$(RSTRIP) $(IDIR_LIBOPENLDAP)
	$(IPKG_BUILD) $(IDIR_LIBOPENLDAP) $(PACKAGE_DIR)
	
$(IPKG_OPENLDAP_UTILS):
	mkdir -p $(IDIR_OPENLDAP_UTILS)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ldap* $(IDIR_OPENLDAP_UTILS)/usr/bin/
	$(RSTRIP) $(IDIR_OPENLDAP_UTILS)
	$(IPKG_BUILD) $(IDIR_OPENLDAP_UTILS) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libldap.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/{lber,ldap}*.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{lber,ldap}*.{a,so*} $(STAGING_DIR)/usr/lib/
	
install-dev: $(STAGING_DIR)/usr/lib/libldap.so

uninstall-dev:
	rm -rf $(STAGING_DIR)/usr/include/{lber,ldap}*.h
	rm -rf $(STAGING_DIR)/usr/lib/lib{lber,ldap}*.{a,so*}

compile: install-dev
clean: uninstall-dev
