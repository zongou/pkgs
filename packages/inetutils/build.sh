PKG_HOMEPAGE=https://www.gnu.org/software/
PKG_DESCRIPTION="Collection of common network programs"
PKG_LICENSE="GPL-3.0"
PKG_MAINTAINER="@termux"
PKG_VERSION="2.5"
PKG_SRCURL=https://mirrors.kernel.org/gnu-${PKG_VERSION}.tar.xz
PKG_SHA256=87697d60a31e10b5cb86a9f0651e1ec7bee98320d048c0739431aac3d5764fb6
PKG_DEPENDS="readline"
PKG_BUILD_DEPENDS="libandroid-glob"
PKG_SUGGESTS="whois"
PKG_HOSTBUILD=true
PKG_RM_AFTER_INSTALL="bin/whois share/man/man1/whois.1"
# These are old cruft / not suited for android
# (we --disable-traceroute as it requires root
# in favour of tracepath, which sets up traceroute
# as a symlink to tracepath):
PKG_EXTRA_CONFIGURE_ARGS="
--disable-ifconfig
--disable-ping
--disable-ping6
--disable-rcp
--disable-rexec
--disable-rexecd
--disable-rlogin
--disable-rsh
--disable-traceroute
--disable-uucpd
ac_cv_lib_crypt_crypt=no
gl_cv_have_weak=no
"

PKG_BASENAME=inetutils-${PKG_VERSION}

# step_host_build() {
# 	# help2man fails to get mans from our binaries
# 	# let's build binaries it can launch for generating mans

# 	cp -r "$PKG_CONFIG_DIR"/* .
# 	aclocal --force
# 	autoreconf -fi

# 	# For some reason I get undefined reference to `crypt` so I make it noop
# 	echo "__attribute__((weak)) void crypt(void) {}" | gcc -x c -c - -o crypt.o

# 	sed -i 's/PATH_LOG/"logcat"/g' ./src/logger.c
# 	LDFLAGS=" $PKG_HOSTBUILD_DIR/crypt.o" \
# 	./configure $PKG_EXTRA_CONFIGURE_ARGS
# 	make
# }

# step_pre_configure() {
# 	aclocal --force
# 	autoreconf -fi

# 	# Reuse binaries from host-build to generate mans
# 	sed -i 's,@HOSTBUILD@,'"$PKG_HOSTBUILD_DIR"',' "$PKG_CONFIG_DIR/man/Makefile.am"
# 	CFLAGS+=" -DNO_INLINE_GETPASS=1"
# 	CPPFLAGS+=" -DNO_INLINE_GETPASS=1 -DLOGIN_PROCESS=6 -DDEAD_PROCESS=8 -DLOG_NFACILITIES=24 -fcommon"
# 	LDFLAGS+=" -landroid-glob -llog"
# 	touch -d "next hour" ./man/whois.1
# }

# step_post_configure() {
# 	cp $PKG_BUILDER_DIR/malloc.h $PKG_BUILDDIR/lib/
# }

build() {
	aclocal --force
	autoreconf -fi

	# Reuse binaries from host-build to generate mans
	# sed -i 's,@HOSTBUILD@,'"$PKG_HOSTBUILD_DIR"',' "$PKG_CONFIG_DIR/man/Makefile.am"
	CFLAGS=" -DNO_INLINE_GETPASS=1"
	CPPFLAGS=" -DNO_INLINE_GETPASS=1 -DLOGIN_PROCESS=6 -DDEAD_PROCESS=8 -DLOG_NFACILITIES=24 -fcommon"
	LDFLAGS=" -landroid-glob -llog"
	touch -d "next hour" ./man/whois.1

	# help2man fails to get mans from our binaries
	# let's build binaries it can launch for generating mans

	cp -r "$PKG_CONFIG_DIR"/* .
	aclocal --force
	autoreconf -fi

	# For some reason I get undefined reference to `crypt` so I make it noop
	echo "__attribute__((weak)) void crypt(void) {}" | $CC -x c -c - -o crypt.o

	sed -i 's/PATH_LOG/"logcat"/g' ./src/logger.c
	LDFLAGS=" $(realpath crypt.o)" ./configure --host=${TARGET} --prefix=${OUTPUT_DIR} $PKG_EXTRA_CONFIGURE_ARGS

	patch -up1 <"${PKG_CONFIG_DIR}"/disable-fdsan.patch
	patch -up1 <"${PKG_CONFIG_DIR}"/ftpd.c.patch
	patch -up1 <"${PKG_CONFIG_DIR}"/if_index.c.patch
	patch -up1 <"${PKG_CONFIG_DIR}"/man-Makefile.am.patch
	# patch -up1 <"${PKG_CONFIG_DIR}"/src-logger.patch
	patch -up1 <"${PKG_CONFIG_DIR}"/telnet-sys_bsd.c.patch
	patch -up1 <"${PKG_CONFIG_DIR}"/utmp_logout.c.patch
	make telnet telnetd
}
