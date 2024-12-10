# SPDX-FileCopyrightText: 2024 M5Stack Technology CO LTD
#
# SPDX-License-Identifier: MIT

PATCH_DIR := patches
SRC_DIR := build/u-boot-2020.04
PATCHES := $(wildcard patches/*.patch)
DTSS := $(wildcard uboot-dts/*.dts*)
CONFIG_FILES := $(wildcard *.config)

# AX630C_KERNEL_PARAM := ARCH=arm CROSS_COMPILE=aarch64-none-linux-gnu- 
# KERNEL_MAKE := cd $(SRC_DIR) ; $(MAKE) $(AX630C_KERNEL_PARAM)

KERNEL_MAKE := cd $(SRC_DIR) ; $(MAKE) 
%:
	@if [ "$(MAKECMDGOALS)" != "build_init" ] ; then \
		$(MAKE) build_init ; \
		$(KERNEL_MAKE) dtb-y=m5stack-ax630c-module-llm.dtb EXTRA_CFLAGS=-DUBOOT_IMG_HEADER_BASE=0x5C000000 DEVICE_TREE=m5stack-ax630c-module-llm  $(MAKECMDGOALS) ; \
		if [ -f "u-boot" ] ; then cp u-boot* ../.. ; fi ; \
	fi

build_init:Configuring

Extracting:
	$(MAKE) build/check_build.tmp
	$(MAKE) build/check_dts.tmp

Patching:Extracting 
	$(MAKE) build/check_patch.tmp

Configuring:Patching 
	$(MAKE) build/check_config.tmp  

build/check_build.tmp:$(PATCHES)
	[ -d 'build' ] || mkdir build
	@if [ -f '.stamp_extracted' ] ; then \
		[ -f '../../../dl/u-boot-2020.04.tar.bz2' ] || wget --passive-ftp -nd -t 3 -O '../../../dl/u-boot-2020.04.tar.bz2' 'https://ftp.denx.de/pub/u-boot/u-boot-2020.04.tar.bz2' ; \
		[ -d 'build/u-boot-2020.04' ] || tar xjf ../../../dl/u-boot-2020.04.tar.bz2 -C build/ ; \
	else \
		[ -f '.u-boot-2020.04.tar.bz2' ] || wget --passive-ftp -nd -t 3 -O '.u-boot-2020.04.tar.bz2' 'https://ftp.denx.de/pub/u-boot/u-boot-2020.04.tar.bz2' ; \
		[ -d 'build/u-boot-2020.04' ] || tar xjf .u-boot-2020.04.tar.bz2 -C build/ ; \
	fi
	@touch build/check_build.tmp

build/check_dts.tmp:$(DTSS)
	cp uboot-dts/* $(SRC_DIR)/arch/arm/dts/
	touch build/check_dts.tmp

build/check_patch.tmp:$(PATCHES)
	@[ -d 'build/u-boot-2020.04/arch/arm/mach-axera' ] || {\
		for patch in $^; do \
			echo "Applying $$patch..."; \
			patch -p1 -d $(SRC_DIR) <$$patch || { echo "Failed to apply $$patch"; exit 1; } \
		done ; \
	}
	@touch build/check_patch.tmp

build/check_config.tmp:$(CONFIG_FILES)
	[ -f '$(SRC_DIR)/.config' ] || $(KERNEL_MAKE) AX630C_m5stack_LLM_module_defconfig
	[ -L '.config' ] || ln -s $(SRC_DIR)/.config .config
	touch build/check_config.tmp

distclean:
	@rm build -rf

uboot-distclean:
	@$(KERNEL_MAKE) distclean
	rm build/check_config.tmp 