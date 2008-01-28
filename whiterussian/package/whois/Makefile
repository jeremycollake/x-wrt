# $Id: Makefile 1004 2005-05-21 02:15:53Z nico $

include $(TOPDIR)/rules.mk

PKG_NAME:=whois
PKG_VERSION:=4.7.24
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/w/whois
PKG_MD5SUM:=479ebc79d1e8189e16ab51b4d8981529
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,WHOIS,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -DDISABLE_NLS -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib"
		prefix=/usr \
		OPTS="" \
	touch $@

$(IPKG_WHOIS):
	install -d -m0755 $(IDIR_WHOIS)/usr/bin
	install -m0755 $(PKG_BUILD_DIR)/whois $(IDIR_WHOIS)/usr/bin/
	$(RSTRIP) $(IDIR_WHOIS)
	$(IPKG_BUILD) $(IDIR_WHOIS) $(PACKAGE_DIR)
