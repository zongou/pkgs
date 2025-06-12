# proot

<!-- zig objcopy currently is not compatible to strip -->

| key             | value                                                         |
| --------------- | ------------------------------------------------------------- |
| PKG_HOMEPAGE    | <https://proot-me.github.io/>                                 |
| PKG_DESCRIPTION | Emulate chroot, bind mount and binfmt_misc for non-root users |
| PKG_LICENSE     | GPL-2.0                                                       |
| PKG_VERSION     | 5.1.107                                                       |
| PKG_SRCURL      | <https://github.com/termux/proot/archive/master.tar.gz>       |
| PKG_BASENAME    | proot-master                                                  |
| PKG_DEPENDS     | libtalloc                                                     |

<!-- # Just bump commit and version when needed: -->

<!-- # PKG_EXTRA_MAKE_ARGS="-C src" -->

## Configure

```sh
patch -up1 <"${PKG_CONFIG_DIR}/base.patch"
patch -up1 <"${PKG_CONFIG_DIR}/proot-try-TMPDIR.patch"
```

## Build

- [x] static
- [x] stripped
- [ ] unbundled

```sh
## Add to toolchain search dirs
export CFLAGS="-I${OUTPUT_DIR}/include"
export LDFLAGS="-L${OUTPUT_DIR}/lib"

## Make small size stripped
if test ${stripped+1} && test ${stripped} = "1"; then
    export CFLAGS="${CFLAGS} -Os -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables"
    export LDFLAGS="${LDFLAGS} -ffunction-sections -fdata-sections -Wl,--gc-sections -s"
fi

## Make static linked
if test ${static+1} && test ${static} = "1"; then
    export LDFLAGS="${LDFLAGS} -static"
fi

## Make loader unbundled
if test ${unbundled+1} && test ${unbundled} = "1"; then
    export PROOT_UNBUNDLE_LOADER='../libexec/proot'
fi

make -C src distclean || true
make -C src V=1 "PREFIX=${OUTPUT_DIR}" ${STRIP+STRIP="${STRIP}"} -j"${JOBS}" install

```
