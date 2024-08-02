## zig objcopy currently is not compatible to strip

PKG_HOMEPAGE=https://proot-me.github.io/
PKG_DESCRIPTION="Emulate chroot, bind mount and binfmt_misc for non-root users"
PKG_LICENSE="GPL-2.0"

# Just bump commit and version when needed:

PKG_VERSION=5.1.107
PKG_BASENAME=proot-master
PKG_EXTNAME=.tar.gz
PKG_SRCURL=https://github.com/termux/proot/archive/master${PKG_EXTNAME}
# PKG_EXTRA_MAKE_ARGS="-C src"
PKG_DEPENDS="libtalloc"

configure() {
  patch -up1 < "${PKG_CONFIG_DIR}/base.patch"
  patch -up1 < "${PKG_CONFIG_DIR}/proot-try-TMPDIR.patch"
}

build() {
  ## Add to toolchain search dirs
  export CFLAGS="-I${OUTPUT_DIR}/include"
  export LDFLAGS="-L${OUTPUT_DIR}/lib"
  export CPPFLAGS="${CPPFLAGS+${CPPFLAGS}} -DARG_MAX=131072"

  ## Make small size stripped
  if test ${PROOT_BUILD_STRIP+1} && test ${PROOT_BUILD_STRIP} = "1"; then
    export CFLAGS="${CFLAGS} -Os -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables"
    export LDFLAGS="${LDFLAGS} -ffunction-sections -fdata-sections -Wl,--gc-sections -s"
  fi

  ## Make static linked
  if test ${PROOT_BUILD_STATIC+1} && test ${PROOT_BUILD_STATIC} = "1"; then
    export LDFLAGS="${LDFLAGS} -static"
  fi

  ## Make loader unbundled
  if test ${PROOT_BUILD_UNBUNDLE+1} && test ${PROOT_BUILD_UNBUNDLE} = "1"; then
    export PROOT_UNBUNDLE_LOADER='../libexec/proot'
  fi

  make -C src distclean || true
  make -C src V=1 "PREFIX=${OUTPUT_DIR}" ${STRIP+STRIP="${STRIP}"} -j"${JOBS}" install
}
