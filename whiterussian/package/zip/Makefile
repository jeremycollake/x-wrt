#
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zip
SRC_VERSION:=232
PKG_VERSION:=2.32
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)$(SRC_VERSION).zip
PKG_SOURCE_URL:=@SF/infozip
PKG_MD5SUM:=da947ed356e5fdb30ff4bc3dc7698f33

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,ZIP,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,ZIP_TOOLS,$(PKG_NAME)-tools,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared: $(DL_DIR)/$(PKG_SOURCE)
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	(cd $(PKG_BUILD_DIR); unzip -qx $(DL_DIR)/$(PKG_SOURCE) )
	if [ -d ./patches ]; then \
		$(PATCH) $(PKG_BUILD_DIR) ./patches ; \
	fi
	touch $@

$(PKG_BUILD_DIR)/.configured:
	# prevent package from rebuilding
	find $(PKG_BUILD_DIR) | xargs touch
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) -f unix/Makefile generic \
		$(TARGET_CONFIGURE_OPTS) \
		prefix="$(PKG_INSTALL_DIR)/usr" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CF="$(TARGET_CFLAGS) -O -I$(STAGING_DIR)/usr/include -I. -DUNIX" \
		LD="$(TARGET_CC) -L$(STAGING_DIR)/usr/lib" \
		install
	touch $@

$(IPKG_ZIP):
	install -d -m0755 $(IDIR_ZIP)/usr/bin
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/zip $(IDIR_ZIP)/usr/bin/
	$(RSTRIP) $(IDIR_ZIP)
	$(IPKG_BUILD) $(IDIR_ZIP) $(PACKAGE_DIR)

$(IPKG_ZIP_TOOLS):
	install -d -m0755 $(IDIR_ZIP_TOOLS)/usr/bin
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/zipcloak $(IDIR_ZIP_TOOLS)/usr/bin/
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/zipnote $(IDIR_ZIP_TOOLS)/usr/bin/
	install -m0755 $(PKG_INSTALL_DIR)/usr/bin/zipsplit $(IDIR_ZIP_TOOLS)/usr/bin/
	$(RSTRIP) $(IDIR_ZIP_TOOLS)
	$(IPKG_BUILD) $(IDIR_ZIP_TOOLS) $(PACKAGE_DIR)
