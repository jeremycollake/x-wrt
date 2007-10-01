include $(TOPDIR)/rules.mk

PKG_NAME:=webif
PKG_VERSION:=0.3
PKG_RELEASE:=7

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/webif
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+haserl
  TITLE:=An HTTP administrative console for OpenWrt.
  DESCRIPTION:=\
	This package contains Webif^2, a web based administration console for OpenWrt.
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
endef

define Package/webif-lang
$(call Package/webif)
  PKGARCH:=all
endef

define Package/webif-lang-ca
$(call Package/webif-lang)
  TITLE:=Catalan language file for webif.
endef

define Package/webif-lang-cs
$(call Package/webif-lang)
  TITLE:=Czech language file for webif.
endef

define Package/webif-lang-da
$(call Package/webif-lang)
  TITLE:=Danish language file for webif.
endef

define Package/webif-lang-de
$(call Package/webif-lang)
  TITLE:=German language file for webif.
endef

define Package/webif-lang-ee
$(call Package/webif-lang)
  TITLE:=Estonian language file for webif.
endef

define Package/webif-lang-es
$(call Package/webif-lang)
  TITLE:=Spanish language file for webif.
endef

define Package/webif-lang-fr
$(call Package/webif-lang)
  TITLE:=French language file for webif.
endef

define Package/webif-lang-hr
$(call Package/webif-lang)
  TITLE:=Croatian language file for webif.
endef

define Package/webif-lang-hu
$(call Package/webif-lang)
  TITLE:=Hungarian language file for webif.
endef

define Package/webif-lang-it
$(call Package/webif-lang)
  TITLE:=wItalian language file for webif.
endef

define Package/webif-lang-nl
$(call Package/webif-lang)
  TITLE:=Dutch language file for webif.
endef

define Package/webif-lang-no
$(call Package/webif-lang)
  TITLE:=Norwegian language file for webif.
endef

define Package/webif-lang-pl
$(call Package/webif-lang)
  TITLE:=Polish language file for webif.
endef

define Package/webif-lang-pt
$(call Package/webif-lang)
  TITLE:=Portuguese language file for webif.
endef

define Package/webif-lang-ru
$(call Package/webif-lang)
  TITLE:=Russian language file for webif.
endef

define Package/webif-lang-sq
$(call Package/webif-lang)
  TITLE:=Albanian language file for webif.
endef

define Package/webif-lang-sv
$(call Package/webif-lang)
  TITLE:=Swedish language file for webif.
endef

define Package/webif-lang-uk
$(call Package/webif-lang)
  TITLE:=Ukrainian language file for webif.
endef

define Package/webif-lang-zh
$(call Package/webif-lang)
  TITLE:=Chinese language file for webif.
endef

define Package/webif-theme-zephyr
$(call Package/webif-lang)
  TITLE:=Zephyr theme for webif^2.
endef

define Package/webif-theme-xwrt
$(call Package/webif-lang)
  TITLE:=Original theme for webif^2.
endef

define Package/webif-theme-xwrt-mini
$(call Package/webif-lang)
  TITLE:=Variant of the original theme (has blank header).
endef

define Package/webif-theme-sedky1
$(call Package/webif-lang)
  TITLE:=Sedky theme for webif^2
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) \
		-D_METAPACK \
		-I$(STAGING_DIR)/include-host -I$(STAGING_DIR_HOST)/include -include endian.h \
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
	$(CP) -a ./ipkg/webif.preinst $(1)/CONTROL/preinst
	$(CP) -a ./ipkg/webif.postinst $(1)/CONTROL/postinst
	$(SED) 's,$$$$S,$(BOARD)-$(KERNEL),g' $(1)/CONTROL/postinst
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -rf $(1)/www/themes/zephyr/
	rm -rf $(1)/www/themes/xwrt-mini/
	rm -rf $(1)/www/themes/sedky1/
	rm -f $(1)/www/cgi-bin/webif/*.wip
	if [ "$(OPENWRTVERSION)" != "7.06 (Kamikaze)" ]; then \
		rm -f $(1)/usr/lib/webif/fixed-functions.sh; \
	fi
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

define Package/webif-lang-ca/install
	mkdir -p $(1)/usr/lib/webif/lang/ca/
	$(CP) -a ./files/usr/lib/webif/lang/ca/common.txt $(1)/usr/lib/webif/lang/ca/common.txt
endef

define Package/webif-lang-cs/install
	mkdir -p $(1)/usr/lib/webif/lang/cs/
	$(CP) -a ./files/usr/lib/webif/lang/cs/common.txt $(1)/usr/lib/webif/lang/cs/common.txt
endef

define Package/webif-lang-da/install
	mkdir -p $(1)/usr/lib/webif/lang/da/
	$(CP) -a ./files/usr/lib/webif/lang/da/common.txt $(1)/usr/lib/webif/lang/da/common.txt
endef

define Package/webif-lang-de/install
	mkdir -p $(1)/usr/lib/webif/lang/de/
	$(CP) -a ./files/usr/lib/webif/lang/de/common.txt $(1)/usr/lib/webif/lang/de/common.txt
endef

define Package/webif-lang-ee/install
	mkdir -p $(1)/usr/lib/webif/lang/ee/
	$(CP) -a ./files/usr/lib/webif/lang/ee/common.txt $(1)/usr/lib/webif/lang/ee/common.txt
endef

define Package/webif-lang-es/install
	mkdir -p $(1)/usr/lib/webif/lang/es/
	$(CP) -a ./files/usr/lib/webif/lang/es/common.txt $(1)/usr/lib/webif/lang/es/common.txt
endef

define Package/webif-lang-fr/install
	mkdir -p $(1)/usr/lib/webif/lang/fr/
	$(CP) -a ./files/usr/lib/webif/lang/fr/common.txt $(1)/usr/lib/webif/lang/fr/common.txt
endef

define Package/webif-lang-hr/install
	mkdir -p $(1)/usr/lib/webif/lang/hr/
	$(CP) -a ./files/usr/lib/webif/lang/hr/common.txt $(1)/usr/lib/webif/lang/hr/common.txt
endef

define Package/webif-lang-hu/install
	mkdir -p $(1)/usr/lib/webif/lang/hu/
	$(CP) -a ./files/usr/lib/webif/lang/hu/common.txt $(1)/usr/lib/webif/lang/hu/common.txt
endef

define Package/webif-lang-it/install
	mkdir -p $(1)/usr/lib/webif/lang/it/
	$(CP) -a ./files/usr/lib/webif/lang/it/common.txt $(1)/usr/lib/webif/lang/it/common.txt
endef

define Package/webif-lang-nl/install
	mkdir -p $(1)/usr/lib/webif/lang/nl/
	$(CP) -a ./files/usr/lib/webif/lang/nl/common.txt $(1)/usr/lib/webif/lang/nl/common.txt
endef

define Package/webif-lang-no/install
	mkdir -p $(1)/usr/lib/webif/lang/no/
	$(CP) -a ./files/usr/lib/webif/lang/no/common.txt $(1)/usr/lib/webif/lang/no/common.txt
endef

define Package/webif-lang-pl/install
	mkdir -p $(1)/usr/lib/webif/lang/pl/
	$(CP) -a ./files/usr/lib/webif/lang/pl/common.txt $(1)/usr/lib/webif/lang/pl/common.txt
endef

define Package/webif-lang-pt/install
	mkdir -p $(1)/usr/lib/webif/lang/pt/
	$(CP) -a ./files/usr/lib/webif/lang/pt/common.txt $(1)/usr/lib/webif/lang/pt/common.txt
endef

define Package/webif-lang-ru/install
	mkdir -p $(1)/usr/lib/webif/lang/ru/
	$(CP) -a ./files/usr/lib/webif/lang/ru/common.txt $(1)/usr/lib/webif/lang/ru/common.txt
endef

define Package/webif-lang-sq/install
	mkdir -p $(1)/usr/lib/webif/lang/sq/
	$(CP) -a ./files/usr/lib/webif/lang/sq/common.txt $(1)/usr/lib/webif/lang/sq/common.txt
endef

define Package/webif-lang-sv/install
	mkdir -p $(1)/usr/lib/webif/lang/sv/
	$(CP) -a ./files/usr/lib/webif/lang/sv/common.txt $(1)/usr/lib/webif/lang/sv/common.txt
endef

define Package/webif-lang-uk/install
	mkdir -p $(1)/usr/lib/webif/lang/uk/
	$(CP) -a ./files/usr/lib/webif/lang/uk/common.txt $(1)/usr/lib/webif/lang/uk/common.txt
endef

define Package/webif-lang-zh/install
	mkdir -p $(1)/usr/lib/webif/lang/zh/
	$(CP) -a ./files/usr/lib/webif/lang/zh/common.txt $(1)/usr/lib/webif/lang/zh/common.txt
endef

define Package/webif-theme-zephyr/install
	mkdir -p $(1)/www/themes/zephyr/
	$(CP) -a ./files/www/themes/zephyr/* $(1)/www/themes/zephyr/
endef

define Package/webif-theme-xwrt/install
	mkdir -p $(1)/www/themes/xwrt/
	$(CP) -a ./files/www/themes/xwrt/* $(1)/www/themes/xwrt/
endef

define Package/webif-theme-xwrt-mini/install
	mkdir -p $(1)/www/themes/xwrt-mini/
	$(CP) -a ./files/www/themes/xwrt-mini/* $(1)/www/themes/xwrt-mini/
endef

define Package/webif-theme-sedky1/install
	mkdir -p $(1)/www/themes/sedky1/
	$(CP) -a ./files/www/themes/sedky1/* $(1)/www/themes/sedky1/
endef


$(eval $(call BuildPackage,webif))
$(eval $(call BuildPackage,webif-lang-ca))
$(eval $(call BuildPackage,webif-lang-cs))
$(eval $(call BuildPackage,webif-lang-da))
$(eval $(call BuildPackage,webif-lang-de))
$(eval $(call BuildPackage,webif-lang-ee))
$(eval $(call BuildPackage,webif-lang-es))
$(eval $(call BuildPackage,webif-lang-fr))
$(eval $(call BuildPackage,webif-lang-hr))
$(eval $(call BuildPackage,webif-lang-hu))
$(eval $(call BuildPackage,webif-lang-it))
$(eval $(call BuildPackage,webif-lang-nl))
$(eval $(call BuildPackage,webif-lang-no))
$(eval $(call BuildPackage,webif-lang-pl))
$(eval $(call BuildPackage,webif-lang-pt))
$(eval $(call BuildPackage,webif-lang-ru))
$(eval $(call BuildPackage,webif-lang-sq))
$(eval $(call BuildPackage,webif-lang-sv))
$(eval $(call BuildPackage,webif-lang-uk))
$(eval $(call BuildPackage,webif-lang-zh))
$(eval $(call BuildPackage,webif-theme-zephyr))
$(eval $(call BuildPackage,webif-theme-xwrt))
$(eval $(call BuildPackage,webif-theme-xwrt-mini))
$(eval $(call BuildPackage,webif-theme-sedky1))
