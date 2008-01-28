#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn
PKG_VERSION:=2.0.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://openvpn.net/release @SF/openvpn
PKG_MD5SUM:=60745008b90b7dbe25fe8337c550fec6
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,OPENVPN,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,OPENVPN_EASY_RSA,$(PKG_NAME)-easy-rsa,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

PKG_DEPEND:="kmod-tun"
ifneq ($(BR2_PACKAGE_OPENVPN_OPENSSL),y)
DISABLE_OPENSSL:=--disable-ssl --disable-crypto
else
PKG_DEPEND+=", libopenssl"
endif
ifneq ($(BR2_PACKAGE_OPENVPN_LZO),y)
DISABLE_LZO:=--disable-lzo
else
PKG_DEPEND+=", liblzo"
endif
ifneq ($(BR2_PACKAGE_OPENVPN_SERVER),y)
DISABLE_SERVER:=--disable-server
endif
ifneq ($(BR2_PACKAGE_OPENVPN_HTTP),y)
DISABLE_HTTP:=--disable-http
endif
ifeq ($(BR2_PACKAGE_OPENVPN_PASSWORD_SAVE),y)
ENABLE_PASSWORD_SAVE:=--enable-password-save
endif
ifeq ($(BR2_PACKAGE_OPENVPN_SMALL),y)
ENABLE_SMALL:=--enable-small
endif
ifneq ($(BR2_PACKAGE_OPENVPN_MANAGEMENT),y)
DISABLE_MANAGEMENT:=--disable-management
endif

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(strip $(TARGET_CFLAGS))" \
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
		  --disable-static \
		  --disable-pthread \
		  --disable-debug \
		  --disable-plugins \
		  --disable-socks \
		  $(DISABLE_LZO) \
		  $(DISABLE_OPENSSL) \
		  $(DISABLE_SERVER) \
		  $(DISABLE_HTTP) \
		  $(ENABLE_PASSWORD_SAVE) \
		  $(ENABLE_SMALL) \
		  $(DISABLE_MANAGEMENT) \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_OPENVPN):
	install -d -m0755 $(IDIR_OPENVPN)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/openvpn $(IDIR_OPENVPN)/usr/sbin/
	echo "Depends: $(PKG_DEPEND)" >> $(IDIR_OPENVPN)/CONTROL/control
	$(RSTRIP) $(IDIR_OPENVPN)
	$(IPKG_BUILD) $(IDIR_OPENVPN) $(PACKAGE_DIR)

$(IPKG_OPENVPN_EASY_RSA):
	install -d -m0755 $(IDIR_OPENVPN_EASY_RSA)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/easy-rsa/2.0/{build-*,clean-all,inherit-inter,list-crl,pkitool,revoke-full,sign-req,whichopensslcnf} $(IDIR_OPENVPN_EASY_RSA)/usr/sbin
	install -d -m0755 $(IDIR_OPENVPN_EASY_RSA)/etc/easy-rsa
	install -m 0644 $(PKG_BUILD_DIR)/easy-rsa/2.0/openssl.cnf $(IDIR_OPENVPN_EASY_RSA)/etc/easy-rsa/
	install -m 0644 $(PKG_BUILD_DIR)/easy-rsa/2.0/vars $(IDIR_OPENVPN_EASY_RSA)/etc/easy-rsa/
	$(IPKG_BUILD) $(IDIR_OPENVPN_EASY_RSA) $(PACKAGE_DIR)
