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

SOCAT_CONFIGURE_OPTS:=--enable-openssl

SOCAT_NOSSL_CONFIGURE_OPTS:=--disable-openssl

define PKG_build

ifneq ($(BR2_PACKAGE_$(1)),)
BUILD_TARGETS += $(PKG_BUILD_DIR)/$(2)
endif

$(PKG_BUILD_DIR)/$(2): $(PKG_BUILD_DIR)/.prepared
	mkdir -p $(PKG_BUILD_DIR)/$(2)
	(cd $(PKG_BUILD_DIR)/$(2); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib" \
		sc_cv_sys_crdly_shift=9 \
		sc_cv_sys_tabdly_shift=11 \
		sc_cv_sys_csize_shift=4 \
		sc_cv_termios_ispeed=no \
		ac_cv_have_z_modifier=no \
		../configure \
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
		  --disable-rpath \
		  --disable-libwrap \
		  --disable-readline \
		  --disable-termios \
		  $$($(1)_CONFIGURE_OPTS) \
	);
	-rm -rf $(PKG_INSTALL_DIR)/$(1)
	$(MAKE) -C $(PKG_BUILD_DIR)/$(2) all
	mkdir -p $(PKG_INSTALL_DIR)/$(1)
	$(CP) $(PKG_BUILD_DIR)/$(2)/socat \
		$(PKG_BUILD_DIR)/$(2)/filan \
		$(PKG_BUILD_DIR)/$(2)/procan \
		$(PKG_INSTALL_DIR)/$(1)

$$(IPKG_$(1)): $(PKG_BUILD_DIR)/.installed $(PKG_BUILD_DIR)/$(2)
	install -m0755 -d $$(IDIR_$(1))/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/$(1)/socat $$(IDIR_$(1))/usr/bin/
	$(RSTRIP) $$(IDIR_$(1))
	$(IPKG_BUILD) $$(IDIR_$(1)) $(PACKAGE_DIR)

$$(IPKG_$(1)_TOOLS): $(PKG_BUILD_DIR)/.installed $(PKG_BUILD_DIR)/$(2)
	install -m0755 -d $$(IDIR_$(1)_TOOLS)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/$(1)/filan $$(IDIR_$(1)_TOOLS)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/$(1)/procan $$(IDIR_$(1)_TOOLS)/usr/bin/
	$(RSTRIP) $$(IDIR_$(1)_TOOLS)
	$(IPKG_BUILD) $$(IDIR_$(1)_TOOLS) $(PACKAGE_DIR)

endef

$(eval $(call PKG_template,SOCAT,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,SOCAT_TOOLS,$(PKG_NAME)-tools,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,SOCAT_NOSSL,$(PKG_NAME)-nossl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,SOCAT_NOSSL_TOOLS,$(PKG_NAME)-nossl-tools,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(eval $(call PKG_build,SOCAT,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_build,SOCAT_NOSSL,$(PKG_NAME)-nossl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built: $(BUILD_TARGETS)
	touch $@

$(PKG_BUILD_DIR)/.installed: $(PKG_BUILD_DIR)/.built
	touch $@

