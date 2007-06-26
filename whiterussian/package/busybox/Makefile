# $Id: Makefile 4885 2006-10-02 17:38:17Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=busybox
PKG_RELEASE:=1

ifeq ($(strip $(BR2_PACKAGE_BUSYBOX_SNAPSHOT)),y)
# Be aware that this changes daily....
PKG_VERSION:=0.${shell date +"%G%m%d"}
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-snapshot.tar.bz2
PKG_SOURCE_URL:=http://www.busybox.net/downloads/snapshots
PKG_MD5SUM:=x
else
PKG_VERSION:=1.4.2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.busybox.net/downloads
PKG_MD5SUM:=b4c61fb15642be9dde20e8493788c585
endif
PKG_CAT:=bzcat

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,BUSYBOX,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	$(SCRIPT_DIR)/gen_busybox_config.pl $(TOPDIR)/.config > $(PKG_BUILD_DIR)/.config
	yes '' | $(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(ARCH)" \
		oldconfig
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		PREFIX="$(IDIR_BUSYBOX)" \
		CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		ARCH="$(ARCH)" \
		IPKG_ARCH="$(ARCH)" \
		-C $(PKG_BUILD_DIR) \
		all
	touch $@

$(IPKG_BUSYBOX):
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		ARCH="$(ARCH)" \
		IPKG_ARCH="$(ARCH)" \
		CONFIG_PREFIX="$(IDIR_BUSYBOX)" \
 		-C $(PKG_BUILD_DIR) \
		install
	$(STRIP) $(IDIR_BUSYBOX)/bin/busybox
	$(IPKG_BUILD) $(IDIR_BUSYBOX) $(PACKAGE_DIR)
