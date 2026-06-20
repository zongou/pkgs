PKG_HOMEPAGE=https://busybox.net/
PKG_DESCRIPTION="Tiny versions of many common UNIX utilities into a single small executable"
PKG_LICENSE="GPL-2.0"

PKG_VERSION=1.38.0
PKG_BASENAME=busybox-${PKG_VERSION}
PKG_EXTNAME=.tar.bz2
PKG_SRCURL=https://busybox.net/downloads/${PKG_BASENAME}${PKG_EXTNAME}

configure() {
	# cp "${PKG_CONFIG_DIR}/minimal.config" .config
	cp "${PKG_CONFIG_DIR}/optmized.config" .config

	patch -up1 <"${PKG_CONFIG_DIR}/0000-use-clang.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0001-clang-fix.patch"
	# patch -up1 <"${PKG_CONFIG_DIR}/0002-hardcoded-paths-fix.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0003-strchrnul-fix.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0004-no-change-identity.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0005-miscutils-crond.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0006-miscutils-crontab.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0007-networking-ftpd-no-chroot.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0008-networking-httpd-default-port.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0009-networking-tftp-no-chroot.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0010-util-linux-mount-no-addmntent.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0011-busybox-1.36.1-kernel-6.8.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0012-fix-segfault.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0013-fix-ipv6.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0014-fix-ipv6-2.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0015-selinux.patch"
	patch -up1 <"${PKG_CONFIG_DIR}/0016-explicit_bzero.patch"
}

build() {
	make ${HOSTCC+HOSTCC="${HOSTCC}"} ${CC+CC="${CC}"} ${AR+AR="${AR}"} ${STRIP+STRIP="${STRIP}"} -j"${JOBS}" busybox_unstripped
	${OBJCOPY} --strip-all busybox_unstripped busybox && chmod +x busybox
	install -Dt "${OUTPUT_DIR}/bin" busybox
}
