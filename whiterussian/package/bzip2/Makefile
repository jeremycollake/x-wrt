#
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bzip2
PKG_VERSION:=1.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.bzip.org/$(PKG_VERSION)/
PKG_MD5SUM:=fc310b254f6ba5fbb5da018f04533688
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBBZIP2,lib$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,BZIP2,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,BZIP2RECOVER,$(PKG_NAME)recover,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		-f Makefile-libbz2_so \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64" \
		PREFIX="/usr"
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64" \
		PREFIX="$(PKG_INSTALL_DIR)/usr" \
		libbz2.a bzip2 bzip2recover
	touch $@

$(STAGING_DIR)/usr/lib/libbz2.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/bzlib.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libbz2.{a,so*} $(STAGING_DIR)/usr/lib/
	touch $@

$(IPKG_LIBBZIP2): $(STAGING_DIR)/usr/lib/libbz2.so
	install -m0755 -d $(IDIR_LIBBZIP2)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libbz2.so.* $(IDIR_LIBBZIP2)/usr/lib/
	$(RSTRIP) $(IDIR_LIBBZIP2)
	$(IPKG_BUILD) $(IDIR_LIBBZIP2) $(PACKAGE_DIR)

$(IPKG_BZIP2):
	install -m0755 -d $(IDIR_BZIP2)/usr/bin
	install -m0755  $(PKG_BUILD_DIR)/bzip2 $(IDIR_BZIP2)/usr/bin/
	ln -sf bzip2 $(IDIR_BZIP2)/usr/bin/bunzip2
	ln -sf bzip2 $(IDIR_BZIP2)/usr/bin/bzcat
	$(RSTRIP) $(IDIR_BZIP2)
	$(IPKG_BUILD) $(IDIR_BZIP2) $(PACKAGE_DIR)

$(IPKG_BZIP2RECOVER):
	install -m0755 -d $(IDIR_BZIP2RECOVER)/usr/bin
	install -m0755  $(PKG_BUILD_DIR)/bzip2recover $(IDIR_BZIP2RECOVER)/usr/bin/
	$(RSTRIP) $(IDIR_BZIP2RECOVER)
	$(IPKG_BUILD) $(IDIR_BZIP2RECOVER) $(PACKAGE_DIR)

install-dev: $(STAGING_DIR)/usr/lib/libbz2.so

uninstall-dev:
	rm -rf	\
		$(STAGING_DIR)/usr/include/bzlib.h \
		$(STAGING_DIR)/usr/lib/libbz2.{a,so*}

compile: install-dev
clean: uninstall-dev
