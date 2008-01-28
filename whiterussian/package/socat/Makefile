# Copyright (C) 2008 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=socat
PKG_VERSION:=1.6.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.dest-unreach.org/socat/download
PKG_MD5SUM:=810135eb1c3e892b1577735b7deca8ef
PKG_CAT:=bzcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,SOCAT,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,SOCAT_TOOLS,$(PKG_NAME)-tools,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib" \
		sc_cv_sys_crdly_shift=9 \
		sc_cv_sys_tabdly_shift=11 \
		sc_cv_sys_csize_shift=4 \
		sc_cv_termios_ispeed=no \
		ac_cv_have_z_modifier=no \
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
		  --disable-libwrap \
		  --disable-readline \
		  --disable-termios \
		  --disable-openssl \
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

$(IPKG_SOCAT):
	install -m0755 -d $(IDIR_SOCAT)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/socat $(IDIR_SOCAT)/usr/bin/
	$(RSTRIP) $(IDIR_SOCAT)
	$(IPKG_BUILD) $(IDIR_SOCAT) $(PACKAGE_DIR)

$(IPKG_SOCAT_TOOLS):
	install -m0755 -d $(IDIR_SOCAT_TOOLS)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/filan $(IDIR_SOCAT_TOOLS)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/procan $(IDIR_SOCAT_TOOLS)/usr/bin/
	$(RSTRIP) $(IDIR_SOCAT_TOOLS)
	$(IPKG_BUILD) $(IDIR_SOCAT_TOOLS) $(PACKAGE_DIR)
