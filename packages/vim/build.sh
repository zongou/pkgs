PKG_HOMEPAGE=https://www.vim.org
PKG_DESCRIPTION="Vi IMproved - enhanced vi editor"
PKG_LICENSE="VIM License"
PKG_MAINTAINER="@termux"
PKG_DEPENDS="libiconv, ncurses, vim-runtime"
PKG_RECOMMENDS="diffutils"
# vim should only be updated every 50 releases on multiples of 50.
# Update all of vim, vim-python and vim-gtk to the same version in one PR.

# PKG_VERSION=9.1.0200
PKG_VERSION=9.1.0411
PKG_BASENAME=vim-${PKG_VERSION}
PKG_EXTNAME=.tar.gz
# https://github.com/vim/vim/releases/tag/v9.1.0411
PKG_SRCURL="https://github.com/vim/vim/archive/v${PKG_VERSION}.tar.gz"
PKG_SHA256=cc991d7f6d147a8552ce80ca45e8a2335228096fe1578461149e67dbc97ed35e
PKG_AUTO_UPDATE=false
PKG_EXTRA_CONFIGURE_ARGS="
vim_cv_getcwd_broken=no
vim_cv_memmove_handles_overlap=yes
vim_cv_stat_ignores_slash=no
vim_cv_terminfo=yes
vim_cv_tgetent=zero
vim_cv_toupper_broken=no
vim_cv_tty_group=world
--enable-gui=no
--enable-multibyte
--enable-netbeans=no
--with-features=huge
--without-x
--with-tlib=ncursesw
"
PKG_BUILD_IN_SRC=true
PKG_RM_AFTER_INSTALL="
bin/rview
bin/rvim
bin/ex
share/man/man1/evim.1
share/icons
share/vim/vim91/spell/en.ascii*
share/vim/vim91/print
share/vim/vim91/tools
"
PKG_CONFFILES="share/vim/vimrc"

PKG_CONFLICTS="vim-python"

# step_pre_configure() {
# 	# Certain packages are not safe to build on device because their
# 	# build.sh script deletes specific files in $PREFIX.
# 	if $ON_DEVICE_BUILD; then
# 		error_exit "Package '$PKG_NAME' is not safe for on-device builds."
# 	fi

# 	# Version guard
# 	local ver_v=$(. $SCRIPTDIR/packages/vim/build.sh; echo ${PKG_VERSION#*:})
# 	local ver_p=$(. $SCRIPTDIR/packages/vim-python/build.sh; echo ${PKG_VERSION#*:})
# 	local ver_g=$(. $SCRIPTDIR/x11-packages/vim-gtk/build.sh; echo ${PKG_VERSION#*:})
# 	if [ "${ver_v}" != "${ver_p}" ] || [ "${ver_p}" != "${ver_g}" ]; then
# 		error_exit "Version mismatch between vim, vim-python and vim-gtk."
# 	fi

# 	make distclean

# 	# Remove eventually existing symlinks from previous builds so that they get re-created
# 	for b in rview rvim ex view vimdiff; do rm -f $PREFIX/bin/$b; done
# 	rm -f $PREFIX/share/man/man1/view.1
# }

# step_post_make_install() {
# 	sed -e "s%\@PREFIX\@%${PREFIX}%g" $PKG_BUILDER_DIR/vimrc \
# 		> $PREFIX/share/vim/vimrc

# 	# Remove most tutor files:
# 	cp $PREFIX/share/vim/vim91/tutor/{tutor,tutor.vim,tutor.utf-8} $PKG_TMPDIR/
# 	rm -f $PREFIX/share/vim/vim91/tutor/*
# 	cp $PKG_TMPDIR/{tutor,tutor.vim,tutor.utf-8} $PREFIX/share/vim/vim91/tutor/
# }

# step_create_debscripts() {
# 	cat <<- EOF > ./postinst
# 	#!$PREFIX/bin/sh
# 	if [ "$PACKAGE_FORMAT" = "pacman" ] || [ "\$1" = "configure" ] || [ "\$1" = "abort-upgrade" ]; then
# 		if [ -x "$PREFIX/bin/update-alternatives" ]; then
# 			update-alternatives --install \
# 				$PREFIX/bin/editor editor $PREFIX/bin/vim 50
# 			update-alternatives --install \
# 				$PREFIX/bin/vi vi $PREFIX/bin/vim 20
# 		fi
# 	fi
# 	EOF

# 	cat <<- EOF > ./prerm
# 	#!$PREFIX/bin/sh
# 	if [ "$PACKAGE_FORMAT" = "pacman" ] || [ "\$1" != "upgrade" ]; then
# 		if [ -x "$PREFIX/bin/update-alternatives" ]; then
# 			update-alternatives --remove editor $PREFIX/bin/vim
# 			update-alternatives --remove vi $PREFIX/bin/vim
# 		fi
# 	fi
# 	EOF
# }

depends() {
	echo "ncurses"
}

configure() {
	ls
	# ./configure CFLAGS="$CFLAGS -I$prefix/include" LDFLAGS="$LDFLAGS -L$prefix/lib" \
	# --host=$target_host --target="${TARGET}" \

	export GCC="${CC}"
	export GXX="${CXX}"

	./configure CFLAGS="${CFLAGS+${CFLAGS}} -I${OUTPUT_DIR}/include" LDFLAGS="${LDFLAGS+${LDFLAGS}} -L${OUTPUT_DIR}/lib" \
		--host="${TARGET}" --prefix="${OUTPUT_DIR}" \
		--disable-nls \
		--with-tlib=ncursesw \
		--without-x \
		--with-compiledby=Zackptg5 \
		--enable-gui=no \
		--enable-multibyte \
		--enable-terminal \
		remove_size \
		ac_cv_sizeof_int=4 \
		vim_cv_getcwd_broken=no \
		vim_cv_memmove_handles_overlap=yes \
		vim_cv_stat_ignores_slash=yes \
		vim_cv_tgetent=zero \
		vim_cv_terminfo=yes \
		vim_cv_toupper_broken=no \
		vim_cv_tty_group=world

	make -j"${JOBS}" install
	file src/vim
}
