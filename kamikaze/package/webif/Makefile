include $(TOPDIR)/rules.mk

PKG_NAME:=webif
PKG_VERSION:=0.3
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk


define Package/webif
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Webif
  TITLE:=Webif
  DESCRIPTION:=\
	This package contains Webif^2
  VERSION:=$(LINUX_VERSION)+$(PKG_VERSION)-$(PKG_RELEASE)
endef

define Package/WEBIF_LANG_CA
$(call Package/webif)
  TITLE:=WEBIF_LANG_CA
endef

define Package/WEBIF_LANG_CZ
$(call Package/webif)
  TITLE:=WEBIF_LANG_CZ
endef

define Package/WEBIF_LANG_DE
$(call Package/webif)
  TITLE:=WEBIF_LANG_DE
endef

define Package/WEBIF_LANG_DK
$(call Package/webif)
  TITLE:=WEBIF_LANG_DK
endef

define Package/WEBIF_LANG_EE
$(call Package/webif)
  TITLE:=WEBIF_LANG_EE
endef

define Package/WEBIF_LANG_ES
$(call Package/webif)
  TITLE:=WEBIF_LANG_ES
endef

define Package/WEBIF_LANG_FR
$(call Package/webif)
  TITLE:=WEBIF_LANG_FR
endef

define Package/WEBIF_LANG_HR
$(call Package/webif)
  TITLE:=WEBIF_LANG_HR
endef

define Package/WEBIF_LANG_HU
$(call Package/webif)
  TITLE:=WEBIF_LANG_HU
endef

define Package/WEBIF_LANG_IT
$(call Package/webif)
  TITLE:=WEBIF_LANG_IT
endef

define Package/WEBIF_LANG_NL
$(call Package/webif)
  TITLE:=WEBIF_LANG_NL
endef

define Package/WEBIF_LANG_NO
$(call Package/webif)
  TITLE:=WEBIF_LANG_NO
endef

define Package/WEBIF_LANG_PL
$(call Package/webif)
  TITLE:=WEBIF_LANG_PL
endef

define Package/WEBIF_LANG_PT
$(call Package/webif)
  TITLE:=WEBIF_LANG_PT
endef

define Package/WEBIF_LANG_RU
$(call Package/webif)
  TITLE:=WEBIF_LANG_RU
endef

define Package/WEBIF_LANG_SE
$(call Package/webif)
  TITLE:=WEBIF_LANG_SE
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) \
		-D_METAPACK \
		$(TARGET_CFLAGS_EXTRA) \
		$(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/webifmetabin \
		src/int2human/main.c src/int2human/human_readable.c \
		src/wepkeygen/keygen.c src/wepkeygen/md5.c \
		src/webif-page.c src/bstrip.c src/webifmetabin.c
	$(STRIP) $(PKG_BUILD_DIR)/webifmetabin
endef

define Package/webif/install
	$(CP) -a ./files/* $(1)/
	$(CP) -a ./ipkg/*inst $(1)/CONTROL/
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip
	./embed_rev.sh $(1)/www/.version \
			$(1)/usr/lib/webif/webif.sh \
			$(1)/etc/init.d/* \
			$(1)/www/cgi-bin/webif/*
	chmod 777 $(1)/CONTROL/*inst
	./embed_rev.sh $(1)/CONTROL/*inst
	chmod 755 $(1)/CONTROL/*inst
	mkdir -p $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/webifmetabin $(1)/usr/bin/webifmetabin
	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
endef

define Package/WEBIF_LANG_CA/install
	mkdir -p $(1)/usr/lib/webif/lang/ca/
	$(CP) -a ./usr/lib/webif/lang/ca/common.txt $(1)//usr/lib/webif/lang/ca/common.txt
endef

define Package/WEBIF_LANG_CZ/install
	mkdir -p $(1)/usr/lib/webif/lang/cz/
	$(CP) -a ./usr/lib/webif/lang/cz/common.txt $(1)//usr/lib/webif/lang/cz/common.txt
endef

define Package/WEBIF_LANG_DE/install
	mkdir -p $(1)/usr/lib/webif/lang/de/
	$(CP) -a ./usr/lib/webif/lang/de/common.txt $(1)//usr/lib/webif/lang/de/common.txt
endef

define Package/WEBIF_LANG_DK/install
	mkdir -p $(1)/usr/lib/webif/lang/dk/
	$(CP) -a ./usr/lib/webif/lang/dk/common.txt $(1)//usr/lib/webif/lang/dk/common.txt
endef

define Package/WEBIF_LANG_EE/install
	mkdir -p $(1)/usr/lib/webif/lang/ee/
	$(CP) -a ./usr/lib/webif/lang/ee/common.txt $(1)//usr/lib/webif/lang/ee/common.txt
endef

define Package/WEBIF_LANG_ES/install
	mkdir -p $(1)/usr/lib/webif/lang/es/
	$(CP) -a ./usr/lib/webif/lang/es/common.txt $(1)//usr/lib/webif/lang/es/common.txt
endef

define Package/WEBIF_LANG_FR/install
	mkdir -p $(1)/usr/lib/webif/lang/fr/
	$(CP) -a ./usr/lib/webif/lang/fr/common.txt $(1)//usr/lib/webif/lang/fr/common.txt
endef

define Package/WEBIF_LANG_HR/install
	mkdir -p $(1)/usr/lib/webif/lang/hr/
	$(CP) -a ./usr/lib/webif/lang/hr/common.txt $(1)//usr/lib/webif/lang/hr/common.txt
endef

define Package/WEBIF_LANG_HU/install
	mkdir -p $(1)/usr/lib/webif/lang/hu/
	$(CP) -a ./usr/lib/webif/lang/hu/common.txt $(1)//usr/lib/webif/lang/hu/common.txt
endef

define Package/WEBIF_LANG_IT/install
	mkdir -p $(1)/usr/lib/webif/lang/it/
	$(CP) -a ./usr/lib/webif/lang/it/common.txt $(1)//usr/lib/webif/lang/it/common.txt
endef

define Package/WEBIF_LANG_NL/install
	mkdir -p $(1)/usr/lib/webif/lang/nl/
	$(CP) -a ./usr/lib/webif/lang/nl/common.txt $(1)//usr/lib/webif/lang/nl/common.txt
endef

define Package/WEBIF_LANG_NO/install
	mkdir -p $(1)/usr/lib/webif/lang/no/
	$(CP) -a ./usr/lib/webif/lang/no/common.txt $(1)//usr/lib/webif/lang/no/common.txt
endef

define Package/WEBIF_LANG_PL/install
	mkdir -p $(1)/usr/lib/webif/lang/pl/
	$(CP) -a ./usr/lib/webif/lang/pl/common.txt $(1)//usr/lib/webif/lang/pl/common.txt
endef

define Package/WEBIF_LANG_PT/install
	mkdir -p $(1)/usr/lib/webif/lang/pt/
	$(CP) -a ./usr/lib/webif/lang/pt/common.txt $(1)//usr/lib/webif/lang/pt/common.txt
endef

define Package/WEBIF_LANG_RU/install
	mkdir -p $(1)/usr/lib/webif/lang/ru/
	$(CP) -a ./usr/lib/webif/lang/ru/common.txt $(1)//usr/lib/webif/lang/ru/common.txt
endef

define Package/WEBIF_LANG_SE/install
	mkdir -p $(1)/usr/lib/webif/lang/se/
	$(CP) -a ./usr/lib/webif/lang/se/common.txt $(1)//usr/lib/webif/lang/se/common.txt
endef

$(eval $(call BuildPackage,webif))
$(eval $(call BuildPackage,WEBIF_LANG_CA))
$(eval $(call BuildPackage,WEBIF_LANG_CZ))
$(eval $(call BuildPackage,WEBIF_LANG_DE))
$(eval $(call BuildPackage,WEBIF_LANG_DK))
$(eval $(call BuildPackage,WEBIF_LANG_EE))
$(eval $(call BuildPackage,WEBIF_LANG_ES))
$(eval $(call BuildPackage,WEBIF_LANG_FR))
$(eval $(call BuildPackage,WEBIF_LANG_HR))
$(eval $(call BuildPackage,WEBIF_LANG_HU))
$(eval $(call BuildPackage,WEBIF_LANG_IT))
$(eval $(call BuildPackage,WEBIF_LANG_NL))
$(eval $(call BuildPackage,WEBIF_LANG_NO))
$(eval $(call BuildPackage,WEBIF_LANG_PL))
$(eval $(call BuildPackage,WEBIF_LANG_PT))
$(eval $(call BuildPackage,WEBIF_LANG_RU))
$(eval $(call BuildPackage,WEBIF_LANG_SE))
