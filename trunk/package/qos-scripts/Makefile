# $Id: Makefile 3198 2006-02-09 03:21:01Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME := qos_scripts
PKG_RELEASE := 1
PKG_VERSION := 0.9.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,QOS_SCRIPTS,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $@
	touch $@

$(PKG_BUILD_DIR)/.built:
	cp -a ./files/* $(PKG_BUILD_DIR)/qos_scripts/
	touch $@

$(IPKG_QOS_SCRIPTS): 
	install -d $(IDIR_QOS_SCRIPTS)/usr/lib
	install -d $(IDIR_QOS_SCRIPTS)/usr/bin	
	install -d $(IDIR_QOS_SCRIPTS)/etc/init.d
	install -d $(IDIR_QOS_SCRIPTS)/etc/hotplug.d
	install -d $(IDIR_QOS_SCRIPTS)/etc/config
	chmod -R 755 $(PKG_BUILD_DIR)/qos_scripts/
	cp -a $(PKG_BUILD_DIR)/qos_scripts/* $(IDIR_QOS_SCRIPTS)/
	$(IPKG_BUILD) $(IDIR_QOS_SCRIPTS) $(PACKAGE_DIR)

