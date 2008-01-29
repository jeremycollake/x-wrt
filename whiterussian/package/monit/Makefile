#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=monit
PKG_VERSION:=4.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.tildeslash.com/monit/dist/
PKG_MD5SUM:=4e53aa44e4ca264e61c7c401cee4e697
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,MONIT,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,MONIT_NOSSL,$(PKG_NAME)-nossl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

CONFIGURE_OPTS := \
		  --target=$(GNU_TARGET_NAME) \
		  --host=$(GNU_TARGET_NAME) \
		  --build=$(GNU_HOST_NAME) \
		  --program-prefix="" \
		  --program-suffix="" \
		  --prefix=/usr \
		  --exec-prefix=/usr \
		  --bindir=/usr/sbin \
		  --datadir=/usr/share \
		  --includedir=/usr/include \
		  --infodir=/usr/share/info \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/etc

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	cd $(PKG_BUILD_DIR); rm -rf config.{cache,status}
	mkdir -p $(PKG_BUILD_DIR)/build_ssl
	(cd $(PKG_BUILD_DIR)/build_ssl; rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		../configure \
		  $(CONFIGURE_OPTS) \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --with-ssl-dir="$(STAGING_DIR)/usr" \
	);
	mkdir -p $(PKG_BUILD_DIR)/build_nossl
	(cd $(PKG_BUILD_DIR)/build_nossl; rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		../configure \
		  $(CONFIGURE_OPTS) \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --without-ssl \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(CP) $(PKG_BUILD_DIR)/build_ssl/* $(PKG_BUILD_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR)
	$(CP) $(PKG_BUILD_DIR)/monit $(PKG_BUILD_DIR)/build_ssl/
	$(MAKE) -C $(PKG_BUILD_DIR) clean
	$(CP) $(PKG_BUILD_DIR)/build_nossl/* $(PKG_BUILD_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR)
	$(CP) $(PKG_BUILD_DIR)/monit $(PKG_BUILD_DIR)/build_nossl/
	touch $@

$(IPKG_MONIT):
	install -d -m0755 $(IDIR_MONIT)/etc
	install -m0600 $(PKG_BUILD_DIR)/monitrc $(IDIR_MONIT)/etc/
	install -d -m0755 $(IDIR_MONIT)/etc/init.d
	install -m0755 ./files/monit.init $(IDIR_MONIT)/etc/init.d/monit
	install -d -m0755 $(IDIR_MONIT)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/build_ssl/monit $(IDIR_MONIT)/usr/sbin/
	$(RSTRIP) $(IDIR_MONIT)
	$(IPKG_BUILD) $(IDIR_MONIT) $(PACKAGE_DIR)

$(IPKG_MONIT_NOSSL):
	install -d -m0755 $(IDIR_MONIT_NOSSL)/etc
	install -m0600 $(PKG_BUILD_DIR)/monitrc $(IDIR_MONIT_NOSSL)/etc/
	install -d -m0755 $(IDIR_MONIT_NOSSL)/etc/init.d
	install -m0755 ./files/monit.init $(IDIR_MONIT_NOSSL)/etc/init.d/monit
	install -d -m0755 $(IDIR_MONIT_NOSSL)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/build_nossl/monit $(IDIR_MONIT_NOSSL)/usr/sbin/
	$(RSTRIP) $(IDIR_MONIT_NOSSL)
	$(IPKG_BUILD) $(IDIR_MONIT_NOSSL) $(PACKAGE_DIR)
