# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=hswebif
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

define PKG_mod_template

$$(IPKG_$(1)):
	[ -z "$(2)" ] || install -d -m0755 $$(IDIR_$(1))/usr/lib/hswebif/lang/$(2)
	$(CP) ./files/usr/lib/hswebif/lang/$(2)/common.txt $$(IDIR_$(1))/usr/lib/hswebif/lang/$(2)/
	$(RSTRIP) $$(IDIR_$(1))
	$(IPKG_BUILD) $$(IDIR_$(1)) $(PACKAGE_DIR)

endef

$(eval $(call PKG_template,HSWEBIF,hswebif,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@
	
$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	touch $@

$(IPKG_HSWEBIF): 
	$(CP) -a ./files/* $(IDIR_HSWEBIF)/
	chmod -R 755 $(IDIR_HSWEBIF)/*
	rm -f $(IDIR_HSWEBIF)/www/cgi-bin/hswebif/*.wip
	find $(IDIR_HSWEBIF) -name CVS | xargs rm -rf
	find $(IDIR_HSWEBIF) -name .svn | xargs rm -rf
	$(IPKG_BUILD) $(IDIR_HSWEBIF) $(PACKAGE_DIR)
