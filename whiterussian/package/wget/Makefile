# $Id: Makefile 1004 2005-05-21 02:15:53Z nico $

include $(TOPDIR)/rules.mk

PKG_NAME:=wget
PKG_VERSION:=1.10.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_MD5SUM:=795fefbb7099f93e2d346b026785c4b8
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

WGET_CONFIGURE_OPTS := 		  --with-ssl \
		  --with-libssl-prefix="$(STAGING_DIR)/usr"

WGET_NOSSL_CONFIGURE_OPTS := 		  --without-ssl

define PKG_build

ifneq ($(BR2_PACKAGE_$(1)),)
BUILD_TARGETS += $(PKG_BUILD_DIR)/$(2)
endif

$(PKG_BUILD_DIR)/$(2): $(PKG_BUILD_DIR)/.prepared
	mkdir -p $(PKG_BUILD_DIR)/$(2)
	(cd $(PKG_BUILD_DIR)/$(2); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -D__UCLIBC__" \
		../configure \
		  --target=$(GNU_TARGET_NAME) \
		  --host=$(GNU_TARGET_NAME) \
		  --build=$(GNU_HOST_NAME) \
		  --program-prefix="" \
		  --program-suffix="" \
		  --prefix=/usr \
		  --exec-prefix=/usr \
		  --bindir=/usr/bin \
		  --datadir=/usr/share \
		  --includedir=/usr/include \
		  --infodir=/usr/share/info \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/etc \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --enable-shared \
		  --disable-static \
		  --disable-rpath \
		  $$($(1)_CONFIGURE_OPTS) \
	);
	$(MAKE) -C $(PKG_BUILD_DIR)/$(2) \
		DESTDIR="$(PKG_INSTALL_DIR)/$(1)" \
		all install

$$(IPKG_$(1)): $(PKG_BUILD_DIR)/.installed $(PKG_BUILD_DIR)/$(2)
	install -d -m0755 $$(IDIR_$(1))/etc
	install -m0644 $(PKG_INSTALL_DIR)/$(1)/etc/wgetrc $$(IDIR_$(1))/etc
	install -d -m0755 $$(IDIR_$(1))/usr/bin
	install -m0755 $(PKG_INSTALL_DIR)/$(1)/usr/bin/wget $$(IDIR_$(1))/usr/bin/wget.real
	ln -sf wget.real $$(IDIR_$(1))/usr/bin/wget
	$(RSTRIP) $$(IDIR_$(1))
	$(IPKG_BUILD) $$(IDIR_$(1)) $(PACKAGE_DIR)

endef

$(eval $(call PKG_template,WGET,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,WGET_NOSSL,$(PKG_NAME)-nossl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(eval $(call PKG_build,WGET,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_build,WGET_NOSSL,$(PKG_NAME)-nossl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built: $(BUILD_TARGETS)
	touch $@

$(PKG_BUILD_DIR)/.installed: $(PKG_BUILD_DIR)/.built
	touch $@

