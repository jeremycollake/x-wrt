# $Id: Makefile 4284 2006-07-25 19:07:23Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=webif_freeloader
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


$(eval $(call PKG_template,WEBIF_FREELOADER,webif-freeloader,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_CA,webif-freeloader-lang-ca,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_CS,webif-freeloader-lang-cs,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_DA,webif-freeloader-lang-da,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_DE,webif-freeloader-lang-de,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_EE,webif-freeloader-lang-ee,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_ES,webif-freeloader-lang-es,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_FR,webif-freeloader-lang-fr,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_HE,webif-freeloader-lang-he,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_HR,webif-freeloader-lang-hr,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_HU,webif-freeloader-lang-hu,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_IT,webif-freeloader-lang-it,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_NL,webif-freeloader-lang-nl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_NO,webif-freeloader-lang-no,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_PL,webif-freeloader-lang-pl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_PT,webif-freeloader-lang-pt,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_RU,webif-freeloader-lang-ru,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_SQ,webif-freeloader-lang-sq,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_SV,webif-freeloader-lang-sv,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_UK,webif-freeloader-lang-uk,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
#$(eval $(call PKG_template,WEBIF_FREELOADER_LANG_ZH,webif-freeloader-lang-zh,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_CA,ca))
$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_CS,cs))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_DA,da))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_DE,de))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_EE,ee))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_ES,es))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_FR,fr))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_HE,he))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_HR,hr))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_HU,hu))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_IT,it))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_NL,nl))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_NO,no))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_PL,pl))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_PT,pt))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_RU,ru))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_SQ,sq))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_SV,sv))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_UK,uk))
#$(eval $(call PKG_mod_template,WEBIF_FREELOADER_LANG_ZH,zh))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@
	
$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	touch $@

$(IPKG_WEBIF_FREELOADER): 
	$(CP) -a ./files/* $(IDIR_WEBIF_FREELOADER)/
	chmod -R 755 $(IDIR_WEBIF_FREELOADER)/*
	rm -rf $(IDIR_WEBIF_FREELOADER)/usr/lib/webif/lang/
	rm -f $(IDIR_WEBIF_FREELOADER)/www/cgi-bin/webif/*.wip
	chmod 755 $(IDIR_WEBIF_FREELOADER)/CONTROL/*inst
	find $(IDIR_WEBIF_FREELOADER) -name CVS | xargs rm -rf
	find $(IDIR_WEBIF_FREELOADER) -name .svn | xargs rm -rf
	find $(IDIR_WEBIF_FREELOADER) -name *~ | xargs rm -rf
	$(IPKG_BUILD) $(IDIR_WEBIF_FREELOADER) $(PACKAGE_DIR)
