# 
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=spcaview
PKG_VERSION:=20071224
PKG_RELEASE:=1


PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://mxhaard.free.fr/spca50x/Download \
		http://mxhaard.free.fr/spca50x/Download/oldrelease
PKG_MD5SUM:=12e46424844b937dd55eab28f74bcd8d
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,SPCACAT,spcacat,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,SPCASERV,spcaserv,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		BIN="usr/bin" \
		SERVFLAGS="$(TARGET_CFLAGS) -DLINUX -I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include" \
		SERVLIBS="-lm -lpthread -L$(STAGING_DIR)/lib -I$(STAGING_DIR)/usr/lib" \
		spcaserv spcacat
	touch $@

$(IPKG_SPCACAT):
	install -d -m0755 $(IDIR_SPCACAT)/etc/config
	install -m0755 ./files/spcacat.config $(IDIR_SPCACAT)/etc/config/spcacat
	install -d -m0755 $(IDIR_SPCACAT)/etc/init.d
	install -m0755 ./files/spcacat.init $(IDIR_SPCACAT)/etc/init.d/spcacat
	install -d -m0755 $(IDIR_SPCACAT)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/spcacat $(IDIR_SPCACAT)/usr/bin
	$(RSTRIP) $(IDIR_SPCACAT)
	$(IPKG_BUILD) $(IDIR_SPCACAT) $(PACKAGE_DIR)

$(IPKG_SPCASERV):
	install -d -m0755 $(IDIR_SPCASERV)/etc/config
	install -m0755 ./files/spcaserv.config $(IDIR_SPCASERV)/etc/config/spcaserv
	install -d -m0755 $(IDIR_SPCASERV)/etc/init.d
	install -m0755 ./files/spcaserv.init $(IDIR_SPCASERV)/etc/init.d/spcaserv
	install -d -m0755 $(IDIR_SPCASERV)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/spcaserv $(IDIR_SPCASERV)/usr/bin
	$(RSTRIP) $(IDIR_SPCASERV)
	$(IPKG_BUILD) $(IDIR_SPCASERV) $(PACKAGE_DIR)

