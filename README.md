# ESP toolchains

Convenience script for building both esp8266 and esp32 toolchains:

```
make esp8266
make esp32
```

Uses [pfalcon's esp-open-sdk](https://github.com/pfalcon/esp-open-sdk) for
the esp8266 toolchain (in toolchain-only mode), and the [official Espressif
repo](https://github.com/espressif/crosstool-NG) for the esp32 toolchain.

Based on the [nodemcu-prebuilt-toolchains](https://github.com/jmattsson/nodemcu-prebuilt-toolchains) script.

---

# 2023-12-06

The pfalcon [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk) repository hasn't been updated since 27th Nov., 2018 (commit c70543e). There are numerous forks. The changes here allow building this legacy snapshot on contemporary Ubuntu (tested on Ubuntu 23.10, aarch64).

Two patches against [crosstool-NG](https://github.com/jcmvbkbc/crosstool-NG/tree/37b07f6fbea2e5d23434f7e91614528f839db056) are included here:
1. __*esp8266-companion_libs.patch*__: updates urls for downloading the isl (integer set library) and expat libraries. See https://github.com/pfalcon/esp-open-sdk/issues/386.
2. __*esp8266-config-overrides.patch*__: sets crosstool-NG configuration options to address two issues when building on Ubuntu 23.10 (aarch64) and presumably newer build environments:
   * Building gcc 4.8.5 requires C++ 2003 (see https://gcc.gnu.org/gcc-4.8/changes.html).   Building the cross compiler fails for build toolchains assuming a more recent dialect (e.g., C++ 2017). This patch sets CT_EXTRA_CFLAGS_FOR_HOST to force the dialect to C++ 2003. 
   * Building gdb-cross requires Python and the distutils package which was deprecated in Python 3.12. Rather than downgrade the build system Python installation, this patch sets CT_GDB_CROSS_PYTHON to disable Python when building gdb_cross.

As of c70543e pfalcon's [esp-open-sdk] pulls in the following submodules:

| Submodule | Commit |
| --- | --- |
| crosstool-NG | 37b07f6fbea2e5d23434f7e91614528f839db056 |
| esp-open-lwip | 8c39d2179a273553466043f388772abb6251a4ca |
| esptool | 9dfcb350e1a91bb4641f725fc6c2f126791013ce |
| lx106-hal | e4bcc63c9c016e4f8848e7e8f512438ca857531d |