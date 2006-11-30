# $Id: Makefile 1407 2005-07-11 19:04:50Z nico $

include $(TOPDIR)/rules.mk

PKG_NAME:=nas
PKG_VERSION:=3.90.37
PKG_RELEASE:=17
PKG_MD5SUM:=1826c480e61e0573dfa1d835ee9d8802

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,NAS,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	touch $@

$(IPKG_NAS):
	mkdir -p $(IDIR_NAS)/usr/bin
	$(CP) -a ./files/* $(IDIR_NAS)/
	find $(IDIR_NAS) -name CVS | xargs rm -rf
	find $(IDIR_NAS) -name .svn | xargs rm -rf
	$(STRIP) $(IDIR_NAS)/usr/sbin/nas
	$(IPKG_BUILD) $(IDIR_NAS) $(PACKAGE_DIR)

