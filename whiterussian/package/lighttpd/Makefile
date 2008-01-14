# 
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2008 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lighttpd
PKG_VERSION:=1.4.18
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.lighttpd.net/download/
PKG_MD5SUM:=26f98dddf9d8c0775221b800986003ee
PKG_CAT:=bzcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

define PKG_mod_template

$$(IPKG_$(1)):
	install -d -m0755 $$(IDIR_$(1))/usr/lib/lighttpd
	install -m0755 $(PKG_INSTALL_DIR)/usr/lib/lighttpd/mod_$(2).so $$(IDIR_$(1))/usr/lib/lighttpd/
	$(RSTRIP) $$(IDIR_$(1))
	$(IPKG_BUILD) $$(IDIR_$(1)) $(PACKAGE_DIR)

endef

$(eval $(call PKG_template,LIGHTTPD,lighttpd,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_ACCESS,lighttpd-mod-access,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_ACCESSLOG,lighttpd-mod-accesslog,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_ALIAS,lighttpd-mod-alias,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_AUTH,lighttpd-mod-auth,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_CGI,lighttpd-mod-cgi,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_COMPRESS,lighttpd-mod-compress,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_EVASIVE,lighttpd-mod-evasive,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_EVHOST,lighttpd-mod-evhost,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_EXPIRE,lighttpd-mod-expire,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_EXTFORWARD,lighttpd-mod-extforward,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_FASTCGI,lighttpd-mod-fastcgi,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_FLV_STREAMING,lighttpd-mod-flv-streaming,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_PROXY,lighttpd-mod-proxy,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_REDIRECT,lighttpd-mod-redirect,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_REWRITE,lighttpd-mod-rewrite,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_RRDTOOL,lighttpd-mod-rrdtool,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_SCGI,lighttpd-mod-scgi,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_SECDOWNLOAD,lighttpd-mod-secdownload,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_SETENV,lighttpd-mod-setenv,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_SIMPLE_VHOST,lighttpd-mod-simple-vhost,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_SSI,lighttpd-mod-ssi,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_STATUS,lighttpd-mod-status,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_TRIGGER_B4_DL,lighttpd-mod-trigger-b4-dl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_USERDIR,lighttpd-mod-userdir,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_USERTRACK,lighttpd-mod-usertrack,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIGHTTPD_MOD_WEBDAV,lighttpd-mod-webdav,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(eval $(call PKG_mod_template,LIGHTTPD_MOD_ACCESS,access))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_ACCESSLOG,accesslog))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_ALIAS,alias))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_AUTH,auth))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_CGI,cgi))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_COMPRESS,compress))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_EVASIVE,evasive))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_EVHOST,evhost))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_EXPIRE,expire))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_EXTFORWARD,extforward))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_FASTCGI,fastcgi))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_FLV_STREAMING,flv_streaming))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_PROXY,proxy))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_REDIRECT,redirect))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_REWRITE,rewrite))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_RRDTOOL,rrdtool))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_SCGI,scgi))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_SECDOWNLOAD,secdownload))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_SETENV,setenv))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_SIMPLE_VHOST,simple_vhost))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_SSI,ssi))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_STATUS,status))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_TRIGGER_B4_DL,trigger_b4_dl))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_USERDIR,userdir))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_USERTRACK,usertrack))
$(eval $(call PKG_mod_template,LIGHTTPD_MOD_WEBDAV,webdav))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig" \
		./configure \
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
		  --libdir=/usr/lib/lighttpd \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/etc/lighttpd \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --disable-rpath \
		  --enable-shared \
		  --enable-static \
		  --without-attr \
		  --without-bzip2 \
		  --without-fam \
		  --with-gdbm \
		  --without-ldap \
		  --without-lua \
		  --without-memcache \
		  --without-mysql \
		  --without-valgrind \
		  --with-pcre \
		  --with-openssl="$(STAGING_DIR)/usr" \
		  --with-webdav-props \
	)
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

DEFAULT_MODULES:=dirlisting indexfile staticfile

$(IPKG_LIGHTTPD):
	install -m0755 -d $(IDIR_LIGHTTPD)/etc/lighttpd
	install -m0644 ./files/lighttpd.conf $(IDIR_LIGHTTPD)/etc/lighttpd/
	install -m0755 -d $(IDIR_LIGHTTPD)/etc/default
	install -m0644 ./files/lighttpd.default $(IDIR_LIGHTTPD)/etc/default/lighttpd
	install -m0755 -d $(IDIR_LIGHTTPD)/etc/init.d
	install -m0755 ./files/lighttpd.init $(IDIR_LIGHTTPD)/etc/init.d/lighttpd
	install -m0755 -d $(IDIR_LIGHTTPD)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/lighttpd $(IDIR_LIGHTTPD)/usr/sbin/
	install -d -m0755 $(IDIR_LIGHTTPD)/usr/lib/lighttpd
	for defmod in $(DEFAULT_MODULES); do \
		install -m0755 $(PKG_INSTALL_DIR)/usr/lib/lighttpd/mod_$${defmod}.so $(IDIR_LIGHTTPD)/usr/lib/lighttpd ; \
	done
	$(RSTRIP) $(IDIR_LIGHTTPD)
	$(IPKG_BUILD) $(IDIR_LIGHTTPD) $(PACKAGE_DIR)
