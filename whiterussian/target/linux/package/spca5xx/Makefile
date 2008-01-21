include $(TOPDIR)/rules.mk
include ../../rules.mk

PKG_NAME := kmod-usb-spca5xx
PKG_VERSION := 00.60.00.1
PKG_RELEASE := 1

PKG_SOURCE_URL := http://mxhaard.free.fr/spca50x/Download \
		http://mxhaard.free.fr/spca50x/Download/oldrelease
PKG_DIR_NAME := spca5xx-v4l1goodbye
PKG_SOURCE := $(PKG_DIR_NAME).tar.gz
PKG_MD5SUM := 63bbe5d5c833f9b6b266fb58c54bf25e
PKG_CAT := zcat

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_DIR_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,KMOD_USB_SPCA5XX,$(PKG_NAME),$(LINUX_VERSION)-$(BOARD)-$(PKG_RELEASE),$(ARCH),kernel ($(LINUX_VERSION)-$(BOARD)-$(KERNEL_RELEASE))))

$(PKG_BUILD_DIR)/.configured:
	cp -fpR ./src/* $(PKG_BUILD_DIR)/
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C "$(KERNEL_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		PATH="$(TARGET_PATH)" \
		SUBDIRS="$(PKG_BUILD_DIR)/drivers/usb" \
		modules
	touch $@

$(IPKG_KMOD_USB_SPCA5XX):
	install -m0755 -d $(IDIR_KMOD_USB_SPCA5XX)/etc/modules.d
	install -m0644 ./files/modules $(IDIR_KMOD_USB_SPCA5XX)/etc/modules.d/90-spca5xx
	install -m0755 -d $(IDIR_KMOD_USB_SPCA5XX)/lib/modules/$(LINUX_VERSION)
	cp -fpR $(PKG_BUILD_DIR)/drivers/spca5xx.o \
		$(IDIR_KMOD_USB_SPCA5XX)/lib/modules/$(LINUX_VERSION)
	$(IPKG_BUILD) $(IDIR_KMOD_USB_SPCA5XX) $(PACKAGE_DIR)
