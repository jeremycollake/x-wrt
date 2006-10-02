include $(TOPDIR)/rules.mk

KDIR:=$(BUILD_DIR)/linux-$(KERNEL)-$(BOARD)

ifeq ($(BR2_TARGET_ROOTFS_JFFS2),y)
include ./jffs2.mk
endif

ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS_LZMA),y)
include ./squashfs.mk
endif

prepare:
compile:
install:
	$(MAKE) -C $(BOARD) prepare
	$(MAKE) -C $(BOARD) compile

install-ib:
	-$(MAKE) -C $(BOARD) IB_DIR="$(IB_DIR)" install-ib
	mkdir -p $(IB_DIR)/build_$(ARCH)/linux-$(KERNEL)-$(BOARD)
	cp $(BUILD_DIR)/linux-$(KERNEL)-$(BOARD)/kernel[-_]*.ipk $(IB_DIR)/build_$(ARCH)/linux-$(KERNEL)-$(BOARD)/	
ifeq ($(BR2_TARGET_TAR_FS),y)
        tar -cf $(IB_DIR)/root/rom/local.tar --owner=root --group=root -C $(IB_DIR)/root etc
        mkdir -p $(IB_DIR)/root/tmp/local/etc
        chmod 0755 $(IB_DIR)/root/tmp/local
        chmod 0755 $(IB_DIR)/root/tmp/local/etc
        mv $(IB_DIR)/root/etc/preinit $(IB_DIR)/root/tmp/local/etc/preinit
        rm -fr $(IB_DIR)/root/etc
        ln -s /tmp/local/etc $(IB_DIR)/root/etc
        ln -s /tmp/local $(IB_DIR)/root/usr/local
endif

install-prepare:
	find $(KDIR)/root -type f -not -perm +0100 | xargs chmod 0644
	find $(KDIR)/root -type f -perm +0100 | xargs chmod 0755
	find $(KDIR)/root -type d | xargs chmod 0755
	chmod 0777 $(KDIR)/root/tmp

rebuild: clean prepare compile install
clean:

