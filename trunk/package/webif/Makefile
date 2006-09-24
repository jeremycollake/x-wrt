# $Id: Makefile 4284 2006-07-25 19:07:23Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=webif
PKG_VERSION:=0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

# for whiterussian only:
NVRAM_OPTS=-DNVRAM -lnvram -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,WEBIF,webif,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@
	
$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(TARGET_CC) $(TARGET_CFLAGS) $(NVRAM_OPTS) -o $(PKG_BUILD_DIR)/webif-page src/webif-page.c
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/bstrip src/bstrip.c
	$(STRIP) $(PKG_BUILD_DIR)/webif-page $(PKG_BUILD_DIR)/bstrip
	touch $@

$(IPKG_WEBIF): 
	chmod -R 755 ./files/*
	cp -a ./files/* $(IDIR_WEBIF)/
	sh ./embed_rev.sh $(IDIR_WEBIF)/www/.version $(IDIR_WEBIF)/www/cgi-bin/webif/* $(IDIR_WEBIF)/usr/lib/webif/webif.sh
	install -d $(IDIR_WEBIF)/usr/bin
	install -m0755 $(PKG_BUILD_DIR)/webif-page $(IDIR_WEBIF)/usr/bin/webif-page
	install -m0755 $(PKG_BUILD_DIR)/bstrip $(IDIR_WEBIF)/usr/bin/bstrip
	ln -sf /www/index.html $(IDIR_WEBIF)/www/index.asp
	find $(IDIR_WEBIF) -name CVS | xargs rm -rf
	find $(IDIR_WEBIF) -name .svn | xargs rm -rf
	$(IPKG_BUILD) $(IDIR_WEBIF) $(PACKAGE_DIR)
