# busybox

| key             | value                                                                      |
| --------------- | -------------------------------------------------------------------------- |
| PKG_HOMEPAGE    | <https://busybox.net/>                                                     |
| PKG_DESCRIPTION | Tiny versions of many common UNIX utilities into a single small executable |
| PKG_LICENSE     | GPL-2.0                                                                    |
| PKG_VERSION     | 1.37.0                                                                     |
| PKG_BASENAME    | busybox-1.37.0                                                             |
| PKG_EXTNAME     | .tar.bz2                                                                   |
| PKG_SRCURL      | <https://busybox.net/downloads/busybox-1.37.0.tar.bz2>                     |

## Configure

```sh
cp "${PKG_CONFIG_DIR}/optmized.config" .config

## shell: fix SIGWINCH and SIGCHLD (in hush) interrupting line input, fixed in v1.37
## https://github.com/mirror/busybox/commit/93e0898c663a533082b5f3c2e7dcce93ec47076d
# patch -up1 <"${PKG_CONFIG_DIR}/fix_line_interrupting.patch"

patch -up1 <"${PKG_CONFIG_DIR}/0000-use-clang.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0001-clang-fix.patch"
# patch -up1 <"${PKG_CONFIG_DIR}/0002-hardcoded-paths-fix.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0003-strchrnul-fix.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0005-no-change-identity.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0006-miscutils-crond.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0007-miscutils-crontab.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0008-networking-ftpd-no-chroot.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0009-networking-httpd-default-port.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0011-networking-tftp-no-chroot.patch"
patch -up1 <"${PKG_CONFIG_DIR}/0012-util-linux-mount-no-addmntent.patch"
```

## Build

```sh
make ${HOSTCC+HOSTCC="${HOSTCC}"} ${CC+CC="${CC}"} ${AR+AR="${AR}"} ${STRIP+STRIP="${STRIP}"} -j"${JOBS}" busybox_unstripped
${OBJCOPY} --strip-all busybox_unstripped busybox && chmod +x busybox
install -Dt "${OUTPUT_DIR}/bin" busybox
```
