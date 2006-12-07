# $Id: Makefile 1407 2005-07-11 19:04:50Z nico $

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=20061130
PKG_RELEASE:=2
PKG_MD5SUM:=0d295d2edb725ca495767eb3ffa3de1d

PKG_SOURCE_URL:=http://miniupnp.tuxfamily.org/files/
PKG_SOURCE:=$(PKG_NAME)$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_CAT:=zcat

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,MINIUPNPD,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	make -C $(PKG_BUILD_DIR) -f Makefile.openwrt	
	touch $@

$(IPKG_MINIUPNPD):
	mkdir -p $(IDIR_MINIUPNPD)/usr/bin
	install -m 755 $(PKG_BUILD_DIR)/miniupnpd $(IDIR_MINIUPNPD)/usr/bin/
	install -m 755 $(PKG_BUILD_DIR)/linux/*.sh $(IDIR_MINIUPNPD)/usr/bin/
	$(CP) -a ./files/* $(IDIR_MINIUPNPD)/
	find $(IDIR_MINIUPNPD) -name CVS | xargs rm -rf
	find $(IDIR_MINIUPNPD) -name .svn | xargs rm -rf
	$(STRIP) $(IDIR_MINIUPNPD)/usr/bin/miniupnpd
	$(IPKG_BUILD) $(IDIR_MINIUPNPD) $(PACKAGE_DIR)

