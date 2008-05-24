# $Id: Makefile 4284 2006-07-25 19:07:23Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=webif-freeloader
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

define Package/webif-freeloader
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+webif
  TITLE:=An download manager for the webif
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
endef

define Package/webif-lang-freeloader
$(call Package/webif-freeloader)
  PKGARCH:=all
endef

define Package/webif-freeloader-lang-ca
$(call Package/webif-lang-freeloader)
  TITLE:=Catalan language file for webif-freeloader.
endef

define Package/webif-freeloader/install 
	$(CP) -a ./files/* $(1)/
	$(CP) -a ./ipkg/webif-freeloader.preinst $(1)/CONTROL/preinst
	$(CP) -a ./ipkg/webif-freeloader.postinst $(1)/CONTROL/postinst
	$(CP) -a ./ipkg/webif-freeloader.postrm $(1)/CONTROL/postrm
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip
	chmod 755 $(1)/CONTROL/*inst
	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
	find $(1) -name *~ | xargs rm -rf
	$(IPKG_BUILD) $(IDIR_WEBIF_FREELOADER) $(PACKAGE_DIR)
endef

$(eval $(call BuildPackage,webif-freeloader))
$(eval $(call BuildPackage,webif-freeloader-lang-ca))