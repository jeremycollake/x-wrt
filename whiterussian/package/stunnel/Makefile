#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stunnel
PKG_VERSION:=4.24
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.stunnel.org/download/stunnel/src
PKG_MD5SUM:=f2eea97f2e51f524b4add907ffae077b
#5f3d267c108cc0998b8fcaa16dcc5767
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,STUNNEL,stunnel,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -DPIDFILE=\\\"/var/run/stunnel.pid\\\" -DLIBDIR=\\\"/usr/lib\\\"" \
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
		  --with-random=/dev/urandom \
		  --with-threads=fork \
		  --enable-ipv6 \
		  --with-ssl=$(STAGING_DIR)/usr \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)/etc/stunnel
	echo '#dummy' > $(PKG_INSTALL_DIR)/etc/stunnel/stunnel.pem
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_STUNNEL):
	install -d -m0755 $(IDIR_STUNNEL)/usr/sbin \
		$(IDIR_STUNNEL)/usr/lib \
		$(IDIR_STUNNEL)/etc/stunnel \
		$(IDIR_STUNNEL)/etc/init.d
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/stunnel $(IDIR_STUNNEL)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/stunnel/libstunnel.so $(IDIR_STUNNEL)/usr/lib/
	$(CP) ./files/stunnel.conf $(IDIR_STUNNEL)/etc/stunnel/stunnel.conf
	$(CP) ./files/stunnel.init $(IDIR_STUNNEL)/etc/init.d/S90stunnel
	$(RSTRIP) $(IDIR_STUNNEL)
	$(IPKG_BUILD) $(IDIR_STUNNEL) $(PACKAGE_DIR)
