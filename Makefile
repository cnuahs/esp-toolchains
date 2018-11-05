# Based off the nodemcu-prebuilt-toolchains repo, but intended for packaging
# up the toolchains rather than checking them into the repo itself.
default: esp8266 esp32

TOPDIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DATE:=$(shell date +%Y%m%d)
RELVER?=0
VER:=$(DATE).$(RELVER)

Q?=@

.PHONY: esp32 esp8266
esp32: build/toolchain-esp32-$(VER).tar.xz
esp8266: build/toolchain-esp8266-$(VER).tar.xz

build/lx106/Makefile:
	$Qcd build && git clone --recursive https://github.com/pfalcon/esp-open-sdk.git lx106

esp8266/bin/xtensa-lx106-elf-gcc: build/lx106/Makefile
	$Qecho CT_STATIC_TOOLCHAIN=y >> $(dir $<)/crosstool-config-overrides
	$Qcd "$(dir $<)" && $(MAKE) STANDALONE=n TOOLCHAIN="$(TOPDIR)/esp8266" toolchain libhal

build/toolchain-esp8266-$(VER).tar.xz: esp8266/bin/xtensa-lx106-elf-gcc
	@echo 'Packaging toolchain ($@)...'
	$Qtar cJf $@ esp8266/
	$Qtouch $@
	@echo [32m[DONE] $@[0m


build/esp32/bootstrap:
	$Qcd build && git clone -b xtensa-1.22.x https://github.com/espressif/crosstool-NG.git esp32
	@touch $@

build/esp32/Makefile: build/esp32/bootstrap
	$Qcd "$(dir $@)" && ./bootstrap && ./configure --prefix="`pwd`"

build/esp32/ct-ng: build/esp32/Makefile
	$Qcd "$(dir $@)" && $(MAKE) MAKELEVEL=0 && $(MAKE) MAKELEVEL=0 install

build/esp32/.config: build/esp32/ct-ng
	$Qcd "$(dir $@)" && ./ct-ng xtensa-esp32-elf
	$Qsed -i 's,^CT_PREFIX_DIR=.*$$,CT_PREFIX_DIR="$${CT_TOP_DIR}/../../esp32",' $@
	$Qecho CT_STATIC_TOOLCHAIN=y >> $@

esp32/bin/xtensa-esp32-elf-gcc: build/esp32/.config
	$Qcd "$(dir $<)" && ./ct-ng build

build/toolchain-esp32-$(VER).tar.xz: esp32/bin/xtensa-esp32-elf-gcc
	@echo 'Packaging toolchain ($@)...'
	$Qtar cJf $@ esp32/
	$Qtouch $@
	@echo [32m[DONE] $@[0m


.PHONY:clean
clean:
	-rm -rf build/esp32 build/lx106 build/toolchain-*.tar.xz

.SUFFIXES:
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%
