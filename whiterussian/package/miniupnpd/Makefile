# 
# Copyright (C) 2008 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://miniupnp.tuxfamily.org/files/
PKG_MD5SUM:=9d500aa930e31fd49250c143df0abb4c
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,MINIUPNPD,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	$(CP) -a ./src/* $(PKG_BUILD_DIR)/
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	$(MAKE) -C $(PKG_BUILD_DIR) \
		-f Makefile.linux \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		LIBS="$(STAGING_DIR)/usr/lib/libiptc.a"
	touch $@

$(IPKG_MINIUPNPD): $(PKG_BUILD_DIR)/.built
	mkdir -p $(IDIR_MINIUPNPD)/usr/sbin
	install -m 755 $(PKG_BUILD_DIR)/miniupnpd $(IDIR_MINIUPNPD)/usr/sbin/
	install -m 755 $(PKG_BUILD_DIR)/miniupnpdctl $(IDIR_MINIUPNPD)/usr/sbin/
	install -m 755 $(PKG_BUILD_DIR)/netfilter/*.sh $(IDIR_MINIUPNPD)/usr/sbin/
	$(CP) -a ./files/* $(IDIR_MINIUPNPD)/
	find $(IDIR_MINIUPNPD) -name CVS | xargs rm -rf
	find $(IDIR_MINIUPNPD) -name .svn | xargs rm -rf
	$(RSTRIP) $(IDIR_MINIUPNPD)
	$(IPKG_BUILD) $(IDIR_MINIUPNPD) $(PACKAGE_DIR)
