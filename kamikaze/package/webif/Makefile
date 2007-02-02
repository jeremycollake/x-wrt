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
  SUBMENU:=webif
  DEPENDS:=+haserl
  TITLE:=An HTTP administrative console for OpenWrt.
  DESCRIPTION:=\
	This package contains Webif^2, a web based administration console for OpenWrt.
  VERSION:=$(LINUX_VERSION) $(PKG_VERSION)-$(PKG_RELEASE)
endef

define Package/webif-lang-ca
$(call Package/webif)
  TITLE:=Catalan language file for webif.
endef

define Package/webif-lang-cz
$(call Package/webif)
  TITLE:=Czech language file for webif.
endef

define Package/webif-lang-de
$(call Package/webif)
  TITLE:=German language file for webif.
endef

define Package/webif-lang-dk
$(call Package/webif)
  TITLE:=Danish language file for webif.
endef

define Package/webif-lang-ee
$(call Package/webif)
  TITLE:=Estonian language file for webif.
endef

define Package/webif-lang-es
$(call Package/webif)
  TITLE:=Spanish language file for webif.
endef

define Package/webif-lang-fr
$(call Package/webif)
  TITLE:=French language file for webif.
endef

define Package/webif-lang-hr
$(call Package/webif)
  TITLE:=Croatian language file for webif.
endef

define Package/webif-lang-hu
$(call Package/webif)
  TITLE:=Hungarian language file for webif.
endef

define Package/webif-lang-it
$(call Package/webif)
  TITLE:=wItalian language file for webif.
endef

define Package/webif-lang-nl
$(call Package/webif)
  TITLE:=Dutch language file for webif.
endef

define Package/webif-lang-no
$(call Package/webif)
  TITLE:=Norwegian language file for webif.
endef

define Package/webif-lang-pl
$(call Package/webif)
  TITLE:=Polish language file for webif.
endef

define Package/webif-lang-pt
$(call Package/webif)
  TITLE:=Portuguese language file for webif.
endef

define Package/webif-lang-ru
$(call Package/webif)
  TITLE:=Russian language file for webif.
endef

define Package/webif-lang-se
$(call Package/webif)
  TITLE:=Swedish language file for webif.
endef

define Package/webif-theme-zephyr
$(call Package/webif)
  TITLE:=Zephyr theme for webif^2.
endef

define Package/webif-theme-xwrt
$(call Package/webif)
  TITLE:=Original theme for webif^2.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) \
		-D_METAPACK \
		-I$(STAGING_DIR)/include-host -include endian.h \
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
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -rf $(1)/www/themes/zephyr/
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

define Package/webif-lang-ca/install
	mkdir -p $(1)/usr/lib/webif/lang/ca/
	$(CP) -a ./files/usr/lib/webif/lang/ca/common.txt $(1)/usr/lib/webif/lang/ca/common.txt
endef

define Package/webif-lang-cz/install
	mkdir -p $(1)/usr/lib/webif/lang/cz/
	$(CP) -a ./files/usr/lib/webif/lang/cz/common.txt $(1)/usr/lib/webif/lang/cz/common.txt
endef

define Package/webif-lang-de/install
	mkdir -p $(1)/usr/lib/webif/lang/de/
	$(CP) -a ./files/usr/lib/webif/lang/de/common.txt $(1)/usr/lib/webif/lang/de/common.txt
endef

define Package/webif-lang-dk/install
	mkdir -p $(1)/usr/lib/webif/lang/dk/
	$(CP) -a ./files/usr/lib/webif/lang/dk/common.txt $(1)/usr/lib/webif/lang/dk/common.txt
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

define Package/webif-lang-se/install
	mkdir -p $(1)/usr/lib/webif/lang/se/
	$(CP) -a ./files/usr/lib/webif/lang/se/common.txt $(1)/usr/lib/webif/lang/se/common.txt
endef

define Package/webif-theme-zephyr/install
	mkdir -p $(1)/www/themes/zephyr/
	$(CP) -a ./files/www/themes/zephyr/* $(1)/www/themes/zephyr/
endef

define Package/webif-theme-xwrt/install
	mkdir -p $(1)/www/themes/xwrt/
	$(CP) -a ./files/www/themes/xwrt/* $(1)/www/themes/xwrt/
endef


$(eval $(call BuildPackage,webif))
$(eval $(call BuildPackage,webif-lang-ca))
$(eval $(call BuildPackage,webif-lang-cz))
$(eval $(call BuildPackage,webif-lang-de))
$(eval $(call BuildPackage,webif-lang-dk))
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
$(eval $(call BuildPackage,webif-lang-se))
$(eval $(call BuildPackage,webif-theme-zephyr))
$(eval $(call BuildPackage,webif-theme-xwrt))
