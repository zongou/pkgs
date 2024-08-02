PKG_HOMEPAGE=https://www.nano-editor.org/
PKG_DESCRIPTION="Small, free and friendly text editor"
PKG_LICENSE="GPL-3.0"
PKG_VERSION=8.0
PKG_SRCURL=https://nano-editor.org/dist/latest/nano-$PKG_VERSION.tar.xz
PKG_BASENAME=nano-$PKG_VERSION

build() {
	# pwd.h: struct passwd* getpwent(void) __INTRODUCED_IN(26);
	if [ "$ANDROID_API" -lt 26 ]; then
		export ac_cv_header_pwd_h=no
	fi

	# glob.h: void globfree(glob_t* __result_ptr) __INTRODUCED_IN(28);
	if [ "$ANDROID_API" -lt 28 ]; then
		export ac_cv_header_glob_h=no
	fi

	# ./configure --host="${TARGET}" --prefix="${OUTPUT_DIR}" --disable-libmagic --enable-utf8 --with-wordbounds
	./configure \
		--enable-utf8 \
		--enable-color \
		--enable-extra \
		--enable-nanorc \
		--enable-multibuffer \
		--host="${TARGET}"

	make -j "${JOBS}"
}
