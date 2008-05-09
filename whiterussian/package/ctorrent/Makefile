# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ctorrent
PKG_VERSION:=dnh3.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/dtorrent \
	http://www.rahul.net/dholmes/ctorrent/
PKG_MD5SUM:=9bfe42c2dd6a6aabd545fe332bc23e87

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
PKG_CAT:=zcat

include $(TOPDIR)/package/rules.mk

CTORRENT_CONFIGURE_OPTS:=--with-ssl=no

CTORRENT_OPENSSL_CONFIGURE_OPTS:=--with-ssl="$(STAGING_DIR)/usr"

define PKG_build

ifneq ($(BR2_PACKAGE_$(1)),)
BUILD_TARGETS += $(PKG_BUILD_DIR)/$(2)
endif

$(PKG_BUILD_DIR)/$(2): $(PKG_BUILD_DIR)/.prepared
	-rm -rf $(PKG_BUILD_DIR)/$(2)
	mkdir -p $(PKG_BUILD_DIR)/$(2)
	(cd $(PKG_BUILD_DIR)/$(2); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		CXXFLAGS="$(TARGET_CFLAGS) -fno-builtin -fno-rtti -nostdinc++" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		LIBS="-nodefaultlibs -luClibc++ -lc -lgcc" \
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
		  --enable-shared \
		  --disable-static \
		  --disable-rpath \
		  $$($(1)_CONFIGURE_OPTS) \
	);
	-rm -rf $(PKG_INSTALL_DIR)/$(1)
	mkdir -p $(PKG_INSTALL_DIR)/$(1)
	$(MAKE) -C $(PKG_BUILD_DIR)/$(2) \
		$(TARGET_CONFIGURE_OPTS) \
		DESTDIR="$(PKG_INSTALL_DIR)/$(1)" \
		all install

$$(IPKG_$(1)): $(PKG_BUILD_DIR)/.installed $(PKG_BUILD_DIR)/$(2)
	install -d -m0755 $$(IDIR_$(1))/usr/bin
	install -m0755 $(PKG_INSTALL_DIR)/$(1)/usr/bin/ctorrent $$(IDIR_$(1))/usr/bin/
	$(RSTRIP) $$(IDIR_$(1))
	$(IPKG_BUILD) $$(IDIR_$(1)) $(PACKAGE_DIR)

endef


$(eval $(call PKG_template,CTORRENT,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,CTORRENT_OPENSSL,$(PKG_NAME)-openssl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(eval $(call PKG_build,CTORRENT,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_build,CTORRENT_OPENSSL,$(PKG_NAME)-openssl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built: $(BUILD_TARGETS)
	touch $@

$(PKG_BUILD_DIR)/.installed: $(PKG_BUILD_DIR)/.built
	touch $@
