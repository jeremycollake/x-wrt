# 
# Copyright (C) 2008 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pppoesk
PKG_VERSION:=1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.loicp.eu/pppoesk
PKG_MD5SUM:=c9f3f5af3d916debdc7d5930b339618d
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

PPPOESK_LIBS:=-lpcap -lnet

PPPOESK_STATIC_LIBS:=-static -lpcap -lnet

define PKG_build

ifneq ($(BR2_PACKAGE_$(1)),)
BUILD_TARGETS += $(PKG_BUILD_DIR)/$(2)
endif

$(PKG_BUILD_DIR)/$(2): $(PKG_BUILD_DIR)/.prepared
	mkdir -p $(PKG_BUILD_DIR)/$(2)
	(cd $(PKG_BUILD_DIR)/$(2); rm -rf config.{cache,status} ; \
		touch ../configure.ac \
			../aclocal.m4 \
			../config.h.in \
			../Makefile.in \
			../Makefile.am \
			../configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/lib/libnet-1.1.x/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/usr/lib/libnet-1.1.x/lib" \
		ac_cv_c_bigendian=no \
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
	);
	$(MAKE) -C $(PKG_BUILD_DIR)/$(2) \
		$(TARGET_CONFIGURE_OPTS) \
		LIBS="$$($(1)_LIBS)" \
		DESTDIR="$(PKG_INSTALL_DIR)/$(1)" \
		all install

$$(IPKG_$(1)): $(PKG_BUILD_DIR)/.installed $(PKG_BUILD_DIR)/$(2)
	install -d -m0755 $$(IDIR_$(1))/usr/bin
	install -m0755 $(PKG_INSTALL_DIR)/$(1)/usr/bin/pppoesk $$(IDIR_$(1))/usr/bin/
	$(RSTRIP) $$(IDIR_$(1))
	$(IPKG_BUILD) $$(IDIR_$(1)) $(PACKAGE_DIR)

endef

$(eval $(call PKG_template,PPPOESK,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,PPPOESK_STATIC,$(PKG_NAME)-static,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(eval $(call PKG_build,PPPOESK,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_build,PPPOESK_STATIC,$(PKG_NAME)-static,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built: $(BUILD_TARGETS)
	touch $@

$(PKG_BUILD_DIR)/.installed: $(PKG_BUILD_DIR)/.built
	touch $@
