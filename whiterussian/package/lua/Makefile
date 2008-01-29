# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua
PKG_VERSION:=5.1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.lua.org/ftp/ \
	http://ftp.gwdg.de/pub/languages/lua/ \
	http://mirrors.dotsrc.org/lua/ \
	http://www.tecgraf.puc-rio.br/lua/ftp/
PKG_MD5SUM:=687ce4c2a1ddff18f1008490fdc4e5e0
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBLUA,liblua,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LUA_INTERPRETER,lua,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LUA_COMPILER,luac,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LUA_EXAMPLES,lua-examples,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		AR="$(TARGET_CROSS)ar rcu" \
		INSTALL_ROOT=/usr \
		MYCFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		MYLDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		PKG_VERSION=$(PKG_VERSION) \
		all linux 
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		INSTALL_TOP="$(PKG_INSTALL_DIR)/usr" \
		install
	touch $@

$(IPKG_LIBLUA):
	install -d -m0755 $(IDIR_LIBLUA)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblua.so.* $(IDIR_LIBLUA)/usr/lib/
	$(RSTRIP) $(IDIR_LIBLUA)
	$(IPKG_BUILD) $(IDIR_LIBLUA) $(PACKAGE_DIR)

$(IPKG_LUA_INTERPRETER):
	install -d -m0755 $(IDIR_LUA_INTERPRETER)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/lua $(IDIR_LUA_INTERPRETER)/usr/bin/
	$(RSTRIP) $(IDIR_LUA_INTERPRETER)
	$(IPKG_BUILD) $(IDIR_LUA_INTERPRETER) $(PACKAGE_DIR)

$(IPKG_LUA_COMPILER):
	install -d -m0755 $(IDIR_LUA_COMPILER)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/luac $(IDIR_LUA_COMPILER)/usr/bin/
	$(RSTRIP) $(IDIR_LUA_COMPILER)
	$(IPKG_BUILD) $(IDIR_LUA_COMPILER) $(PACKAGE_DIR)

$(IPKG_LUA_EXAMPLES):
	install -d -m0755 $(IDIR_LUA_EXAMPLES)/usr/share/lua/examples
	install -m0644 $(PKG_BUILD_DIR)/test/*.lua \
		$(IDIR_LUA_EXAMPLES)/usr/share/lua/examples/
	$(RSTRIP) $(IDIR_LUA_EXAMPLES)
	$(IPKG_BUILD) $(IDIR_LUA_EXAMPLES) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/liblua.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lua{,lib,conf}.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lauxlib.h $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblua.{a,so.*} $(STAGING_DIR)/usr/lib/
	ln -sf liblua.so.$(PKG_VERSION) $(STAGING_DIR)/usr/lib/liblua.so
	ln -sf liblua.so.$(PKG_VERSION) $(STAGING_DIR)/usr/lib/liblualib.so
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/liblua.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/include/lua{,lib,conf}.h \
		$(STAGING_DIR)/usr/include/lauxlib.h \
		$(STAGING_DIR)/usr/lib/liblua{,lib}.{a,so*} \

compile: install-dev
clean: uninstall-dev
