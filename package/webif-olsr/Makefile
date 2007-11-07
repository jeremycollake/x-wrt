# 
# Copyright (C) 2006 Michele Favara Pedarsi <mik.fp@commentaria.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=webif-olsr
PKG_VERSION:=0.1
PKG_RELEASE:=beta

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=http://
# PKG_MD5SUM:=90b2b2bef15e307b42a04702385be25d
# PKG_CAT:=zcat
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

define Package/webif-olsr
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+webif +webif-mesh +ip +olsrd +olsrd-mod-dyn-gw +olsrd-mod-httpinfo +olsrd-mod-nameservice +olsrd-mod-secure +olsrd-mod-tas
  TITLE:=XWrt olsr mesh plugin
endef

define Build/Compile
endef


define Package/webif-olsr/install
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/*
	# TODO: install /etc/config/mesh
	# TODO: install /etc/config/olsr
	# TODO: install /etc/firewall.mesh
	# TODO: remove default /etc/init.d/olsrd
	# TODO: install /etc/init.d/olsrd
	# TODO: remove default /etc/olsrd.conf
	# TODO: ln -s /var/olsrd.conf /etc/olsrd.conf
	# TODO: add line "addn-hosts=/var/hosts.olsr" to /etc/dnsmasq.conf
	# TODO: install /usr/sbin/olsr.clearroutes
	# TODO: install /usr/sbin/olsr.minutely
endef

$(eval $(call BuildPackage,webif-olsr))
