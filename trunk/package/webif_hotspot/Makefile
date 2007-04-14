# $Id: Makefile 4284 2006-07-25 19:07:23Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=webif_hotspot
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

define PKG_mod_template

$$(IPKG_$(1)):
	[ -z "$(2)" ] || install -d -m0755 $$(IDIR_$(1))/usr/lib/webif/lang/$(2)
	$(CP) ./files/usr/lib/webif/lang/$(2)/*.txt $$(IDIR_$(1))/usr/lib/webif/lang/$(2)/
	rm -rf $$(IDIR_$(1))/usr/lib/webif/lang/template/
	$(RSTRIP) $$(IDIR_$(1))
	$(IPKG_BUILD) $$(IDIR_$(1)) $(PACKAGE_DIR)

endef


$(eval $(call PKG_template,WEBIF_HOTSPOT,webif-hotspot,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_CA,webif-hotspot-lang-ca,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_CS,webif-hotspot-lang-cs,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_DA,webif-hotspot-lang-da,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_DE,webif-hotspot-lang-de,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_EE,webif-hotspot-lang-ee,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_ES,webif-hotspot-lang-es,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_FR,webif-hotspot-lang-fr,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_HE,webif-hotspot-lang-he,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_HR,webif-hotspot-lang-hr,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_HU,webif-hotspot-lang-hu,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_IT,webif-hotspot-lang-it,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_NL,webif-hotspot-lang-nl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_NO,webif-hotspot-lang-no,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_PL,webif-hotspot-lang-pl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_PT,webif-hotspot-lang-pt,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_RU,webif-hotspot-lang-ru,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_SQ,webif-hotspot-lang-sq,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_SV,webif-hotspot-lang-sv,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_UK,webif-hotspot-lang-uk,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_HOTSPOT_LANG_ZH,webif-hotspot-lang-zh,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_CA,ca))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_CS,cs))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_DA,da))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_DE,de))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_EE,ee))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_ES,es))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_FR,fr))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_HE,he))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_HR,hr))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_HU,hu))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_IT,it))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_NL,nl))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_NO,no))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_PL,pl))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_PT,pt))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_RU,ru))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_SQ,sq))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_SV,sv))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_UK,uk))
#$(eval $(call PKG_mod_template,WEBIF_HOTSPOT_LANG_ZH,zh))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@
	
$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	touch $@

$(IPKG_WEBIF_HOTSPOT): 
	$(CP) -a ./files/* $(IDIR_WEBIF_HOTSPOT)/
	chmod -R 755 $(IDIR_WEBIF_HOTSPOT)/*
	rm -rf $(IDIR_WEBIF_HOTSPOT)/usr/
	rm -f $(IDIR_WEBIF_HOTSPOT)/www/cgi-bin/webif/*.wip
	chmod 755 $(IDIR_WEBIF_HOTSPOT)/CONTROL/*inst
	find $(IDIR_WEBIF_HOTSPOT) -name CVS | xargs rm -rf
	find $(IDIR_WEBIF_HOTSPOT) -name .svn | xargs rm -rf
	find $(IDIR_WEBIF_HOTSPOT) -name *~ | xargs rm -rf
	$(IPKG_BUILD) $(IDIR_WEBIF_HOTSPOT) $(PACKAGE_DIR)
